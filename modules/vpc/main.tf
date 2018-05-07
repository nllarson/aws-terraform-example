resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "subnet" {
  count                   = "${var.subnet_count}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.environment}-subnet-${count.index + 1}"
    Environment = "${var.environment}"
  }
}

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
  count          = "${var.subnet_count}"
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
}
