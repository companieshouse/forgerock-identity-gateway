output "cluster_id" {
  value = aws_ecs_cluster.ig.id
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
