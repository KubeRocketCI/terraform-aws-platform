resource "aws_autoscaling_schedule" "spot_start" {
  count = var.create_schedule ? 1 : 0

  scheduled_action_name  = "Start"
  min_size               = var.spot_min_nodes_count
  max_size               = var.spot_max_nodes_count
  desired_capacity       = var.spot_desired_nodes_count
  recurrence             = "0 6 * * MON-FRI"
  time_zone              = "Etc/UTC"
  autoscaling_group_name = module.eks.self_managed_node_groups_autoscaling_group_names[0]
}

resource "aws_autoscaling_schedule" "spot_stop" {
  count = var.create_schedule ? 1 : 0

  scheduled_action_name  = "Stop"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 18 * * MON-FRI"
  time_zone              = "Etc/UTC"
  autoscaling_group_name = module.eks.self_managed_node_groups_autoscaling_group_names[0]
}

resource "aws_autoscaling_schedule" "demand_start" {
  count = var.create_schedule ? 1 : 0

  scheduled_action_name  = "Start"
  min_size               = var.demand_min_nodes_count
  max_size               = var.demand_max_nodes_count
  desired_capacity       = var.demand_desired_nodes_count
  recurrence             = "0 6 * * MON-FRI"
  time_zone              = "Etc/UTC"
  autoscaling_group_name = module.eks.self_managed_node_groups_autoscaling_group_names[1]
}

resource "aws_autoscaling_schedule" "demand_stop" {
  count = var.create_schedule ? 1 : 0

  scheduled_action_name  = "Stop"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 18 * * MON-FRI"
  time_zone              = "Etc/UTC"
  autoscaling_group_name = module.eks.self_managed_node_groups_autoscaling_group_names[1]
}
