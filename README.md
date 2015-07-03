# CryptoSage

Cryptography Implementation in SageMath (http://www.sagemath.org).

This project is for students and engineers interested in cryptography.
You can try and test these cryptography algorithms with real parameters and full key lengths.
We write cryptography algorithms in SageMath.

We hope to implement all popular public key schemes:

* Integer-Factoring-Based Cryptosystems including RSA/Rabin/Paillier, etc. 
* Descrete-Log-Based Cryptosystems including DH/ElGamal/DSA, etc.
* ECC (Elliptic curve cryptography)
* Pairing-Based Cryptography
* Lattice-Based Cryptography
* Coding-Based Cryptography


### Elliptic Curve Cryptography

* EC domain parameters: `prime192v1.sage`
* EC key generation: `eckeygen.sage`
* ECDSA signature generation and verification `ecdsa.sage`

You can view and try the `ectest.sage`

```
$ sage ectest.sage
```

