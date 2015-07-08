#!/usr/bin/env sage -python
load('cryptosage/prime192v1.sage')
load('cryptosage/digest.sage')
load('cryptosage/mathhelper.sage')
load('cryptosage/eckeygen.sage')
load('cryptosage/ecies.sage')

(Q, d) = ec_keygen()
#pk: Q, sk:d
m = 'hello'

# ECIES
[R, C, t] = ecies_encrypt(Q, m)
ans = ecies_decrypt(R, C, t, d)
print "PlainText is        : ", m
print "Decrypt Result is   : ", ans
