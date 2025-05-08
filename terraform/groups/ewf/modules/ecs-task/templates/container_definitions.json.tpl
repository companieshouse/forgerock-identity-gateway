[
  {
    "name": "${task_name}",
    "image": "${aws_ecr_url}:${tag}",
    "environment": [
      {
        "name": "APPLICATION_HOST",
        "value": "${application_host}"
      },
      {
        "name": "IG_HOST",
        "value": "${ig_host}"
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
        "name": "FIDC_MAIN_JOURNEY",
        "value": "${fidc_main_journey}"
      },
      {
        "name": "FIDC_LOGIN_JOURNEY",
        "value": "${fidc_login_journey}"
      },
      {
        "name": "OIDC_CLIENT_ID",
        "value": "${oidc_client_id}"
      },
      {
        "name": "OIDC_CLIENT_SECRET",
        "value": "${oidc_client_secret}"
      },
      {
        "name": "UI_URL",
        "value": "${ui_url}"
      },
      {
        "name": "LOGIN_PATH",
        "value": "${login_path}"
      },
     {
        "name": "LOGOUT_PATH",
        "value": "${logout_path}"
      },
      {
        "name": "ERROR_PATH",
        "value": "${error_path}"
      },
      {
        "name": "MANAGE_PATH",
        "value": "${manage_path}"
      },
      {
        "name": "COMPANIES_PATH",
        "value": "${companies_path}"
      },
      {
        "name": "WEBFILING_COMP",
        "value": "${webfiling_comp}"
      },
      {
        "name": "APPLICATION_LEGACY_HOST",
        "value": "${application_legacy_host}"
      },
      {
        "name": "APPLICATION_LEGACY_HOST_PREFIX",
        "value": "${application_legacy_host_prefix}"
      },
      {
        "name": "APPLICATION_BETA_HOST",
        "value": "${application_beta_host}"
      },
      {
        "name": "APPLICATION_BETA_HOST_PREFIX",
        "value": "${application_beta_host_prefix}"
      },
      {
        "name": "APPLICATION_HOST_PREFIX",
        "value": "${application_host_prefix}"
      },
      {
        "name": "IG_JVM_ARGS",
        "value": "${ig_jvm_args}"
      },
      {
        "name": "ROOT_LOG_LEVEL",
        "value": "${root_log_level}"
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