resource "aws_iam_role" "pc_defender_role" {
  name = var.pc_defender_role_name

  assume_role_policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "pc_defender_profile_for_ec2" {
  name = var.pc_defender_profile_for_ec2
  role = aws_iam_role.pc_defender_role.name
}

resource "aws_iam_role_policy" "pc_defender_policy" {
  name = var.pc_defender_policy
  role = aws_iam_role.pc_defender_role.id

  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": [
            "secretsmanager:GetSecretValue"
        ],
        "Resource": "arn:aws:secretsmanager:*",
        "Effect": "Allow"
      }
    ]
  })
}
