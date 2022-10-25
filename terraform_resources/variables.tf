variable "docker_image_tag" {
  type = string
}

variable "ecr_repo_url" {
  type = string
}


variable "ecr_repo_name" {
  type = string
}


variable "number_of_instances" {
  type = number
  default = 2
}

variable "ingress_rules" {
  type = list(object({
    protocol = string
    from_port = number
    to_port = number
    cidr_blocks = list(string)
    description = string
    ipv6_cidr_blocks = list(string)
    prefix_list_ids = list(string)
    security_groups = list(string)
    self = bool
    
  }))
}