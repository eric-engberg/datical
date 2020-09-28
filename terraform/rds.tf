resource aws_db_instance prod {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "12.4"
  instance_class         = "db.t2.micro"
  name                   = "uat_dev"

  # Username and password would be stored in Vault in a real environment
  username               = "yourusername"
  password               = "yoursecurepassword"
  #parameter_group_name  = "default.mysql5.7"
  apply_immediately      = true
  identifier             = lower(var.environment)
  #vpc_security_group_is = []
  db_subnet_group_name   = aws_db_subnet_group.prod.name
  skip_final_snapshot    = true

}

resource aws_db_subnet_group prod {
  name       = lower(var.environment)
  # Hard code subnets to get it working quickly
  subnet_ids = [
    aws_subnet.this["${var.environment} Database Subnet - us-east-1a"].id,
    aws_subnet.this["${var.environment} Database Subnet - us-east-1b"].id,
  ]

  tags = {
    Name        = "${var.environment} DB Subnet Group"
    Environment = var.environment
  }
}