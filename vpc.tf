module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ani-assignment-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

}
resource "aws_security_group" "sg_bastion_host" {
  name        = "Bastion host SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["27.57.158.153/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "sg_private_instances" {
  name        = "Private Instances SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SG for Jenkins Instance"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "sg_public_web" {
  name        = "Public Web SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Http Traffic"
    from_port   = 22
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {

  ami                    = "ami-000722651477bd39b"
  instance_type          = "t2.micro"
  key_name               = "RHEL_KeyAws"
  vpc_security_group_ids = [aws_security_group.sg_bastion_host.id]
  subnet_id              = module.vpc.public_subnets[0]
  tags = {
    Name = "bastion host"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.bastion.public_ip} >> public_ips.txt"
  }

}

resource "aws_instance" "jenkins" {

  ami                    = "ami-000722651477bd39b"
  instance_type          = "t2.micro"
  key_name               = "RHEL_KeyAws"
  vpc_security_group_ids = [aws_security_group.sg_private_instances.id]
  subnet_id              = module.vpc.private_subnets[0]
  tags = {
    Name = "jenkins"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.jenkins.private_ip} >> private_ips.txt"
  }

}


resource "aws_instance" "app" {

  ami                    = "ami-000722651477bd39b"
  instance_type          = "t2.micro"
  key_name               = "RHEL_KeyAws"
  vpc_security_group_ids = [aws_security_group.sg_public_web.id]
  subnet_id              = module.vpc.private_subnets[1]
  tags = {
    Name = "app"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.app.private_ip} >> private_ips.txt"
  }

}