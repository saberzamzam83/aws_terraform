variable "access_key_prefix" {
  description = "AWS access key"
}
variable "secret_key_prefix" {
  description = "AWS secret key"
}
variable "vpc_prefix" {
  description = "VPC CIDR"
}
variable "subnet_prefix" {
  description = "Subnet CIDR"
}
variable "private_ips_prefix" {
  description = "AWS EIP association with private IP"
}
variable "aws_eip_association_prefix" {
  description = "AWS EIP association with private IP"
}
variable "aim_prefix" {
  description = "AWS EC2 aim ID"
}