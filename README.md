# **Módulo Terraform: cloudops-ref-repo-aws-workload-terraform**

## Descripción:

Este módulo combina 5 sub módulos (elb, iam, ecs cluster, ecs service y security groups) los cuales permiten:


elb:

- Crear un balanceador de carga.

iam:

- Crear un rol de IAM.
- Crear una política de IAM.
- Asociar la política a un rol.

ecs cluster:

- Crear un cluster de ECS
- Crear un capcity provider para el cluster.

ecs service:

- Crear servicios
- Crear tareas
- Crear log group para el servicio
- Crear un target auto scaling
- Crear una polítca de auto scaling

security groups:

- Crear security groups.


Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo
El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-transversal-terraform/
└── environments/dev
    ├── terraform.tfvars
├── .gitignore
├── .terraform.lock.hcl
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.
 
<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2023-09-20 | 3.2.232 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->

## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/vpc/providers.tf
provider "aws" {
  alias = "alias01"
  # ... otras configuraciones del provider
}

sample/vpc/main.tf
module "vpc" {
  source = ""
  providers = {
    aws.project = aws.alias01
  }
  # ... resto de la configuración
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |


## Permisos IAM

Este repositorio requiere el siguiente rol IAM:
- **Rol**: `TerraformWorkloadRole`
- **Política**: `iam-policies/workload-policy.json`

### Permisos Incluidos
- ECS: Gestión completa de clusters, servicios y task definitions
- ALB: Gestión de load balancers, target groups y listeners
- ECR: Gestión de repositorios de imágenes Docker
- Cloud Map: Service discovery y DNS privado
- Auto Scaling: Configuración de escalado automático
- CloudWatch: Gestión de logs y métricas
- VPC/IAM/RDS: Acceso de lectura a recursos dependientes

## References (PENDIENTE)

| Module | Use | Resources | Varibales | Outputs |
|------| ----- |------| ----- | ----- |
| ecr | [Ver]() | [Ver]() | [Ver]() | [Ver]() |
| elb | [Ver]() | [Ver]() | [Ver]() | [Ver]() |
| iam | [Ver]() | [Ver]() | [Ver]() | [Ver]() |
| rds | [Ver]() | [Ver]() | [Ver]() | [Ver]() |
| ecs cluster | [Ver]() | [Ver]() | [Ver]() | [Ver]() |
| ecs service | [Ver]() | [Ver]() | [Ver]() | [Ver]() |
| security groups | [Ver]() | [Ver]() | [Ver]() | [Ver]() |
