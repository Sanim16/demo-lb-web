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

  depends_on = [aws_internet_gateway.main]

  user_data = file("bootstrap.sh")
}

resource "aws_network_interface" "main" {
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.main.id]

  attachment {
    instance     = aws_instance.main.id
    device_index = 1
  }
}

# resource "aws_eip" "main" {
#   domain = "vpc"

#   instance                  = aws_instance.main.id
#   depends_on                = [aws_internet_gateway.main]
# }
