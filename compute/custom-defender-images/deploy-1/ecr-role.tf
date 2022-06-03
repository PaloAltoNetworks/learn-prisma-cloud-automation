resource "aws_iam_role" "ecr_role" {
  name = var.ecr_role_name

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

resource "aws_iam_instance_profile" "ecr_profile_for_ec2" {
  name = var.ecr_profile_for_ec2
  role = aws_iam_role.ecr_role.name
}

resource "aws_iam_role_policy" "ecr_policy" {
  name = var.ecr_policy
  role = aws_iam_role.ecr_role.id

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
      }
    ]
  })
}
