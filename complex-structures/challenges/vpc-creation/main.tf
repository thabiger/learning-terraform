
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


locals {
    subnets = { 
        for _, subnet in
            flatten([
                for vpc_id, vpc in var.network_config: [
                    for name, subnet in vpc.subnets: 
                        merge(subnet, {
                            name   = name
                            vpc_id = vpc_id
                        })
                ]
            ]):
        "${subnet.vpc_id}-${subnet.name}" => subnet
    }
}

resource "aws_vpc" "main" {
  
  for_each = var.network_config

  cidr_block       = each.value.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "main" {

  for_each = local.subnets

  vpc_id     = each.value.vpc_id
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "main" {

  for_each = local.subnets

  vpc_id = each.value.vpc_id

  dynamic "route" {
    for_each = each.value.route_rules

    content {
        cidr_block = route.value.destination_cidr_block
        gateway_id = route.value.gateway_id
    }
  }
  tags = {
    Name = "rt-${each.key}"
  }
}

output "subnets" {
    value = local.subnets
}