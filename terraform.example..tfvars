
### PHASE 1

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

# --------------- Cloudflare ----------------- #

domain_name = "example.com"
record_name = "@"
api_token   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
zone_id     = "xxxxxxxxxxxxxxxxxxxxxxxxxx"