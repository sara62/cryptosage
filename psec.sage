def psec_encrypt(Q, m, P):
	r = randint(1, n - 1)
	l = ceil(math.log(n, 2)/8)
	rstr = I2OSP(r, l)
	str = KDF(rstr, 96, '')
	kstr = str[0:32]
	k = int(kstr, 16) % n
	k1 = str[32:64]
	k2 = str[64:96]
	R = k * P
	Z = k * Q
	rstr = point2str(R, l)
	zstr = point2str(Z, l)
	addstr = KDF(rstr, l, zstr)
	num = int(addstr, 16)
	r = int(r)
	s = r ^ num
	aesobj = AES.new(k1)
	C = aesobj.encrypt(pad(m))
	print C
	hmacobj = hmac.new(k2)
	hmacobj.update(C)
	t = hmacobj.digest()
	print t
	return [R, C, s, t]

def psec_decrypt(R, C, s, t, d, P):
	Z = d * R
	l = ceil(math.log(n, 2)/8)
	Rstr = point2str(R, l)
	Zstr = point2str(Z, l)

	addstr = KDF(Rstr, l, Zstr)
	num = int(addstr, 16)
	s = int(s)
	r = s ^ num
	rstr = I2OSP(r, l)
	str = KDF(rstr, 48, '')
	kstr = str[0:32]
	k = int(kstr, 16) % n
	k1 = str[32:64]
	k2 = str[64:96]
	Rp = k * P
	(rpx, rpy) = Rp.xy()
	(rx, ry) = R.xy()
	if rx != rpx or ry != rpy:
		return "Reject"
	hmacobj = hmac.new(k2)
	hmacobj.update(C)
	t1 = hmacobj.digest()
	print t1
	if t1 != t:
		return "Reject"
	aesobj = AES.new(k1)
	m = aesobj.decrypt(C)
	return m
