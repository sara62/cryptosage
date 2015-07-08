#!/usr/bin/env sage -python
load('cryptosage/prime192v1.sage')
load('cryptosage/digest.sage')
load('cryptosage/mathhelper.sage')
load('cryptosage/sts.sage')

[Ra, ka] = A_step1()

[Rb, sb, tb, Rbstr, Rastr, k1] = B_step1(Ra)

[sa, ta] = A_step2(Rb, sb, tb, ka, Rbstr, Rastr, k1)

B_step2(sa, ta, Rbstr, Rastr, k1)