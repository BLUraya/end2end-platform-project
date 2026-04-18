# InfinityLabs R&D - DevOps Home Assignment

## 🎯 Project Overview
This project is an end-to-end DevOps solution for deploying a Node.js application. It includes provisioning cloud infrastructure on AWS, configuring servers automatically, and running a complete CI/CD pipeline using GitLab and HashiCorp Vault.

The architecture is built with a "Production-Ready" mindset, focusing on security, automation, and data persistence.

![Architecture Diagram](./architecture.png)
*(Note: Place your architecture diagram image in the repository and update the path above)*

## 🛠️ Tech Stack
* **Cloud Provider:** AWS
* **Infrastructure as Code (IaC):** Terraform
* **Configuration Management:** Ansible
* **CI/CD:** GitLab CI/CD, GitLab Container Registry
* **Container Orchestration:** Amazon EKS (Kubernetes)
* **Deployment:** Helm
* **Secrets Management:** HashiCorp Vault
* **Application:** Node.js (Express) & Docker

## 🏗️ Architecture & Key Features

### 1. Infrastructure (Terraform)
* **Secure Network:** Everything runs in a VPC with Private Subnets. External access is only allowed through an Application Load Balancer (ALB) in the Public Subnet.
* **No SSH Keys (Security):** EC2 instances (GitLab and Vault) are accessed securely using AWS Systems Manager (SSM) instead of opening port 22.
* **Storage Separation:** Compute and Data are separated. GitLab and Vault use attached external EBS volumes for persistent data. If a machine dies, the data is safe.
* **Dynamic Inventory:** Terraform automatically generates the Ansible `inventory.ini` file with the newly created AWS instance IDs and S3 bucket details.

### 2. Configuration (Ansible)
* Connects to the AWS instances via SSM plugin.
* Formats and mounts the external EBS volumes.
* Installs Docker and Docker Compose.
* Deploys GitLab and Vault containers.

### 3. CI/CD Pipeline (GitLab CI)
A push-based pipeline triggered on code changes to the `app/` directory:
1. **Build:** Builds the Docker image using Docker-in-Docker (DinD).
2. **Test:** Runs the container locally and uses `curl` to check the `/health` endpoint.
3. **Push:** Pushes the verified image to the GitLab Container Registry.
4. **Deploy:** Uses a custom Helm chart to deploy the app to the EKS cluster.

### 4. Secrets Management (Vault)
* Vault stores a specific secret (`Key: Assignment, Value: Complete`).
* The pipeline authenticates to Vault using a specific CI/CD Policy and Token (Authorization & Authentication).
* **Security Best Practice:** The secret is NOT built into the Docker image. Instead, the pipeline fetches the secret and creates a Kubernetes `Secret` object. The application reads it as an Environment Variable at runtime.

## 📂 Repository Structure

.
├── ansible/               # Ansible playbooks and roles for configuration
│   ├── roles/             # Roles for docker, gitlab, and vault
│   └── site.yml           # Main playbook
├── app/                   # Application and CI/CD code
│   ├── chart/             # Helm chart for deploying the app
│   ├── .gitlab-ci.yml     # The GitLab CI/CD pipeline definition
│   ├── Dockerfile         # Multi-stage Dockerfile
│   └── server.js          # Node.js application code
├── terraform/             # Terraform infrastructure code
│   ├── modules/           # VPC, ALB, Compute (EC2), and EKS modules
│   └── main.tf            # Main Terraform file
└── README.md              # This file


## 🚀 How to Run the Project

**Step 1: Provision Infrastructure**
cd terraform
terraform init
terraform apply -auto-approve

**Step 2: Configure Servers**
cd ../ansible
ansible-playbook -i inventory.ini site.yml

**Step 3: Setup Vault & GitLab Runner**
1. Access Vault via the ALB URL (Port 8200), initialize it, and create the secret engine and KV secret (`secret/data/myapp`).
2. Generate a Vault Token with the CI policy.
3. Access GitLab via the ALB URL (Port 80) and get the Runner Registration Token.
4. Connect to EKS (`aws eks update-kubeconfig...`) and install the GitLab Runner using Helm.

**Step 4: Run the Pipeline**
1. Push the `app/` directory to your GitLab repository.
2. Ensure you have added the required CI/CD Variables in GitLab (`VAULT_ADDR`, `VAULT_CI_TOKEN`).
3. The pipeline will start automatically and deploy the app to EKS!