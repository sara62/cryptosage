# elliptic curve domain parameters, prime192v1
#
# p = 2**192 - 2**64 - 1
# a = -3
# b = 0x64210519E59C80E70FA7E9AB72243049FEB8DEECC146B9B1
# x = 0x188DA80EB03090F67CBF20EB43A18800F4FF0AFD82FF1012
# y = 0x07192B95FFC8DA78631011ED6B24CDD573F977A11E794811
# n = 0xFFFFFFFFFFFFFFFFFFFFFFFF99DEF836146BC9B1B4D22831
# h = 1
#

Fp = FiniteField(2**192 - 2**64 - 1)
a  = -3
b  = 0x64210519E59C80E70FA7E9AB72243049FEB8DEECC146B9B1
E  = EllipticCurve(Fp, [a, b])
P  = E((0x188DA80EB03090F67CBF20EB43A18800F4FF0AFD82FF1012,
	0x07192B95FFC8DA78631011ED6B24CDD573F977A11E794811))
n  = 0xFFFFFFFFFFFFFFFFFFFFFFFF99DEF836146BC9B1B4D22831
h  = 1
Zn = FiniteField(n)

