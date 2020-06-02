resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name            = "${var.vpc_name}-${var.env}"
    RawName         = var.vpc_name
    OwnerList       = var.owner
    EnvironmentList = var.env
    EndDate         = var.end_date
    ProjectList     = var.project
    DeploymentType  = var.deployment_type
  }
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

  tags = {
    Name            = "${var.vpc_name}-${var.env}"
    RawName         = var.vpc_name
    OwnerList       = var.owner
    EnvironmentList = var.env
    EndDate         = var.end_date
    ProjectList     = var.project
    DeploymentType  = var.deployment_type
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name            = "${var.vpc_name}-${var.env}"
    RawName         = var.vpc_name
    OwnerList       = var.owner
    EnvironmentList = var.env
    EndDate         = var.end_date
    ProjectList     = var.project
    DeploymentType  = var.deployment_type
  }
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

  tags = {
    Name            = "${var.vpc_name}-${var.env}"
    RawName         = var.vpc_name
    OwnerList       = var.owner
    EnvironmentList = var.env
    EndDate         = var.end_date
    ProjectList     = var.project
    DeploymentType  = var.deployment_type
  }
}

resource "aws_route_table" "without-peer" {
  count  = var.peer_to_default ? 0 : 1
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name            = "${var.vpc_name}-${var.env}"
    RawName         = var.vpc_name
    OwnerList       = var.owner
    EnvironmentList = var.env
    EndDate         = var.end_date
    ProjectList     = var.project
    DeploymentType  = var.deployment_type
  }
}

resource "aws_route" "default_to_main" {
  count = var.peer_to_default ? 1 : 0

  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_default[count.index].id
}

resource "aws_subnet" "onadata-api-subnets" {
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, var.cidr_new_bits, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name            = "${var.vpc_name}-${var.env} ${count.index}"
    RawName         = var.vpc_name
    OwnerList       = var.owner
    EnvironmentList = var.env
    EndDate         = var.end_date
    ProjectList     = var.project
    DeploymentType  = var.deployment_type
  }
}

resource "aws_route_table_association" "main" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.onadata-api-subnets.*.id, count.index)
  route_table_id = var.peer_to_default ? aws_route_table.with-peer[0].id : aws_route_table.without-peer[0].id
}
