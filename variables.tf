variable "aws_region" {
  description = "aws region to be used for all objects"
  default     = "eu-west-2"
}

variable "stack_name" {
  description = "default name for the stack"
  default     = "methendor_minecraft"
}

variable "instance_ami" {
  description = "the ami used by the minecraft instance"
  default     = "ami-00785f4835c6acf64"
}

variable "instance_type" {
  description = "the size of the minecraft instance"
  default     = "t2.small"
}

variable "port" {
  description = "port the minecraft server will allow access on"
  type        = number
  default     = 25565
}