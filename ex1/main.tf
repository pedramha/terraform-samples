provider "aws" {
  region = "eu-west-1"
}

provider "random" {
}

provider "tls" {

}
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

# create a vpc
resource "aws_vpc" "vpc-tf" {
  cidr_block = "0.0.0.0/16"
  tags = {
    Name = "terraform-example"
  }
}

# create a subnet
resource "aws_subnet" "subnet-tf" {
  vpc_id            = aws_vpc.vpc-tf.id
  cidr_block        = "0.0.0.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "terraform-example"
  }
}


resource "aws_security_group" "instanceb" {
  name = "terraform-example-instanceb"

  # ingress for windows instances
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
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

resource "aws_instance" "exampleb" {
  ami               = "ami-0c2b0d3fb02824d92 "
  instance_type     = "t2.micro"
  availability_zone = aws_subnet.subnet-tf.availability_zone

  key_name               = aws_key_pair.aws_key_pair.key_name
  vpc_security_group_ids = ["${aws_security_group.instanceb.id}"]
  tags = {
    Name = "pedram@hashicorp.com"
  }

  # user_data = <<-EOF
  #       #!/bin/bash
  #       echo "Hello, World" > index.html
  #       nohup busybox httpd -f -p 8080 &
  #       EOF
}
