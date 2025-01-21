###########################################
########## Common variables ###############
###########################################

profile     = "pra_idp_dev"
aws_region  = "us-east-1"
environment = "dev"
client      = "cliente01"
project     = "proyecto01"
application = "app01"
common_tags = {
  environment   = "dev"
  project-name  = "proyecto01"
  cost-center   = "xxx"
  owner         = "xxx"
  area          = "xxx"
  provisioned   = "xxx"
  datatype      = "xxx"
}


#################################################
# IAM - Task Roles - Task Executions - Variables
#################################################

# Task execution role
functionality_execution = "web001"
application_execution   = "app01"
service_execution       = "execution"
path_execution          = "/service-role/"
type_execution          = "AWS"
test_execution          = "StringLike"
variable_execution      = "aws:RequestTag/project"
values_execution        = ["hefesto"]

# Task role
functionality_task = "web001"
application_task   = "app01"
service_task       = "task"
path_task          = "/service-role/"
type_task          = "AWS"
test_task          = "StringLike"
variable_task      = "aws:RequestTag/project"
values_task        = ["hefesto"]
