#include "fpe.h"
#include <assert.h>
#include <openssl/err.h>
#include <stdio.h>
#include <openssl/aes.h>
#include <openssl/rand.h>
#include <math.h>
/*
 * 2^32 = 4294967296, 10 digits, with can be used 9 digits
 * 2^64 = 18446744073709551616, 20 digits, 19 digits can be used.
 * we use 7 bytes fixed-length tweaks
 * Plaintext MinLength: 10
 * Plaintext MaxLength: 19
 *
 * cnid: location (6) + birthday (8) + checksum (4) : 18
 */

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
#define RADIX 10
uint32_t TWEAK_LENGTH = 7;


void print_chars(unsigned char ch[]){
	int len = strlen(ch);
	int i = 0;
	for(i = 0 ; i < len; i++)
	{
		printf("%d ", ch[i]);
	}
	printf("\n");
	return;
}

int ciphersql_fpe_encrypt_digits(
		const unsigned char *key,
		size_t keybits,
		const unsigned char *tweak,
		const char *indigits,
		char *outdigits)
{
	
	/* varibles */
	uint32_t digitslen = strlen(indigits);
	size_t llen = floor(digitslen/2);
	size_t rlen = digitslen - llen;
	//printf("u = %d, v = %d\n", llen, rlen);

	size_t bnum = ceil(ceil(rlen * log(10)/log(2))/8);
	//max_b: 4
	size_t d = 4*ceil(bnum/4) + 4;
	//max_d: 8
	unsigned char pblock[16] = {
		0x01, 0x02, 0x01,
		0x03, 0x04, 0x10,
		0x10,
		llen & 0xff};
	unsigned char qblock[16];

	char abuf[10];
	uint32_t a, b;
	// uint64_t A, B;


	/* check */
	if (!key) {
		fprintf(stderr, "%s: invalid argument\n", __FUNCTION__);
		return -1;
	}
	if (digitslen >= 19) {
		printf("digits len %d \n", digitslen);
		fprintf(stderr, "%s: input digits too long\n", __FUNCTION__);
		return -1;
	}
	int i = 0;
	for (i = 0; i < digitslen; i++) {
		if(!(indigits[i] >= '0' && indigits[i] <= '9')) {
			fprintf(stderr, "%s: input digits has non-numeric characters\n", __FUNCTION__);
			return -1;
		}
	}

	/* init */

	memset(abuf, 0, sizeof(abuf));
	memcpy(abuf, indigits, llen);
	
	a = atoi(abuf);
	b = atoi(indigits + llen);

	//printf("a = %d, b = %d\n", a, b);

	AES_KEY aes_key;

	if (AES_set_encrypt_key(key, keybits, &aes_key)) {
		fprintf(stderr, "%s: AES_set_encrypt_key() failed\n", __FUNCTION__);
		ERR_print_errors_fp(stderr);
		return -1;
	}

	memcpy(pblock + 8, &digitslen, 4);
	memcpy(pblock + 12, &TWEAK_LENGTH, 4);
	//printf("pblock has length %d\n", strlen(pblock));
	//print_chars(pblock);
	AES_encrypt(pblock, pblock, &aes_key);

	memset(qblock, 0, 16);
	int block = 0;
	for(block = 0 ; block < TWEAK_LENGTH; block++)
	{
		qblock[block] = tweak[block];
	}

	unsigned char rd = 0;
	for(rd = 0; rd<=9; rd++)
	{
		qblock[11] = rd;
		memcpy(qblock + 12, &b, sizeof(b));
		//print_chars(qblock);
		unsigned char rblock[16] = {0};
		for (i = 0; i < 16; i++) {
			rblock[i] = pblock[i] ^ qblock[i];
		}
		//
		// print_chars(rblock);
		//PRF processes only two blocks
		AES_encrypt(rblock, rblock, &aes_key);
		uint64_t y;
		//y = (uint64_t)rblock;
		memcpy(&y, rblock, sizeof(y));

		uint32_t m;
		if(rd % 2 == 0){
			m = llen;
		}
		else
			m = rlen;

		uint64_t c = ((uint64_t )a + y) % (uint64_t)pow(RADIX, m);

		a = b;
		b = (uint32_t )c;
		//printf("a = %d, b = %d\n", a, b);
	}
	//return results
	sprintf(outdigits, "%d", a);
	sprintf(outdigits + llen, "%d", b);
	return 1;
}

int ciphersql_fpe_decrypt_digits(
		const unsigned char *key,
		size_t keybits,
		const unsigned char *tweak,
		const char *indigits,
		char *outdigits)
{

	/* varibles */
	uint32_t digitslen = strlen(indigits);
	size_t llen = floor(digitslen/2);
	size_t rlen = digitslen - llen;
	//printf("u = %d, v = %d\n", llen, rlen);

	size_t bnum = ceil(ceil(rlen * log(10)/log(2))/8);
	//max_b: 4
	size_t d = 4*ceil(bnum/4) + 4;
	//max_d: 8
	unsigned char pblock[16] = {
			0x01, 0x02, 0x01,
			0x03, 0x04, 0x05,
			0x10,
			llen & 0xff};
	unsigned char qblock[16];

	char abuf[10];
	uint32_t a, b;
	// uint64_t A, B;


	/* check */
	if (!key) {
		fprintf(stderr, "%s: invalid argument\n", __FUNCTION__);
		return -1;
	}
	if (digitslen >= 19) {
		printf("digits len %d \n", digitslen);
		fprintf(stderr, "%s: input digits too long\n", __FUNCTION__);
		return -1;
	}
	int i = 0;
	for (i = 0; i < digitslen; i++) {
		if(!(indigits[i] >= '0' && indigits[i] <= '9')) {
			fprintf(stderr, "%s: input digits has non-numeric characters\n", __FUNCTION__);
			return -1;
		}
	}

	/* init */

	memset(abuf, 0, sizeof(abuf));
	memcpy(abuf, indigits, llen);

	a = atoi(abuf);
	b = atoi(indigits + llen);

	//printf("a = %d, b = %d\n", a, b);

	AES_KEY aes_key;

	if (AES_set_encrypt_key(key, keybits, &aes_key)) {
		fprintf(stderr, "%s: AES_set_encrypt_key() failed\n", __FUNCTION__);
		ERR_print_errors_fp(stderr);
		return -1;
	}

	memcpy(pblock + 8, &digitslen, 4);
	memcpy(pblock + 12, &TWEAK_LENGTH, 4);
	//print_chars(pblock);
	AES_encrypt(pblock, pblock, &aes_key);

	//memcpy(qblock, tweak, TWEAK_LENGTH);
	memset(qblock, 0, sizeof(qblock));
	int block = 0;
	for(block = 0 ; block < TWEAK_LENGTH; block++)
	{
		qblock[block] = tweak[block];
	}
	//print_chars(qblock);

	char rd = 9;
	for(rd = 9; rd>=0; rd--)
	{
		qblock[11] = (unsigned char)rd;
		memcpy(qblock + 12, &b, sizeof(b));
		print_chars(qblock);
		unsigned char rblock[16] = {0};
		for (i = 0; i < 16; i++) {
			rblock[i] = pblock[i] ^ qblock[i];
		}
		//PRF processes only two blocks
		AES_encrypt(rblock, rblock, &aes_key);
		uint64_t y;
		//y = (uint64_t)rblock;
		memcpy(&y, rblock, sizeof(y));

		uint32_t m;
		if(rd % 2 == 0){
			m = llen;
		}
		else
			m = rlen;

		uint64_t c = ((uint64_t )a - y) % (uint64_t)pow(RADIX, m);

		a = b;
		b = (uint32_t )c;
		//printf("a = %d, b = %d\n", a, b);
	}

	sprintf(outdigits, "%d", a);
	sprintf(outdigits + rlen, "%d", b);
	return 1;
}

int FPE_encrypt_digits(
		int algor,
		const unsigned char *key,
		size_t keylen,
		const unsigned char tweak[16],
		const char *indigits,
		char *outdigits)
{
	if(algor == CIPHERSQL_FF1)
		ciphersql_fpe_encrypt_digits(key, keylen, tweak, indigits, outdigits);

	return 1;
}

int FPE_decrypt_digits(
		int algor,
		const unsigned char *key,
		size_t keylen,
		const unsigned char tweak[16],
		const char *indigits,
		char *outdigits)
{
	if(algor == CIPHERSQL_FF1)
		ciphersql_fpe_decrypt_digits(key, keylen, tweak, indigits, outdigits);

	return 1;
}


int main()
{
	unsigned char key[16];
	size_t keybits = 128;
	unsigned char tweak[7] = "1533168";
	char *indigits = "15210832599";
	char outdigits[11] = {0};
	RAND_pseudo_bytes(key, 16);

	FPE_encrypt_digits(CIPHERSQL_FF1, key, keybits, tweak, indigits, outdigits);
	printf("encrypt over:");
	print_chars(outdigits);

	char out[11] = {0};

	FPE_decrypt_digits(CIPHERSQL_FF1, key, keybits, tweak, outdigits, out);
	printf("decrypt over:");
	print_chars(out);

	return 0;
}

/*
static int pseudo_random_func(
		int cipher,
		const unsigned char *key,
		size_t keybits,
		const unsigned char *inblocks,
		int nblocks,
		unsigned char *outblock)
{
	sms4_key_t sms4_key;
	unsigned char block[16];

	if (cipher != CIPHERSQL_AES && cipher != CIPHERSQL_SM4) {
		return -1;
	}

	memset(outblock, 0, sizeof(block));

	for (i = 0; i < nblocks; i++) {

		for (j = 0; j < sizeof(block); j++)
			block[j] ^= inblock[j];


		sms4_encrypt(sms4_key, block, block);

	}


	memcpy(outblock, block, sizeof(block));

	return 0;
}
*/