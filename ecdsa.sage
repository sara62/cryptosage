# load("prime192v1.sage")
# load("digest.sage")

# Algorithm 4.29 ECDSA signature generation
# Require:
#	generator point P of elliptic curve E
#	order n of P and the field Zn defined by n
# Input:
#	message m
#	private key d in [1, n - 1]
# Output:
#	signature (r, s) where r, s in Zn
#
def ecdsa_sign(d, m):
	r = 0
	s = 0
	e = digest(m)

	while s == 0:
		while r == 0:
			k = randint(1, n - 1)
			kP = k * P
			(x, y) = kP.xy()
			r = Zn(x)
		s = Zn(k)^-1 * (e + d * r)

	return (r, s)

# Algorithm 4.30 ECDSA signature verification
# Require:
#	generator point P of curve E
#	order n of P and the field Zn defined by n
# Input:
#	public key point Q on curve E
#	message m
#	signature sig = (r, s) where r, s in Zn
# Output:
#	True or False
#
def ecdsa_verify(Q, m, sig):
	r = sig[0]
	if r == 0:
		return False
	s = sig[1]
	if s == 0:
		return False
	e = digest(m)

	w = s^(-1)
	u1 = e * w
	u2 = r * w
	X = Integer(u1) * P + Integer(u2) * Q
	if X == 0:
		return False
	(x, y) = X.xy()
	v = Zn(x)

	return v == r

