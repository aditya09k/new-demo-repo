resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "mainsubnet1" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "mainsubnet2" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "subnet2"
  }
}

resource "aws_subnet" "mainsubnet3" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "subnet3"
  }
}

resource "aws_subnet" "mainsubnet4" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "subnet4"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_eip" "for-nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-1" {
  allocation_id = aws_eip.for-nat.id
  subnet_id     = aws_subnet.mainsubnet1.id

  tags = {
    Name = "gw-NAT"
  }
}

resource "aws_route_table" "route-1" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "rout-pub-1"
  }
}


resource "aws_route_table" "route-2" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-1.id
  }

  tags = {
    Name = "rout-pvt-2"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mainsubnet1.id
  route_table_id = aws_route_table.route-1.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.mainsubnet2.id
  route_table_id = aws_route_table.route-1.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.mainsubnet3.id
  route_table_id = aws_route_table.route-2.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.mainsubnet4.id
  route_table_id = aws_route_table.route-2.id
}

resource "aws_security_group" "my-new-sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.mainvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pvt_instance1" {
  ami           = "ami-006dcf34c09e50022"
  instance_type = "t2.micro"
  key_name      = "deployer_key"

  subnet_id                   = aws_subnet.mainsubnet3.id
  vpc_security_group_ids      = [aws_security_group.my-new-sg.id]
  associate_public_ip_address = false
  user_data                   = <<EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd
    cd /var/www/html
    echo "namaste india" | sudo tee index.html
    EOF
}

resource "aws_instance" "pvt_instance2" {
  ami           = "ami-006dcf34c09e50022"
  instance_type = "t2.micro"
  key_name      = "deployer_key"

  subnet_id                   = aws_subnet.mainsubnet4.id
  vpc_security_group_ids      = [aws_security_group.my-new-sg.id]
  associate_public_ip_address = false
  user_data                   = <<EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd
    cd /var/www/html
    echo "namaste maharastra" | sudo tee index.html
    EOF
}

resource "aws_key_pair" "generated_key" {
  key_name   = "deployer_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCe01zdkwEgtv2o8msjNkvBbbFUQY0d1Iy6I6F3e7VUMbVT/BgbJ1IE2l1/XHheUWS18EDdVsUmN+IChF+7vgy1wfqSvn9qW33N9BEvkuzEWs2BYw4jntjwAAuPkNLprSYdvejFcVhJNqrTo8Vz4lDLIahzuodmfxgnrfEFqWF508MeQZn6ZGzBC7L4OLxkgGZsHnfCNatVyOcKeuKMLP8i0vz7ZtWJxJzXELowHNr75l/DHkGMz7O5iqYVQtvu5UzpcEerLVp4wwxPIKAR+K9tVKNVivFQucftTE4+/B8sNzMVeQhJgE+k54pRgMA2nxHwC14G7/2oIQsZviLa7z37t1JKX+NwqEVZptUC22Ul318N/5K89bXVi9dgCHszU2PwRJZPQNui+Q78uJlJwqUxQ5jj5Bn32hlb+v0s5mdMeEOdrFsSZPMa/MbCdA31BiRURfPplERDHxtAXwupXMDF7og+toT7GzTkQoQtKe9Yre8nrvnyyxPKEI1ooXoKImE= aditya@LAPTOP-COAUUDVA"

}

resource "aws_instance" "pub_instance" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  key_name      = "deployer_key"

  subnet_id                   = aws_subnet.mainsubnet1.id
  vpc_security_group_ids      = [aws_security_group.my-new-sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y nginx
                sudo systemctl start nginx
                sudo systemctl enable nginx
                sudo systemctl restart nginx
                sudo chmod 777 etc
              
              
EOF

  provisioner "file" {
    source      = "./myproxy.conf"
    destination = "/etc/nginx/conf.d/myproxy.conf"
   
  }
 connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./.ssh/id_rsa")
    host        = aws_instance.pub_instance.public_ip
  }
}

resource "null_resource" "replace_word" {
    
    provisioner "local-exec" {
      command = "sed -i 's/private1/${aws_instance.pvt_instance1.private_ip}/g' myproxy.conf"
    }

    
    provisioner "local-exec" {
      command = "sed -i 's/private2/${aws_instance.pvt_instance2.private_ip}/g' myproxy.conf"
    }

     depends_on = [
      aws_instance.pvt_instance1,
      aws_instance.pvt_instance2,
      ]
  }