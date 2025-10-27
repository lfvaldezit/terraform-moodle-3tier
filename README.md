# Moodle 3-Tier Infrastructure Design

## 🏗️ Architecture

<img width="800" height="500" alt="image" src="https://raw.githubusercontent.com/lfvaldezit/terraform-moodle-3tier/main/image.png" />


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
* **Parameter Store**: It manages Moodle’s configuration parameters.

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

- Open the terraform.example.tfvars file and complete all the `Phase 2` variables according to your environment configuration.
- Open the root `main.tf` file.
- Uncomment the entire `Phase 2` section and comment out the `module "ec2"` block that is no longer needed.
- Run `terraform init --upgrade`.
- Run `terraform apply` to deploy the changes.

## 📝 tfvars file

```
## PHASE 1

name = "moodle-test"

# --------------- VPC ----------------- #

cidr_block = "192.168.0.0/16"

public_subnets = [{ name = "moodle-test-sn-pub-A", cidr_block = "192.168.0.0/24", az = "us-east-1a" },
{ name = "moodle-test-sn-pub-B", cidr_block = "192.168.3.0/24", az = "us-east-1b" }]

app_subnets = [{ name = "moodle-test-sn-app-A", cidr_block = "192.168.1.0/24", az = "us-east-1a" },
{ name = "moodle-test-sn-app-B", cidr_block = "192.168.4.0/24", az = "us-east-1b" }]

data_subnets = [{ name = "moodle-test-sn-db-A", cidr_block = "192.168.2.0/24", az = "us-east-1a" },
{ name = "moodle-test-sn-db-B", cidr_block = "192.168.5.0/24", az = "us-east-1b" }]

# --------------- EC2 ----------------- #

ami_id        = "ami-08982f1c5bf93d976"
instance_type = "t3.micro"

# --------------- RDS ----------------- #

engine           = "mariadb"
engine_version   = "10.11.10"
db_instance_type = "db.t3.micro"
db_name          = "moodle"
db_username      = "moodleuser"
db_pass          = "moodlepass123!"

# --------------- Moodle ----------------- #

admin_user  = "admin"
admin_pass  = "Admin123!"
admin_email = "admin@example.com"

# --------------- ELASTICACHE ----------------- #

node_type = "cache.t2.micro"

### PHASE 2

# --------------- ASG ----------------- #

ami_id_ASG        = "ami-xxxxxxxxxxxxxxxxx"
health_check_path = "/moodle/health.html"
min_size          = 1
max_size          = 2
desired_capacity  = 1

autoscaling_policy = [
{ name = "simple-scale-up", scaling_adjustment = 1, cooldown = 300 },
{ name = "simple-scale-down", scaling_adjustment = -1, cooldown = 300 }]


cloudwatch_metric_alarm = [
{ name = "cpu-util-up-75%", threshold = 75, alarm_description = "Trigger scale out when CPU > 75%", 
comparison_operator = "GreaterThanThreshold"},
{ name = "cpu-util-up-25%", threshold = 25, alarm_description = "Trigger scale out when CPU < 25%", 
comparison_operator = "LessThanThreshold"}]

# --------------- Cloudflare ----------------- #

domain_name = "example.com"
record_name = "@"
api_token   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
zone_id     = "xxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## 🧪 Testing

- Select the single instance in the `EC2 Auto Scaling Group (ASG)`.
- Connect to it using AWS `Session Manager`.
- Run the following `stress command` — a utility that generates artificial system load to test performance and scaling behavior. The Auto Scaling Group will detect the high CPU utilization and automatically launch EC2 instances based on the launch template and auto scaling policies.

```bash
stress -c 2 -v -t 3000
```

## ✅ Outputs

- `RDS-ENDPOINT`: The hostname of the RDS instance.
- `REDIS-ENDPOINT`: The hostname of the REDIS primary node.

## 📁 Project Structure

```
├── locals.tf       
├── main.tf
├── outputs.tf              
├── providers.tf
├── README.md
├── terraform.example.tfvars 
├── variables.tf
├── version.tf
├── image.png 
├── .gitignore                   
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
