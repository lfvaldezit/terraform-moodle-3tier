
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

# --------------- ALB ----------------- #

# https://docs.moodle.org/500/en/Apache#Load_Balancer_Hints_(AWS)

listener_rule = [ 
  {path_pattern = ["*/.*", "*/upgrade.txt", "*/db/install.xml", "*/README.md", "*/composer.json"],
  type = "fixed-response",
  status_code = 404,
  content_type = "text/html",
  message_body = "<html>\n<head><title>404 Not Found</title></head>\n<body>\n<center><h1>404 Not Found</h1></center>\n<hr>\n</body>\n</html>"}, 

  {path_pattern = ["*/composer.json", "*/Gruntfile.js", "*.lock", "*/environtment.xml", "*/readme.txt"],
  type = "fixed-response",
  status_code = 404,
  content_type = "text/html",
  message_body = "<html>\n<head><title>404 Not Found</title></head>\n<body>\n<center><h1>404 Not Found</h1></center>\n<hr>\n</body>\n</html>"},
  
  {path_pattern = ["*/fixtures/*", "*/behat/*", "*/phpunit.xml", "*/health.html"],
  type = "fixed-response",
  status_code = 404,
  content_type = "text/html",
  message_body = "<html>\n<head><title>404 Not Found</title></head>\n<body>\n<center><h1>404 Not Found</h1></center>\n<hr>\n</body>\n</html>"}]

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