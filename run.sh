#!/bin/bash -x

cd 01_hetzner

terraform init
terraform plan
terraform apply -auto-approve
sleep 30
./terraform-swarm-inventory.py --accept
cd ..

cd 02_sw_setup
ansible-playbook -i ../01_hetzner/terraform-swarm-inventory.py --key-file $HOME/.ssh/github_actions cluster_setup.yml
cd ..

cd 03_stacks
ansible-playbook -i ../01_hetzner/terraform-swarm-inventory.py --key-file $HOME/.ssh/github_actions deploy_trackdirect.yml
cd ..
