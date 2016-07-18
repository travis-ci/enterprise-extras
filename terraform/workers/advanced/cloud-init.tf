resource "template_file" "cloud_init" {
    template = "${file("${path.module}/cloud-init.tpl")}"

    vars {
        enterprise_host_name = "${var.enterprise_host_name}"
        rabbitmq_password = "${var.rabbitmq_password}"
    }
}
