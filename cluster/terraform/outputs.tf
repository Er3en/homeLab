output "public_ips" {
  value = [for instance in aws_instance.vm : instance.public_ip]
}
