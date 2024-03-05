.POSIX:

bootstrap:
	@sh ./bootstrap.sh

clean:
	@rm ./rootCA.pem
	@rm ./vault/certs/*.{crt,key}
