# -------------------------------
# TARGET

resource "aws_vpc" "vpc_target" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name    = "vpc_target"
    project = "oracle2aurora"
  }
}

resource "aws_security_group" "allow_public_target" {
  name        = "allow_public_target"
  description = "Allow public inbound"
  vpc_id      = aws_vpc.vpc_target.id

  ingress {
    description      = "Allow db connection"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "allow_public_target"
    project = "oracle2aurora"
  }
}

resource "aws_security_group" "allow_migration" {
  name        = "allow_migration"
  description = "Allow migration"
  vpc_id      = aws_vpc.vpc_target.id

  ingress {
    description      = "Allow all" # @WARINNG
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "allow_migration"
    project = "oracle2aurora"
  }
}

resource "aws_internet_gateway" "igw_target" {
  vpc_id = aws_vpc.vpc_target.id

  tags = {
    Name    = "igw_target"
    project = "oracle2aurora"
  }
}

resource "aws_subnet" "subnet_target_a" {
  vpc_id            = aws_vpc.vpc_target.id
  cidr_block        = var.subnet_cidr_a
  availability_zone = "${var.region}a"

  tags = {
    Name    = "subnet_target_a"
    project = "oracle2aurora"
  }
}

resource "aws_subnet" "subnet_target_b" {
  vpc_id            = aws_vpc.vpc_target.id
  cidr_block        = var.subnet_cidr_b
  availability_zone = "${var.region}b"

  tags = {
    Name    = "subnet_target_b"
    project = "oracle2aurora"
  }
}

resource "aws_subnet" "subnet_target_c" {
  vpc_id            = aws_vpc.vpc_target.id
  cidr_block        = var.subnet_cidr_c
  availability_zone = "${var.region}c"

  tags = {
    Name    = "subnet_target_c"
    project = "oracle2aurora"
  }
}

resource "aws_route_table" "rt_target" {
  vpc_id = aws_vpc.vpc_target.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_target.id
  }

  tags = {
    Name    = "rt_target"
    project = "oracle2aurora"
  }
}

resource "aws_route_table_association" "rt_association_target_a" {
  subnet_id      = aws_subnet.subnet_target_a.id
  route_table_id = aws_route_table.rt_target.id
}

resource "aws_route_table_association" "rt_association_target_b" {
  subnet_id      = aws_subnet.subnet_target_b.id
  route_table_id = aws_route_table.rt_target.id
}

resource "aws_route_table_association" "rt_association_target_c" {
  subnet_id      = aws_subnet.subnet_target_c.id
  route_table_id = aws_route_table.rt_target.id
}

