locals {

    s3_buckets = {
        for _, bucket in
            flatten([
                for i in var.deployment_targets: [
                    for region, buckets in i.regions: [
                        for name in buckets.bucket_names:
                        {
                            account_alias = "${i.account_alias}-${region}"
                            bucket_name = name
                            bucket_tags = buckets.bucket_tags   
                        }
                    ]
                ]
            ]):
        bucket.bucket_name => bucket
    }       
}

provider "aws" {

    for_each = local.provider_config

    region = each.value.region
    alias = "multi_provider"
    
    assume_role {
        role_arn = "arn:aws:iam::${each.value.account_id}:role/OrganizationAccountAccessRole"
    }
}

# create buckets using a resource
# resource "aws_s3_bucket" "b" {

#     for_each = local.s3_buckets

#     provider = aws.multi_provider[each.value.account_alias]
    
#     bucket = each.key
#     tags = local.s3_buckets[each.key].bucket_tags
# }

# create buckets using a module
module "s3" {
  for_each = local.s3_buckets

  source    = "../../../../modules/s3"

  providers = {
    aws = aws.multi_provider[each.value.account_alias]
  }

  name = each.key
  tags = local.s3_buckets[each.key].bucket_tags
}


output "s3_buckets" {
  value = local.s3_buckets
}