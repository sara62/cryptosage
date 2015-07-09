
# Paillier keygen, simple version with g = n + 1
# Output:
#	public key (n, g), private key (lmd, mu)
#	`n` is integer
#	`g` in Z_{n^2}*
#	`lmd` is integer
#	`mu` is in Z_n
#
def paillier_keygen_simple(bits):
	p = random_prime(2^bits)
	q = random_prime(2^bits)
	n = p * q
	Zn = IntegerModRing(n)
	Zn2 = IntegerModRing(n^2)
	g = Zn2(n + 1)
	lmd = (p - 1) * (q - 1)
	mu = Zn(lmd)^-1
	return ((n, g), (lmd, mu))

# Paillier Encryption
# input:
#	plaintext `m` is integer in [0, n-1]
# output:
#	ciphertext `c` in Z_{n^2}*
#
def paillier_encrypt(m, pk):
	(n, g) = pk
	Zn2 = IntegerModRing(n^2)
	r = Zn2(randint(0, n))
	c = g^m * r^n
	return c

# L(u) = (u - 1)/n
# m = (L((c^lambda) mod n^2) * u) mod n
# c in Z_{n^2}
#
def paillier_decrypt(c, sk):
	((n, g), (lmd, mu)) = sk
	Zn = IntegerModRing(n)
	c = Zn((Integer(c^lmd) - 1) / n) * mu
	return c

# FIXME
def paillier_ciphertext_add(c1, c2, pk):
	return c1 * c2

