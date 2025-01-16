variable "deployment_targets" {
    type = list(object({
        account_alias = string
        regions       = map(object({
            bucket_names = list(string)
            bucket_tags  = map(string)
        }))
    }))

    default = [
        {
            account_alias = "account1"
            regions = {
                "eu-central-1" = {
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
}

variable "accounts" {
    type = list(object({
        alias = string
        id    = string
    }))

    default = [
        {
            alias = "account1"
            id    = "111111111111"
        },
        {
            alias = "account2"
            id    = "222222222222"
        }
    ]
}
