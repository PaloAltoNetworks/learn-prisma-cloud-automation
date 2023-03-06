# Ref: https://aws.amazon.com/premiumsupport/knowledge-center/restrict-launch-tagged-ami/

# Policy
resource "aws_iam_policy" "ec2-launch-policy" {
  name        = "EC2LaunchwithAMIsAndTags-Policy"
  path        = "/"
  description = "Allow Launch of EC2 Instances with AMIs with required tags"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "EC2Access",
        Effect: "Allow",
        Action: [
          "ec2:Describe*",
          "ec2:GetConsole*",
          "ec2:CreateKeyPair",
          "ec2:AssociateIamInstanceProfile",
          "iam:ListInstanceProfiles",
          "iam:PassRole"
        ],
        Resource: "*"
      },
      {
        Sid: "ActionsRequiredtoRunInstancesInVPC",
        Effect: "Allow",
        Action: [
          "ec2:RunInstances",
          "ec2:TerminateInstances"
          ],
        Resource: [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:key-pair/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/*"
        ]
      },
      {
        Sid: "LaunchingEC2withAMIsAndTags",
        Effect: "Allow",
        Action: [
          "ec2:RunInstances",
          "ec2:TerminateInstances"
          ],
        Resource: "arn:aws:ec2:${var.region}::image/ami-*",
        Condition: {
          StringEquals: {
            "ec2:ResourceTag/${var.ami_tag_key}": "${var.ami_tag_value}"
          }
        } 
      }
    ]
  })
}

# Role
resource "aws_iam_role" "ec2-access-role" {
  name                = "EC2LaunchwithAMIsAndTags-Role"
  assume_role_policy  = jsonencode({
   "Version": "2012-10-17",
   "Statement": [
     {
       "Action": "sts:AssumeRole",
       "Principal": {
         "Service": "ec2.amazonaws.com"
       },
       "Effect": "Allow",
       "Sid": ""
     }
   ]
  })
}


# Attachment Policy for Role - Option #1 - Exclusive
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
resource "aws_iam_policy_attachment" "ec2-policy-attachment" {
  name       = "EC2LaunchwithAMIsAndTags-PolicyAttachment"
  roles      = ["${aws_iam_role.ec2-access-role.name}"]
  policy_arn = "${aws_iam_policy.ec2-launch-policy.arn}"
}

# Attachment Policy for Role - Option #2 - Non-exclusive
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
#resource "aws_iam_role_policy_attachment" "role-attach-policy" {
#  role       = aws_iam_role.ec2-access-role.name
#  policy_arn = aws_iam_policy.ec2-launch-policy.arn
#}
