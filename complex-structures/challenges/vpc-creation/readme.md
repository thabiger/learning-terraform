## Goal

Having a single 'mega-object' describing multiple VPCs, their subnets, and the routing rules for each subnet, transform its data to create VPCs, subnets, and route tables with routes.

### Requirements

## Input structure:
- Keys (main_vpc, secondary_vpc, etc.) represent distinct VPCs,
- Each VPC has a cidr_block and a map of subnets,
- Each subnet has a cidr_block and possibly multiple route_rules.

A variable named var.network_config looks like:

```
variable "network_config" {
  type = map(object({
    cidr_block = string
    subnets     = map(object({
      cidr_block  = string
      route_rules = list(object({
        destination_cidr_block = string
        gateway_id             = string
      }))
    }))
  }))
  default = {
    main_vpc = {
      cidr_block = "10.0.0.0/16"
      subnets = {
        public_subnet = {
          cidr_block = "10.0.1.0/24"
          route_rules = [
            {
              destination_cidr_block = "0.0.0.0/0"
              gateway_id             = "igw-123456"
            }
          ]
        }
        private_subnet = {
          cidr_block = "10.0.2.0/24"
          route_rules = []
        }
      }
    }
    secondary_vpc = {
      cidr_block = "10.1.0.0/16"
      subnets = {
        apps_subnet = {
          cidr_block = "10.1.1.0/24"
          route_rules = [
            {
              destination_cidr_block = "0.0.0.0/0"
              gateway_id             = "igw-abcde"
            }
          ]
        }
      }
    }
  }
}
```

## Resource creation:
- Create 1 VPC per top-level key (use for_each).
- For each VPC, create subnets (again for_each or dynamic).
- For each subnet, create a route table and the route(s) defined in route_rules.

## Advanced requirement:
- Use local values to simplify references to the VPC and subnets (e.g., storing IDs in a local map).
- Consider using dynamic blocks for route creation within a single aws_route_table resource or a separate route resource.