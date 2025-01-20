###############################################################
# Variables Globales
###############################################################

aws_region = "us-east-1"

#
profile = "pra_idp_dev"

#
environment = "dev"

#
client = "pragma"

#
project = "fc"
#
application="app01"
#
common_tags = {
  environment  = "dev"
  project-name = "Modulos Referencia"
  cost-center  = "-"
  owner        = "cristian.noguera@pragma.com.co"
  area         = "KCCC"
  provisioned  = "terraform"
  datatype     = "interno"
}


###############################################################
# Variables IAM - Roles Task - Task Executions
###############################################################
# Rol Excution Task
functionality_execution = "web001"
application_execution   = "app01"
service_execution       = "execution"
path_execution          = "/service-role/"
type_execution          = "AWS"
test_execution          = "StringLike"
variable_execution      = "aws:RequestTag/project"
values_execution        = ["hefesto"]

# Rol Task
functionality_task = "web001"
application_task   = "app01"
service_task       = "task"
path_task          = "/service-role/"
type_task          = "AWS"
test_task          = "StringLike"
variable_task      = "aws:RequestTag/project"
values_task        = ["hefesto"]
