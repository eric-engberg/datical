variable cidr_block {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable az_list {
  description = "List of Availability zones to create resources in"
  default = ["us-east-1a", "us-east-1b"]
}

variable ec2_cidr {
  default = "10.0.0.0/24"
}

variable db_cidr {
  default = "10.0.1.0/24"
}

variable subnets {
  default = {
    "EC2"      = "10.0.0.0/24"
    "Database" = "10.0.1.0/24"
  }
}

locals {
  # This creates a data structure to loop over to create subnets for all defined availability zones
  subnets = flatten([
    for name, subnet in var.subnets : [
      for zone in var.az_list : {
        name   = format("%s %s Subnet - %s", var.environment, name, zone)
        cidr   = cidrsubnet(subnet, 3, index(var.az_list, zone))
        zone   = zone
      }
    ]
  ])
}

data aws_subnet_ids ec2 {
  vpc_id = aws_vpc.this.id

  filter {
    name   = "tag:Name"
    values = ["${var.environment} EC2 *"]
  }
}

data aws_subnet_ids db {
  vpc_id = aws_vpc.this.id

  filter {
    name   = "tag:Name"
    values = ["${var.environment} Database *"]
  }
}

output ec2_subnet_ids {
  value = data.aws_subnet_ids.ec2.ids
}

output db_subnet_ids {
  value = data.aws_subnet_ids.db.ids
}

output vpc_id {
  value = aws_vpc.this.id
}

resource aws_vpc this {
  cidr_block = var.cidr_block

  enable_dns_hostnames = true
}

resource aws_subnet this {
  for_each = {
    for subnet in local.subnets : subnet.name => subnet
  }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.zone

  tags = {
    Name        = each.value.name
    Environment = "Production"
  }
}

# resource aws_subnet ec2_subnet {
#   count = length(az_list)
#   vpc_id = aws_vpc.this.id
#   cidr_block = local.ec2_subnet

#   tags = {
#     Environment = "Production"
#     Name        = "Production EC2 Subnet"
#   }
# }

# resource aws_subnet db_subnet {
#   vpc_id = aws_vpc.this.id
#   cidr_block = local.db_subnet

#   tags = {
#     Environment = "Production"
#     Name        = "Production Database Subnet"
#   }
# }