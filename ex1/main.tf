provider "aws" {
  region = "eu-west-1"
}

provider "random" {
}


# create a sample webserver ec2 instance
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  
  ingress {
    from_port	  = 8080
    to_port	    = 8080
    protocol	  = "tcp"
    cidr_blocks	= var.cidr_blocks
  }
}
resource "aws_instance" "example" {
  ami                     = "ami-785db401"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.instance.id}"]
  
  user_data = <<-EOF
	      #!/bin/bash
	      echo "Hello, World" > index.html
	      nohup busybox httpd -f -p 8080 &
	      EOF
			  
  tags {
    Name = "terraform-example"
  }
}


# s3
resource "aws_s3_bucket" "bucket" {
  bucket = random.String.result
  acl    = "public-read"
}