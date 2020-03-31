output "cloudinit_config_rendered" {
    value = "${data.template_file.sa-demo-plex-user-data.rendered}"
}
