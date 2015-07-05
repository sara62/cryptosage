# ECMQV
# A's key pair
da = randint(1, n - 1)
Qa = da * G
# B's key pair
db = randint(1, n - 1)
Qb = db * G

# A:
ka = randint(1, n - 1)
Ra = ka * G
#send A, Ra to B
#B
kb = randint(1, n - 1)
Rb = kb * G
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
# end of ECMQV