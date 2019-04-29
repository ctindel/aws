output "cloudinit_config_rendered" {
    value = "${data.template_file.sa-demo-cassandra-user-data.rendered}"
}
