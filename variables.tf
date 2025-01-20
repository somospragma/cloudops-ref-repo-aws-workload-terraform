##################################################
# Variable Globales
##################################################
#
variable "client" {
  type = string
}

#
variable "environment" {
  type = string
}

#
variable "aws_region" {
  type = string
}

#
variable "profile" {
  type = string
}

#
variable "common_tags" {
    type = map(string)
    description = "Tags comunes aplicadas a los recursos"
}

#
variable "project" {
  type = string  
}


###############################################################
# Variables IAM - Roles Task - Task Executions - App01
###############################################################
# Variables Rol Task execution
variable "functionality_execution" {
  type = string
}
variable "application_execution" {
  type = string
}
variable "path_execution" {
  type = string
}
variable "type_execution" {
  type = string
}
variable "test_execution" {
  type = string
}
variable "variable_execution" {
  type = string
}
variable "values_execution" {
  type = list(string)
}
variable "service_execution" {
  type = string
  
}

# Variables Rol Task 
variable "functionality_task" {
  type = string
}
variable "application_task" {
  type = string
}
variable "path_task" {
  type = string
}
variable "type_task" {
  type = string
}
variable "test_task" {
  type = string
}
variable "variable_task" {
  type = string
}
variable "values_task" {
  type = list(string)
}
variable "service_task" {
  type = string
  
}

###############################################################
# Variables ECS
###############################################################

variable "application" {
    description = "Nombre de la aplicacion"
    type = string
}