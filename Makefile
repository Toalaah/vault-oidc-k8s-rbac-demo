.POSIX:

bootstrap:
	@sh ./bootstrap.sh

clean:
	@rm ./rootCA.pem
	@rm ./vault/certs/*.{crt,key}
	@docker volume rm kube-vault-oidc_vault-data kube-vault-oidc_vault-misc
	@kind delete cluster --name=kind
