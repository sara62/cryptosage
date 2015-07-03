import hashlib

def digest(msg):
	return Integer('0x' + hashlib.sha1(msg).hexdigest())

