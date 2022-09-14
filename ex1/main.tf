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

  website {
    index_document = "index.html"
  }
  
}

resource "aws_s3_bucket_object" "file_upload" {
  for_each = fileset("${path.module}/static", "**")
    bucket = aws_s3_bucket.bucket.id
    key = each.value
    source = "${path.module}/static/${each.value}"
    etag = filemd5("${path.module}/static/${each.value}") 
}