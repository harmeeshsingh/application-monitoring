terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}


############################
# KEY PAIR
############################


resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "keypair" {
  key_name   = "cicd-demo-key"
  public_key = tls_private_key.key.public_key_openssh
}


resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "cicd-demo-key.pem"
}


############################
# IAM ROLE FOR EC2
############################


resource "aws_iam_role" "ec2_role" {
  name = "codedeploy-ec2-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_profile" {
  role = aws_iam_role.ec2_role.name
}


############################
# SECURITY GROUP
############################


resource "aws_security_group" "sg" {
  name = "cicd-sg"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


############################
# EC2 INSTANCE
############################


resource "aws_instance" "server" {
  ami           = "ami-0fc5d935ebf8bc3bc" # Ubuntu
  instance_type = "t2.micro"


  key_name               = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name


  tags = {
    Name = "cicd-demo-server"
  }


  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install ruby wget -y
              cd /home/ubuntu
              wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
              chmod +x install
              ./install auto
              service codedeploy-agent start
              EOF
}


############################
# CODECOMMIT
############################


resource "aws_codecommit_repository" "repo" {
  repository_name = "cicd-demo-repo"
}


############################
# S3 BUCKET
############################


resource "aws_s3_bucket" "bucket" {
  bucket = "cicd-demo-artifacts-123456789"
}


############################
# CODEBUILD ROLE
############################


resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


############################
# CODEBUILD PROJECT
############################


resource "aws_codebuild_project" "build" {
  name         = "cicd-build"
  service_role = aws_iam_role.codebuild_role.arn


  artifacts { type = "CODEPIPELINE" }


  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:6.0"
    type         = "LINUX_CONTAINER"
  }


  source {
    type = "CODEPIPELINE"
  }
}


############################
# CODEDEPLOY ROLE
############################


resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "codedeploy.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


############################
# CODEDEPLOY APP
############################


resource "aws_codedeploy_app" "app" {
  name = "cicd-app"
}


resource "aws_codedeploy_deployment_group" "group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "cicd-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn


  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      value = "cicd-demo-server"
      type  = "KEY_AND_VALUE"
    }
  }
}


############################
# CODEPIPELINE ROLE
############################


resource "aws_iam_role" "pipeline_role" {
  name = "pipeline-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "pipeline_policy" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


############################
# CODEPIPELINE
############################


resource "aws_codepipeline" "pipeline" {
  name     = "cicd-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn


  artifact_store {
    location = aws_s3_bucket.bucket.bucket
    type     = "S3"
  }


  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]


      configuration = {
        RepositoryName = aws_codecommit_repository.repo.repository_name
        BranchName     = "main"
      }
    }
  }


  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]


      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }


  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build"]


      configuration = {
        ApplicationName     = aws_codedeploy_app.app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.group.deployment_group_name
      }
    }
  }
}


############################
# OUTPUTS
############################


output "repo_url" {
  value = aws_codecommit_repository.repo.clone_url_http
}


output "ec2_ip" {
  value = aws_instance.server.public_ip
}