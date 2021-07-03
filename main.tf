provider "aws"{
region= "us-east-1"
access_key= ""
secret_key= ""
}


resource "aws_launch_configuration" "gk_lc" {
  for_each = var.ami_id
  name   = "${var.env}-${each.key}-LC"
  image_id      = each.value
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "time_sleep" "wait_30_seconds"{
depends_on = [
   aws_autoscaling_group.gk_asg
  ]
create_duration = "60s"
}


resource "aws_autoscaling_group" "gk_asg" {
  for_each = var.ami_id
  name = "${var.env}-${each.key}-ASG"
  launch_configuration = "${var.env}-${each.key}-LC"
  min_size = 1
  max_size = 1
  vpc_zone_identifier= ["${lookup(var.vpc_zone_identifiers, each.key) }"]
  health_check_type    = "EC2"
  wait_for_capacity_timeout = 0
  force_delete      = true
  lifecycle {
    create_before_destroy = true
  }
  tags = [{
      key                 = "Name"
      value               = "${var.env}-${each.key}"
      propagate_at_launch = true
    },

  ]
  depends_on = [
   aws_launch_configuration.gk_lc
  ]
}

resource "aws_lb_target_group" "Tg"{
 count = length(var.target_group)
 name = "${var.env}-${lookup(var.target_group[count.index],"name")}"
 port =  "${lookup(var.target_group[count.index],"port")}"
 protocol = "${lookup(var.target_group[count.index],"protocol")}"
 target_type = "${lookup(var.target_group[count.index],"target_type")}"
 vpc_id = var.vpc_id
}

data "aws_instances" "test"{
  for_each = var.ami_id
  filter{
  name = "tag:Name"
  values = ["${var.env}-${each.key}"]
 }
 instance_state_names = ["running", "pending"]
depends_on = [ 
 time_sleep.wait_30_seconds
 ]
}

resource "aws_lb_target_group_attachment" "test_attach"{
# count = length(aws_lb_target_group.Tg)
 target_group_arn = aws_lb_target_group.Tg.arn
 for_each = data.aws_instances.test
 target_id = "${lookup(each.value.ids, aws_lb_target_group.Tg[count.index].arn,each.value.name)}"
 port = 32154
}

