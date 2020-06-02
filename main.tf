###########################################################################
# Virtual Private Cloud
#
# Anything named 'default' is associated to the default VPC in our AWS account
# Anything named 'main' is associated to the VPC being defined here
###########################################################################

data "aws_vpc" "default" {
  id      = "${var.default_vpc}"
  default = true
}

data "aws_route_table" "default" {
  route_table_id = "${length(var.default_route_table) > 0 ? var.default_route_table : aws_vpc.main.main_route_table_id}"
}
