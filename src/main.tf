provider "aws" {
  region  = "us-east-1"
  profile = "cloud"
}

resource "aws_vpc" "practica_2_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "practica_2_vpc"
  }
}

resource "aws_internet_gateway" "practica_2_igw" {
  vpc_id = aws_vpc.practica_2_vpc.id

  tags = {
    Name = "practica_2_igw"
  }
}


resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.practica_2_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public_a"
  }

}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.practica_2_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public_b"
  }

}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.practica_2_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_a"
  }

}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.practica_2_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public_b"
  }

}

resource "aws_eip" "nat_ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.practica_2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.practica_2_igw.id
  }

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.practica_2_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "web_server" {
  name        = "web_server"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.practica_2_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_key_pair" "web" {
  key_name = "web"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web_server" {
  ami           = "ami-0044130ca185d0880"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_server.id]
  subnet_id              = aws_subnet.public_b.id

  associate_public_ip_address = true

  key_name = aws_key_pair.web.key_name

  user_data = file("./user-data.sh")

}
