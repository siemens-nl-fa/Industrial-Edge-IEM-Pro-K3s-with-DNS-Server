# Setting Up Industrial Edge Management on K3s
  - [Description](#description)
    - [Overview](#overview)
    - [General task](#general-task)
  - [Requirements](#requirements)
    - [Prerequisites](#prerequisites)
    - [Used components](#used-components)
  - [Installation](#installation)    
  - [Usage](#usage)
  - [Documentation](#documentation)
  - [Contribution](#contribution)
  - [License and Legal Information](#license-and-legal-information)
  - [Disclaimer](#disclaimer)

<br>

## Description
This version of the IEM allows the setup with kubernetes (k3s) for ubuntu.

### Overview
This tutorial guides you through the process of setting up and installing Industrial Edge Management (IEM) on a K3s cluster running on an Ubuntu machine. The instructions covers the happy-flow. And takes the necessary steps, from setting up prerequisites to deploying and configuring the IEM. 

### General task
The goal is to create a K3s cluster, install IEM, and set up necessary certificates and namespaces to ensure a fully functional Industrial Edge environment.

<br>

## Requirements

### Prerequisites
Ensure you have the following in place before proceeding:

- A working Ubuntu machine with K3s installed [Installation guide](https://docs.eu1.edge.siemens.cloud/get_started_and_operate/industrial_edge_management/k8s/getting_started/setup_cluster/k3s/setup-k3s.html)
- Access to Industrial Edge Hub for downloading resources.
- This git's project folder downloaded.

### Used components
- K3s Kubernetes distribution
- Industrial Edge Hub
- ieprovision tool
- Generated certificates for Kubernetes
<br><br>

## Installation

### 1 Generate certificates
1. Get the files from docs.eu1.edge.siemens.cloud or use the 'Certificates' folder
    * Option 1: <br>
Get Started and operate > Industrial Edge management > IEM Pro > Getting Started > Setup Cluster > Using K3s > Scroll down to certificates code example and take 'Generate certificate by providing IP address'.
    * Option 2: <br>
Use these files or use the already existing files in the 'Certificates' Folder.

2. Give write access to gen_with_ca_IP.sh and Generate Certificates
```bash
sudo chmod +x ./Certificates/gen_with_ca.sh
./Certificates/gen_with_ca.sh iem.local
```

3. Now your created certificates are in the folder '/Certificates/out' these will be used later.

<br>

### 2 Install the Ieprovision tool
1. Download the ieprovision tool from the [iehub.eu1.edge.siemens.cloud](https://iehub.eu1.edge.siemens.cloud)
2. Extract the folder and place the file 'ieprovision' in the Provision Folder
Extract the ieprovision to the ./Provision folder.
3. Install the file as Alias

```bash
sudo install ./Provision/ieprovision /usr/local/bin/
```
4. The ieprovision will be used as command line tool to install the management

<br>

### 3 Create k8s namespace for the managment
```bash
kubectl create namespace iem
```

<br>

### 4 Give permissions for k3s (kubectl)
Run the following commands
```bash 
mkdir ~/.kube/
sudo cp -a /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown <your-user:your-group> ~/.kube/config
```

<br>

### 5 Create onboarding file in the IEHUB
1. Navigate to IEM Instances and click ```Create new IEM Instance```
2. Fill in the name and save
3. Download the onboarding file
4. place in the ```./Onboarding``` folder and rename to ```configuration.json```


<br>

### 6 Install the IEM on the kubernetes (k3s) Cluster
1. Run
```bash
 ieprovision install ./Onboarding/configuration.json \
 --set global.hostname=iem.local \
 --namespace iem \
 --values ./Kubernetes/template.yaml \
 --set global.certChain="$(cat ./Certificates/out/certChain.crt | base64 -w 0)" \
 --set global.gateway.ingress.enabled=false -v
```

2. Wait for the installation to finish, this can take some time.
3. The result should look like this
```bash
        NOTES:
        CHART NAME: application-management-service
        CHART VERSION: v1.7.6
        APP VERSION: v1.7.6

        ** Please be patient while the chart is being deployed **

        IEM: https://iem.local/

        NAMESPACE: iem

        KEYCLOAK_CUSTOMER_REALM_ADMIN: admin
        KEYCLOAK_CUSTOMER_REALM_ADMIN_PASSWORD: Password123!
```

<br>

### Configure Ingress for IP based setup
1. Get the service name of Industrial Edge Gateway
```bash
kubectl get svc --no-headers -o custom-columns=":metadata.name" -n iem | grep gateway-proxy
```
2. Copy your output: `123456-gateway-proxy` (example)
3. And paste in the `./Kubernetes/ingress.yaml` replace the `<name-gateway-proxy>`
4. Deploy Ingress 
```bash
kubectl apply -f ./Kubernetes/ingress.yaml
```
<br>

###  Deploy the secret for self signed certificates
1. Run command
```bash
kubectl -n iem create secret tls iemcert --cert=./Certificates/out/myCert.crt --key=./Certificates/out/myCert.key
```

<br>

### Install bind9 for ubuntu
1. Install bind9
```bash
sudo apt update
sudo apt install bind9
```

2. Edit the following file

```bash 
sudo nano /etc/bind/named.conf.local
```
3. And add the following text

```bash
zone "iem.local" {
    type master;
    file "/etc/bind/db.iem.local";
};
```
4. Open the file ```DNS/db.iem.local``` and change ```<IP>``` to the IP of ubuntu, and save.

5. Move the file db.iem.local file to the bind folder

6. Restart the DNS Server 
```bash
sudo systemctl restart bind9
```

7. Check if iem.local exists.
```bash
nslookup iem.local
```

The result should look something like this:
```bash
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   iem.local
Address: 192.168.0.100
```




### Access the management
1. Open the browser `https://iem.local`
2. Login with: username: `admin`, password: `Password123!`    

<br><br>

## Usage
All the command line commands should be run in the main folder of this folder.
For further use please refer to the [documentation](https://docs.eu1.edge.siemens.cloud/get_started_and_operate/industrial_edge_management/k8s/index.html)

<br>

## Documentation
* [Industrial Edge Hub](https://iehub.eu1.edge.siemens.cloud/#/documentation)
* [Industrial Edge Forum](https://forum.industrial-edge.siemens.cloud)
* [Industrial Edge Documentation](https://docs.industrial-edge.siemens.cloud/)
* [Industrial Edge landing page](https://new.siemens.com/global/en/products/automation/topic-areas/industrial-edge/simatic-edge.html)
* [Industrial Edge GitHub page](https://github.com/industrial-edge)

<br>

## Contribution
We welcome contributions! Please report any issues, unclear documentation, or other problems in the Issues section of this repository. Additionally, you can propose changes through Pull Requests.

<br>

## License and Legal Information
Read license

<br>

## Disclaimer
This tutorial includes guidance for downloading and setting up third-party software. By following this tutorial, you accept the risks associated with using third-party software and agree to comply with all applicable licenses.
