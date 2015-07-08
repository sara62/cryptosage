#!/usr/bin/env sage -python
load('cryptosage/prime192v1.sage')
load('cryptosage/digest.sage')
load('cryptosage/mathhelper.sage')
load('cryptosage/eckeygen.sage')
load('cryptosage/psec.sage')

(Q, d) = ec_keygen()
#pk: Q, sk:d
m = 'hello'

print "EC Public Key       : ", Q.xy()
print "EC Private Key      : ", d

#PSEC
[R, C, s, t] = psec_encrypt(Q, m)
print "PlainText is        : ", m
print "encrypt details: ", C
ans = psec_decrypt(R, C, s, t, d)
print "Decrypt Result is   : ", ans
