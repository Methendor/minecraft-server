terraform {
  backend "s3" {
    bucket = "methendor-minecraft-state"
    key    = "minecraft_server.tfstate"
    region = "eu-west-2"
  }
}

module "minecraft_server_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.stack_name}_vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = local.tags
}

module "minecraft_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.stack_name}_sg"
  description = "security group for the minecraft server."
  vpc_id      = module.minecraft_server_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "Minecraft Server"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules = ["all-all"]
}

module "ec2_minecraft" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Minecraft Server"

  # instance
  ami                  = var.instance_ami
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.instance_profile.id
  user_data            = data.template_file.user_data.rendered

  # network
  subnet_id                   = module.minecraft_server_vpc.public_subnets[0]
  vpc_security_group_ids      = [module.minecraft_server_sg.security_group_id]
  associate_public_ip_address = true

  tags = local.tags
}

module "minecraft_worlds_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "methendor-minecraft-worlds"
  acl    = "private"
  force_destroy = true

  versioning = {
    enabled = true
  }

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = local.tags
}

module "minecraft_web_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "methendor-minecraft-website"
  acl    = "private"
  force_destroy = true

  versioning = {
    enabled = true
  }

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = local.tags
}