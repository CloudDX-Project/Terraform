resource "aws_vpc" "travel_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "travel-vpc"
  }
}

resource "aws_internet_gateway" "travel_igw" {
  vpc_id = aws_vpc.travel_vpc.id

  tags = {
    Name = "travel-igw"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.travel_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "travel-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.travel_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "travel-public-b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.travel_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "travel-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.travel_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "travel-private-b"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.travel_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.travel_igw.id
  }

  tags = {
    Name = "travel-public-rt"
  }
}

resource "aws_route_table_association" "public_a_rt" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_rt" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}