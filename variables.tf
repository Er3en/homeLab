variable "instance_count" {
  default = 3
}

variable "instance_type" {
  default = "t2.micro"
}

# Ubuntu Server 22.04 LTS (x86_64) - eu-central-1
variable "ami_id" {
  default = "ami-06dd92ecc74fdfb36"
}
