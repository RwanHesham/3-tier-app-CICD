resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-vpc"
      "kubernates.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public-subnet" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "private-subnet" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-private-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${cluster_name}-igw"
  }
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${cluster_name}-publicRT"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.publicRT.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
  Name = "nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "ngw" {
  count         = length(var.public_subnet_cidr)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id

  tags = {
    Name = "${cluster_name}-nat-gateway-${count.index + 1}"
  }
}

resource "aws_route_table" "privateRT" {
  count  = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[count.index].id
  }
  tags = {
    Name = "${cluster_name}-private-route-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr) ## This will associate all the public subnet to this route table
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.privateRT[count.index].id
}