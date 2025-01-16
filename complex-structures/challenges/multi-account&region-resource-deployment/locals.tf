locals {

    accounts = {
        for account in var.accounts:
            account.alias => account.id
    }

    provider_config = {
        for _, provider in
            flatten([
                for i in var.deployment_targets: [
                    for region, _ in i.regions:
                        {
                            account_alias  = i.account_alias
                            account_id     = local.accounts[i.account_alias]
                            region         = region
                        }
                ]
            ]):
        "${provider.account_alias}-${provider.region}" => provider
    }     
}

output "accounts" {
    value = local.accounts
}


output "provider_config" {
    value = local.provider_config
}