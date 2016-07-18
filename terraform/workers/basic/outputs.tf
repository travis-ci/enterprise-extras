output "workers" {
  value = "${join(", ", aws_instance.workers.*.id)}"
}
