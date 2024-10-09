resource "aws_vpc" "group4_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-group-4"
  }
}


resource "aws_subnet" "group4_subnet" {
  vpc_id                  = aws_vpc.group4_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "devops-group-4"
  }

}


resource "aws_internet_gateway" "group4_igw" {
  vpc_id = aws_vpc.group4_vpc.id

  tags = {
    Name = "devops-group-4"
  }

}


resource "aws_route_table" "group4_public_rt" {
  vpc_id = aws_vpc.group4_vpc.id

  tags = {
    Name = "devops-group-4"
  }
}


resource "aws_route" "group4_routes" {
  route_table_id            = aws_route_table.group4_public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.group4_igw.id
}


resource "aws_route_table_association" "group4_subnet_association" {
  subnet_id      = aws_subnet.group4_subnet.id
  route_table_id = aws_route_table.group4_public_rt.id
}


resource "aws_security_group" "group4_sg" {
  name = "devops-group-4" 
  description = "Allow inbound traffic on port 22 and 80"
  vpc_id = aws_vpc.group4_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}


resource "aws_instance" "group4_instance" {
  ami           = data.aws_ami.group4_ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.group4_subnet.id
  key_name      = "group4"
  vpc_security_group_ids = [aws_security_group.group4_sg.id]
  user_data = file("userdata.tpl")

  tags = {
    Name = "devops-group-4"
  }
}


output "name" {
  value = aws_instance.group4_instance.public_ip
  
}
