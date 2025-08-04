resource "aws_ecs_task_definition" "ig" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  execution_role_arn       = var.ecs_task_role_arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
  container_definitions = templatefile("${path.module}/templates/container_definitions.json.tpl", {
    task_name                 = var.service_name
    aws_ecr_url               = var.ecr_url
    tag                       = var.container_image_version
    cloudwatch_log_group_name = var.log_group_name
    cloudwatch_log_prefix     = var.log_prefix
    region                    = var.region
    api_load_balancer         = var.api_load_balancer
    fidc_fqdn                 = var.fidc_fqdn
    fidc_realm                = var.fidc_realm
    agent_secret_id           = base64encode(var.agent_secret_id)
    ig_jvm_args               = var.ig_jvm_args
    root_log_level            = var.root_log_level
    signing_key_secret        = var.signing_key_secret
    ig_host                   = var.domain_name
  })

  tags = var.tags
}

resource "aws_ecs_service" "ig" {
  name            = var.service_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.ig.arn
  desired_count   = var.autoscaling_min
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.instance.id]
    subnets          = var.subnet_ids
    assign_public_ip = false
  }

  # load_balancer {
  #   target_group_arn = var.target_group_arn
  #   container_name   = var.service_name
  #   container_port   = 8080
  # }

  dynamic "load_balancer" {
    for_each = var.target_group_arns
    content {
      target_group_arn = load_balancer.value
      container_name   = var.service_name
      container_port   = 8080
    }
  }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.tags
}


resource "aws_security_group" "instance" {
  description = "Restricts access to ${var.service_name} instance"
  name        = "${var.service_name}-instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = var.lb_security_group_ids
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.service_name}-instance"
  })
}

resource "aws_appautoscaling_target" "ig" {
  max_capacity       = var.autoscaling_max
  min_capacity       = var.autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.ig.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ig-cpu" {
  name               = "${var.service_name} CPU Target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ig.resource_id
  scalable_dimension = aws_appautoscaling_target.ig.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ig.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.target_cpu
  }
}

resource "aws_appautoscaling_policy" "ig-memory" {
  name               = "${var.service_name} Memory Target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ig.resource_id
  scalable_dimension = aws_appautoscaling_target.ig.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ig.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = var.target_memory
  }
}
