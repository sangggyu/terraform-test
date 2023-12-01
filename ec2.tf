resource "aws_key_pair" "ec2_key" {
  key_name   = "key"
  public_key = file("./key.pub")
}

resource "aws_instance" "test-ec2" {
  ami                    = "ami-086cae3329a3f7d75"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.publicWebSecurityGroup.id]
  subnet_id              = aws_subnet.publicWebA.id
  key_name               = aws_key_pair.ec2_key.key_name
  associate_public_ip_address = true #퍼블릭 IP주소 할당 

  tags = {
    Name = "test_terraform_ec2"
  }

}

resource "aws_launch_configuration" "autoscale_config" {
  name_prefix   = "autoscale-config" #리소스 이름을 지정하는 접두사
  image_id      = "ami-086cae3329a3f7d75"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.publicWebSecurityGroup.id]

  lifecycle {
    create_before_destroy = true #리소스가 변경될 때 이전 리소스를 먼저 생성한 후 삭제합니다.
  }
}

resource "aws_autoscaling_group" "autoscale_group" {
  name_prefix     = "autoscale-group"
  launch_configuration = aws_launch_configuration.autoscale_config.name
  min_size        = 1 #Auto Scaling 그룹에서 유지할 최소 인스턴스 수
  max_size        = 3 #Auto Scaling 그룹에서 유지할 최대 인스턴스 수
  desired_capacity = 1 # Auto Scaling 그룹에서 시작 및 유지하려는 인스턴스 수
  vpc_zone_identifier = [
    aws_subnet.publicWebA.id,
    aws_subnet.publicWebC.id
  ]

    tag {
    key                 = "Name"
    value               = "autoscale-instance"
    propagate_at_launch = true
  }
}
