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
	while s == 0:
		k = 1
		while r == 0:
			k = randint(1, n - 1)
			Q = k * P
			(x1, y1) = Q.xy()
			r = Fn(x1)
		kk = Fn(k)
		e = digest(m)
		s = kk ^ (-1) * (e + d * r)
	return [r, s]

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
def ecdsa_verify(Q, m, r, s):
	e = digest(m)
	w = s ^ (-1)
	u1 = (e * w)
	u2 = (r * w)
	P1 = Integer(u1) * P
	P2 = Integer(u2) * Q
	X = P1 + P2
	(x, y) = X.xy()
	v = Fn(x)
	return v == r

