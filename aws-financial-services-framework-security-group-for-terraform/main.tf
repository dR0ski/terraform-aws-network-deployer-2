# Edge Security Security Group creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "database_edge_security_group" {
	name        = "edge_security_group"
	description = "Controls access from external networks to resources inside the Amazon VPC."
	vpc_id      = var.vpc_id

	dynamic "ingress" {
		for_each = var.database_port_list
		iterator = db_grps
		content {
			description = db_grps.value.description
			from_port   = db_grps.value.from_port
			to_port     = db_grps.value.to_port
			protocol    = db_grps.value.protocol
			cidr_blocks = [
			for x in var.on_premises_cidrs:
			x
			]

		} # closes contents
	} #closes dynamic block


	egress {
		description = "Allow the VPC CIDR Block to send traffic out as needed"
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	count        = var.security_grp_traffic_pattern.database == true ? 1 : 0
	tags = {
		Name = var.environment_type
	}


}

# Edge Security Security Group creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "web_edge_security_group" {
	name        = "web_edge_security_group"
	description = "Controls access from external networks to resources inside the Amazon VPC."
	vpc_id      = var.vpc_id

	dynamic "ingress" {
		for_each = var.web_port_list
		iterator = web_grps
		content {
			description = web_grps.value.description
			from_port   = web_grps.value.from_port
			to_port     = web_grps.value.to_port
			protocol    = web_grps.value.protocol
			cidr_blocks = [
			for x in var.on_premises_cidrs:
			x
			]

		} # closes contents
	} #closes dynamic block


	egress {
		description = "Allow the VPC CIDR Block to send traffic out as needed"
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	count        = var.security_grp_traffic_pattern.web == true ? 1 : 0
	tags = {
		Name = var.environment_type
	}


}

# Edge Security Security Group creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "kafka_zookeeper_edge_security_group" {
	name        = "kafka_zookeeper_edge_security_group"
	description = "Controls access from external networks to resources inside the Amazon VPC."
	vpc_id      = var.vpc_id

	dynamic "ingress" {
		for_each = var.kafka_zookeeper_port_list
		iterator = kafka_zookeeper_grps
		content {
			description = kafka_zookeeper_grps.value.description
			from_port   = kafka_zookeeper_grps.value.from_port
			to_port     = kafka_zookeeper_grps.value.to_port
			protocol    = kafka_zookeeper_grps.value.protocol
			cidr_blocks = [
			for x in var.on_premises_cidrs:
			x
			]

		} # closes contents
	} #closes dynamic block


	egress {
		description = "Allow the VPC CIDR Block to send traffic out as needed"
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	count        = var.security_grp_traffic_pattern.kafka_zookeeper == true ? 1 : 0
	tags = {
		Name = var.environment_type
	}


}


# Edge Security Security Group creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "elasticsearch_edge_security_group" {
	name        = "elasticsearch_edge_security_group"
	description = "Controls access from external networks to resources inside the Amazon VPC."
	vpc_id      = var.vpc_id

	dynamic "ingress" {
		for_each = var.elasticsearch_port_list
		iterator = elasticsearch_grps
		content {
			description = elasticsearch_grps.value.description
			from_port   = elasticsearch_grps.value.from_port
			to_port     = elasticsearch_grps.value.to_port
			protocol    = elasticsearch_grps.value.protocol
			cidr_blocks = [
			for x in var.on_premises_cidrs:
			x
			]

		} # closes contents
	} #closes dynamic block


	egress {
		description = "Allow the VPC CIDR Block to send traffic out as needed"
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	count        = var.security_grp_traffic_pattern.elasticsearch == true ? 1 : 0
	tags = {
		Name = var.environment_type
	}


}


# Edge Security Security Group creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "apache_spark_edge_security_group" {
	name        = "apache_spark_edge_security_group"
	description = "Controls access from external networks to resources inside the Amazon VPC."
	vpc_id      = var.vpc_id

	dynamic "ingress" {
		for_each = var.apache_spark_port_list
		iterator = apache_spark_grps
		content {
			description = apache_spark_grps.value.description
			from_port   = apache_spark_grps.value.from_port
			to_port     = apache_spark_grps.value.to_port
			protocol    = apache_spark_grps.value.protocol
			cidr_blocks = [
			for x in var.on_premises_cidrs:
			x
			]

		} # closes contents
	} #closes dynamic block


	egress {
		description = "Allow the VPC CIDR Block to send traffic out as needed"
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	count        = var.security_grp_traffic_pattern.apache_spark == true ? 1 : 0
	tags = {
		Name = var.environment_type
	}


}

# Non-routable Security Group
# ---------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "non_routable_security_group" {
	name        = "spoke_vpc_non_routable_security_group"
	description = "Only allows routing inside the VPC"
	vpc_id      = var.vpc_id

	dynamic "ingress" {
		for_each = var.port_list
		iterator = sec_grps
		content {
			description = sec_grps.value.description
			from_port   = sec_grps.value.from_port
			to_port     = sec_grps.value.to_port
			protocol    = sec_grps.value.protocol
			cidr_blocks = [var.vpc_cidr_block]

		}
	} # closes contents

	ingress {
		description = "TLS encryption to support end-to-end encryption of traffic within the Amazon VPC"
		from_port   = 8443
		to_port     = 8443
		protocol    = "tcp"
		cidr_blocks = [var.vpc_cidr_block]
	}


	egress {
		description = "Allow the VPC CIDR Block to send traffic out as needed"
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = [var.vpc_cidr_block]
	}

	tags = {
		Name = var.environment_type
	}



}

#TODO:
# - Third Security Group: References other security groups for access
# - Database Port Selection based on Dev requirements
