resource "aws_eip" "private_subnets_nat_gateway_public_ip" {
  count = var.allow_private_subnets_access_to_internet ? length(var.availability_zones) : 0
  vpc   = true
  tags  = merge(local.common_tags, { "Name" = "${local.common_tags.Name}-nat-gateway-${count.index + 1}-ip" })

}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.allow_private_subnets_access_to_internet ? length(var.availability_zones) : 0
  allocation_id = aws_eip.private_subnets_nat_gateway_public_ip[count.index].id
  subnet_id     = aws_subnet.onadata-api-subnets[count.index].id
  tags          = merge(local.common_tags, { "Name" = "${local.common_tags.Name}-nat-gateway-${count.index + 1}" })

}
