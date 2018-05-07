provider "aws" {
  profile = "aws-meetup"
}

##################################
# VPC
##################################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.150.0.0/22"
  enable_dns_hostnames = true

  tags {
    Name        = "demo1-vpc"
    Environment = "demo1"
  }
}

##################################
# SUBNETS
##################################

resource "aws_subnet" "subnet_1" {
  availability_zone       = "us-east-1a"
  cidr_block              = "10.150.0.0/24"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = true

  tags {
    Name        = "demo1-subnet-1"
    Environment = "demo1"
  }
}

resource "aws_subnet" "subnet_2" {
  availability_zone       = "us-east-1b"
  cidr_block              = "10.150.1.0/24"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = true

  tags {
    Name        = "demo1-subnet-2"
    Environment = "demo1"
  }
}

##################################
# INTERNET GATEWAY
##################################

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "demo1-igw"
    Environment = "demo1"
  }
}

resource "aws_route" "vpc-internet_access" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = "${aws_subnet.subnet_1.id}"
  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = "${aws_subnet.subnet_2.id}"
  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
}

##################################
# SECURITY GROUPS
##################################

resource "aws_security_group" "lb_sg" {
  name        = "demo1-lb-sg"
  description = "AWS Meetup - demo1 - lb security group"
  vpc_id      = "${aws_vpc.vpc.id}"

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

  tags {
    Name        = "demo1-lb-sg"
    Environment = "demo1"
  }
}

resource "aws_security_group" "www_sg" {
  name        = "demo1-www-sg"
  description = "AWS Meetup - demo1 - www security group"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["68.96.28.240/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "demo1-www-sg"
    Environment = "demo1"
  }
}

##################################
# LOAD BALANCER
##################################

resource "aws_alb" "lb" {
  name            = "demo1-lb"
  security_groups = ["${aws_security_group.lb_sg.id}"]
  subnets         = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]

  tags {
    Name        = "demo1-lb"
    Environment = "demo1"
  }
}

resource "aws_alb_target_group" "lb_tg" {
  name     = "demo1-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  tags {
    Name        = "demo1-alb-tg"
    Environment = "demo1"
  }

  health_check {
    port = "80"
  }
}

resource "aws_alb_listener" "lb_listener" {
  load_balancer_arn = "${aws_alb.lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.lb_tg.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "lb-listener-rule" {
  listener_arn = "${aws_alb_listener.lb_listener.arn}"
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.lb_tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}

##################################
# EC2
##################################

resource "aws_instance" "www_1" {
  ami                    = "ami-1853ac65"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.subnet_1.id}"
  vpc_security_group_ids = ["${aws_security_group.www_sg.id}"]
  key_name               = "aws-meetup"

  tags {
    Name        = "demo1-www-1"
    Environment = "demo1"
    node        = "1"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  provisioner "remote-exec" {
    script = "conf/setup.sh"
  }
}

resource "aws_alb_target_group_attachment" "www_1_target" {
  target_group_arn = "${aws_alb_target_group.lb_tg.arn}"
  target_id        = "${aws_instance.www_1.id}"
  port             = 80
}

resource "aws_instance" "www_2" {
  ami                    = "ami-1853ac65"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.subnet_2.id}"
  vpc_security_group_ids = ["${aws_security_group.www_sg.id}"]
  key_name               = "aws-meetup"

  tags {
    Name        = "demo1-www-2"
    Environment = "demo1"
    node        = "2"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  provisioner "remote-exec" {
    script = "conf/setup.sh"
  }
}

resource "aws_alb_target_group_attachment" "www_2_target" {
  target_group_arn = "${aws_alb_target_group.lb_tg.arn}"
  target_id        = "${aws_instance.www_2.id}"
  port             = 80
}
