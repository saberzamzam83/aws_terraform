provider "aws" {
  region     = "eu-west-2"
  access_key = var.access_key_prefix
  secret_key = var.secret_key_prefix
}

resource "aws_vpc" "prod_vpc" {
  cidr_block = var.vpc_prefix

  tags = {
    Name = "Prod VPC"
  }
}

resource "aws_internet_gateway" "prod_gw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "Prod IGW"
  }
}

resource "aws_route_table" "prod_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.prod_gw.id
  }

  tags = {
    Name = "Prod Route Table"
  }
}

resource "aws_subnet" "prod_subnet" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = var.subnet_prefix
  availability_zone = "eu-west-2a"
  tags = {
    Name = "Prod Subnet"
  }
}

resource "aws_route_table_association" "prod_route_table_association" {
  subnet_id      = aws_subnet.prod_subnet.id
  route_table_id = aws_route_table.prod_route_table.id
}

resource "aws_security_group" "Prod_Security_Group" {
  name        = "prod security group"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
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
    Name = "Prod Security Group"
  }
}

resource "aws_network_interface" "webserver_if" {
  subnet_id       = aws_subnet.prod_subnet.id
  private_ips     = var.private_ips_prefix  
  security_groups = [aws_security_group.Prod_Security_Group.id]
  #depends_on = [aws_subnet.prod_subnet]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.webserver_if.id
  associate_with_private_ip = var.aws_eip_association_prefix
  depends_on                = [aws_internet_gateway.prod_gw]
}


resource "aws_instance" "web_server" {
  ami               = var.aim_prefix
  instance_type     = "t2.micro"
  availability_zone = "eu-west-2a"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.webserver_if.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y apache2
                sudo chmod -R 775 /var/www/html
                sudo echo "<html><head><title>Hello World!</title></head><body><h1>Hello World</h1></body></html>" > /var/www/html/index.html
                sudo systemctl restart apache2
                EOF

  tags = {
    Name = "Apache Web Server"
  }
}