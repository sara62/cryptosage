#!/usr/bin/env sage -python
load('cryptosage/prime192v1.sage')
load('cryptosage/digest.sage')
load('cryptosage/mathhelper.sage')
load('cryptosage/eckeygen.sage')
load('cryptosage/eckcdsa.sage')

(Q, d) = ec_keygen()
#pk: Q, sk:d
m = 'hello'

print "Public Key       : ", Q.xy()
print "Private Key      : ", d

hcert = "unique"
[r, s] = eckcdsa_sign(d, m, hcert)
ans = eckcdsa_verify(Q, m, r, s, hcert)

print "ECKCDSA Verification Result : ", ans
#print ans

