variable "vpc_id" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}
# variable "ecr_repository_url" {
#   type = string
# }
# variable "image_tag" {
#   type    = string
#   default = "latest"
# }
variable "sg_ecs" {
  type = string
}
variable "alb_target_group" {
  type = string
}
