output "id" {
  value = "${aws_vpc.vpc.id}"
}

output "main_route_table_id" {
  value = "${aws_vpc.vpc.main_route_table_id}"
}

output "subnets" {
  value = ["${aws_subnet.subnet.*.id}"]
}
