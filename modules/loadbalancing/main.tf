resource "aws_lb" "three_tier_lb" {
    name = "three_tier_lb"
    security_groups = [var.lb_sg]
    subnets = [var.public_subnets]
    idle_timeout = 400 
    depends_on = [ var.app_sg ]
}


resource "aws_lb_target_group" "three_tier_lb" {
    name = "three_tier_lb_tg"
    port = var.port
    protocol = var.protocol
    vpc_id = var.vpc_id

    lifecycle {
        ignore_changes = [  ]
    }
}
