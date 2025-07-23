provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_name}-vpc"
    managed_by = "terraform"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet"
    managed_by = "terraform"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.project_name}-private-subnet"
    managed_by = "terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
    managed_by = "terraform"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
    managed_by = "terraform"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.project_name}-private-rt"
    managed_by = "terraform"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security Group
resource "aws_security_group" "public_ec2_sg" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project_name}-public-ec2-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "-1"
    cidr_blocks = [var.ssh_allow_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-public-ec2-sg"
    managed_by = "terraform"
  }
}

resource "aws_security_group" "private_ec2-sg" {
  name        = "${var.project_name}-private-ec2-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow private access"
  
  ingress  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.public_subnet_cidr ]
  }

  tags = {
   Name = "${var.project_name}-private-ec2-sg"
   managed_by = "terraform"
  }   
}

# EC2 Instances
resource "aws_instance" "public_instance_1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]
  user_data              = file("userdata/ha.sh")
  key_name               = var.key_name  # need to change
  tags = {
    Name = "${var.project_name}-public-instance-1"
    managed_by = "terraform"
  }
    root_block_device {
    volume_size           =  var.public_instance_disk_size
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

resource "aws_instance" "public_instance_2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]
  key_name               = var.key_name   # need to change
  user_data              = file("userdata/one.sh")
  tags = {
    Name = "${var.project_name}-public-instance-2"
    managed_by = "terraform"
  }
   root_block_device {
    volume_size           =  var.public_instance_disk_size
    volume_type           = "gp3"
    delete_on_termination = true
  }
}
resource "aws_instance" "public_instance_3" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]
  user_data              = file("userdata/two.sh")
  key_name               = var.key_name   #need to change
  tags = {
    Name = "${var.project_name}-public-instance-3"
    managed_by = "terraform"
  }
   root_block_device {
    volume_size           =  var.public_instance_disk_size
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

# resource "aws_instance" "private_instance" {
#   ami                    = var.ami_id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.private.id
#   vpc_security_group_ids = [aws_security_group.ec2_sg.id]
#   key_name               = var.key_name
#   tags = {
#     Name = "${var.project_name}-private-instance"
#   }
# }