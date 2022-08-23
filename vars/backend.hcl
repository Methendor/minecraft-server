terraform {
  backend "s3" {
    bucket = module.minecraft_server_state_bucket.s3_bucket_id
    key    = "minecraft_server.tfstate"
    region = var.aws_region
  }
}