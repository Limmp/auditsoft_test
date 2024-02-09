output "apache-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.apache-worker :
    instance.tags["Name"] => instance.public_ip

  }
}
output "apache-Worker-private-IPs" {
  value = {
    for instance in aws_instance.apache-worker :
    instance.tags["Name"] => instance.private_ip
  }
}

output "elb-DNS" {
  value = aws_elb.web.dns_name
}
