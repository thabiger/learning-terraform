variable "iam_setup" {
  type = map(map(list(string)))
  default = {
    dev = {
      "us-east-1" = ["arn:aws:iam::aws:policy/ReadOnlyAccess", "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"]
      "us-west-2" = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
    prod = {
      "us-east-1" = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  }
}

locals {

    iam_roles = {
      for _, object in

          flatten([
            for env_name, env_data in var.iam_setup: [
              for region, policies in env_data: {
                name = "${env_name}-${region}"
                policies = policies
              }
            ]
          ]):

      object.name => object.policies
    }

    iam_policies = {
      for _, object in
        flatten([
          for role, policies in local.iam_roles: [
            for policy in policies:
              {
                role = role  
                policy = policy
              }
          ]
        ]):
      md5("${object.role}-${object.policy}") => object
    }
}

resource "aws_iam_role" "test_role" {
  
  for_each = local.iam_roles
  
  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpecificUserToAssumeRole"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
            "AWS": "arn:aws:iam::123456789012:user/alice"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test-attach" {

  for_each = local.iam_policies

  role       = each.value.role
  policy_arn = each.value.policy
}


output iam_roles {
    value = local.iam_roles
}

output iam_policies {
    value = local.iam_policies
}



