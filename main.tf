

resource "aws_vpc" "my_vpc"{

  cidr_block      = var.cidr_block

  tags = {
  name = "my_tf"
  }
}

resource "aws_subnet" "my_subnet"{
vpc_id = aws_vpc.my_vpc.id
cidr_block = "10.0.0.0/24"
availability_zone = "eu-west-1a"

tags = {
name = "my_tf"
 }
}

resource "aws_security_group" "allow80" {
  vpc_id = aws_vpc.my_vpc.id

   ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
   description = "HTTPS"
   from_port = 443
   protocol = "tcp"
   to_port = 443
   cidr_blocks = ["0.0.0.0/0"]
 }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
  Name = "my_tf"
  }
}

resource "aws_network_interface" "my_interface" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips = ["10.0.0.50"]
  security_groups = [aws_security_group.allow80.id]
  }

resource "aws_internet_gateway" "aws_ig" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
  Name = "my_tf"
  }
  }

  resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_ig.id
  }

  tags = {
  Name = "my_tf"
  }
}

  resource "aws_route_table_association" "my_association" {
    subnet_id      = aws_subnet.my_subnet.id
    route_table_id = aws_route_table.public.id
  }


  resource "aws_instance" "wordpress" {
    ami                            = "ami-08ff526923a6e8e5f"
    count                          = "1"
    instance_type                  = "t2.micro"
    security_groups                 = [aws_security_group.allow80.id]
    subnet_id                      = aws_subnet.my_subnet.id
    associate_public_ip_address    = true
  }
