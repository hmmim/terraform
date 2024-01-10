output "app_asg" {
  value = aws_autoscaling_group.three_tier_app
}
output "backend_app_asg" {
    value = aws_autoscaling_group.three_tier_backend
}
