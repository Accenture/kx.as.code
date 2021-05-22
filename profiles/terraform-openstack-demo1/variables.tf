locals {
  raw_data     = jsondecode(file("profile-config.json"))
  event_topics = local.raw_data.config[*].*
}