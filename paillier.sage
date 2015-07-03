
bits = 1024

# Key Generation
p = random_prime(2**bits)
q = random_prime(2**bits)
n = p * q
d = lcm(p-1, q-1)
u = xgcd(d, n)[1] % n

print "pk = %d" %n
print "sk = %d" %d

# Encryption
m = 3
r = random_prime(n)
n2 = n * n
c = ((n + 1)**m) * (r**n) % (n*n)

# Decryption

m = 
