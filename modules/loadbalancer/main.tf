resource "aws_security_group" "lb_sg" {
  name        = "${var.environment}-lb-sg"
  description = "AWS Meetup - ${var.environment} - lb security group"
  vpc_id      = "${var.vpc_id}"

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

resource "aws_alb" "lb" {
  name            = "${var.environment}-lb"
  security_groups = ["${aws_security_group.lb_sg.id}"]
  subnets         = ["${var.subnets}"]

  tags {
    Name        = "${var.environment}-lb"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "lb_tg" {
  name     = "${var.environment}-alb-tg"
  port     = "${var.target_group_port}"
  protocol = "${var.target_group_protocol}"
  vpc_id   = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-alb-tg"
    Environment = "${var.environment}"
  }

  health_check {
    port = "${var.target_group_health_check_port}"
  }
}

resource "aws_alb_listener" "lb_listener" {
  load_balancer_arn = "${aws_alb.lb.arn}"
  port              = "${var.listener_port}"
  protocol          = "${var.listener_protocol}"

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
