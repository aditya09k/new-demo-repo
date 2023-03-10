resource "aws_iam_user" "demo" {
  count = length(var.username)
  name  = element(var.username, count.index)
}

resource "aws_iam_group" "users_group" {
  name = "goupAdmin"
}

resource "aws_iam_user_group_membership" "example" {
  count  = length(var.username)
  user   = element(var.username, count.index)
  groups = [aws_iam_group.users_group.id]
}

data "aws_iam_policy_document" "read_only_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "rds:Describe*",
      "s3:List*",
      "s3:Get*",
    ]
    resources = [
      "arn:aws:ec2:*:*:*",
      "arn:aws:rds:*:*:*",
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "all-policy"
  policy = data.aws_iam_policy_document.read_only_policy.json
}

resource "aws_iam_group_policy_attachment" "policy_attachment" {
  group      = aws_iam_group.users_group.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role" "example_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_role_attachment" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.example_role.name
}

resource "aws_instance" "example_instance" {
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.example_profile.name
}

resource "aws_iam_instance_profile" "example_profile" {
  name = "example-profile"
  role = aws_iam_role.example_role.name

  tags = {
    Name = "${var.name}-instance"
  }
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCe01zdkwEgtv2o8msjNkvBbbFUQY0d1Iy6I6F3e7VUMbVT/BgbJ1IE2l1/XHheUWS18EDdVsUmN+IChF+7vgy1wfqSvn9qW33N9BEvkuzEWs2BYw4jntjwAAuPkNLprSYdvejFcVhJNqrTo8Vz4lDLIahzuodmfxgnrfEFqWF508MeQZn6ZGzBC7L4OLxkgGZsHnfCNatVyOcKeuKMLP8i0vz7ZtWJxJzXELowHNr75l/DHkGMz7O5iqYVQtvu5UzpcEerLVp4wwxPIKAR+K9tVKNVivFQucftTE4+/B8sNzMVeQhJgE+k54pRgMA2nxHwC14G7/2oIQsZviLa7z37t1JKX+NwqEVZptUC22Ul318N/5K89bXVi9dgCHszU2PwRJZPQNui+Q78uJlJwqUxQ5jj5Bn32hlb+v0s5mdMeEOdrFsSZPMa/MbCdA31BiRURfPplERDHxtAXwupXMDF7og+toT7GzTkQoQtKe9Yre8nrvnyyxPKEI1ooXoKImE= aditya@LAPTOP-COAUUDVA"

}