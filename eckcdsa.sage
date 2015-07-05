def eckcdsa_sign(P, n, d, m, hcert):
	s = 0
	r = 0
	while s == 0:
		k = randint(1, n - 1)
		Q = k * P
		(x1, y1) = Q.xy()
		r = digest(x1)
		e = digest(hcert + m)
		w = r ^ e
		wt = Integer(w)
		if wt >= n:
			wt = wt - n
		s = Fn(d * (k - wt))
	return [r, s]


def eckcdsa_verify(P, Q, m, r, s, hcert):
	e = digest(hcert + m)
	w = r ^ e
	wt = Integer(w)
	if wt >= n:
		wt = wt - n
	P1 = Integer(s) * Q
	P2 = wt * P
	X = P1 + P2
	(x, y) = X.xy()
	v = digest(x)
	return v == r