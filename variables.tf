###########################################
########## Common variables ###############
###########################################

variable "profile" {
  type = string
  description = "Profile name containing the access credentials to deploy the infrastructure on AWS"
}

variable "common_tags" {
  type = map(string)
  description = "Common tags to be applied to the resources"
}

variable "aws_region" {
  type = string
  description = "AWS region where resources will be deployed"
}

variable "environment" {
  type = string
  description = "Environment where resources will be deployed"
}

variable "client" {
  type = string
  description = "Client name"
}

variable "project" {
  type = string  
  description = "Project name"
}

variable "application" {
  type = string
  description = "Application name"
}

variable "functionality" {
  type = string
  description = "Functionality name"
}

###########################################
############ ALB variables ################
###########################################

variable "port_number" {
  type = number
  description = "Port number"
}

variable "acm_arn_certificate" {
  type = string
  description = "ARN of ACM certificate"
}

#################################################
# IAM - Task Roles - Task Executions - Variables
#################################################

# Task execution role variables
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

# Task role variables 
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


###########################################
############ ECS variables ################
###########################################

variable "memory" {
  type = number
  description = "Memory value"
}

variable "cpu" {
  type = number
  description = "CPU value"
}