/**
 * Requires Terraform ~> 0.12
 */
terraform {
  required_version = ">= 0.12"
}

/**
 * Fetch the current region for logs, incase a region is not passed in.
 */
data aws_region region {}

/**
 * Create the container definition from a map - with in the locals, we fix the keys to camelCase, per the container definition spec.
 *
 * @see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#standard_container_definition_params
 */
locals {
  image_name = var.name == null ? var.image : var.name
  awslogs_options = merge({
    awslogs-group         = var.cloudwatch_log_group
    awslogs-region        = data.aws_region.region.name
    awslogs-stream-prefix = local.image_name
  }, var.log_driver_options)

  definition = {
    name      = local.image_name
    essential = var.essential

    entryPoint = length(var.entrypoint) == 0 ? null : var.entrypoint
    command    = length(var.command) == 0 ? null : var.command

    image = "${var.image}${var.image_version == null ? "" : ":${var.image_version}"}"

    cpu    = var.cpu
    memory = var.memory

    healthCheck = var.health_check != null ? {
      command     = var.health_check.command
      interval    = var.health_check.interval
      timeout     = var.health_check.timeout
      retries     = var.health_check.retries
      startPeriod = var.health_check.start_period
    } : null

    environment = var.environment_variables
    ulimits     = var.ulimits
    secrets     = [for s in var.secrets : { for key, val in s : key == "value_from" ? "valueFrom" : key => val }]

    systemControls = var.system_controls

    portMappings = [for val in var.port_mappings : { protocol : val.protocol, containerPort = val.container_port, hostPort = val.host_port }]
    mountPoints  = [for val in var.mount_points : { containerPath = val.container_path, readOnly : val.read_only, sourceVolume : val.source_volume }]
    volumesFrom  = [for val in var.volumes_from : { sourceContainer = val.source_container, readOnly = val.read_only }]
    dependsOn    = [for val in var.dependencies : { containerName = val.container_name, condition = val.condition }]
    stopTimeout  = var.stop_timeout


    logConfiguration = {
      logDriver     = var.log_driver
      options       = var.log_driver == "awslogs" ? local.awslogs_options : var.log_driver_options
      secretOptions = [for s in var.log_driver_secrets : { for key, val in s : key == "value_from" ? "valueFrom" : key => val }]
    }
  }
}
