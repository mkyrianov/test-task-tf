provider "aws" {
  region = "ap-southeast-2"
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }
}

resource "aws_launch_configuration" "web_server" {
  name_prefix     = "web_server"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t2.nano"
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.web_server.id]
  key_name = "mkyrianov"

  associate_public_ip_address = true


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.web_server.name
  vpc_zone_identifier  = [
    aws_subnet.public_ap-southeast-2a.id,
    aws_subnet.public_ap-southeast-2b.id
  ]
  load_balancers = [aws_elb.web_lb.id]
}

resource "aws_elb" "web_lb" {
  name               = "web-lb"
  internal           = false
  security_groups    = [aws_security_group.web_server.id]
  subnets = [
    aws_subnet.public_ap-southeast-2a.id,
    aws_subnet.public_ap-southeast-2b.id
  ]
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}

resource "aws_security_group" "web_server" {
  name        = "web_sg"
  description = "Web Security Group"
  vpc_id = aws_vpc.web_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name  = "Web Server Security Group"
    Owner = "Mykhailo Kyrianov"
  }
}