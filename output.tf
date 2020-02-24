output definition {
  description = "The container definition as a map."
  value       = local.definition
}

output json {
  description = "The container definition in a JSON string."
  value       = jsonencode(local.definition)
}
