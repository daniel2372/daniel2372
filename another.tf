provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami = data.aws_ami.amzlinux2.id
   metadata_options {
     http_tokens = "required"
     }  

root_block_device {
      encrypted = true
  }
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_autoscaling_group" "my_asg" {
  availability_zones        = ["us-west-1a"]
  name                      = "my_asg"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  launch_configuration      = "my_web_config"
}

resource "aws_launch_configuration" "my_web_config" {
  name = "my_web_config"
  image_id = data.aws_ami.amzlinux2.id
  instance_type = "t2.micro"

  metadata_options {
       http_tokens = "required"
     }  
 root_block_device {
        encrypted = true
    }
}

data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "dannys3bucket1478"

   versioning {
        enabled = true
    }
      logging {
        target_bucket = "dannys3bucket1478"
    }
   server_side_encryption_configuration {
     rule {
       apply_server_side_encryption_by_default {
         kms_master_key_id = "arn"
         sse_algorithm     = "aws:kms"
       }
     }
   }
}

resource "aws_s3_bucket_public_access_block" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id
  block_public_acls = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
