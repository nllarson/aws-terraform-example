provider "aws" {
  profile = "aws-meetup"
}

##################################
# VPC
##################################

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

##################################
# SUBNETS
##################################

resource "aws_subnet" "subnet" {
  count                   = 2
  availability_zone       = "${element(var.availability_zones, count.index)}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.environment}-subnet-${count.index + 1}"
    Environment = "${var.environment}"
  }
}

##################################
# INTERNET GATEWAY
##################################

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "vpc-internet_access" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
}

##################################
# LOAD BALANCER
##################################

resource "aws_alb" "lb" {
  name            = "${var.environment}-lb"
  security_groups = ["${aws_security_group.lb_sg.id}"]
  subnets         = ["${aws_subnet.subnet.*.id}"]

  tags {
    Name        = "${var.environment}-lb"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "lb_tg" {
  name     = "${var.environment}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.environment}-alb-tg"
    Environment = "${var.environment}"
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

resource "aws_security_group" "lb_sg" {
  name        = "${var.environment}-lb-sg"
  description = "AWS Meetup - ${var.environment} - lb security group"
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
    Name        = "${var.environment}-lb-sg"
    Environment = "${var.environment}"
  }
}

##################################
# EC2
##################################

resource "aws_instance" "www" {
  count                  = 4
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(aws_subnet.subnet.*.id, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.www_sg.id}"]
  key_name               = "${var.key_name}"

  connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  provisioner "remote-exec" {
    script = "conf/setup.sh"
  }

  tags {
    Name        = "${var.environment}-www-${count.index + 1}"
    Environment = "${var.environment}"
    node        = "${count.index + 1}"
  }
}

resource "aws_alb_target_group_attachment" "www_target" {
  count            = 4
  target_group_arn = "${aws_alb_target_group.lb_tg.arn}"
  target_id        = "${element(aws_instance.www.*.id, count.index)}"
  port             = 80
}

resource "aws_security_group" "www_sg" {
  name        = "${var.environment}-www-sg"
  description = "AWS Meetup - ${var.environment} - www security group"
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
    Name        = "${var.environment}-www-sg"
    Environment = "${var.environment}"
  }
}
