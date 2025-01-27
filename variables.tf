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

variable "port" {
  type = number
  description = "Port number"
}

variable "arn_acm" {
  type = string
  description = "ARN of ACM certificate"
}

#################################################
# Module SG ALB 
#################################################
variable "service_lb" {
  type = string
  description = "Service name for security group ALB" 
}

variable "functionality_lb" {
  type = string
  description = "Functionality name for security group ALB" 
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

variable "health_path" {
  type = string
  description = "Health Path value"
}

variable "url_image_respository" {
  type = string
  description = "ARN Image respository"
}

variable "environment_variables" {
  type = list(object({ 
    name = string
    value  = string
  }))
  description = "Environment task ECS"
}