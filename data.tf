data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  # vars = {
  #   mc_root        = var.mc_root
  #   mc_bucket      = local.bucket
  #   mc_backup_freq = var.mc_backup_freq
  #   mc_version     = var.mc_version
  #   mc_type        = var.mc_type   
  #   java_mx_mem    = var.java_mx_mem
  #   java_ms_mem    = var.java_ms_mem
  # }
}