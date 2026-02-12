ANSIBLE_DIR := ansible
TERRAFORM_DIR := terraform
INVENTORY := inventory/aws_ec2.yaml

.PHONY: terraform-init terraform-plan terraform-apply terraform-destroy terraform-output
.PHONY: provision provision-backup provision-database provision-monitoring provision-troubleshooting
.PHONY: backup-postgres health-check ping encrypt-secrets decrypt-secrets

terraform-init:
	cd $(TERRAFORM_DIR) && terraform init

terraform-plan: terraform-init
	cd $(TERRAFORM_DIR) && terraform plan

terraform-apply: terraform-init
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

terraform-destroy:
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

terraform-output:
	cd $(TERRAFORM_DIR) && terraform output

provision:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/setup-server.yaml -i $(INVENTORY)

provision-backup:
	@test -f $(SECRETS_ENC) || (echo "No $(SECRETS_ENC) found"; exit 1)
	@SECRETS_DEC=$$(mktemp -t linux-ops-secrets-XXXXXX.yaml); \
	trap 'rm -f $$SECRETS_DEC' EXIT; \
	GPG_TTY=$$(tty) SOPS_GPG_EXEC="$(SOPS_GPG_EXEC)" sops -d $(SECRETS_ENC) > $$SECRETS_DEC && \
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/setup-backup.yaml -i $(INVENTORY) -e "secrets_dec_file=$$SECRETS_DEC"

provision-database:
	@test -f $(SECRETS_ENC) || (echo "No $(SECRETS_ENC) found"; exit 1)
	@SECRETS_DEC=$$(mktemp -t linux-ops-secrets-XXXXXX.yaml); \
	trap 'rm -f $$SECRETS_DEC' EXIT; \
	GPG_TTY=$$(tty) SOPS_GPG_EXEC="$(SOPS_GPG_EXEC)" sops -d $(SECRETS_ENC) > $$SECRETS_DEC && \
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/setup-database.yaml -i $(INVENTORY) -e "secrets_dec_file=$$SECRETS_DEC"

provision-monitoring:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/setup-monitoring-agent.yaml -i $(INVENTORY)

provision-troubleshooting:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/setup-troubleshooting.yaml -i $(INVENTORY)

backup-postgres:
	cd $(ANSIBLE_DIR) && ansible all -i $(INVENTORY) -m command -a "/opt/backup/scripts/postgres-backup-full.sh" --become

health-check:
	cd $(ANSIBLE_DIR) && ansible all -i $(INVENTORY) -m shell -a "/opt/monitoring/health-check.sh" --become

ping:
	cd $(ANSIBLE_DIR) && ansible all -i $(INVENTORY) -m ping

SECRETS_PLAIN := secrets/sops/secrets.yaml
SECRETS_ENC := secrets/sops/secrets.enc.yaml
SOPS_CONFIG := secrets/sops/.sops.yaml
SOPS_GPG_EXEC ?= $(shell which gpg 2>/dev/null || true)

encrypt-secrets:
	@test -f $(SECRETS_PLAIN) || (echo "Create $(SECRETS_PLAIN) from secrets.yaml.example first"; exit 1)
	sops --config $(SOPS_CONFIG) -e $(SECRETS_PLAIN) > $(SECRETS_ENC)
	@echo "Encrypted: $(SECRETS_ENC)"

decrypt-secrets:
	@test -f $(SECRETS_ENC) || (echo "No $(SECRETS_ENC) found"; exit 1)
	GPG_TTY=$$(tty) SOPS_GPG_EXEC="$(SOPS_GPG_EXEC)" sops -d $(SECRETS_ENC)
