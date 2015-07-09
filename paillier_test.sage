
load("paillier.sage")

sk = paillier_keygen_simple(1024)
pk = sk[0]
print sk

m1 = randint(0, 1000)
c1 = paillier_encrypt(m1, pk)
print c1
print m1
print paillier_decrypt(c1, sk)

m2 = randint(0, 1000)
c2 = paillier_encrypt(m2, pk)
print c2
print m2
print paillier_decrypt(c2, sk)

sum = paillier_ciphertext_add(c1, c2, pk)
print m1 + m2
print paillier_decrypt(sum, sk)

