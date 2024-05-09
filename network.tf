resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = local.common_tags
}

resource "aws_vpc_peering_connection" "main_to_default" {
  count       = var.peer_to_default ? 1 : 0
  peer_vpc_id = data.aws_vpc.default.id
  vpc_id      = aws_vpc.main.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = local.common_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { "Name" = "${local.common_tags.Name}-default-internet-gateway" })
}

resource "aws_route_table" "with-peer" {
  count  = var.peer_to_default ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    cidr_block                = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main_to_default[count.index].id
  }
  tags = merge(local.common_tags, { "Name" = "${local.common_tags.Name}-default-route-table" })
}

resource "aws_route_table" "without-peer" {
  count  = var.peer_to_default ? 0 : 1
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.common_tags, { "Name" = "${local.common_tags.Name}-default-route-table" })
}

resource "aws_route_table" "private_subnet_connection_to_nat_gateway" {
  count  = var.allow_private_subnets_access_to_internet ? length(var.availability_zones) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }
  tags = merge(local.common_tags, { "Name" = "${local.common_tags.Name}-route-table-${count.index + 1}" })
}


resource "aws_route" "default_to_main" {
  count = var.peer_to_default ? 1 : 0

  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_default[count.index].id
}

resource "aws_subnet" "public_subnets" {
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, var.cidr_new_bits, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = merge(local.common_tags, { "Name" = "${local.common_tags.Name}-public-subnet-${count.index + 1}" })
}

resource "aws_subnet" "private_subnets" {
  availability_zone       = element(var.availability_zones, count.index)
  count                   = var.create_private_subnets ? length(var.availability_zones) : 0
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, var.cidr_new_bits, count.index + length(var.availability_zones))
  tags                    = merge(local.common_tags, { "Name" = "${local.common_tags.Name}-private-subnet-${count.index + 1}" })
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

resource "aws_route_table_association" "main" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = var.peer_to_default ? aws_route_table.with-peer[0].id : aws_route_table.without-peer[0].id
}

resource "aws_route_table_association" "private_subnets_association" {
  count          = var.allow_private_subnets_access_to_internet ? length(var.availability_zones) : 0
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_subnet_connection_to_nat_gateway[count.index].id
}
