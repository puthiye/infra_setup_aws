provider "aws" {
  region = "ap-southeast-2"
}

data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "launch-config-sample" {
  image_id          = "ami-0810abbfb78d37cdf"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.elb-sg-sample.id]
   
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elb-sg-sample" {
  name = "elb-sg-demo"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound SSH from any ip
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg-sample" {
  launch_configuration = aws_launch_configuration.launch-config-sample.id
  availability_zones   = data.aws_availability_zones.all.names
  min_size = 1
  max_size = 2
  desired_capacity = 1

  load_balancers    = [aws_elb.elb-sample.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "demo-asg"
    propagate_at_launch = true
  }
}

resource "aws_elb" "elb-sample" {
  name               = "elb-demo"
  security_groups    = [aws_security_group.elb-sg-sample.id]
  availability_zones = data.aws_availability_zones.all.names
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 15
  }

  # Adding a listener for SSH 
  listener {
    lb_port           = var.elb_port
    instance_port     = var.elb_port
    instance_protocol = "tcp"
    lb_protocol       = "tcp"
  }
}    
