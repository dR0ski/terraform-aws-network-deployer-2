# VPC ID
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_id" {}


# Primary VPC CIDR range that is allocated to the spoke VPC
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_cidr_block" {}


# Primary VPC CIDR range that is allocated to the spoke VPC
# ---------------------------------------------------------------------------------------------------------------
variable "environment_type" {
  description = "Environment in which the VPC exist dev/uat/prod/sandbox/lab"
  type    = string
}

# On-premises IP Range to be added to the spoke VPC security group
# ---------------------------------------------------------------------------------------------------------------

variable "on_premises_cidrs" {
  description = "On-premises or non VPC network range"
  type    = list(string)
  default = [ "172.16.0.0/16", "172.17.0.0/16", "172.18.0.0/16", "172.19.0.0/16", "172.20.0.0/16", "172.22.0.0/16" ]
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
    port_six = {
      to_port = 9092
      from_port = 9092
      description = "Kafka access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_seven = {
      to_port = 2181
      from_port = 2181
      description = "Zookeeper access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_eight = {
      to_port = 3888
      from_port = 3888
      description = "Zookeeper access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_nine = {
      to_port = 2888
      from_port = 2888
      description = "Zookeeper to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_ten = {
      to_port = 9200
      from_port = 9200
      description = "ElasticSearch access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    },
    port_eleven = {
      to_port = 9300
      from_port = 9300
      description = "ElasticSearch access to/from the Amazon VPC and/or on-premises CIDRs"
      protocol = "tcp"
    }
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


