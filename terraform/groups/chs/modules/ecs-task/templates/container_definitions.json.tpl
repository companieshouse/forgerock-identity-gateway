[
  {
    "name": "${task_name}",
    "image": "${aws_ecr_url}:${tag}",
    "environment": [
      {
        "name": "API_LOAD_BALANCER",
        "value": "${api_load_balancer}"
      },
      {
        "name": "FIDC_FQDN",
        "value": "${fidc_fqdn}"
      },
      {
        "name": "FIDC_REALM",
        "value": "${fidc_realm}"
      },
      {
        "name": "AGENT_SECRET_ID",
        "value": "${agent_secret_id}"
      }
    ],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${cloudwatch_log_group_name}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${cloudwatch_log_prefix}"
      }
    }
  }
]