###########################################
###### Security Group Module - ALB ########
###########################################

module "sg_alb" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-sg-terraform.git?ref=feature/sg-module-init"

  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  environment = var.environment
  
  sg_config = [
    {
      application = var.application
      description = "Security group for ALB"
      vpc_id      = data.aws_vpc.vpc.id

      ingress = [
        {
          from_port       = var.port
          to_port         = var.port
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          prefix_list_ids = []
          self            = false
          description     = "Allow HTTPS inbound"
        }
      ]

      egress = [
        {
          from_port       = 0
          to_port         = 0
          protocol        = "-1"
          cidr_blocks     = ["0.0.0.0/0"]
          prefix_list_ids = []
          description     = "Allow all outbound traffic"
        }
      ]
    }
  ]
}

###########################################
############# ALB Module ##################
###########################################

module "alb" {
  #Before using the module, once you have the new location of your repo, you need to change the source value.
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-elb-terraform.git?ref=feature/elb-module-init"

  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  service     = "alb" 
  environment = var.environment

  lb_config = [{
    internal           = false
    load_balancer_type = "application"
    subnets            = [data.aws_subnet.public_subnet_1.id, data.aws_subnet.public_subnet_2.id]
    security_groups    = [module.sg_alb.sg_info["alb-${var.application}"].sg_id]
    application_id     = var.application
    accessclass        = "public"

    # Target Group configuration
    target_groups = [{
      target_application_id = var.functionality #(PENDING FOR VALIDATION)
      port                  = var.port
      protocol              = "HTTP"
      vpc_id                = data.aws_vpc.vpc.id
      target_type           = "ip"
      healthy_threshold     = "2"
      interval              = "30"
      path                  = var.health_path
      unhealthy_threshold   = "2"
    }]

    # Listeners configuration
    listeners = [
      # HTTP Listener (80) to redirect to HTTPS
      {
        port     = var.port
        protocol = "HTTP"
        default_action = {
          type = "redirect"
          redirect = {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
          }
        }
      },
      # HTTPS Listener (443) to send to the above target group ⬆
      {
        port            = 443
        protocol        = "HTTPS"
        certificate_arn = var.acm_arn_certificate
        default_action = {
          type             = "forward"
          target_group_key = var.functionality
        }
      }
    ]
  }]
  depends_on = [module.sg_alb]
}

###########################################
### Security Group Module - ECS Service ###
###########################################

module "sg_ecs_web01" {
  #Before using the module, once you have the new location of your repo, you need to change the source value.
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-sg-terraform.git?ref=feature/sg-module-init"

  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  sg_config = [
    {
      application = var.application
      description = "Security group for ALB"
      vpc_id      = data.aws_vpc.vpc.id

      ingress = [
        {
          from_port       = var.port
          to_port         = var.port
          protocol        = "tcp"
          cidr_blocks     = []
          security_groups = [module.sg_alb.sg_info["alb-${var.application}"].sg_id]
          prefix_list_ids = []
          self            = false
          description     = "Allow HTTP inbound security group ALB"
        }
      ]

      egress = [
        {
          from_port       = 0
          to_port         = 0
          protocol        = "-1"
          cidr_blocks     = ["0.0.0.0/0"]
          prefix_list_ids = []
          description     = "Allow all outbound traffic"
        }
      ]
    }
  ]
}

###########################################
############# ECR Module ##################
###########################################

module "ecr" {
  #Before using the module, once you have the new location of your repo, you need to change the source value.
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-ecr-terraform.git?ref=feature/ecr-module-init"
  
  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  application = var.application
  environment = var.environment

  ecr_config = [
    {
      application_id           = var.application
      force_delete             = true
      image_tag_mutability     = "MUTABLE"
      encryption_configuration = []
      image_scanning_configuration = [
        {
          scan_on_push = "true"
        }
      ]
      accessclass = "private"
      # Lifecycle policy to remove old images
      lifecycle_rules = [
        {
          rulePriority = 1
          description  = "Remove images older than 180 days"
          selection = {
            tagStatus   = "any"
            countType   = "sinceImagePushed"
            countUnit   = "days"
            countNumber = 180
          }
          action = {
            type = "expire"
          }
        }
      ]
    }
  ]
}

###########################################
############# IAM Module ##################
###########################################

module "iam" {
  #Before using the module, once you have the new location of your repo, you need to change the source value.
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-iam-terraform.git?ref=feature/iam-module-init"
  
  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  iam_config = [
    {
      functionality = var.functionality
      application   = var.application
      service       = var.service_execution
      path          = var.path_execution
      type          = var.type_execution
      identifiers   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      principal_conditions = [
        {
          test     = var.test_execution
          variable = var.variable_execution
          values   = var.values_execution
        }
      ]
      policies = [
        {
          policy_description = "Policy to allow access to S3 and DynamoDB"
          policy_statements = [
            {
              sid       = "AllowS3Access"
              actions   = ["s3:ListBucket", "s3:GetObject"]
              resources = ["*"]
              effect    = "Allow"
              condition = []
            }
          ]
        }
      ]
    },
    {
      functionality = var.functionality
      application   = var.application
      service       = var.service_task
      path          = var.path_task
      type          = var.type_task
      identifiers   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      principal_conditions = [
        {
          test     = var.test_task
          variable = var.variable_task
          values   = var.values_task
        }
      ]
      policies = [
        {
          policy_description = "Policy to allow access to S3 and DynamoDB"
          policy_statements = [
            {
              sid       = "AllowDynamoDBAccess"
              actions   = ["dynamodb:GetItem", "dynamodb:Query", "dynamodb:PutItem"]
              resources = ["*"]
              effect    = "Allow"
              condition = []
            }
          ]
        }
      ]
    }
  ]
}

###########################################
######### ECS Cluster Module ##############
###########################################

module "ecs_cluster" {
  #Before using the module, once you have the new location of your repo, you need to change the source value.
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-ecs-cluster-terraform.git?ref=feature/ecs-module-init"
  
  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  # Cluster configuration (Enable Fargate and Fargate Spot)
  cluster_config = [
    {
      application             = var.application
      containerInsights       = "enabled"
      enableCapacityProviders = true
    }
  ]
}

###########################################
######### ECS Service Module ##############
###########################################

 module "module_ecs_service" {
  #Before using the module, once you have the new location of your repo, you need to change the source value.
  source      = "git::https://github.com/somospragma/cloudops-ref-repo-aws-ecs-service-terraform.git?ref=feature/ecs-service-module-init"

  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  application = var.application
  environment = var.environment

  ecs_config = [
    {
      functionality            = var.functionality
      execution_role_arn       = module.iam.iam_roles_info[join("-",[var.functionality, var.application, "execution"])].role_arn
      task_role_arn            = module.iam.iam_roles_info[join("-",[var.functionality, var.application, "task"])].role_arn 
      network_mode             = "awsvpc"
      memory                   = var.memory
      cpu                      = var.cpu
      cpu_container            = var.cpu
      image                    = "nginx:stable" # PENDING FOR VALIDATION
      image_version            = "latest"
      requires_compatibilities = ["FARGATE"]
      cluster_name             = module.ecs_cluster.cluster_info["${var.application}"].cluster_name

      environmentFiles = []

      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
          protocol      = "tcp"
        }
      ]

      environment_variables = []
      volumes = []

      runtime_platform = {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
      }

      desired_count = 1
      health_check_grace_period_seconds = 60
      target_group_arn                  = ""
      security_groups                   = [module.sg_ecs_web01.sg_info["${var.functionality}"].sg_id]
      subnets                           = [data.aws_subnet.service_subnet_1.id, data.aws_subnet.service_subnet_2.id]
      assign_public_ip                  = "false"
      enable_rollback                   = "true"
      rollback                          = "true"

      secrets = []
      parameters  = []
      entry_point = []
      command     = []
    }
  ]

  compute_configuration = "capacity_providers"
  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      base              = 0
      weight            = 1
    }
  ]
  depends_on = [ module.ecs_cluster ]
}
