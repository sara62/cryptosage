#!/usr/bin/env sage -python
load('cryptosage/prime192v1.sage')
load('cryptosage/digest.sage')
load('cryptosage/mathhelper.sage')
load('cryptosage/eckeygen.sage')
load('cryptosage/ecdsa.sage')

(Q, d) = ec_keygen()
#pk: Q, sk:d
m = 'hello'

[r, s] = ecdsa_sign(d, m)
result = ecdsa_verify(Q, m, r, s)

print "EC Public Key       : ", Q.xy()
print "EC Private Key      : ", d
print "Signed Message      : ", m
print "ECDSA Signature     : ", r
print "Verification Result : ", result
