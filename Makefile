SSH_KEY?="keys/id_rsa"
ALLOWED_IPS?="10.100.100.2/32"
PEER_ALLOWED_IPS?="0.0.0.0/0"
CLOUD_PROVIDER?="aws"
WG_CONFIG?="${PWD}/${CLOUD_PROVIDER}/wg0-client.conf"

all: plan

init:
	@cd $(CLOUD_PROVIDER) && \
	terraform init

plan: gen-sshkey
	@cd $(CLOUD_PROVIDER) && \
	terraform plan

destroy-plan:
	@cd $(CLOUD_PROVIDER) && \
	terraform plan -destroy

apply: gen-sshkey
	@cd $(CLOUD_PROVIDER) && \
	terraform apply -auto-approve

destroy:
	@cd $(CLOUD_PROVIDER) && \
	terraform destroy -auto-approve

console:
	@echo ":: Connecting to SSH_HOST=${SSH_HOST}"
	@cd $(CLOUD_PROVIDER) && \
	ssh -i $(SSH_KEY) ${SSH_HOST}

# generate cloud ssh keys
gen-sshkey:
	@cd $(CLOUD_PROVIDER) && \
		test -f keys/id_rsa \
		|| (echo "Creating ssh key '$(CLOUD_PROVIDER)/$(SSH_KEY)' ..."; \
		ssh-keygen -b 2048 -t rsa -f $(SSH_KEY) -q -N ""; \
		ssh-keygen -lf $(SSH_KEY).pub; \
		ssh-keygen -l -E md5 -f $(SSH_KEY).pub)

# generate client peer wireguard keys
gen-peer-keys:
	@cd $(CLOUD_PROVIDER) && \
		test -f keys/client_private_key \
		|| wg genkey | tee keys/client_private_key | wg pubkey > keys/client_public_key

add-peer: gen-peer-keys
	@cd $(CLOUD_PROVIDER) && \
		ssh -i $(SSH_KEY) ${SSH_HOST} "sudo wg set wg0 peer $(shell cat ${CLOUD_PROVIDER}/keys/client_public_key) allowed-ips $(ALLOWED_IPS)"

wg-config: gen-peer-keys
	@cd $(CLOUD_PROVIDER) && \
		../scripts/install-wireguard.sh -c

wg-up: wg-config
	wg-quick up $(WG_CONFIG) 

wg-down:
	wg-quick down $(WG_CONFIG)
