###########################################
########## Common variables ###############
###########################################

profile     = "pra_idp_dev"
aws_region  = "us-east-1"
environment = "dev"
client      = "pragma"
project     = "fc"
application = "app01"
functionality = "web001"
common_tags = {
  environment  = "dev"
  project-name = "Modulos Referencia"
  cost-center  = "-"
  owner        = "cristian.noguera@pragma.com.co"
  area         = "KCCC"
  provisioned  = "terraform"
  datatype     = "interno"
}


#################################################
# IAM - Task Roles - Task Executions - Variables
#################################################

# Task execution role
service_execution       = "execution"
path_execution          = "/service-role/"
type_execution          = "Service"

# Task role
service_task       = "task"
path_task          = "/service-role/"
type_task          = "Service"


#################################################
# ECS - Service - Task - Variables
#################################################
arn_acm = "arn:aws:acm:us-east-1:008971642453:certificate/7cb55d32-3f7c-4311-9b78-5d6da1cc6448"
cpu = 256
memory = 512
port = "80"
health_path = "/"
url_image_respository = "008971642453.dkr.ecr.us-east-1.amazonaws.com/pragma-fc-dev-nginx-ecr"

#################################################
# SG ALB 
#################################################
service_alb = "alb"
functionality_alb = "back"