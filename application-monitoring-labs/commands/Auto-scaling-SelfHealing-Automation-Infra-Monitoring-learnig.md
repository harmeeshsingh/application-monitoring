1 curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
2  unzip awscliv2.zip
3  sudo apt install unzip
4  unzip awscliv2.zip
5  sudo ./aws/install
6  aws --version
7  aws configure
8  wget https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip
9  unzip terraform_1.8.5_linux_amd64.zip
10  sudo mv terraform /usr/local/bin/
11  terraform -v
12  pip install locust
13  sudo apt install -y pipx python3-full
14  pipx ensurepath
15  exec $SHELL
16  pipx install locust
17  locust --version
18  vi locustfile.py
19  cat locustfile.py 
20  aws --version
21  mkdir self-healing-terraform
22  cd self-healing-terraform
23  vi main.tf
24  cat -n main.tf 
25  terraform init
26  terraform validate
27  vi main.tf
28  terraform validate
29  terraform plan
30  terraform apply
31  cd ..
32  locust -f locustfile.py
33  vi locustfile.py 
34  cat locustfile.py 
35  locust -f locustfile.py