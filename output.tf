output "main_vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "subnet_ids" {
  value = "${aws_subnet.onadata-api-subnets.*.id}"
}

output "vpc_arn" {
  value = "${aws_vpc.main.arn}"
}
