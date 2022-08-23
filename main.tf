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

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = local.tags
}

module "minecraft_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.stack_name}_sg"
  description = "security group for the minecraft server."
  vpc_id      = module.minecraft_server_vpc.vpc_id

ingress_rules            = [ "ssh-tcp"]
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

module "minecraft_server_state_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "methendor-minecraft-state"
  acl    = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  tags = local.tags
}

# module "ec2_minecraft" {
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=master"
#   name   = "${var.name}-public"

#   # instance
#   ami                  = var.ami != "" ? var.ami : data.aws_ami.ubuntu.image_id
#   instance_type        = var.instance_type
#   iam_instance_profile = aws_iam_instance_profile.id
#   user_data            = data.template_file.user_data.rendered

#   # network
#   subnet_id                   = local.subnet_id
#   vpc_security_group_ids      = [ module.ec2_security_group.this_security_group_id ]
#   associate_public_ip_address = var.associate_public_ip_address

#   tags = module.label.tags
# }