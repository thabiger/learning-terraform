## Goal

Having a nested map that groups environments, AWS regions, IAM policies, and roles, the goal is to iterate through these nested structures to create multiple IAM roles and attach the correct policies in each region.

The input structure is as follows:

```
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
```

The resources and outputs to be created go like this.

### Resource creation:

- For each (environment, region) pair, create an IAM role named using a pattern like myrole-{environment}-{region}.
- Attach the relevant policies to that role using an aws_iam_role_policy_attachment resource (or a dynamic block within a single resource, if you prefer).

### Output:

- Produce an output listing all IAM role ARNs you created, keyed by (environment, region).

### Advanced requirement:

- Use a for_each or dynamic blocks to handle the attachments. Avoid writing repeated resource blocks for each policy.