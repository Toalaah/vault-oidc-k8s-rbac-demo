.POSIX:

bootstrap:
	@sh ./bootstrap.sh

clean:
	@rm ./rootCA.pem -f
	@rm ./vault/certs/*.{crt,key} -f
	@docker volume rm kube-vault-oidc_vault-data kube-vault-oidc_vault-misc -f
	@kind delete cluster --name=kind
