#!/usr/bin/env sage -python

load('cryptosage/prime192v1.sage')
load('cryptosage/digest.sage')
load('cryptosage/mathhelper.sage')
# ECMQV

# A's key pair
da = randint(1, n - 1)
Qa = da * P
# B's key pair
db = randint(1, n - 1)
Qb = db * P

ka = 0
Rastr = ''
Rbstr = ''
k1 = ''

Ra = A_step1()
[Rb, tb] = B_step1(Ra)
ta = A_step2(Rb, tb)
B_step2(ta)

def A_step1():
	ka = randint(1, n - 1)
	Ra = ka * P
	return Ra

def B_step1(Ra):
	kb = randint(1, n - 1)
	Rb = kb * P
	sb = Integer(kb) + point_hat(Rb) * Integer(db)

	Ra_hat = point_hat(Ra)
	Pz = Ra + Integer(Ra_hat) * Qa
	Z = h * Integer(sb) * Pz
	(zx, zy) = Z.xy()
	l = ceil(math.log(n, 2)/8)
	zxstr = I2OSP(zx, l)
	str = KDF(zxstr, l, '')
	k1 = str[0:l]
	k2 = str[l:2*l]
	Rbstr = point2str(Rb, l)
	Rastr = point2str(Ra, l)
	hmacobj = hmac.new(k1)
	hmacobj.update("2" + Rbstr + Rastr)
	tb = hmacobj.digest()
	return [Rb, tb]

def A_step2(Rb, tb):
	sa = Integer(ka) + point_hat(Ra) * Integer(da)
	Rb_hat = point_hat(Rb)
	Pz = Rb + Integer(Rb_hat) * Qb
	Z = h * Integer(sa) * Pz
	(zx, zy) = Z.xy()
	l = ceil(math.log(n, 2)/8)
	zxstr = I2OSP(zx, l)
	str = KDF(zxstr, l, '')
	k1 = str[0:l]
	k2 = str[l:2*l]
	hmacobj = hmac.new(k1)
	hmacobj.update("2" + Rbstr + Rastr)
	t = hmacobj.digest()
	if t != tb:
		print "false"
	else:
		print "Hmac value is the same"
	hmacobj = hmac.new(k1)
	hmacobj.update("3" + Rastr + Rbstr)
	ta = hmacobj.digest()
	return ta

def B_step2(ta):
	hmacobj = hmac.new(k1)
	hmacobj.update("3" + Rastr + Rbstr)
	ta2 = hmacobj.digest()
	if ta2 != ta:
		print "false"
	else:
		print "Hmac value is the same"

# end of ECMQV
"""
# A:
ka = randint(1, n - 1)
Ra = ka * P
#send A, Ra to B
#B
kb = randint(1, n - 1)
Rb = kb * P
sb = Integer(kb) + point_hat(Rb) * Integer(db)

Ra_hat = point_hat(Ra)
Pz = Ra + Integer(Ra_hat) * Qa
Z = h * Integer(sb) * Pz
(zx, zy) = Z.xy()
l = ceil(math.log(n, 2)/8)
zxstr = I2OSP(zx, l)
str = KDF(zxstr, l, '')
k1 = str[0:l]
k2 = str[l:2*l]
Rbstr = point2str(Rb, l)
Rastr = point2str(Ra, l)
hmacobj = hmac.new(k1)
hmacobj.update("2" + Rbstr + Rastr)
tb = hmacobj.digest()
#send B, Rb, tb to A
#A
sa = Integer(ka) + point_hat(Ra) * Integer(da)
Rb_hat = point_hat(Rb)
Pz = Rb + Integer(Rb_hat) * Qb
Z = h * Integer(sa) * Pz
(zx, zy) = Z.xy()
l = ceil(math.log(n, 2)/8)
zxstr = I2OSP(zx, l)
str = KDF(zxstr, l, '')
k1 = str[0:l]
k2 = str[l:2*l]
hmacobj = hmac.new(k1)
hmacobj.update("2" + Rbstr + Rastr)
t = hmacobj.digest()
if t != tb:
	print "false"
else:
	print "Hmac value is the same"
hmacobj = hmac.new(k1)
hmacobj.update("3" + Rastr + Rbstr)
ta = hmacobj.digest()
# send ta to B
#B
hmacobj = hmac.new(k1)
hmacobj.update("3" + Rastr + Rbstr)
ta2 = hmacobj.digest()
if ta2 != ta:
	print "false"
else:
	print "Hmac value is the same"
"""
