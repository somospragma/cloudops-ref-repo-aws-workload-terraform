####################################################################
# Data Name VPC - Este data trea el resultado de la Infraestructura 
# creada en transversal
####################################################################
data "aws_vpc" "vpc" {
  provider = aws.pra_idp_dev
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-vpc"]
  }
}

####################################################################
# Data Name Subnet Publica - Este data trea el resultado de la 
# Infraestructura  creada en transversal
####################################################################

data "aws_subnet" "public_subnet_1" {
  provider = aws.pra_idp_dev
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-public-1"] 
  }
}

data "aws_subnet" "public_subnet_2" {
  provider = aws.pra_idp_dev
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-public-2"] 
  }
}

####################################################################
# Data Name Subnet Service - Este data trea el resultado de la 
# Infraestructura  creada en transversal
####################################################################

data "aws_subnet" "service_subnet_1" {
  provider = aws.pra_idp_dev
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-service-1"] 
  }
}

data "aws_subnet" "service_subnet_2" {
  provider = aws.pra_idp_dev
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-service-2"] 
  }
}



####################################################################
# Data Account
# 
####################################################################
data "aws_caller_identity" "current" {
  provider = aws.pra_idp_dev
}