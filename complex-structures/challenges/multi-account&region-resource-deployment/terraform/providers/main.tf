data "template_file" "providers" {
  
  for_each = local.provider_config

  template = "${file("provider.tpl")}"
  
  vars = {
    region = each.value.region
    alias = each.key
    account_id = each.value.account_id
  }
}

resource "null_resource" "providers" {
  
  for_each = data.template_file.providers

  provisioner "local-exec" {
    command = "echo \"${data.template_file.providers[each.key].rendered}\" > ../${each.key}.auto.tf"
  }
}
