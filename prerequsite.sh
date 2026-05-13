#!/bin/bash

#install unzip
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y unzip

#install python
#sudo apt install -y python3 python3-pip

#Install Ansible
#sudo apt install -y ansible

#install terraform
sudo apt update -y
curl -fsSL https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip -o terraform.zip
unzip terraform.zip
sudo mv terraform /usr/local/bin/
terraform -version

# Install AWS CLI
sudo apt install awscli -y


# Install kubectl
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# chmod +x kubectl
# sudo mv kubectl /usr/local/bin/
# kubectl version --client


#verison check
echo "Python version:"
python3 --version
echo "Ansible version:"
ansible --version
echo "Terraform version:"
terraform --version
echo "AWS CLI version:"
aws --version
echo "kubectl version:"
kubectl version --client

#configure AWS CLI
echo "Please configure your AWS CLI with your credentials and default region. output = json"
aws configure
