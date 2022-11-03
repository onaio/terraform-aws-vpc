resource "aws_eip" "private_subnets_nat_gateway_public_ip" {
  count = var.allow_private_subnets_access_to_internet ? 1 : 0
  vpc   = true
  tags  = merge(local.common_tags, { "Name" = "${local.common_tags.Name}-nat_gateway_ip"})

}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.allow_private_subnets_access_to_internet ? 1 : 0
  allocation_id = aws_eip.ip[count.index].id
  subnet_id     = aws_subnet.onadata-api-subnets[count.index].id
  tags          = local.common_tags

}
