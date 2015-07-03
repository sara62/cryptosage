
bits = 1024
p	= random_prime(2**bits);	print "      p = %d" %p
q	= random_prime(2**bits);	print "      q = %d" %q
N	= p * q;			print "      N = p * q = %d" %N
phi	= (p - 1)*(q - 1);		print " phi(N) = (p - 1)*(q - 1) = %d" %phi
e	= 2**16 + 1;			print "      e = 2^16 + 1 = %d" %e
d	=  xgcd(e, phi)[1] % phi;	print "      d = e^-1 mod phi(N) = %d" %d


print "%x" %(2**(bits*2))
print "%x" %N
v = 2**(bits*2) - N; print "%x" %v
