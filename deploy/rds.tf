locals {
	db_name     = "appdb"
	db_username = "dbadmin"
}

resource "aws_security_group" "rds" {
	name        = "${local.name_prefix}-rds-sg"
	description = "RDS security group"
	vpc_id      = aws_vpc.main.id

	ingress {
		description = "MySQL/MariaDB from VPC"
		from_port   = 3306
		to_port     = 3306
		protocol    = "tcp"
    # Only allow private subnets connectivity
		cidr_blocks = [local.subnets.subnet_a.private_cidr, local.subnets.subnet_b.private_cidr]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_db_subnet_group" "rds" {
	name       = "${local.name_prefix}-rds-subnets"
	subnet_ids = [
		module.subnets_a.private_subnet_id,
		module.subnets_b.private_subnet_id,
	]
}

resource "aws_db_parameter_group" "mariadb" {
	name   = "${local.name_prefix}-mariadb-params"
	family = "mariadb11.8"
	description = "Parameter group for MariaDB 11.8"

	parameter {
		name  = "character_set_server"
		value = "utf8mb4"
	}
	parameter {
		name  = "collation_server"
		value = "utf8mb4_unicode_ci"
	}
}

resource "random_password" "db_master" {
	length  = 24
	special = true
}

resource "aws_secretsmanager_secret" "db_master" {
	name        = "${local.name_prefix}-db-master"
	description = "Master credentials for ${local.name_prefix} MariaDB"
}

resource "aws_secretsmanager_secret_version" "db_master" {
	secret_id     = aws_secretsmanager_secret.db_master.id
	secret_string = jsonencode({
		username = local.db_username
		password = random_password.db_master.result
		host     = aws_db_instance.mariadb.address
		port     = 3306
		dbname   = local.db_name
	})
}

resource "aws_db_instance" "mariadb" {
	identifier                 = "${local.name_prefix}-mariadb"
	availability_zone          = data.aws_availability_zones.available.names[0]
	allocated_storage          = 20
	max_allocated_storage      = 50
	storage_type               = "gp3"
	engine                     = "mariadb"
	engine_version             = "11.8.3"
	instance_class             = "db.m5.large"
	db_name                    = local.db_name
	username                   = local.db_username
	password                   = random_password.db_master.result
	port                       = 3306
	multi_az                   = false
	publicly_accessible        = false
	deletion_protection        = false
	skip_final_snapshot        = true
	backup_retention_period    = 7
	auto_minor_version_upgrade = true
	apply_immediately          = true
	storage_encrypted          = true
	performance_insights_enabled = false

	vpc_security_group_ids = [aws_security_group.rds.id]
	db_subnet_group_name   = aws_db_subnet_group.rds.name
	parameter_group_name   = aws_db_parameter_group.mariadb.name

	depends_on = [module.subnets_a, module.subnets_b]
}

resource "aws_db_instance" "mariadb_replica" {
	identifier           = "${local.name_prefix}-mariadb-replica-1"
	replicate_source_db  = aws_db_instance.mariadb.id
	instance_class       = "db.m5.large"
	availability_zone    = data.aws_availability_zones.available.names[1]
	publicly_accessible  = false
	apply_immediately    = true
	auto_minor_version_upgrade = true

	vpc_security_group_ids = [aws_security_group.rds.id]
	db_subnet_group_name   = aws_db_subnet_group.rds.name

	depends_on = [aws_db_instance.mariadb]
}

