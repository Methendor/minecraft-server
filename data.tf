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
  template = file("${path.module}/files/user_data.sh")

  vars = { 
    java_mx_mem    = var.java_mx_mem
    java_ms_mem    = var.java_ms_mem
    mc_root = "/opt/minecraft_server"
    mc_worlds = "/opt/minecraft_worlds"
    mc_bucket = module.minecraft_worlds_bucket.s3_bucket_id
    mc_backup_freq = 5
  }
}