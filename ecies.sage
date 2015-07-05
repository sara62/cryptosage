import sys
import hashlib
from Crypto.Cipher import AES
from sage.all import *
import hmac
import math
from binascii import a2b_hex, b2a_hex

def pad(s):
    return s + b"\0" * (AES.block_size - len(s) % AES.block_size)

def KDF(x, l, certi):
	assert l >= 0, 'l should be positive integer'
	k = l / float(20)
	k = int(ceil(k))

	l_str = ''
	for i in range(0, k):
		l_str = l_str + hashlib.sha1(x + I2OSP(i, 4) + certi).hexdigest()

	return l_str[:l * 2]


def I2OSP(longint, length):
	hex_string = '%X' % longint
	if len(hex_string) > 2 * length:
		raise ValueError('integer %i too large to encode in %i octets' % ( longint, length ))
	return a2b_hex(hex_string.zfill(2 * length))

def point2str(R, l):
	(rx, ry) = R.xy()
	rxstr = I2OSP(rx, l)
	rystr = I2OSP(ry, l)
	rstr = rxstr + rystr
	return rstr

def ecies_encrypt(Q, m, n, h, P):
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


def ecies_decrypt(R, C, t, d, h, n):
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