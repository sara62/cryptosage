import hashlib

def digest(msg):
	msg = str(msg)
	return Integer('0x' + hashlib.sha1(msg).hexdigest())

