resource "aws_sns_topic" "alerting" {
  name = var.service_name

  tags = var.tags
}

resource "aws_sns_topic_subscription" "alerting" {
  topic_arn = aws_sns_topic.alerting.arn
  protocol  = "email"
  endpoint  = var.alerting_email_address
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "${var.service_name}-AWS-ECS-High-CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerting.arn]
  actions_enabled     = true

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_memory" {
  alarm_name          = "${var.service_name}-AWS-ECS-High-Memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerting.arn]
  actions_enabled     = true

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }
}