################################################################
# Module Security Groups - ALB
################################################################

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
      application = "alb-app01" # Se debe pasar var.applications.
      description = "Security group for ALB"
      vpc_id      = data.aws_vpc.vpc.id

      ingress = [
        {
          from_port       = 8080
          to_port         = 8080
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


############################################################################################
# Definicion Elastic Load Balancing
############################################################################################

module "alb" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-elb-terraform.git?ref=feature/elb-module-init"

  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  environment = var.environment
  service     = "alb"

  lb_config = [{
    internal           = false
    load_balancer_type = "application"
    subnets            = [data.aws_subnet.public_subnet_1.id, data.aws_subnet.public_subnet_2.id]
    security_groups    = [module.sg_alb.sg_info["alb-app01"].sg_id]
    application_id     = "app01" # Validar nombre
    accessclass        = "public"

    # Configuración del Target Group
    target_groups = [{
      target_application_id = "nginx-app" # Esta vareiables es la misma de quede tener target_group_key
      port                  = "8080"
      protocol              = "HTTP"
      vpc_id                = data.aws_vpc.vpc.id
      target_type           = "ip"
      healthy_threshold     = "2"
      interval              = "30"
      path                  = "/health"
      unhealthy_threshold   = "2"
    }]

    # Configuración de los Listeners
    listeners = [
      # Listener HTTP (80) que redirecciona a HTTPS
      {
        port     = 8080
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
      # Listener HTTPS (443) que envía al target group en puerto 7007
      {
        port            = 443
        protocol        = "HTTPS"
        certificate_arn = "arn:aws:acm:us-east-1:008971642453:certificate/7cb55d32-3f7c-4311-9b78-5d6da1cc6448" # Reemplazar con tu ARN de certificado
        default_action = {
          type             = "forward"
          target_group_key = "nginx-app" # Debe coincidir con target_application_id
        }
      }
    ]
  }]
  depends_on = [module.sg_alb]
}


################################################################
# Module Security Group ECS-Web01
################################################################

module "sg_ecs_web01" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-sg-terraform.git?ref=feature/sg-module-init"

  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  environment = var.environment
  sg_config = [
    {
      application = "web01" # Se debe pasar var.applications.
      description = "Security group for ALB"
      vpc_id      = data.aws_vpc.vpc.id

      ingress = [
        {
          from_port       = 8080
          to_port         = 8080
          protocol        = "tcp"
          cidr_blocks     = []
          security_groups = [module.sg_alb.sg_info["alb-app01"].sg_id]
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

############################################################################################
# Definicion ECR
############################################################################################

module "ecr" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-ecr-terraform.git?ref=feature/ecr-module-init"
  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  environment = var.environment
  service     = "hefesto"
  project     = var.project

  ecr_config = [
    {
      application_id           = "app01"
      force_delete             = true
      image_tag_mutability     = "MUTABLE"
      encryption_configuration = [] # Sin configuración KMS
      image_scanning_configuration = [
        {
          scan_on_push = "true"
        }
      ]
      accessclass = "private"
      # Política de lifecycle para eliminar imágenes antiguas
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

################################################################
# Module IAM
################################################################
module "iam" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-iam-terraform.git?ref=feature/iam-module-init"
  providers = {
    aws.project = aws.pra_idp_dev
  }
  client      = var.client
  environment = var.environment
  project     = var.project

  iam_config = [
    {
      functionality = var.functionality_execution
      application   = var.application_execution
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
      functionality = var.functionality_task
      service       = var.service_task
      application   = var.application_task
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



############################################################################################
# Definicion Cluster ECS 
############################################################################################

module "ecs_cluster" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-ecs-cluster-terraform.git?ref=feature/ecs-module-init"
  providers = {
    aws.project = aws.pra_idp_dev
  }
  client      = var.client
  environment = var.environment
  project     = var.project

  # Configuración del clúster (habilitar Fargate y Fargate Spot)
  cluster_config = [
    {
      application             = "app01"
      containerInsights       = "enabled"
      enableCapacityProviders = true
    }
  ]
}

############################################################################################
# Definicion Modulo  ECS - Service
############################################################################################

 module "module_ecs_service" {
  providers = {
    aws.project = aws.pra_idp_dev
  }
  source      = "git::https://github.com/somospragma/cloudops-ref-repo-aws-ecs-service-terraform.git?ref=feature/ecs-service-module-init"
  client      = var.client
  project     = var.project
  environment = var.environment
  application = var.application

  ecs_config = [
    {
      functionality              = "web001"
      execution_role_arn       = "arn:aws:iam::008971642453:role/service-role/pragma-fc-dev-role-execution-app01-web001" #module.iam.iam_role_info["execution-app01-0"].arn
      task_role_arn            = "arn:aws:iam::008971642453:role/service-role/pragma-fc-dev-role-task-app01-web001"      #module.iam.iam_role_info["task-app01-0"].arn
      network_mode             = "awsvpc"
      memory                   = 512
      cpu                      = 256
      cpu_container            = 256
      image                    = "nginx:stable" # Temporal mientras validamos imagen ECR
      image_version            = "latest"
      requires_compatibilities = ["FARGATE"]
      cluster_name             = module.ecs_cluster.cluster_info["app01"].cluster_name # Nombre del cluster ECS

      # Configuración de archivos de entorno (se deja vacía por ahora)
      environmentFiles = []

      # Configuración de puertos
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      # Variables de entorno (puedes descomentarlas cuando las necesites)
      environment_variables = []
      # Volúmenes (puedes descomentarlos cuando los necesites)
      volumes = []
      # Configuración de plataforma
      runtime_platform = {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
      }

      # Configuración del servicio ECS
      desired_count = 1
      #launch_type                       = "FARGATE"
      health_check_grace_period_seconds = 60
      target_group_arn                  = ""
      security_groups                   = [module.sg_ecs_web01.sg_info["web01"].sg_id]
      subnets                           = [data.aws_subnet.service_subnet_1.id, data.aws_subnet.service_subnet_2.id]
      assign_public_ip                  = "false"
      enable_rollback                   = "true"
      rollback                          = "true"
      # Secreto de la base de datos (puedes descomentarlo cuando lo necesites)
      secrets = []
      # Parámetros desde SSM (puedes descomentarlos cuando los necesites)
      parameters  = []
      entry_point = []
      command     = []
    }

  ]

  # Configuración para usar capacity providers
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
