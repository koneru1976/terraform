resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = "${aws_vpc.my-vpc.id}"
}

resource "aws_subnet" "my-public-subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id = "${aws_vpc.my-vpc.id}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "my-public-route-table" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my-igw.id}"
  }
}

resource "aws_route_table_association" "my-public-route-table-association" {
  subnet_id = "${aws_subnet.my-public-subnet.id}"
  route_table_id = "${aws_route_table.my-public-route-table.id}"
}
