# Moodle 3-Tier Infrastructure Design

## 🏗️ Architecture

<img width="800" height="500" alt="image" src="https://raw.githubusercontent.com/lfvaldezit/terraform-moodle-3tier/main/image.png" />

## 📦 Stack Overview

* **VPC**: Isolated network for deploying AWS resources.
* **NAT Gateway**: Enables outbound Internet access for private subnets securely.
* **Internet Gateway**: Connects public subnets to the Internet.
* **EC2 Instances**: VM used to generate AMI for the moodle application.
* **Application Load Balancer (ALB)**: Distributes incoming web traffic across multiple EC2 instances.
* **Auto Scaling Group (ASG)**: Automatically adjusts the number of EC2 instances based on demand.
* **Amazon Elastic File Systems**: Scalable shared storage for moodledata.
* **Relational Database**: Managed MySQL/PostgreSQL database for Moodle data.
* **Amazon ElastiCache (Redis)**: Stores moodle sessions and applications caches.
* **AMI**: Pre-configured image for consistent Moodle deployments.
* **AWS Systems Manager Parameter Store**: It manages Moodle’s configuration parameters.
* **AWS Certificate Manager**: Centralized and encrypted configuration storage.
* **CloudFlare**: Manage DNS records for the domain.

## 📁 Project Structure

```

├── .gitignore
├── image.png              
├── locals.tf       
├── main.tf
├── outputs.tf              
├── providers.tf
├── README.md
├── terraform.example.tfvars 
├── variables.tf
├── version.tf                    
└── modules/
    └── auto-scaling/     
    └── cloudflare/     
    └── ec2/     
    └── efs/     
    └── elasticache/
    └── load-balancer/
    └── parameter-store/
    └── rds/
    └── security-group/
    └── vpc/     

```

## 🚀 Deployment

### PHASE 1

- In the first phase of the `Moodle 3-tier architecture design`, we pre-provision a single EC2 instance using a user data script to automate the configuration process.
- Once the pre-provisioned EC2 instance is running, access the Moodle site at http://<PUBLIC_IP>/moodle to complete the installation.
- Log in. Navigate to `Site Administration → Plugins → Caching → Configuration`.
- Under ` Installed cache stores → Redis, click Add instance`.
- Use the following format for the Redis connection: `redis_url:6379`.
- More about [Redis cache store](https://docs.moodle.org/501/en/Redis_cache_store).
- From the EC2 console, select your instance, go to `Actions → Images and templates → Create image`.
- Copy the AMI ID generated and paste it into the `ami_id_ASG` variable within your terraform.example.tfvars file — this AMI will be used later in `Phase 2`.

### PHASE 2

- Open the terraform.example.tfvars file and complete all the `Phase 2` variables according to your environment configuration
- Open the root `main.tf` file.
- Uncomment the entire `Phase 2` section and comment out the `module "ec2"` block that is no longer needed
- Run `terraform init --upgrade`
- Run `terraform apply` to deploy the changes.

## 🧪 Testing

- Select the single instance in the `EC2 Auto Scaling Group (ASG)`.
- Connect to it using AWS `Session Manager`.
- Run the following `stress command` — a utility that generates artificial system load to test performance and scaling behavior. The Auto Scaling Group will detect the high CPU utilization and automatically launch a new EC2 instance based on the launch template.

```bash
stress -c 2 -v -t 3000
```
## ✅ Outputs

- `RDS-ENDPOINT`: The hostname of the RDS instance.
- `REDIS-ENDPOINT`: The hostname of the REDIS primary node.
