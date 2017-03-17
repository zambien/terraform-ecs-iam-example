resource "aws_vpc" "nginx" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.tag_name}-vpc"
  }
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.nginx.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.nginx.id}"
  }

  tags {
    Name = "${var.tag_name}-route-table"
  }
}

resource "aws_route_table_association" "external-nginx" {
  subnet_id      = "${aws_subnet.nginx.id}"
  route_table_id = "${aws_route_table.external.id}"
}

resource "aws_subnet" "nginx" {
  vpc_id            = "${aws_vpc.nginx.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "${var.tag_name}-subnet"
  }
}

resource "aws_internet_gateway" "nginx" {
  vpc_id = "${aws_vpc.nginx.id}"

  tags {
    Name = "${var.tag_name}-inet-gateway"
  }
}
