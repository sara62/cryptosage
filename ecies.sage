# Algorithm 4.42 ECIES encryption
# Require:
#	generator point P of elliptic curve E
#	order n of P and the field Zn defined by n
# Input:
#	message m
#	public key Q
# Output:
#	Ciphertext (R,C,t).
#
def ecies_encrypt(Q, m):
	k = randint(1, n - 1)
	R = k * P
	Z = h * k * Q
	l = ceil(math.log(n, 2)/8)

	(zx, zy) = Z.xy()
	zxstr = I2OSP(zx, l)
	rstr = point2str(R, l)
	str = KDF(zxstr, l, rstr)
	k1 = str[0:l]
	k2 = str[l:2*l]
	print k1
	aesobj = AES.new(k1)
	C = aesobj.encrypt(pad(m))
	hmacobj = hmac.new(k2)
	hmacobj.update(C)
	t = hmacobj.digest()
	print t
	return [R, C, t]

# Algorithm 4.43 ECIES decryption
# Require:
#	generator point P of elliptic curve E
#	order n of P and the field Zn defined by n
# Input:
#	private key d
#	ciphertext (R,C,t)
# Output:
#	Plaintext m or rejection of the ciphertext.
#

def ecies_decrypt(R, C, t, d):
	Z = h * d * R
	l = ceil(math.log(n, 2)/8)
	(zx, zy) = Z.xy()
	zxstr = I2OSP(zx, l)
	rstr = point2str(R, l)
	str = KDF(zxstr, l, rstr)
	k1 = str[0:l]
	k2 = str[l:2*l]
	hmacobj = hmac.new(k2)
	hmacobj.update(C)
	t1 = hmacobj.digest()
	print t1
	if t1 != t:
		return False
	aesobj = AES.new(k1)
	m = aesobj.decrypt(C)
	return m