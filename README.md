# Moodle 3-Tier Infrastructure Design

## 🏗️ Architecture

<img width="800" height="500" alt="image" src="https://github.com/lfvaldezit/terraform-moodle-3tier/blob/main/image.png" />

## 🌐 Stack Overview

* **VPC**: Isolated network for deploying AWS resources.
* **NAT Gateway**: Enables outbound Internet access for private subnets securely.
* **Internet Gateway**: Connects public subnets to the Internet.
* **EC2 Instances**: VM used to generate AMI for the moodle application.
* **Application Load Balancer (ALB)**: Distributes incoming web traffic across multiple EC2 instances.
* **Auto Scaling Group (ASG)**: Automatically adjusts the number of EC2 instances based on demand.
* **Elastic File Systems**: Scalable shared storage for moodledata.
* **Relational Database**: Managed MySQL/PostgreSQL database for Moodle data.
* **Elasticache (Redis)**: Stores moodle sessions and applications caches.
* **AMI**: Pre-configured image for consistent Moodle deployments.
* **AWS Systems Manager Parameter Store**: It manages Moodle’s configuration parameters.
* **AWS Certificate Manager**: Centralized and encrypted configuration storage.
* **CloudFlare**: Manage DNS records for the domain.

