# Algorithm 4.36 EC-KCDSA signature generation
# Require:
#	generator point P of elliptic curve E
#	order n of P and the field Zn defined by n
# Input:
#	message m
#	private key d in [1, n - 1]
#   hashed certification data hcert
# Output:
#	signature (r, s) where r, s in Zn


def eckcdsa_sign(d, m, hcert):
	s = 0
	r = 0
	while s == 0:
		k = randint(1, n - 1)
		Q = k * P
		(x1, y1) = Q.xy()
		r = digest(x1)
		e = digest(hcert + m)
		w = r ^ e
		wt = Integer(w)
		if wt >= n:
			wt = wt - n
		s = Fn(d * (k - wt))
	return [r, s]

# Algorithm 4.37 EC-KCDSA signature verification
# Require:
#	generator point P of elliptic curve E
#	order n of P and the field Zn defined by n
# Input:
#	message m
#	public key Q
#   hashed certification data hcert
# Output:
#	Acceptance or rejection of the signature.
def eckcdsa_verify(Q, m, r, s, hcert):
	e = digest(hcert + m)
	w = r ^ e
	wt = Integer(w)
	if wt >= n:
		wt = wt - n
	P1 = Integer(s) * Q
	P2 = wt * P
	X = P1 + P2
	(x, y) = X.xy()
	v = digest(x)
	return v == r