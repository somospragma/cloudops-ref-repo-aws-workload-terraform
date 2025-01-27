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
      application   = var.application
      service       = var.service_lb
      functionality = var.functionality_lb #
      description   = "Security group for ALB"
      vpc_id        = data.aws_vpc.vpc.id

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
        },
        { #PENDING
          from_port       = "443"
          to_port         = "443"
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

  client        = var.client
  project       = var.project
  application   = var.application
  environment   = var.environment

  lb_config = [{
    internal           = false
    load_balancer_type = "application"
    subnets            = [data.aws_subnet.public_subnet_1.id, data.aws_subnet.public_subnet_2.id]
    security_groups    = [module.sg_alb.sg_info[join("-", [var.service_lb, var.application, var.functionality_lb])].sg_id]
    application        = var.application

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
        certificate_arn = var.arn_acm
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

module "sg_ecs_functionality" {
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
      application   = var.application
      service       = var.service_task
      functionality = var.functionality
      description   = "Security group for ALB"
      vpc_id        = data.aws_vpc.vpc.id

      ingress = [
        {
          from_port       = var.port
          to_port         = var.port
          protocol        = "tcp"
          cidr_blocks     = []
          security_groups = [module.sg_alb.sg_info[join("-", [var.service_lb, var.application, var.functionality_lb])].sg_id]
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
    # Execution Role (permite que ECS administre la tarea y registre logs)
    {
      functionality        = var.functionality
      application          = var.application
      service              = var.service_execution
      path                 = var.path_execution
      type                 = var.type_execution
      identifiers          = ["ecs-tasks.amazonaws.com"]
      principal_conditions = []
      policies = [
        {
          policy_description = "AmazonECSTaskExecutionRolePolicy"
          policy_statements = [
            {
              sid = "AllowExecutionRole"
              actions = [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:CreateLogGroup"
              ]
              resources = ["*"]
              effect    = "Allow"
              condition = []
            }
          ]
        }
      ]
    },

    {
      functionality        = var.functionality
      application          = var.application
      service              = var.service_task
      path                 = var.path_task
      type                 = var.type_task
      identifiers          = ["ecs-tasks.amazonaws.com"]
      principal_conditions = []
      policies = [
        {
          policy_description = "Policy to allow access to S3 and DynamoDB"
          policy_statements = [
            {
              sid = "DynamoPermission1"
              actions = [
                "dynamodb:BatchGetItem",
                "dynamodb:GetShardIterator",
                "dynamodb:GetItem",
                "dynamodb:List*",
                "dynamodb:GetResourcePolicy",
                "dynamodb:Query",
                "dynamodb:PutItem",
                "dynamodb:GetRecords"
              ]
              resources = [
                "*"
              ]
              effect    = "Allow"
              condition = []
            },
            {
              sid = "S3Access"
              actions = [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
              ]
              resources = [
                "*"
              ]
              effect    = "Allow"
              condition = []
            },
            {
              sid = "CloudWatchLogsFullAccess"
              actions = [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
              ]
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

module "ecs_cluster_functionality" {
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
  depends_on = [ module.alb ]
}

###########################################
######### ECS Service Module ##############
###########################################

module "ecs_service_functionality" {
  #Before using the module, once you have the new location of your repo, you need to change the source value.
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-ecs-service-terraform.git?ref=feature/ecs-service-module-init"

  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  application = var.application
  aws_region  = var.aws_region
  environment = var.environment

  ecs_config = [
    {
      functionality            = var.functionality
      execution_role_arn       = module.iam.iam_roles_info[join("-", [var.functionality, var.application, "execution"])].role_arn
      task_role_arn            = module.iam.iam_roles_info[join("-", [var.functionality, var.application, "task"])].role_arn
      network_mode             = "awsvpc"
      memory                   = var.memory
      cpu                      = var.cpu
      cpu_container            = var.cpu
      image                    = var.url_image_respository
      image_version            = "latest"
      requires_compatibilities = ["FARGATE"]
      cluster_name             = module.ecs_cluster_functionality.cluster_info["${var.application}"].cluster_name

      environmentFiles = []

      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
          protocol      = "tcp"
        }
      ]

      environment_variables = var.environment_variables
      volumes               = []

      runtime_platform = {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
      }

      desired_count                     = 1
      health_check_grace_period_seconds = 60
      target_group_arn                  = module.alb.target_group_info["${var.functionality}"].target_arn
      security_groups                   = [module.sg_ecs_functionality.sg_info[join("-", ["task", var.application, var.functionality])].sg_id]
      subnets                           = [data.aws_subnet.service_subnet_1.id, data.aws_subnet.service_subnet_2.id]
      assign_public_ip                  = "false"
      enable_rollback                   = "true"
      rollback                          = "true"

      secrets     = []
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
  depends_on = [module.ecs_cluster_functionality]
}
