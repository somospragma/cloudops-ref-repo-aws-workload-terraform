output "iam_roles_info" {
 value = module.iam.iam_roles_info
}

output "sg_alb_sg_info" {
 value = module.sg_alb.sg_info
}

output "sg_info" {
 value = module.sg_ecs_functionality.sg_info
}

output "target_group_info" {
  value = module.alb.target_group_info
}