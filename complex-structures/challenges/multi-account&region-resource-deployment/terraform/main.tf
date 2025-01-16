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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "myapp-archive" {

    provider = aws.account1-eu-central-1
    
    bucket = "myapp-archive"
    tags = local.s3_buckets["myapp-archive"].bucket_tags
}

resource "aws_s3_bucket" "myapp-data" {

    provider = aws.account1-eu-central-1
    
    bucket = "myapp-data"
    tags = local.s3_buckets["myapp-data"].bucket_tags
}

resource "aws_s3_bucket" "myapp-logs" {

    provider = aws.account1-eu-west-1
    
    bucket = "myapp-logs"
    tags = local.s3_buckets["myapp-logs"].bucket_tags
}

resource "aws_s3_bucket" "myapp-logs-prod" {

    provider = aws.account2-us-east-1
    
    bucket = "myapp-logs-prod"
    tags = local.s3_buckets["myapp-logs-prod"].bucket_tags
}



output "s3_buckets" {
  value = local.s3_buckets
}