## Goal

Deploy a set of resources (e.g., S3 buckets) across multiple AWS accounts and regions, where each region might have a different set of bucket properties.

## Requirements

### Provider setup
Configure multiple AWS providers referencing different accounts (e.g., aws.account1, aws.account2) with assumed roles.
Each provider might also be configured with multiple regions.

### Data structure
Let's say you have a variable var.deployment_targets describing which accounts and regions to deploy to, plus a set of bucket attributes:

```
variable "deployment_targets" {
  type = list(object({
    account_alias = string
    regions       = map(object({
      bucket_names = list(string)
      bucket_tags  = map(string)
    }))
  }))
}
```

#### Example value:

```
default = [
  {
    account_alias = "account1"
    regions = {
      "us-east-1" = {
        bucket_names = ["myapp-logs", "myapp-data"]
        bucket_tags  = { environment = "dev", owner = "team1" }
      }
      "eu-west-1" = {
        bucket_names = ["myapp-archive"]
        bucket_tags  = { environment = "dev", owner = "team1" }
      }
    }
  },
  {
    account_alias = "account2"
    regions = {
      "us-east-1" = {
        bucket_names = ["myapp-logs-prod"]
        bucket_tags  = { environment = "prod", owner = "team2" }
      }
    }
  }
]
```

### Resource creation
- For each element in the list, identify the correct AWS provider alias (e.g., aws.account1 or aws.account2).
- For each region in regions, set the provider's region argument dynamically.
- Create S3 buckets in each region, naming them with the values in bucket_names.
- Tag the buckets with bucket_tags.

### Advanced requirement
- Use for_each with a complex key (e.g., "{account_alias}-{region}-{bucket_name}").
- Store references to the created bucket ARNs in a local map or outputs for potential cross-module referencing.
- Try to put the S3-related code in a module.