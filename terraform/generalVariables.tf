variable "vpc_cidr" {
  default     = "10.123.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "volume_size" {
  default = 12
  type    = number
}

variable "key_name" {
  default     = "mtckey"
  type        = string
  description = "Name of the AWS key pair for EC2 instances"
}

variable "public_key_path" {
  default     = "/home/ubuntu/.ssh/mtckey.pub"
  type        = string
  description = "Path to the public key file for the AWS key pair"
}
