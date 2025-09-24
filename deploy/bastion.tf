resource "aws_security_group" "bastion" {
	name        = "${local.name_prefix}-bastion-sg"
	description = "Security group for bastion (SSM only)"
	vpc_id      = aws_vpc.main.id

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

data "aws_iam_policy_document" "ssm_assume_role" {
	statement {
		effect = "Allow"
		actions = ["sts:AssumeRole"]
		principals {
			type        = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}

resource "aws_iam_role" "ssm_role" {
	name               = "${local.name_prefix}-ssm-role"
	assume_role_policy = data.aws_iam_policy_document.ssm_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
	role       = aws_iam_role.ssm_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
	name = "${local.name_prefix}-ssm-instance-profile"
	role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "bastion" {
	ami                         = data.aws_ssm_parameter.al2023_ami.value
	instance_type               = "t4g.micro"
	subnet_id                   = module.subnets_a.private_subnet_id
	vpc_security_group_ids      = [aws_security_group.bastion.id]
	iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
	associate_public_ip_address = false

	tags = {
		Name = "${local.name_prefix}-bastion"
	}

	depends_on = [module.subnets_a]
}

