provider "aws" {

    region = "\"${region}\""
    alias =  "\"${alias}\""
    
    assume_role {
        role_arn = "\"arn:aws:iam::${account_id}:role/OrganizationAccountAccessRole\""
    }
}
