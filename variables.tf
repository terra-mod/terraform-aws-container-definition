variable name {
  description = "The name of a container - defaults to the image name if not set."
  type        = string
  default     = null
}

variable essential {
  description = "If the essential parameter of a container is marked as true , and that container fails or stops for any reason, all other containers that are part of the task are stopped."
  type        = bool
  default     = true
}

# Entrypoint and command
variable entrypoint {
  description = "The entry point that is passed to the container."
  type        = list(string)
  default     = []
}

variable command {
  description = "The docker command that can override the default CMD."
  type        = list(string)
  default     = []
}

# Image
variable image {
  description = "The image used to start a container. Images in the Docker Hub registry are available by default."
  type        = string
}

variable image_version {
  description = "The version of the Image to start the container."
  type        = string
  default     = null
}

# Resources
variable cpu {
  description = "The CPU value used for container. Allowed values, see https://docs.aws.amazon.com/AmazonECS/latest/userguide/task-cpu-memory-error.html."
  type        = number
  default     = 256
}

variable memory {
  description = "The Memory value used for the container. Allowed values, see https://docs.aws.amazon.com/AmazonECS/latest/userguide/task-cpu-memory-error.html."
  type        = number
  default     = 1024
}

# Healthcheck
variable health_check {
  description = <<EOF
The HealthCheck property specifies an object representing a container health check. Health check parameters that are
specified in a container definition override any Docker health checks that exist in the container image
(such as those specified in a parent image or from the image's Dockerfile).
EOF
  type        = object({ command : list(string), interval : number, retries : number, start_period : number, timeout : number })
  default     = null
}

# Ports, volumes and dependencies
variable port_mappings {
  description = "The port number and protocol on the container that is bound to the user-specified or automatically assigned host port."
  type        = set(object({ protocol : string, container_port : number, host_port : number }))
  default     = []
}

variable mount_points {
  description = "Specifies details on a volume mount point that is used in a container definition."
  type        = set(object({ container_path : string, read_only : bool, source_volume : string }))
  default     = []
}

variable volumes_from {
  description = "Specifies details on a data volume from another container in the same task definition."
  type        = set(object({ read_only : bool, source_container : string }))
  default     = []
}

variable dependencies {
  description = <<EOF
The dependencies defined for container startup and shutdown. Requires a container name and condition - where condition can
be one of `COMPLETE`, `HEALTHY`, `START`, `SUCCESS`.
EOF
  type        = set(object({ container_name = string, condition = string }))
  default     = []
}

# Environment Variables and Secrets
variable secrets {
  description = "A set of secret environment variables. Each secret must be a map of the form { name = ..., valueFrom = <secret_arn> }"
  type        = set(object({ name = string, value_from = string }))
  default     = []
}

variable environment_variables {
  description = <<EOF
Environment variables that will be passed to the docker container on startup. Each environment variable must be a map of
the form { name = "...", value = "..." }.
EOF
  type        = set(object({ name = string, value = string }))
  default     = []
}

# Logging
variable log_driver {
  description = <<EOF
The name of the log driver used for logging. One of `awslogs`, `fluentd`, `gelf`, `json-file`, `journald`, `logentries`, `syslog`, `splunk`, or `awsfirelens`."
For Fargate launch type the supported drivers are `awslogs`, `splunk` and `awsfirelens`.
EOF
  type        = string
  default     = "awslogs"
}

variable cloudwatch_log_group {
  description = "The name of a Cloudwatch Log Group to log to, when using `awslogs` as the log driver."
  type        = string
  default     = null
}

variable log_driver_options {
  description = <<EOF
Options for the chosen Log Driver. Default values are already set for `awslogs` Log Driver, but this can be used to override the region or stream prefix name.
Otherwise, for all other Log Driver types, this map allows setting configuration options.
EOF
  type        = map(string)
  default     = {}
}

variable log_driver_secrets {
  description = "The secrets to pass to the log configuration."
  type        = set(object({ name = string, value_from = string }))
  default     = []
}

variable "ulimits" {
  type = list(object({
    name      = string
    hardLimit = number
    softLimit = number
  }))
  description = "Container ulimit settings. This is a list of maps, where each map should contain \"name\", \"hardLimit\" and \"softLimit\""
  default     = null
}

variable "stop_timeout" {
  type        = number
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own"
  default     = null
}

variable "system_controls" {
  type = list(object({
    namespace = string
    value     = string
  }))
  description = "A list of namespaced kernel parameters to set in the container. This is a list of maps, where each map should contain \"namespace\" and \"value\""
  default     = null
}
