#!/usr/bin/env sage -python
# pairing example - by guan@pku.edu.cn

import sys
from sage.all import *

# Introduction to Mathematical Cryptography
# Example 5.43
# 	E: y^2 = x^3 + 30x + 34 (mod 631)
# 	#E(F_631) = 650 = 2 * 5^2 * 13
#	E has 25 points of order 5
#	P = (36, 60), Q = (121, 387), #P = #Q = 5
#	S = (0, 36) is not aP + bQ
F = GF(631)
a = F(30)
b = F(34)
m = [1, 0, 1] # 5 = (101)_2
P = [F(36), F(60)]
Q = [F(121), F(387)]
S = [F(0), F(36)]


#print "y^2 = x^3 + %d x + %d" %a %b
print "E: y^2 = x^3 + 30x + 34 (mod 631)"



def point_add(P, Q):

	x1 = P[0]
	y1 = P[1]
	x2 = Q[0]
	y2 = Q[1]

	# we use (0, 0) to represent the point at infinity
	# (0, 0) is not a valid point on E
	if P == [0, 0]:
		return Q
	
	if Q == [0, 0]:
		return P

	if x1 == x2 and y1 + y2 == 0:
		return [0, 0]

	if P == Q:
		return point_double(P)

	slope = F((y2 - y1)/(x2 - x1))
	x3 = F(slope**2 - x1 - x2)
	y3 = F(slope * (x1 - x3) - y1)
	return [x3, y3]

def point_double(P):

	if P == [0, 0]:
		return [0, 0]

	x1 = P[0]
	y1 = P[1]
	slope = F((3 * x1**2 + a)/(2 * y1))
	x3 = F(slope**2 - 2 * x1)
	y3 = F(slope * (x1 - x3) - y1)
	return [x3, y3]

x = var('x')
y = var('y')

def g(P, Q):
	
	xP = P[0]
	yP = P[1]
	xQ = Q[0]
	yQ = Q[1]

	# slope == infinity
	if (xP == xQ) and (yP + yQ == 0):
		return (x - xP)

	if (P == Q):
		slope = (3 * xP * xP + a)/(2 * yP)
	else:
		slope = (yQ - yP)/(xQ - xP)

	return (y - yP - slope * (x - xP))/(x + xP + xQ - slope**2)


def miller(P):
	
	T = P
	f = 1

	for i in range(len(m) - 1):
		
		f = f * f * g(T, T)
		T = point_double(T)
		
		if m[len(m) - i - 2] == 1:
			f = f * g(T, P)
			T = T + P
	
	return f

f = miller(P)

R = point_add(Q, S)

print f(x = R[0], y = R[1])
print f(x = S[0], y = S[1])
print f(x = R[0], y = R[1])/f(x = S[0], y = S[1])

	
