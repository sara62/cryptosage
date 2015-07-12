/*
 * This file is part of CipherSQL project of 256bits.cn
 * All rights preserved. 
 */
#ifndef CIPHERSQL_FPE_H
#define CIPHERSQL_FPE_H

/*
 * Format-Preserve Encryption
 * implementation of NIST 800-38G FFX schemes
 * 
 * FPE is used to encrypt strings such as credit card numbers and phone numbers
 * the ciphertext is still in valid format, for example:
 *	 FPE_encrypt("13810631266") == "98723498792"
 * the output is still 11 digits
 */

#include <string.h>


#define CIPHERSQL_AES			0x0100
#define CIPHERSQL_SM4			0x0200
#define CIPHERSQL_FF1			0x01
#define CIPHERSQL_FF2			0x02
#define CIPHERSQL_FF3			0x03
#define CIPHERSQL_AES_FF1		(CIPHERSQL_AES | CIPHERSQL_FF1)
#define CIPHERSQL_AES_FF2		(CIPHERSQL_AES | CIPHERSQL_FF2)
#define CIPHERSQL_AES_FF3		(CIPHERSQL_AES | CIPHERSQL_FF3)
#define CIPHERSQL_SM4_FF1		(CIPHERSQL_SM4 | CIPHERSQL_FF1)
#define CIPHERSQL_SM4_FF2		(CIPHERSQL_SM4 | CIPHERSQL_FF2)
#define CIPHERSQL_SM4_FF3		(CIPHERSQL_SM4 | CIPHERSQL_FF3)
#define FPE_TWEAK_LENGTH 7

#ifdef __cplusplus
extern "C" {
#endif

/*
 * AES use OpenSSL implementation:
 * openssl/crypto/aes/aes.h
 *	AES_set_encrypt_key
 *	AES_encrypt
 *	AES_set_decrypt_key
 *	AES_decrypt
 *
 * SM4 use our sms4 implementation
 */

/* Algorithm 4 of NIST 800-38G */
static int pseudo_random_func(
		int cipher, /* FPE_AES or FPE_SM4 */
		const unsigned char *key,
		size_t keylen,
		const unsigned char *inblocks,
		int nblocks,
		unsigned char *outblock);

/* the base/radix of FFX is fixed to 10, i.e. digits */
int FPE_encrypt_digits(
		int algor, /* FPE_AES_FF1, FPE_AES_SM4_FF1, ... */
		const unsigned char *key,
		size_t keylen,
		const unsigned char tweak[FPE_TWEAK_LENGTH],
		const char *indigits,
		char *outdigits);

int FPE_decrypt_digits(
		int algor,
		const unsigned char *key,
		size_t keylen,
		const unsigned char tweak[FPE_TWEAK_LENGTH],
		const char *indigits,
		char *outdigits);

#ifdef __cplusplus
}
#endif
#endif
