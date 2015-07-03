load('prime192v1.sage')
load('eckeygen.sage')
load('digest.sage')
load('ecdsa.sage')

(Q, d) = ec_keygen()
m = 'hello'

sig = ecdsa_sign(d, m)
result = ecdsa_verify(Q, m, sig)

print "EC Public Key       : ", Q.xy()
print "EC Private Key      : ", d
print "Signed Message      : ", m
print "ECDSA Signature     : ", sig
print "Verification Result : ", result

