#!/usr/bin/env sage -python

import math

def ecc_curve_gen(p, l):
	t = math.ceil(math.log(p, 2))
	s = math.floor((t-1)/l)
	v = t - s*l
	minnum = math.pow(2, l+1)
	S = randint(minnum, 2*minnum)
	h = digest(S)
	mask = math.pow(2, v) - 1
	r0 = h & mask
	r = r0
	for i in range(1, s+1):
		si = s + i
		ri = digest(si)
		r = (r << l) | ri
	if r == 0 or (4*r + 27)%p == 0:
		print "fail, please retry"
		return
	a = randint(1, p-1)
	b = randint(1, p-1)
	while (r*b*b - a*a*a)%p == 0:
		a = randint(1, p-1)
		b = randint(1, p-1)

	return [S, a, b]

def verify_ecc_curve(p, S, a, b, l):
	t = math.ceil(math.log(p, 2))
	s = math.floor((t-1)/l)
	v = t - s*l
	h = digest(S)
	mask = math.pow(2, v) - 1
	r0 = h & mask
	r = r0
	for i in range(1, s+1):
		si = s + i
		ri = digest(si)
		r = (r << l) | ri

	if (r*b*b - a*a*a)%p == 0:
		return "Accept"
	else:
		return "Reject"


def param_gen(q, L):
	[S, a, b] = ecc_curve_gen(q, L)
	F = GF(q)
	E = EllipticCurve(F, [a, b])
	N = E.order()
	n = prime_gen(L)
	for k in (1, 21):
		modu = math.pow(q, k) - 1
		if n%modu == 0:
			print "fail, please retry"
			return
	h = N / n
	PP = E.gens()
	P = h * PP
	return [q, S, a, b, P, n, h]

