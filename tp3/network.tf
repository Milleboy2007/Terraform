/*
* VPC
*/
resource "aws_vpc" "tp3-2484435-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "tp3-2484435-vpc"
  }
}

/*
* Sous-Reseaux
*/
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.tp3-2484435-vpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)


  tags = {
    Name = "tp3-2484435-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.tp3-2484435-vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)


  tags = {
    Name = "tp3-2484435-private-${count.index + 1}"
  }
}

/*
* Passerelle internet
*/
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tp3-2484435-vpc.id

  tags = {
    Name = "tp3-2484435-igw"
  }
}

/*
* Tables de routage
*/
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tp3-2484435-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    cidr_block = "10.44.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "rtb-tp3-public"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.tp3-2484435-vpc.id

  route {
    cidr_block = "10.44.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "rtb-tp3-private"
  }
}

/*
* Association reseaux routage
*/
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

/*
* Groupes de securite
*/
resource "aws_security_group" "tp3-2484435-sg" {
  name        = "tp3-2484435-sg"
  description = "SSH, HTTP, HTTPS"
  vpc_id      = aws_vpc.tp3-2484435-vpc.id

  ingress {

    description = "SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = "443"
    to_port     = "443"
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