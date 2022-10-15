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
    count = 2
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
    #user_data = file("install-docker.sh")
    user_data = <<-EOF
        #!/bin/bash
        cd /home/ubuntu 
        touch test.txt
        #!/bin/bash
        yum update 
        yum -y install docker
        service docker start
        usermod -a -G docker ec2-user 
        chkconfig docker on 
        pip3 install docker-compose
        sudo apt install unzip -y
        sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        sudo unzip awscliv2.zip
        sudo ./aws/install
        reboot
        EOF

    iam_instance_profile = "EC2_Role_SSM"
    tags = {
      "Name" = "terra-ec2"
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
    security_groups = [
        "sg-06285411bf97c0de3"
    ]
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
  for_each = {
    "instanceid01" = "0"
    "instanceid02" = "1"
  }
  target_group_arn = aws_lb_target_group.targetGroup.arn
  target_id        = aws_instance.terra_ec2[each.value].id
  port             = 80
}
