output "master_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_ips" {
  value = aws_instance.k8s_workers[*].public_ip
}

