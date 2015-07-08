#!/usr/bin/env sage -python
load('cryptosage/prime192v1.sage')

# load('<curve_name>.sage')

# Algorithm 4.24 Elliptic curve key pair generation
# Require:
#	generator point P of elliptic curve E
#	order n of P and the field Zn defined by n
# Input:
#	N/A
# Output:
#	keypair (Q, d)
#		public key point Q on curve E
#		private key d in [1, n-1]
#

def ec_keygen():
	print "keygen"
	d = randint(1, n - 1)
	Q = d * P
	return (Q, d)

