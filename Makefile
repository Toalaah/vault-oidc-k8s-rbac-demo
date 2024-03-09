.POSIX:

vault:
	./scripts/gen-cert.sh
	./scripts/make-vault.sh

cluster:
	./scripts/gen-cert.sh
	kind create cluster --kubeconfig=./KUBECONFIG --config=./cluster.yml
	docker exec kind-control-plane update-ca-certificates
	docker network connect --alias vault.local kind vault

terraform:
	cd ./terraform/vault && terraform init && terraform apply -auto-approve

cert:
	./scripts/gen-cert.sh

kube-user:
	kubectl config set-credentials "$(USER)" \
		--exec-api-version=client.authentication.k8s.io/v1beta1 \
		--exec-command=bash \
		--exec-arg="$(shell pwd)/get-oidc-token.sh" \
		--exec-arg="$(ROLE)"

up:
	docker-compose up -d

down:
	docker-compose down

clean:
	rm -f ./rootCA.pem ./KUBECONFIG ./vault/certs/*.{crt,key}
	docker volume rm kube-vault-oidc_vault-data kube-vault-oidc_vault-misc -f
	kind delete cluster --name=kind
	docker network rm kind

.PHONY: vault cluster terraform cert kube-user up down clean
