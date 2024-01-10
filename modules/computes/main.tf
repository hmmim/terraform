data "aws_ssm_parameter" "three_tier_ami"{
    name = "ssm_three_tier"
}
#Launch template for bastion host
resource "aws_launch_template" "three_tier_bastion" {
 name_prefix = "three-tier-bastion" #Đây là một chuỗi tiền tố được thêm vào tên của launch template. Ví dụ, nếu var.instance_type có giá trị là "t2.micro", thì tên của launch template sẽ là "three-tier-bastion-t2.micro".
 instance_type = var.instance_type # Đây là biến dùng để xác định loại instance (kiểu máy ảo) sẽ được sử dụng khi tạo các instances từ launch template.
 image_id = data.aws_ssm_parameter.three_tier_ami.value #Đây là ID của AMI (Amazon Machine Image) được sử dụng để tạo các instances. AMI là một hình ảnh máy ảo chứa thông tin về hệ điều hành, ứng dụng và cấu hình khác.
 vpc_security_group_ids = [var.bastion.sg]  #Đây là danh sách các ID của các Security Group trong Virtual Private Cloud (VPC) của bạn mà các instances sẽ thuộc vào. Security Groups được sử dụng để kiểm soát traffic đến và từ các instances.
 #user_data  = Đây là dữ liệu người dùng (user data) mà bạn muốn chuyển đến instances khi chúng được khởi tạo. Thông thường, user data này chứa các tác vụ khởi tạo, cài đặt hoặc cấu hình mà bạn muốn thực hiện tự động khi instance khởi động.
 key_name = var.key_name #Đây là tên của key pair (cặp khóa) được sử dụng để truy cập vào instances thông qua SSH. Key pair này thường được sử dụng để xác thực khi kết nối vào instances.
 tags {
    Name = "three-tier-bastion"
 }
}
// Tạo 1 con auto scaling group
resource "aws_autoscaling_group" "three-tier-bastion" {
    name = "three-tier-bastion"
    max_size = 1
    min_size = 1
    desired_capacity = 1
    vpc_zone_identifier = var.public_subnets
    launch_template {
        id = launch_template.three_tier_bastion.id //Hàm lấy trước id
        version = "$Latest"
    }

}
#Launch template for FRONTEND
resource "aws_launch_template" "three_tier_app" {
  name_prefix           = "three_tier_bastion"
  instance_type         = var.instance_type
  image_id              = data.aws_ssm_parameter.three_tier_ami
  vpc_security_group_ids = [var.frontend_app_sg]
  key_name              = var.key_name
  user_data             = filebase64("path/to/install_apache.sh")  # Update the path as needed

  tags = {
    Name = "three_tier_app"
  }
}

data "aws_alb_target_group" "three_tier_tg"{
    name = var.lb_tg_name
}

resource "aws_autoscaling_group" "three_tier_app" {
    name = "three_tier_app"
    min_size = 2
    max_size = 3
    desired_capacity = 2
    vpc_zone_identifier = var.public_subnets
    
    target_group_arns = [data.aws_alb_target_group.three_tier_app.arn]

    launch_template {
      id = aws_launch_template.three_tier_app.id
      version = "$Latest"
    }
}
#Launch template for BACKEND
resource "aws_launch_template" "three_tier_backend" {
  name_prefix           = "three_tier_backend"
  instance_type         = var.instance_type
  image_id              = data.aws_ssm_parameter.three_tier_ami
  vpc_security_group_ids = [var.backend_app_sg]
  key_name              = var.key_name
  user_data             = filebase64("path/to/install_node.sh")  # Update the path as needed

  tags = {
    Name = "three_tier_backend"
  }
}

resource "aws_autoscaling_group" "three_tier_backend" {
    name = "three_tier_backend"
    min_size = 2
    max_size = 3
    desired_capacity = 2
    vpc_zone_identifier = var.public_subnets
    
    target_group_arns = [data.aws_alb_target_group.three_tier_app.arn]

    launch_template {
      id = aws_launch_template.three_tier_app.id
      version = "$Latest"
    }
}








