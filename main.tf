# Provider definition
provider "aws" {
    region = "us-east-2"
}

# Variables definition
variable "exec_task_role" {
    type = string
}
variable "rand_api_image" {
    type = string
}
variable "subnets_id" {
    type = list
}
variable "time_api_image" {
    type = string
}
variable "vpc_id" {
    type = string
}

# Security group for the ECS tasks
resource "aws_security_group" "ecs_sg" {
    vpc_id = var.vpc_id
    name = "ecs-security-group"

    # Inbound and outbound rules
    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# ECS task definition
resource "aws_ecs_task_definition" "task_definition" {
    family = "tf-flask-fargate-api-task"
    network_mode = "awsvpc"
    memory = "1024"
    requires_compatibilities = ["FARGATE"]

    # Task execution role
    execution_role_arn = var.exec_task_role

    # Container definitions
    container_definitions = jsonencode([
        {
            name = "tf-flask-fargate-rand-api-container"
            image = var.rand_api_image 
            cpu  = 256
            memory = 512
            port_mappings = [
                {
                    container_port = 5001
                    host_port = 5000
                    protocol  = "tcp"
                }
            ]
        },
        {
            name = "tf-flask-fargate-time-api-container"
            image = var.time_api_image 
            cpu  = 256
            memory = 512
            port_mappings = [
                {
                    container_port = 5002
                    host_port = 5000
                    protocol  = "tcp"
                }
            ]
        }
    ])

    # Defining the task-level CPU
    cpu = "512"
}

# ECS service
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "tf-flask-fargate-api-cluster"  
}

resource "aws_ecs_service" "service" {
  name = "tf-flask-fargate-api-service"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count = 1
  launch_type = "FARGATE"

  # Network configuration
  network_configuration {
    subnets = var.subnets_id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
