data "aws_ssm_parameter" "al2023_ami" {
	name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_security_group" "asg" {
	name        = "${local.name_prefix}-asg-sg"
	description = "Security group for ASG instances"
	vpc_id      = aws_vpc.main.id

	ingress {
		description = "HTTP from VPC"
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = [local.subnets.subnet_a.private_cidr, local.subnets.subnet_b.private_cidr]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_launch_template" "app" {
	name_prefix   = "${local.name_prefix}-lt-"
	image_id      = data.aws_ssm_parameter.al2023_ami.value
	instance_type = "t4g.micro"

	user_data = base64encode(<<-EOT
							#!/bin/bash
							dnf -y update
							dnf -y install nginx
							systemctl enable --now nginx
							echo "<h1>${local.name_prefix} - $(hostname)</h1>" > /usr/share/nginx/html/index.html
							EOT
	)

	network_interfaces {
		security_groups             = [aws_security_group.asg.id]
		associate_public_ip_address = false
	}

	tag_specifications {
		resource_type = "instance"
		tags = {
			Name = "${local.name_prefix}-asg"
		}
	}
}

resource "aws_autoscaling_group" "app" {
	name                      = "${local.name_prefix}-asg"
	min_size                  = 1
	max_size                  = 3
	desired_capacity          = 1
	vpc_zone_identifier       = [module.subnets_a.private_subnet_id, module.subnets_b.private_subnet_id]
	health_check_type         = "EC2"
	health_check_grace_period = 60

	launch_template {
		id      = aws_launch_template.app.id
		version = "$Latest"
	}

	tag {
		key                 = "Name"
		value               = "${local.name_prefix}-asg"
		propagate_at_launch = true
	}

	lifecycle {
		create_before_destroy = true
	}

	depends_on = [module.subnets_a, module.subnets_b]
}

