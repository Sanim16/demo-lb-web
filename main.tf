data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id

  vpc_security_group_ids = [aws_security_group.main.id]

  associate_public_ip_address = true

  availability_zone = "us-east-1a"
  key_name          = "terraformkey"

  tags = {
    Name = "main"
  }

  iam_instance_profile = "test_profile"

  depends_on = [aws_internet_gateway.main]

  user_data = file("bootstrap.sh")
}

# resource "aws_network_interface" "main" {
#   subnet_id       = aws_subnet.main.id
#   security_groups = [aws_security_group.main.id]

#   attachment {
#     instance     = aws_instance.main.id
#     device_index = 1
#   }
# }

# resource "aws_eip" "main" {
#   domain = "vpc"

#   instance                  = aws_instance.main.id
#   depends_on                = [aws_internet_gateway.main]
# }

data "aws_ami" "base_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "amazon" {
  ami           = data.aws_ami.base_ami.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id

  vpc_security_group_ids = [aws_security_group.main.id]

  associate_public_ip_address = true

  availability_zone = "us-east-1a"
  key_name          = "terraformkey"

  tags = {
    Name = "main"
  }

  iam_instance_profile = "test_profile"

  depends_on = [aws_internet_gateway.main]

  # user_data = file("bootstrap.sh")
}

# locals {
#   variable1      = "admin"
#   variable2      = "your_password"
#   db_address     = aws_db_instance.some-db.address
# }

# resource "aws_instance" "web_01" {

#   user_data = base64encode(templatefile("bootstrap1.sh", {
#     db_address     = local.db_address
#     admin_user     = local.variable1
#     admin_password = local.variable2
#   }))

# }

# resource "aws_db_subnet_group" "aws_3_tier_subnet_group" {
#   name       = "aws_3_tier_subnet_group"
#   subnet_ids = [aws_subnet.Private-DB-Subnet-AZ-1.id, aws_subnet.Private-DB-Subnet-AZ-2.id]

#   tags = {
#     Name = "AWs 3 Tier DB subnet group"
#   }
# }

# resource "aws_rds_cluster" "default" {
#   cluster_identifier      = "database-1"
#   engine                  = "aurora-mysql"
#   engine_version          = "8.0.mysql_aurora.3.05.2"
#   availability_zones      = ["us-east-1a", "us-east-1b"]
#   database_name           = "database1"
#   master_username         = local.variable1
#   master_password         = var.db_password # Note that this may show up in logs, and it will be stored in the state file. 
#   backup_retention_period = 5
#   preferred_backup_window = "07:00-09:00"
#   db_subnet_group_name    = aws_db_subnet_group.aws_3_tier_subnet_group.name
#   skip_final_snapshot     = true
#   vpc_security_group_ids  = [aws_security_group.database-sg.id]

#   lifecycle {
#     ignore_changes = [availability_zones]
#   }
# }

# resource "aws_rds_cluster_instance" "cluster_instances" {
#   count                = 2
#   identifier           = "database-1-${count.index}"
#   cluster_identifier   = aws_rds_cluster.default.id
#   instance_class       = "db.r5.large"
#   engine               = aws_rds_cluster.default.engine
#   engine_version       = aws_rds_cluster.default.engine_version
#   publicly_accessible  = false
#   db_subnet_group_name = aws_db_subnet_group.aws_3_tier_subnet_group.name
# }
