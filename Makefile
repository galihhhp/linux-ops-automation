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
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/setup-backup.yaml -i $(INVENTORY)

provision-database:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/setup-database.yaml -i $(INVENTORY)

provision-monitoring:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/setup-monitoring-agent.yaml -i $(INVENTORY)

provision-troubleshooting:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/setup-troubleshooting.yaml -i $(INVENTORY)

backup-postgres:
	cd $(ANSIBLE_DIR) && ansible all -i $(INVENTORY) -m shell -a "source /etc/default/backup 2>/dev/null; /opt/backup/scripts/postgres-backup.sh" --become

health-check:
	cd $(ANSIBLE_DIR) && ansible all -i $(INVENTORY) -m shell -a "/opt/monitoring/health-check.sh" --become

ping:
	cd $(ANSIBLE_DIR) && ansible all -i $(INVENTORY) -m ping

