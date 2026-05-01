resource "aws_vpc" "tp1" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "VPC-TP1"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.tp1.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)


  tags = {
    Name = "tp1-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.tp1.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)


  tags = {
    Name = "tp1-private-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tp1.id

  tags = {
    Name = "tp1-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tp1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "tp1-rtb-public"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.tp1.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "tp1-rtb-private"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.tp1.id

  ingress {

    description = "SSH"
    from_port   = "22"
    to_port     = "22"
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
}

resource "aws_security_group" "http_access" {
  name        = "http-access"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.tp1.id

  ingress {
    description = "HTTP"
    from_port   = "80"
    to_port     = "80"
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
}