resource "aws_iam_user" "user_one" {
  name = "test-user1"
}

resource "aws_iam_user" "user_two" {
  name = "test-user2"
}

resource "aws_iam_user" "user_three" {
  name = "test-user3"
}

resource "aws_iam_user" "user_four" {
  name = "test-user4"
}

resource "aws_iam_user" "user_five" {
  name = "test-user5"
}

resource "aws_iam_group" "users_group" {
  name = "goupAdmin"

}

resource "aws_iam_group_membership" "team" {
  name = "group-membership"

  users = [
    aws_iam_user.user_one.name,
    aws_iam_user.user_two.name,
    aws_iam_user.user_three.name,
    aws_iam_user.user_four.name,
    aws_iam_user.user_five.name,
  ]
  group = aws_iam_group.users_group.name
}

data "aws_iam_policy_document" "rds_policy" {
  statement {
    actions = [
      "rds:Describe*",
      "rds:List*",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "ec2_policy" {
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:Get*",
      "ec2:List*",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "rds_policy" {
  name   = "rds-policy"
  policy = data.aws_iam_policy_document.rds_policy.json
}

resource "aws_iam_policy" "ec2_policy" {
  name   = "ec2-policy"
  policy = data.aws_iam_policy_document.ec2_policy.json
}

resource "aws_iam_policy" "s3_policy" {
  name   = "s3-policy"
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_iam_group_policy_attachment" "rds_policy_attachment" {
  group      = aws_iam_group.users_group.name
  policy_arn = aws_iam_policy.rds_policy.arn
}

resource "aws_iam_group_policy_attachment" "ec2_policy_attachment" {
  group      = aws_iam_group.users_group.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_group_policy_attachment" "s3_policy_attachment" {
  group      = aws_iam_group.users_group.name
  policy_arn = aws_iam_policy.s3_policy.arn
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
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.example_role.name
}

resource "aws_instance" "example_instance" {
  ami           = "ami-006dcf34c09e50022"
  instance_type = "t2.micro"
  key_name      = "deployer_key"
  iam_instance_profile = aws_iam_instance_profile.example_profile.name
}

resource "aws_iam_instance_profile" "example_profile" {
  name = "example-profile"
  role = aws_iam_role.example_role.name

  tags = {
    Name = "my-role-instance"
  }
}

resource "aws_key_pair" "generated_key" {
  key_name   = "deployer_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCe01zdkwEgtv2o8msjNkvBbbFUQY0d1Iy6I6F3e7VUMbVT/BgbJ1IE2l1/XHheUWS18EDdVsUmN+IChF+7vgy1wfqSvn9qW33N9BEvkuzEWs2BYw4jntjwAAuPkNLprSYdvejFcVhJNqrTo8Vz4lDLIahzuodmfxgnrfEFqWF508MeQZn6ZGzBC7L4OLxkgGZsHnfCNatVyOcKeuKMLP8i0vz7ZtWJxJzXELowHNr75l/DHkGMz7O5iqYVQtvu5UzpcEerLVp4wwxPIKAR+K9tVKNVivFQucftTE4+/B8sNzMVeQhJgE+k54pRgMA2nxHwC14G7/2oIQsZviLa7z37t1JKX+NwqEVZptUC22Ul318N/5K89bXVi9dgCHszU2PwRJZPQNui+Q78uJlJwqUxQ5jj5Bn32hlb+v0s5mdMeEOdrFsSZPMa/MbCdA31BiRURfPplERDHxtAXwupXMDF7og+toT7GzTkQoQtKe9Yre8nrvnyyxPKEI1ooXoKImE= aditya@LAPTOP-COAUUDVA"

}