import math

# sage: load("rfc5091.sage")

# RFC5091 7.1
# q = 0xfffffffffffffffffffffffffffbffff
# p = 0xbffffffffffffffffffffffffffcffff3
# E/F_p: y^2 = x^3 + 1
# A = (0x489a03c58dcf7fcfc97e99ffef0bb4634, 0x510c6972d795ec0c2b081b81de767f808)
# l = 0xb8bbbc0089098f2769b32373ade8f0daf
# [l]A = (0x073734b32a882cc97956b9f7e54a2d326, 0x9c4b891aab199741a44a5b6b632b949f7)


p = 0xbffffffffffffffffffffffffffcffff3

F.<x> = GF(p)[]
K.<a> = GF(p^2, name='a', modulus=x^2 + 1)

# if x_1 = 1 + a, x_2 = 3 + 4*a
# 	x_1 * x2 == 7*a + 4083388403051261561560495289181215391730

# point at infinity
O = [0, 0]
#use sha1 encrypt by default

# Algorithm 3.1.1 (PointDouble1)
# Input:
#	point A in E(F_p^2), with A = (x, y) or 0
# Ouput:
#	point [2]A = A + A
#
def PointDouble1(A):
	x, y = A[0], A[1]

	if A == O or y == 0: return O
	lambda_1 = (3 * x^2) / (2 * y)
	x_R = lambda_1^2 - 2 * x
	y_R = (x - x_R) * lambda_1 - y

	return [x_R, y_R]


# Algorithm 3.1.2 (PointAdd1)
# Input:
#	point A in E(F_p^2), with A = (x_A, y_A) or O
#	point B in E(F_p^2), with B = (x_B, y_B) or O
# Output:
#	point A + B
#
def PointAdd1(A, B):
	x_A, y_A = A[0], A[1]
	x_B, y_B = B[0], B[1]

	if A == O: return B
	if B == O: return A
	if x_A == x_B:
		if y_A == -y_B: return O
		return PointDouble1(A)
	lambda_1 = (y_B - y_A) / (x_B - x_A)
	x_R = lambda_1^2 - x_A - x_B
	y_R = (x_A - x_R) * lambda_1 - y_A

	return [x_R, y_R]


# Algorithm 3.2.1 (SignedWindowDecomposition)
# Input:
#	integer k > 0, where k has the binary representation
#		k = {Sum(k_j * 2^j, for j = 0 to l} where
#		each k_j is either 0 or 1 and k_l = 0
#	integer window bit-size r > 0
# Output:
#	integer d
#
def SignedWindowDecomposition(k, r):
	d = 0
	mask = 1
	l = math.log(k, 2)
	ki = []
	j = l
	list = []
	while j >= 0:
		ki[j] = (k & mask) >> j
		mask = mask << 1
		j = j + 1
	while j <= l:
		if ki[j] == 0:
			j = j+1
		else:
			t = math.min(1, j+r-1)
			h_d = (k << t) >> (l - j + r)
			if h_d > 2**(r-1):
				b_d = h_d - 2**r
			else:
				b_d = h_d
			e_d = j
			d = d + 1
			j = t + 1
			list.append((b_d, e_d))

	return [d, list]


# Algorithm 3.2.2
# Input:
#  o A point A in E(F_p^2)
#  o An integer l > 0
#  o An elliptic curve E/F_p: y^2 = x^3 + a * x + b
#Output:
#  o The point [l]A
def PointMultiply(l, A):
	r = 5
	[d, bilist] = SignedWindowDecomposition(l, r)
	plist = []
	plist.append(A)
	A_2 = PointDouble1(A)
	plist.append(A_2)
	upper = math.pow(2, r-2) - 1
	for i in (0, upper):
		A_tmp = PointAdd1(plist[2*i - 1], A_2)
		plist.append(A_tmp)
	Q = plist[bilist[d-1][0]]
	n = d-2
	while n >= 0:
		times = bilist[i+1][1] - bilist[i][1]
		i = 0
		while i < times:
			Q = PointDouble1(Q)
			i += 1
		if (bilist[i][0] > 0):
			Q = PointAdd1(Q, plist[bilist[i][0]])
		else:
			Q = PointAdd1(Q, plist[-bilist[i][0]])
	times = bilist[0][1]
	i = 0
	while i < times:
		Q = PointDouble1(Q)

	return Q

def check_point_mul():
	q = 0xfffffffffffffffffffffffffffbffff
	p = 0xbffffffffffffffffffffffffffcffff3
	F = FiniteField(p)
	E = EllipticCurve(F, [0, 1])
	A = E((0x489a03c58dcf7fcfc97e99ffef0bb4634,0x510c6972d795ec0c2b081b81de767f808))
	l = 0xb8bbbc0089098f2769b32373ade8f0daf
	A = PointMultiply(l, A)
	(x, y) = A.xy()
	print x
	print y

# Algorithm 3.3.1 (ProjectivePointDouble1)
# Input:
#	point (x, y, z) = A in E(F_p^2) in Jacobian projective coordinates
# Output:
#	point [2]A in Jacobian projective coordinates
#
def ProjectivePointDouble1(A):
	x, y, z = A[0], A[1], A[2]

	if z == 0 or y == 0: return [0, 1, 0]
	lambda_1 = 3 * x^2
	z_R = 2 * y * z
	lambda_2 = y^2
	lambda_3 = 4 * lambda_2 * x
	x_R = lambda_1^2 - 2 * lambda_3
	lambda_4 = 8 * lambda_2^2
	y_R = lambda_1 * (lambda_3 - x_R) - lambda_4

	return [x_R, y_R, z_R]


# Algorithm 3.3.2
def ProjectivePointAccumulate1(A, B):
	x_A, y_A, z_A = A[0], A[1], A[2]
	x_B, y_B = B[0], B[1]
	if z_A == 0: return [x_B, y_B, 1]
	lambda_1 = z_A^2
	lambda_2 = lambda_1 * x_B
	lambda_3 = x_A - lambda_2
	if lambda_3 == 0: return [0, 1, 0]
	lambda_4 = lambda_3^2
	lambda_5 = lambda_1 * y_B * z_A
	lambda_6 = lambda_4 - lambda_5
	lambda_7 = x_A + lambda_2
	lambda_8 = y_A + lambda_5
	x_R = lambda_6^2 - lambda_7 * lambda_4
	lambda_9 = lambda_7 * lambda_4 - 2 * x_R
	y_R = (lambda_9 * lambda_6 - lambda_8 * lambda_3 * lambda_4) / 2
	z_R = lambda_3 * z_A
	return [x_R, y_R, z_R]

# Algorithm 3.4.1
#
def EvalVertical1(B, A):
	x_B = B[0]
	x_A = A[0]

	r = x_B - x_A

	return r



# Algorithm 3.4.2
# Input:
#	point B in E(F_p^2) with B != 0
#	point A in E(F_p)
# Output:
#	number in F_p^2
#
def EvalTangent1(B, A):
	x_A, y_A = A[0], A[1]
	if A == [0, 0]:
		return [1, 0]

#Algorithm 3.4.3

def EvalLine1(B, A1, A2):
	if A1 == 0:
		return EvalVertical1(B, A2)
	if A2 == 0:
		return EvalVertical1(B, A1)
	if A1 == -A2:
		return EvalVertical1(B, A1)
	if A1 == A2:
		return EvalVertical1(B, A1)
	a = A1[1] - A2[1]
	b = A2[0] - A1[0]
	c = -b * A1[1] - a * A1[0]
	r = a * B[0] + b * B[1] + c
	return r

#Algorithm 3.5.1
def Tate(A, B, s, b, c):
	return TateMillerSolinas(A, B, s, a, b, c)

#Algorithm 3.5.2
def TateMillerSolinas(A, B, s, a, b, c):
	q = 2**a + s*(2**b) + c
	v_num = 1
	v_den = 1
	V = [A[0], A[1], 1]
	t_num = 1
	t_den = 1
	for n in range(0, b-1):
		t_num = t_num * t_num
		t_den = t_den * t_den
		V1 = [V[0]/(V[2] * V[2]), V[1]/(V[2] * V[2] * V[2])]
		t_num = t_num * EvalTangent1(B, V1)
		V2 = ProjectivePointDouble1(V)
		V3 = [V2[0]/(V2[2] * V2[2]), V2[1]/(V2[2] * V2[2] * V2[2])]
		t_den = t_den * EvalVertical1(B, V3)

	V_b =  [V[0]/(V[2] * V[2]), s * V[1]/(V[2] * V[2] * V[2])]
	if(s == -1):
		v_num = v_num * t_den
		V1 = [V[0]/(V[2] * V[2]), V[1]/(V[2] * V[2] * V[2])]
		v_den = v_den * EvalVertical1(B, V1)

	if(s == 1):
		v_num = v_num * t_num
		v_den = v_den * t_den

	for n in range(b, a-1):
		t_num = t_num * t_num
		t_den = t_den * t_den
		V1 = [V[0]/(V[2] * V[2]), V[1]/(V[2] * V[2] * V[2])]
		t_num = t_num * EvalTangent1(B, V1)
		V2 = ProjectivePointDouble1(V)
		V3 = [V2[0]/(V2[2] * V2[2]), V2[1]/(V2[2] * V2[2] * V2[2])]
		t_den = t_den * EvalVertical1(B, V3)

	V_a =  [V[0]/(V[2] * V[2]), s * V[1]/(V[2] * V[2] * V[2])]
	v_num = v_num * t_num
	v_den = v_den * t_den
	v_num = v_num * EvalLine1(B, V_a, V_b)
	v_den = v_den * EvalVertical1(B, V_a + V_b)
	if(c == -1):
		v_den = v_den * EvalVertical1(B, A)

	eta = (p*p - 1) / q

	return pow(v_num / v_den, eta)

import hashlib

def digest(msg):
	msg = str(msg)
	return Integer('0x' + hashlib.sha1(msg).hexdigest())

#Algorithm 4.1.1
#Input:
#    A string s of length |s| octets
#    A positive integer n represented as Ceiling(lg(n) / 8) octets.
#    A cryptographic hash function hashfcn
#Output:
#    A positive integer v in the range 0 to n - 1

def HashToRange(s, n):
	hashlen = 20       #length of sha1 output
	h_0 = '0' * hashlen     #8-bit string
	t_1 = h_0 + s
	h_1 = hashlib.sha1(t_1).hexdigest()
	a_1 = int(h_1, 16)
	v_1 = a_1
	t_2 = h_1 + s
	h_2 = hashlib.sha1(t_2).hexdigest()
	a_2 = int(h_2, 16)
	v_2 = 256**hashlen * v_1 + a_2
	v = v_2 % n
	return v

#Algorithm 4.2.1
#Input:
# An integer b
# A string p
#Output:
#  A string r comprising b octets
def HashBytes(b, p):
	hashlen = 20
	k = hashlib.sha1(p).hexdigest()
	h_0 = '0' * hashlen
	l = math.ceil(b / hashlen)
	r = ''
	for i in range(0, l):
		h_i = hashlib.sha1(h_0).hexdigest()
		r_i = hashlib.sha1(h_i + k).hexdigest()
		r = r + r_i
		h_0 = h_i
	return r[0:b]

#Algorithm 4.3.1
# for type-1 curve
def Canonical(v, p, o):
	return Canonical1(v, p, o)

#Algorithm 4.3.2
#Input:
#   o  An element v in F_p^2
#   o  A description of p, where p is congruent to 3 modulo 4
#   o  A ordering parameter o, either 0 or 1
#Output:
#   o  A string s of size 2 * Ceiling(lg(p) / 8) octets

def Canonical1(v, p, o):
	l = math.ceil(math.log(p, 2) / 8)
	v_a, v_b = v[0], v[1]
	a = str(v_a)
	b = str(v_b)
	if o == 0:
		return a + b
	return b + a

#Algorithm 4.4.1
def HashToPoint(E, p, q, id):
	return HashToPoint1(E, p, q, id)

#Algorithm 4.4.2
#Input:
#o A prime p
#o A prime q
#o A string id
#Output:
#   o  A point Q_id of order q in E(F_p)
def HashToPoint1(E, p, q, id):
	y = HashToRange(id, p)
	x = (y*y - 1)**((2*p-1)/3) % p
	Q = E((x, y))
	q = ((p+1)/q) * Q
	return q

#Algorihtm 4.5.1
def Pairing(E, A, B):
	return Pairing1(E, A, B)

#Algorihtm 4.5.2
def Pairing1(E, A, B):
    x, y = B[0], B[1]
    a_zeta = (p-1) / 2
    b_zeta = 3**((p+1)/4) % p
    zeta = E((a_zeta, b_zeta))
    xx = x * zeta
    bb = (xx, y)
    s = 1
    a = 0
    b = 0
    c = 1
    return Tate(A, B, s, a, b, c)

#Algorithm 4.6.1
#Input:
#  o  A description of an elliptic curve E/F_p such that E(F_p) and
#      E(F_p^2) have a subgroup of order q
#   o  Four points A, B, C, and D, of order q in E(F_p) or E(F_p^2)
#Output:
#   o  On supersingular curves, the value of e’(A, B) / e’(C, D) in F_p^2
#      where A, B, C, D are all in E(F_p)
def PairingRatio(E, A, B, C, D):
	return PairingRatio1(E, A, B, C, D)

#Algorithm 4.6.2
def PairingRatio1(E, A, B, C, D):
	return Pairing1(E, A, B) * Pairing(E, -C, D)

#Algorithm 5.1.1
#Input:
#o An integer version number
#o A security parameter n (MUST take values either 1024, 2048, 3072,
#7680, 15360)
#Output:
#o A set of public parameters (version, E, p, q, P, P_pub, hashfcn)
#o A corresponding master secret s
def BFsetup(ver, n):
	if ver == 2:
		return BFsetup1(n)

#Algorithm 5.1.2
#Input:
#o A security parameter n (MUST take values either 1024, 2048, 3072,
#7680, 15360)
#Output:
#o A set of public parameters (version, E, p, q, P, P_pub, hashfcn)
#o A corresponding master secret s

def BFsetup1(n):
	version = 2
	q = 2
	r = 1
	p = 12 * r * q - 1
	F = FiniteField(p)
	E = EllipticCurve(F, [0, 1])
	PP = E.gens()
	P = 12 * r * PP
	s = randint(1, q-1)
	P_pub = s * P
	params = [version, E, p, q, P, P_pub]
	return [params, s]

#Algorithm 5.2.1 (BFderivePubl): derives the public key corresponding
#   to an identity string.
#Input:
#   o  An identity string id
#   o  A set of public parameters (version, E, p, q, P, P_pub, hashfcn)
#Output:
#   o  A point Q_id of order q in E(F_p) or E(F_p^2)
def BFderivePub1(id, set):
	[version, E, p, q, P, P_pub] = set
	Q_id = HashToPoint(E, p, q, id)

#Algorithm 5.3.1 (BFextractPriv): extracts the private key
#   corresponding to an identity string.
#Input:
#   o  An identity string id
#   o  A set of public parameters (version, E, p, q, P, P_pub, hashfcn)
#Output:
#   o  A point S_id of order q in E(F_p)
def BFextractPriv(id, set, s):
	[version, E, p, q, P, P_pub] = set
	Q_id = HashToPoint(E, p, q, id)
	S_id = s * Q_id

#Algorithm 5.4.1 (BFencrypt): encrypts a random session key for an
#   identity string.
#Input:
#   o  A plaintext string m of size |m| octets
#   o  A recipient identity string id
#   o  A set of public parameters (version, E, p, q, P, P_pub, hashfcn)
#Output:
#   o  A ciphertext tuple (U, V, W) in E(F_p) x {0, ... , 255}^hashlen x
#      {0, ... , 255}^|m|
def BFencrypt(m, id, set):
	[version, E, p, q, P, P_pub] = set
	hashlen = 20
	Q_id = HashToPoint(E, p, q, id)
	rho = ""
	t = hashlib.sha1(m).hexdigest()
	l = HashToRange(rho+t, q)
	U = l * P
	theta = Pairing(E, p, q, P_pub, Q_id)
	theta_hat = theta ** l
	z = Canonical(theta_hat, p, 0)
	w = hashlib.sha1(z).hexdigest()
	V = xor(w, rho)
	w = HashBytes(len(m), rho)
	W = xor(w, m)
	return [U, V, W]

#Algorithm 5.5.1 (BFdecrypt): decrypts an encrypted session key using
#   a private key.
#Input:
#   o  A private key point S_id of order q in E(F_p)
#   o  A ciphertext triple (U, V, W) in E(F_p) x {0, ... , 255}^hashlen x
#      {0, ... , 255}*
#   o  A set of public parameters (version, E, p, q, P, P_pub, hashfcn)
#   Output:
#   o  A decrypted plaintext m, or an invalid ciphertext flag
def BFdecrypt(S_id, U, V, W, set):
	[version, E, p, q, P, P_pub] = set
	hashlen = 20
	theta = Pairing(E, U, S_id)
	z = Canonical(theta, p, 0)
	w = hashlib.sha1(z).hexdigest()
	rho = xor(w, V)
	m = HashBytes(len(W), rho)
	t = hashlib.sha1(m).hexdigest()
	l = HashToRange(rho + t, q)
	if U == l * P:
		return m

	return "Error"


#Algorithm 6.1.1
#Input:
#o An integer version number
#o A security parameter n (MUST take values either 1024, 2048, 3072,
#7680, 15360)
#Output:
#o A set of public parameters
#o A corresponding master secret s
def BBsetup(ver, n):
	if ver == 2:
		return BBsetup1(n)

#Algorithm 6.1.2
#Input:
#o A security parameter n (MUST take values either 1024, 2048, 3072,
#7680, 15360)
#Output:
#  A set of public parameters (version, k, E, p, q, P, P_1, P_2, P_3,
#      v, hashfcn)
#  A corresponding triple of master secrets (alpha, beta, gamma)
def BBsetup1(n):
	version = 2
	"""
	n_p = 0
	n_q = 0
	if n == 1024:
		n_p = 512
		n_q = 160
		hashfcn = "sha1"
	elif n == 2048:
		n_p = 1024
		n_q = 224
		hashfcn = "sha224"
	elif n == 3072:
		n_p = 1536
		n_q = 256
		hashfcn = "sha256"
	elif n == 7680:
		n_p = 3840
		n_q = 384
		hashfcn = "sha384"
	elif n == 15360:
		n_p = 7680
		n_q = 512
		hashfcn = "sha512"
	else:
		print "Invalid input for n"
		exit(0)
	"""
	q = 2
	r = 1
	p = 12 * r * q - 1
	F = FiniteField(p)
	E = EllipticCurve(F, [0, 1])
	PP = E.gens()
	P = 12 * r * PP
	alpha = randint(1, q-1)
	P_1 = alpha * P
	beta = randint(1, q-1)
	P_2 = beta * P
	gamma = randint(1, q-1)
	P_3 = gamma * P
	v = Pairing(E, P_1, P_2)
	s = [alpha, beta, gamma]
	params = [version, E, p, q, P, P_1, P_2, P_3, v]
	return [s, params]

#Algorithm 6.2.1
#Input:
#   o  An identity string id
#   o  A set of common public parameters (version, k, E, p, q, P, P_1,
#      P_2, P_3, v, hashfcn)
#Output:
#   o  An integer h_id modulo q
def BBderivePubl(id, params):
	[version, E, p, q, P, P_1, P_2, P_3, v] = params
	h_id = HashToRange(id, q)

#Algorithm 6.3.1
#Input:
#   o  An identity string id
#   o  A set of public parameters (version, k, E, p, q, P, P_1, P_2, P_3,
#      v, hashfcn)
#   Output:
#   o  A pair of points (D_0, D_1), each of which has order q in E(F_p)
def BBextractPriv(id, params, s):
	[version, E, p, q, P, P_1, P_2, P_3, v] = params
	[alpha, beta, gamma] = s
	r = randint(1, q-1)
	hid = HashToRange(id, q)
	y = alpha * beta + r * (alpha * hid + gamma)
	D_0 = y * P
	D_1 = r * P
	prikey = [D_0, D_1]

#Algorithm 6.4.1 (BBencrypt): encrypts a session key for an identity
#   string.
#   Input:
#   o  A plaintext string m of size |m| octets
#   o  A recipient identity string id
#   o  A set of public parameters (version, k, E, p, q, P, P_1, P_2, P_3,
#      v, hashfcn)
#Output:
#   o  A ciphertext tuple (u, C_0, C_1, y) in F_q x E(F_p) x E(F_p) x
#      {0, ... , 255}^|m|
def BBencrypt(m, id, params):
	[version, E, p, q, P, P_1, P_2, P_3, v] = params
	s = randint(1, q-1)
	w = v**s
	C_0 = s * P
	hid = HashToRange(id, q)
	y = s * hid
	C_1 = y * P_1 + s * P_3
	psi = Canonical(w, p, 1)
	l = math.ceil(math.log(p, 2)/8)
	zeta = hashlib.sha1(psi).hexdigest()
	xi = hashlib.sha1(zeta + psi).hexdigest()
	hh = xi + zeta
	y = HashBytes(len(m), hh)
	x_0, y_0 = C_0[0], C_0[1]
	x_1, y_1 = C_1[0], C_1[1]
	sigma = str(y_1) + str(x_1) + str(y_0) + str(x_0) + y + psi
	eta = hashlib.sha1(sigma).hexdigest()
	mu = hashlib.sha1(eta + sigma).hexdigest()
	h2 = mu + eta
	rho = HashToRange(h2, q)
	u = (s + rho) % q
	return [u, C_0, C_1, y]

#Algorithm 6.5.1 (BBdecrypt): decrypts a ciphertext using public
#   parameters and a private key.
#Input:
#   o  A private key given as a pair of points (D_0, D_1) of order q in
#      E(F_p)
#   o  A ciphertext quadruple (u, C_0, C_1, y) in Z_q x E(F_p) x E(F_p) x
#      {0, ... , 255}*
#   o  A set of public parameters (version, k, E, p, q, P, P_1, P_2, P_3,
#      v, hashfcn)
#   Output:
#   o  A decrypted plaintext m, or an invalid ciphertext flag
def BBdecrypt(prikey, ctx, params)
	[D_0, D_1] = prikey
	[u, C_0, C_1, y] = ctx
	[version, E, p, q, P, P_1, P_2, P_3, v] = params
	w = PairingRatio(E, C_0, D_0, C_1, D_1)
	psi = Canonical(w, p, 1)
	l = math.ceil(math.log(p, 2)/8)
	zeta = hashlib.sha1(psi).hexdigest()
	xi = hashlib.sha1(zeta + psi).hexdigest()
	hh = xi + zeta
	m = HashBytes(len(y), hh)
	x_0, y_0 = C_0[0], C_0[1]
	x_1, y_1 = C_1[0], C_1[1]
	sigma = str(y_1) + str(x_1) + str(y_0) + str(x_0) + y + psi
	eta = hashlib.sha1(sigma).hexdigest()
	mu = hashlib.sha1(eta + sigma).hexdigest()
	h2 = mu + eta
	rho = HashToRange(h2, q)
	s = (u - rho) % q
	if w == v**s and C_0 == s *P:
		return m

def xor(a, b):
	return ((a|b)-(a&b))

