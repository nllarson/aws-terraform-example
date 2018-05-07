resource "aws_security_group" "www_sg" {
  name        = "${var.environment}-www-sg"
  description = "AWS Meetup - ${var.environment} - www security group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${var.loadbalancer_security_group_id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.whitelisted_ips}"
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

resource "aws_instance" "www" {
  count                  = "${var.instance_count}"
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(var.subnets, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.www_sg.id}"]
  key_name               = "${var.key_name}"

  connection {
    type = "${var.config_connection_type}"
    user = "${var.config_connection_user}"
    host = "${self.public_ip}"
  }

  provisioner "remote-exec" {
    script = "${var.config_script}"
  }

  tags {
    Name        = "${var.environment}-www-${count.index + 1}"
    Environment = "${var.environment}"
    node        = "${count.index + 1}"
  }
}

resource "aws_alb_target_group_attachment" "www_target" {
  count            = "${var.instance_count}"
  target_group_arn = "${var.loadbalancer_target_group_arn}"
  target_id        = "${element(aws_instance.www.*.id, count.index)}"
  port             = "${var.target_port}"
}
