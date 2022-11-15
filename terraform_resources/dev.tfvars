docker_image_tag = "use-case-app-v1"
ecr_repo_url = "157673692367.dkr.ecr.us-east-1.amazonaws.com"
ecr_repo_name = "terraform-use-case"

ingress_rules = [ {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Inbound Terraform Security Group"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    
  },
  {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Inbound Terraform Security Group"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false 
  },
  {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Inbound Terraform Security Group"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false 
  }
]
