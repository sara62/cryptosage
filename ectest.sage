load('cryptosage/prime192v1.sage')
load('cryptosage/digest.sage')
load('cryptosage/mathhelper.sage')
load('cryptosage/eckeygen.sage')
load('cryptosage/ecdsa.sage')
load('cryptosage/eckcdsa.sage')
load('cryptosage/ecies.sage')
load('cryptosage/psec.sage')

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

hcert = "unique"
[r, s] = eckcdsa_sign(d, m, hcert)
ans = eckcdsa_verify(Q, m, r, s, hcert)

print "ECKCDSA Verification Result : ", ans
#print ans

# ECIES
[R, C, t] = ecies_encrypt(Q, m)
ans = ecies_decrypt(R, C, t, d)
print "PlainText is        : ", m
print "Decrypt Result is   : ", ans

#PSEC
[R, C, s, t] = psec_encrypt(Q, m)
ans = psec_decrypt(R, C, s, t, d)
print "PlainText is        : ", m
print "Decrypt Result is   : ", ans
