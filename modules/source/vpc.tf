# -------------------------------
# SOURCE

resource "aws_vpc" "vpc_source" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name    = "vpc_source"
    project = "oracle2aurora"
  }
}

resource "aws_security_group" "allow_public_source" {
  name        = "allow_public_source"
  description = "Allow public inbound"
  vpc_id      = aws_vpc.vpc_source.id

  ingress {
    description = "Allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow db connection"
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Jupyter"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "allow_public_source"
    project = "oracle2aurora"
  }
}

resource "aws_internet_gateway" "igw_source" {
  vpc_id = aws_vpc.vpc_source.id

  tags = {
    Name    = "igw_source"
    project = "oracle2aurora"
  }
}

resource "aws_subnet" "subnet_source_a" {
  vpc_id            = aws_vpc.vpc_source.id
  cidr_block        = var.subnet_cidr_a
  availability_zone = "${var.region}a"

  tags = {
    Name    = "subnet_source_a"
    project = "oracle2aurora"
  }
}

resource "aws_subnet" "subnet_source_b" {
  vpc_id            = aws_vpc.vpc_source.id
  cidr_block        = var.subnet_cidr_b
  availability_zone = "${var.region}b"

  tags = {
    Name    = "subnet_source_b"
    project = "oracle2aurora"
  }
}

resource "aws_route_table" "rt_source" {
  vpc_id = aws_vpc.vpc_source.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_source.id
  }

  tags = {
    Name    = "rt_source"
    project = "oracle2aurora"
  }
}

resource "aws_route_table_association" "rt_association_a" {
  subnet_id      = aws_subnet.subnet_source_a.id
  route_table_id = aws_route_table.rt_source.id
}

resource "aws_route_table_association" "rt_association_b" {
  subnet_id      = aws_subnet.subnet_source_b.id
  route_table_id = aws_route_table.rt_source.id
}
