/**
 * Requires Terraform ~> 0.12
 */
terraform {
  required_version = "~> 0.12"
}

/**
 * Fetch the current region for logs, incase a region is not passed in.
 */
data aws_region region {}

/**
 * Create the task definition from a map - with in the locals, we fix the keys to camelCase, per the task
 * definition spec.
 *
 * @see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#standard_container_definition_params
 */
locals {
  awslogs_options = merge({
    awslogs_group = var.image
    awslogs_region = data.aws_region.region.name
    awslogs_stream_prefix = var.image_version == null ? "latest" : var.image_version
  }, var.awslog_driver_options != null ? var.awslog_driver_options : {})

  definition = {
    name      = var.name == null ? var.image : var.name
    essential = var.essential

    entryPoint = length(var.entrypoint) == 0 ? null : var.entrypoint
    command    = length(var.command) == 0 ? null : var.command

    image = "${var.image}${var.image_version == null ? "" : ":${var.image_version}"}"

    cpu    = var.cpu
    memory = var.memory

    healthCheck = var.health_check != null ? { for key, value in var.health_check : key == "start_period" ? "startPeriod" : key => value } : null

    environment = var.environment_variables
    secrets     = { for key, val in var.secrets : key == "value_from" ? "valueFrom" : key => val }

    portMappings = [for val in var.port_mappings : { containerPort = val.container_port, hostPort = val.host_port }]
    mountPoints  = [for val in var.mount_points : { containerPath = val.container_path, readOnly : val.read_only, sourceVolume : val.source_volume }]
    volumesFrom  = [for val in var.volumes_from : { sourceContainer = val.source_container, readOnly = val.read_only }]
    dependencies = [for val in var.dependencies : { containerName = val.container_name, condition = val.condition }]

    logConfiguration = {
      logDriver = var.log_driver
      options   = var.log_driver == "awslogs" ? { for key, val in local.awslogs_options : replace(key, "_", "-") => val } : var.log_driver_options
    }
  }
}
