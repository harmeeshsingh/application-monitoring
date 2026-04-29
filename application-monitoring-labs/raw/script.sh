#!/bin/bash

# sudo useradd --no-create-home --shell /bin/false prometheus
# sudo mkdir /etc/prometheus
# sudo mkdir /var/lib/prometheus
# sudo chown prometheus:prometheus /var/lib/prometheus

# wget https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz
# tar -xvf prometheus-2.46.0.linux-amd64.tar.gz

# cd prometheus-2.46.0.linux-amd64
# sudo mv console* /etc/prometheus
# sudo mv prometheus.yml /etc/prometheus
# sudo chown -R prometheus:prometheus /etc/prometheus
# #Now, Move the binaries and set the owner:
# sudo mv prometheus /usr/local/bin/
# sudo chown prometheus:prometheus /usr/local/bin/prometheus

# cd /tmp
# wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
# Unzip the downloaded the file using below command
# sudo tar xvfz node_exporter-*.*-amd64.tar.gz

# #Move the binary file of node exporter to /usr/local/bin location
# sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin/

# #Create a node_exporter user to run the node exporter service
# sudo useradd -rs /bin/false node_exporter
# sudo vi /etc/systemd/system/node_exporter.service


############################################################################

#Now lets Install Grafana for wonderful dashboards and data visualization for monitoring systems, servers, services, etc
#dd the Grafana GPG key in Ubuntu using wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
#Next, add the Grafana repository to your APT sources:
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
#Refresh your APT cache to update your package lists:
sudo apt update
#You can now proceed with the installation:
sudo apt install grafana 

#[ Note: if any issue while installing grafana: run below command: 
sudo apt update 
sudo apt install -y software-properties-common 
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main" 
sudo wget -q -O /usr/share/keyrings/grafana.key https://packages.grafana.com/gpg.key 

echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null 
sudo apt update 

sudo apt install grafana -y 
]

#Once Grafana is installed, use systemctl to start the Grafana server:
sudo systemctl start grafana-server

#ext, verify that Grafana is running by checking the service’s status:
sudo systemctl enable grafana-server
sudo systemctl status grafana-server