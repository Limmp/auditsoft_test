#Get ubuntu ID using SSM Parameter endpoint
data "aws_ssm_parameter" "ubuntuAMI" {
  provider = aws.region-master
  name     = "/aws/service/canonical/ubuntu/server/22.04/stable/20231207/amd64/hvm/ebs-gp2/ami-id"

}

#create key-pair fot logging into EC2 
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "apache-worker-key"
  public_key = file("~/.ssh/id_ed25519.pub")

}

locals {
  public_keys = [
    file("~/.ssh/user1-ed25519.pub"),
    file("~/.ssh/user2-ed25519.pub"),
    file("~/.ssh/user3-ed25519.pub")
  ]
}

#create EC2 
resource "aws_instance" "apache-worker" {
  provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.ubuntuAMI.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  count                       = var.worker-count
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.apache-worker-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id
  user_data = base64encode(templatefile("${path.module}/apache_install.sh.tpl", {
    public_key_contents = local.public_keys
  }))
  tags = {
    Name = join("_", ["apache_worker", count.index + 1])
  }


}


# create ELB
resource "aws_elb" "web" {
  name            = "web-elb"
  subnets         = [aws_subnet.subnet_1.id]
  security_groups = [aws_security_group.lb-sg.id]
  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  instances                 = [for instance in aws_instance.apache-worker : instance.id]
  cross_zone_load_balancing = true
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-elb"
  }
}

# create SNS and cloudwatch alarm
resource "aws_sns_topic" "alarm_topic" {
  name = "web-server-down-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = "kharkov95@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "web_down_alarm" {
  alarm_name          = "web-down-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ELB"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "Triggered when all web servers are down"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]
  dimensions = {
    LoadBalancerName = aws_elb.web.name
  }
}
