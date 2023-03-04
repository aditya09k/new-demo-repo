resource "aws_key_pair" "generated_key" {
  key_name   = "deployer_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCe01zdkwEgtv2o8msjNkvBbbFUQY0d1Iy6I6F3e7VUMbVT/BgbJ1IE2l1/XHheUWS18EDdVsUmN+IChF+7vgy1wfqSvn9qW33N9BEvkuzEWs2BYw4jntjwAAuPkNLprSYdvejFcVhJNqrTo8Vz4lDLIahzuodmfxgnrfEFqWF508MeQZn6ZGzBC7L4OLxkgGZsHnfCNatVyOcKeuKMLP8i0vz7ZtWJxJzXELowHNr75l/DHkGMz7O5iqYVQtvu5UzpcEerLVp4wwxPIKAR+K9tVKNVivFQucftTE4+/B8sNzMVeQhJgE+k54pRgMA2nxHwC14G7/2oIQsZviLa7z37t1JKX+NwqEVZptUC22Ul318N/5K89bXVi9dgCHszU2PwRJZPQNui+Q78uJlJwqUxQ5jj5Bn32hlb+v0s5mdMeEOdrFsSZPMa/MbCdA31BiRURfPplERDHxtAXwupXMDF7og+toT7GzTkQoQtKe9Yre8nrvnyyxPKEI1ooXoKImE= aditya@LAPTOP-COAUUDVA"

}

resource "aws_security_group" "example" {
  name_prefix = "my-security-group"

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

  ingress {
    from_port   = 443
    to_port     = 443
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

data "aws_ami" "example" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "example" {
  ami             = data.aws_ami.example.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.example.name]
  user_data       = <<EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx
sudo systemctl start nginx
EOF

}