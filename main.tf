resource "aws_vpc" "test-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = element(var.availability_zone, 0)
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = element(var.availability_zone, 1)
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "test-vpc-IGW"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test-igw.id
}

resource "aws_route_table_association" "public-subnet-1-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_eip" "nat-eip" {
  vpc = true
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_security_group" "web-sg" {
  vpc_id = aws_vpc.test-vpc.id
  name   = "web-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_security_group" "db-sg" {
  vpc_id = aws_vpc.test-vpc.id
  name   = "db-sg"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

resource "aws_instance" "private-instance" {
  ami           = var.ami_private
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private-subnet-1.id
  tags = {
    Name = "private-instance"
  }
}

resource "aws_instance" "public-instance" {
  ami           = var.ami_public
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet-1.id
  security_groups = [aws_security_group.web-sg.name] # Attach the security group
  tags = {
    Name = "public-instance"
  }
}