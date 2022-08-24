data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# policy to allow ec2 instances to use the SSM and S3
resource "aws_iam_policy" "ssm_policy" {
  name = "minecraft-server-ssm-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ssm:*", "ec2messages:*", "ssmmessages:*", "s3:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# create the iam role for ec2 instances and attach the above policys
resource "aws_iam_role" "instance_role" {
  name                = "minecraft-server-instance-role"
  assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.ssm_policy.arn]
}

# create an instance profile to which can be attached to asg configurations
resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = aws_iam_role.instance_role.name
}