# Environment Type
# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "environment_type" {
  type    = string
  description = "The environment type that the network is being created for. That is, DEV/PROD/UAT/SANDBOX."
}



# VPC Tenancy Bool. There are two tenancy type [default, dedicated]
# ---------------------------------------------------------------------------------------------------------------
variable "instance_tenancy" {
  type    = string
  validation {
    condition     = var.instance_tenancy == "default" || var.instance_tenancy == "dedicated"
    error_message = "VPC tenancy must be of type default or dedicated."
  }
}

# DNS_Support Bool Variable. This is used in the DHCP Option Set for the VPC
# ---------------------------------------------------------------------------------------------------------------
variable "dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type    = bool
  validation {
    condition     = (var.dns_support == true)
    error_message = "DNS Support flag must be either true or false."
  }
}

# DNS_Hostname Bool Variable. This is used in the DHCP Option Set for the VPC
# ---------------------------------------------------------------------------------------------------------------
variable "dns_host_names" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type    = bool
  validation {
    condition     = (var.dns_host_names == true)
    error_message = "DNS Hostname flag must be either true or false."
  }
}

# Primary VPC CIDR range that is allocated to the spoke VPC
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_cidr_block" {
  description = "The cidr block allocated to this vpc."
  type    = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}($|/(16|17|18|19|20|21|22|23|24|25|26|27|28))$", var.vpc_cidr_block))
    error_message = "Invalid IPv4 CIDR Block."
  }
}

# Enable an AWS provided /56 IPv6 CIDR Block with /64 Subnet Ranges
# ---------------------------------------------------------------------------------------------------------------
variable "enable_aws_ipv6_cidr_block"{
  description = "Enable and add an AWS Provided IPv6 Address block"
  type    = bool
  validation {
    condition     = (var.enable_aws_ipv6_cidr_block == false)
    error_message = "IPv6 flag must be false for now."
  }
}

# AWS Region decalration
# ---------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  type    = string
  validation {
    # The condition here identifies if the variable contains one of the AWS Regions specified. This list can be reduced.
    condition = can(regex("us-east-2|us-east-1|us-west-1|us-west-2|af-south-1|ap-east-1|ap-south-1|ap-northeast-3|ap-northeast-2|ap-southeast-1|ap-southeast-2|ap-northeast-1|ca-central-1|eu-central-1|eu-west-1|eu-west-2|eu-south-1|eu-west-3|eu-north-1|me-south-1|sa-east-1", var.aws_region))
    error_message = "Invalid AWS Region entered."
  }

}

# VPC Flow enablement bool
# ---------------------------------------------------------------------------------------------------------------
variable "enable_vpc_flow_logs" {
  description = "Whether vpc flow log should be enabled for this vpc."
  type    = bool
  validation {
    condition     = (var.enable_vpc_flow_logs == true) || (var.enable_vpc_flow_logs == false)
    error_message = "IPv6 flag must be false for now."
  }
}



# On-premises IP Range to be added to the spoke VPC security group
# ---------------------------------------------------------------------------------------------------------------

variable "on_premises_cidrs" {
  description = "On-premises or non VPC network range"
  type    = list(string)
}


variable "security_grp_traffic_pattern" {
  type = map(bool)
  default = {
    database                = true
    web                     = true
    kafka_zookeeper         = true
    elasticsearch           = true
    apache_spark            = true

  }
}


# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "port_list" {
  description = "An object map of ports required for the creation of the routable and non routable Security Groups."
  type = map(object({
    to_port = number
    from_port = number
    description = string
    protocol = string
  }))

  default = {
    port_one = {
      to_port = 3306
      from_port = 3306
      description = "MySQL access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_two = {
      to_port = 1433
      from_port = 1433
      description = "SQL Server access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_three = {
      to_port = 443
      from_port = 443
      description = "TLS encryption to support end-to-end encryption of traffic from external sources to the Amazon VPC"
      protocol = "tcp"
    },
    port_four = {
      to_port = 5432
      from_port = 5432
      description = "Postgres access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_five = {
      to_port = 1521
      from_port = 1521
      description = "Oracle access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    # port_six = {
    #   to_port = 9092
    #   from_port = 9092
    #   description = "Kafka access to/from the Amazon VPC and/or on-premises CIDRs"
    #   protocol = "tcp"
    # },
    # port_seven = {
    #   to_port = 2181
    #   from_port = 2181
    #   description = "Zookeeper access to/from the Amazon VPC and/or on-premises CIDRs"
    #   protocol = "tcp"
    # },
    # port_eight = {
    #   to_port = 3888
    #   from_port = 3888
    #   description = "Zookeeper access to/from the Amazon VPC and/or on-premises CIDRs"
    #   protocol = "tcp"
    # },
    # port_nine = {
    #   to_port = 2888
    #   from_port = 2888
    #   description = "Zookeeper to/from the Amazon VPC and/or on-premises CIDRs"
    #   protocol = "tcp"
    # },
    # port_ten = {
    #   to_port = 9200
    #   from_port = 9200
    #   description = "ElasticSearch access to/from the Amazon VPC and/or on-premises CIDRs"
    #   protocol = "tcp"
    # },
    # port_eleven = {
    #   to_port = 9300
    #   from_port = 9300
    #   description = "ElasticSearch access to/from the Amazon VPC and/or on-premises CIDRs"
    #   protocol = "tcp"
    # }
  }
}

# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "database_port_list" {
  description = "An object map of ports required for the creation of the routable and non routable Security Groups."
  type = map(object({
    to_port = number
    from_port = number
    description = string
    protocol = string
  }))

  default = {
    port_one = {
      to_port = 3306
      from_port = 3306
      description = "MySQL access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_two = {
      to_port = 1433
      from_port = 1433
      description = "SQL Server access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_three = {
      to_port = 5432
      from_port = 5432
      description = "Postgres access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_four = {
      to_port = 1521
      from_port = 1521
      description = "Oracle access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    }
  }
}

# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "web_port_list" {
  description = "An object map of ports required for the creation of the routable and non routable Security Groups."
  type = map(object({
    to_port = number
    from_port = number
    description = string
    protocol = string
  }))

  default = {
    port_one = {
      to_port = 8443
      from_port = 8443
      description = "Internal HTTPS ports"
      protocol = "tcp"
    },
    port_two = {
      to_port = 443
      from_port = 443
      description = "TLS encryption to support end-to-end encryption of traffic from external sources to the Amazon VPC"
      protocol = "tcp"
    }
  }
}


# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "kafka_zookeeper_port_list" {
  description = "An object map of ports required for the creation of the routable and non routable Security Groups."
  type = map(object({
    to_port = number
    from_port = number
    description = string
    protocol = string
  }))

  default = {
    port_one = {
      to_port = 9092
      from_port = 9092
      description = "Kafka access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_two = {
      to_port = 2181
      from_port = 2181
      description = "Zookeeper access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_three = {
      to_port = 3888
      from_port = 3888
      description = "Zookeeper access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_four = {
      to_port = 2888
      from_port = 2888
      description = "Zookeeper to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    }
  }
}

# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "elasticsearch_port_list" {
  description = "An object map of ports required for the creation of the routable and non routable Security Groups."
  type = map(object({
    to_port = number
    from_port = number
    description = string
    protocol = string
  }))

  default = {
    port_one = {
      to_port = 9200
      from_port = 9200
      description = "ElasticSearch access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_two = {
      to_port = 9300
      from_port = 9300
      description = "ElasticSearch access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    }
  }
}



# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "apache_spark_port_list" {
  description = "An object map of ports required for the creation of the routable and non routable Security Groups."
  type = map(object({
    to_port = number
    from_port = number
    description = string
    protocol = string
  }))

  default = {
    port_one = {
      to_port = 7077
      from_port = 7077
      description = "Spark Standalone Master (RPC)"
      protocol = "tcp"
    },
    port_two = {
      to_port = 8580
      from_port = 8580
      description = "Spark Standalone Master (Web UI)"
      protocol = "tcp"
    },
    port_three = {
      to_port = 8980
      from_port = 8980
      description = "Spark Standalone Master (Web UI)"
      protocol = "tcp"
    },
    port_four = {
      to_port = 8581
      from_port = 8581
      description = "Spark Standalone Worker"
      protocol = "tcp"
    },
    port_five = {
      to_port = 2304
      from_port = 2304
      description = "Spark Thrift Server"
      protocol = "tcp"
    },
    port_six = {
      to_port = 18080
      from_port = 18080
      description = "Spark History Server"
      protocol = "tcp"
    },
    port_seven = {
      to_port = 18480
      from_port = 18480
      description = "Spark History Server"
      protocol = "tcp"
    },
    port_eight = {
      to_port = 7337
      from_port = 7337
      description = "Spark External Shuffle Service (if yarn shuffle service is enabled)"
      protocol = "tcp"
    },
    port_nine = {
      to_port = 7222
      from_port = 7222
      description = "CLDB"
      protocol = "tcp"
    },
    port_ten = {
      to_port = 	5181
      from_port = 	5181
      description = "ZooKeeper"
      protocol = "tcp"
    },
    port_eleven = {
      to_port = 8032
      from_port = 8032
      description = "Nodes running ResourceManager"
      protocol = "tcp"
    },
    port_twelve = {
      to_port = 5660
      from_port = 5660
      description = "MapR Filesystem Server"
      protocol = "tcp"
    },
    port_thirteen = {
      to_port = 5692
      from_port = 5692
      description = "MapR Filesystem Server"
      protocol = "tcp"
    }

  }
}


