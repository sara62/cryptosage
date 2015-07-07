load('prime192v1.sage')
load('eckeygen.sage')
load('digest.sage')
load('ecdsa.sage')
load('eckcdsa.sage')
load('ecies.sage')
load('psec.sage')

(Q, d) = ec_keygen() //pk: Q, sk:d
m = 'hello'

sig = ecdsa_sign(d, m)
result = ecdsa_verify(Q, m, sig)

print "EC Public Key       : ", Q.xy()
print "EC Private Key      : ", d
print "Signed Message      : ", m
print "ECDSA Signature     : ", sig
print "Verification Result : ", result

hcert = "unique"
[r, s] = eckcdsa_sign(P, d, m, hcert)
ans = eckcdsa_verify(P, Q, m, r, s, hcert)

print "ECKCDSA Verification Result : ", ans
#print ans

# ECIES
[R, C, t] = ecies_encrypt(Q, m, P)
ans = ecies_decrypt(R, C, t, d)
print ans


#PSEC
[R, C, s, t] = psec_encrypt(Q, m, P)
ans = psec_decrypt(R, C, s, t, d, P)
print "encrypt over"
print ans
