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
	j = 0
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
	if A == [0, 0]: return [1, 0]	

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
	return Pairing1(E, A, B);

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

Enter file contents here
