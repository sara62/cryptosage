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

def point_hat(P):
	(x, y) = P.xy()
	l = floor(math.log(n, 2)) + 1
	ll = math.pow(2, l)
	i = Integer(x)%ll + ll
	return i