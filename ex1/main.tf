provider "aws" {
  region = "eu-central-1"
}

provider "random" {
}

provider "tls" {

}
provider "hcp" {}

# create a sample webserver ec2 instance
# resource "aws_security_group" "instance" {
#   name = "terraform-example-instance"

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = var.cidr_blocks
#   }
# }


# resource "aws_instance" "example" {
#   ami                    = "ami-785db401"
#   instance_type          = "t2.micro"
#   # instance_type          = "i2.2xlarge"
#   availability_zone      = "eu-west-1a"
#   vpc_security_group_ids = ["${aws_security_group.instance.id}"]
#   tags = {
#     Name = "pedram@hashicorp.com"
#   }

#   user_data = <<-EOF
# 	      #!/bin/bash
# 	      echo "Hello, World" > index.html
# 	      nohup busybox httpd -f -p 8080 &
# 	      EOF


# }


# s3
# resource "random_pet" "lambda_bucket_name" {
#   prefix = "pedram"
#   length = 4
# }
# resource "aws_s3_bucket" "bucket" {
#   bucket = random_pet.lambda_bucket_name.id
#   acl    = "public-read-write"
# }
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"  # Update with your preferred VPC CIDR block

  tags = {
    Name = "example-vpc"
  }
}

# Create public subnet resource
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"  # Update with your preferred subnet CIDR block

  tags = {
    Name = "example-public-subnet"
  }
}

# Create internet gateway resource and attach it to VPC
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-internet-gateway"
  }
}

# Create route table for public subnet and add default route to internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "example-public-route-table"
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create security group for Windows machine
resource "aws_security_group" "windows" {
  name_prefix = "windows-sg-"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create a keypair
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key_pair" {
  key_name   = "terraform-key"
  public_key = tls_private_key.keypair.public_key_openssh
}

# resource "aws_instance" "exampleb" {
#   ami               = "ami-086f54a5d4d34a5be"
#   instance_type     = "t2.micro"
#   availability_zone = aws_subnet.public.availability_zone

#   # key_name               = aws_key_pair.aws_key_pair.key_name
#   vpc_security_group_ids = ["${aws_security_group.windows.id}"]
#   tags = {
#     Name = "pedram@hashicorp.com"
#   }

# provisioner "remote-exec" {
#     script = "nginx-install.sh"
#   }
# }

data "hcp_packer_iteration" "windows" {
  bucket_name = "my-registry-bucket"
  channel     = "latest"
}

data "hcp_packer_image" "windows_image_eu-central" {
  bucket_name    = "my-registry-bucket"
  cloud_provider = "aws"
  iteration_id   = data.hcp_packer_iteration.windows.id
  region         = "eu-central-1"
}

resource "aws_instance" "app_server" {
  ami           = data.hcp_packer_image.windows_image_eu-central.cloud_image_id
  # instance_type = "t2.micro"
  availability_zone = aws_subnet.public.availability_zone

  vpc_security_group_ids = ["${aws_security_group.windows.id}"]
  tags = {
    Name = "Learn-HCP-Packer"
  }
}