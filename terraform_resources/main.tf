resource "aws_security_group" "terra_sg" {
  name = "terra-sg"
  description = "terraform course security group"
  vpc_id = "vpc-06f4255c5722106aa"
  ingress = [ {
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
    description = "Outbound Terraform Security Group"
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

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

 tags = {
   "Environment" = "DEV"
 }
}

resource "aws_instance" "terra_ec2" {
    count = var.number_of_instances
    ami = "ami-01216e7612243e0ef"
    instance_type = "t2.micro"
    key_name = "ec2_key_pair"
    subnet_id = "subnet-00d2838782fa3ecee"
    associate_public_ip_address = true
    availability_zone = "ap-south-1a"
    vpc_security_group_ids = [aws_security_group.terra_sg.id]
    root_block_device {
      volume_size = 20
      volume_type = "gp2"
      delete_on_termination = true
    }
    user_data = file("install-pre-requisites.sh")


    iam_instance_profile = "EC2_Role_SSM"
    tags = {
      "Name" = "terra-ec2"
    }

}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [aws_instance.terra_ec2]
  create_duration = "60s"
}

resource "null_resource" "pull_docker" {
  count = var.number_of_instances
  depends_on = [time_sleep.wait_60_seconds]

  connection {
      type = "ssh"
      host = aws_instance.terra_ec2[count.index].public_ip
      user = "ec2-user"
      password = ""
      private_key = file("private_key/ec2_key_pair.pem")
    }  

    provisioner "remote-exec" {
      inline = [
         "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 157673692367.dkr.ecr.us-east-1.amazonaws.com",
         "docker pull 157673692367.dkr.ecr.us-east-1.amazonaws.com/app-repo:latest",
         "docker run -d -p 80:80 157673692367.dkr.ecr.us-east-1.amazonaws.com/app-repo:latest"
      ]
    }
}




resource "aws_lb" "LoadBalancer" {
    name = "terra-alb"
    internal = false
    load_balancer_type = "application"
    subnets = [
        "subnet-00d2838782fa3ecee",
        "subnet-0ca78c43341642cf0"
    ]
    security_groups = [aws_security_group.terra_sg.id]
    ip_address_type = "ipv4"

}

resource "aws_lb_target_group" "targetGroup" {
    health_check {
        interval = 30
        path = "/"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = 5
        unhealthy_threshold = 2
        healthy_threshold = 5
        matcher = "200"
    }
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = "vpc-06f4255c5722106aa"
    name = "terra-tg"
}

resource "aws_lb_target_group_attachment" "test" {
  count = var.number_of_instances
  target_group_arn = aws_lb_target_group.targetGroup.arn
  target_id        = aws_instance.terra_ec2[count.index].id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.LoadBalancer.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetGroup.arn
  }
}