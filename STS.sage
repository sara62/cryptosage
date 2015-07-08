#Station-to-Station
load('cryptosage/prime192v1.sage')

def A_step1():
	ka = randint(1, n - 1)
	Ra = ka * P
	return [Ra, ka]

def B_step1(Ra):
	kb = randint(1, n - 1)
	Rb = kb * P
	Z = h * kb * Ra
	(zx, zy) = Z.xy()
	l = ceil(math.log(n, 2)/8)
	zxstr = I2OSP(zx, l)
	str = KDF(zxstr, l, '')
	k1 = str[0:l]
	k2 = str[l:2*l]
	Rbstr = point2str(Rb, l)
	Rastr = point2str(Ra, l)
	sb = digest(Rbstr + Rastr)
	hmacobj = hmac.new(k1)
	hmacobj.update(Rbstr + Rastr)
	tb = hmacobj.digest()
	return [Rb, sb, tb, Rbstr, Rastr, k1]

def A_step2(Rb, sb, tb, ka, Rbstr, Rastr, k1):
	Z = h * ka * Rb
	(zx, zy) = Z.xy()
	l = ceil(math.log(n, 2)/8)
	zxstr = I2OSP(zx, l)
	str = KDF(zxstr, l, '')
	k1 = str[0:l]
	k2 = str[l:2*l]
	sb2 = digest(Rbstr + Rastr)
	if sb2 == sb:
		print "Hash value is the same"
	else:
		print "Hash value is different"

	hmacobj = hmac.new(k1)
	hmacobj.update(Rbstr + Rastr)
	t = hmacobj.digest()
	if t != tb:
		print "Hmac value is different"
	else:
		print "Hmac value is the same"

	sa = digest(Rastr + Rbstr)
	hmacobj = hmac.new(k1)
	hmacobj.update(Rastr + Rbstr)
	ta = hmacobj.digest()
	return [sa, ta]

def B_step2(sa, ta, Rbstr, Rastr, k1):
	sab = digest(Rastr + Rbstr)
	print sab
	if sab != sa:
		print "false"
	else:
		print "Hash value is the same"
	hmacobj = hmac.new(k1)
	hmacobj.update(Rastr + Rbstr)
	ta2 = hmacobj.digest()
	print ta2
	if ta2 != ta:
		print "false"
	else:
		print "Hmac value is the same"

# end of STS

"""
# A:
ka = randint(1, n - 1)
Ra = ka * P
#send A, Ra to B
#B
kb = randint(1, n - 1)
Rb = kb * P
Z = h * kb * Ra
(zx, zy) = Z.xy()
l = ceil(math.log(n, 2)/8)
zxstr = I2OSP(zx, l)
str = KDF(zxstr, l, '')
k1 = str[0:l]
k2 = str[l:2*l]
Rbstr = point2str(Rb, l)
Rastr = point2str(Ra, l)
sb = digest(Rbstr + Rastr)
hmacobj = hmac.new(k1)
hmacobj.update(Rbstr + Rastr)
tb = hmacobj.digest()
#send B, Rb, sb, tb to A
#A
Z = h * ka * Rb
(zx, zy) = Z.xy()
l = ceil(math.log(n, 2)/8)
zxstr = I2OSP(zx, l)
str = KDF(zxstr, l, '')
k1 = str[0:l]
k2 = str[l:2*l]
sb2 = digest(Rbstr + Rastr)
if sb2 == sb:
	print "Hash value is the same"
else:
	print "Hash value is different"

hmacobj = hmac.new(k1)
hmacobj.update(Rbstr + Rastr)
t = hmacobj.digest()
if t != tb:
	print "Hmac value is different"
else:
	print "Hmac value is the same"

sa = digest(Rastr + Rbstr)
hmacobj = hmac.new(k1)
hmacobj.update(Rastr + Rbstr)
ta = hmacobj.digest()
print sa
print ta
# send sa, ta to B
#B
sab = digest(Rastr + Rbstr)
print sab
if sab != sa:
	print "false"
else:
	print "Hash value is the same"
hmacobj = hmac.new(k1)
hmacobj.update(Rastr + Rbstr)
ta2 = hmacobj.digest()
print ta2
if ta2 != ta:
	print "false"
else:
	print "Hmac value is the same"
"""