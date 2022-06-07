# Ref: https://aws.amazon.com/premiumsupport/knowledge-center/restrict-launch-tagged-ami/

# Policy
# Ensure to set "ec2:ResourceTag/.....": "......" below to your desired tag

resource "aws_iam_policy" "ec2-launch-policy" {
  name        = "EC2LaunchwithAMIsAndTags-Policy"
  path        = "/"
  description = "Allow Launch of EC2 Instances with AMIs with required tags"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "ReadOnlyAccess",
        "Effect": "Allow",
        "Action": [
          "ec2:Describe*",
          "ec2:GetConsole*",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricStatistics",
          "iam:ListInstanceProfiles"
        ],
        "Resource": "*"
      },
      {
        "Sid": "ActionsRequiredtoRunInstancesInVPC",
        "Effect": "Allow",
        "Action": "ec2:RunInstances",
        "Resource": [
          "arn:aws:ec2:us-east-1:AccountId:instance/*",
          "arn:aws:ec2:us-east-1:AccountId:key-pair/*",
          "arn:aws:ec2:us-east-1:AccountId:security-group/*",
          "arn:aws:ec2:us-east-1:AccountId:volume/*",
          "arn:aws:ec2:us-east-1:AccountId:network-interface/*",
          "arn:aws:ec2:us-east-1:AccountId:subnet/*"
        ]
      },
      {
        "Sid": "LaunchingEC2withAMIsAndTags",
        "Effect": "Allow",
        "Action": "ec2:RunInstances",
        "Resource": "arn:aws:ec2:us-east-1::image/ami-*",
        "Condition": {
          "StringEquals": {
            "ec2:ResourceTag/image": "defender"
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

# Attachment Policy
resource "aws_iam_policy_attachment" "ec2-policy-attachment" {
  name       = "EC2LaunchwithAMIsAndTags-PolicyAttachment"
  roles      = ["${aws_iam_role.ec2-access-role.name}"]
  policy_arn = "${aws_iam_policy.ec2-launch-policy.arn}"
}
