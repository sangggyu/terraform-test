
#rds의 서브넷 그룹으로 사용할 subnet들 미리 지정
resource "aws_db_subnet_group" "testDBSubnetGroup" {
  name = "db-subnet-group"
  subnet_ids = [
    aws_subnet.publicWebA.id,
    aws_subnet.publicWebC.id,
    aws_subnet.privateAppA.id,
    aws_subnet.privateAppC.id
  ]
  tags = {
    "Name" = "test-db-subnet-group"
  }
}
# RDS 인스턴스 생성
resource "aws_db_instance" "test_rds" {
  allocated_storage      = 50 #인스턴스에 할당된 스토리지
  max_allocated_storage  = 80 #최대 스토리지 크기
  skip_final_snapshot    = true # 최종 스냅샷을 생성하지 않도록 true
  vpc_security_group_ids = [aws_security_group.appSecurityGroup.id]   #보안 그륩 지정
  db_subnet_group_name   = aws_db_subnet_group.testDBSubnetGroup.name #서브넷 그륩 지정
  publicly_accessible    = true # 인스턴스가 인터넷에서 접근 가능합니다.
  backup_retention_period = 8 #백업 보존 기간을 7일로 설정
  db_name                = "testDB"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "testadmin"
  tags = {
    "Name" = "testDB"
  }
}

#RDS 읽기 복제본(Read Replica)
resource "aws_db_instance" "test_rds_read_replica" {
  identifier              = "test-rds-read-replica" #복제본 고유 식별자
  replicate_source_db     = "terraform-20231128091524088200000001" #원본 RDS 인스턴스의 식별자를 정확하게 지정
  instance_class          = "db.t2.micro"
  publicly_accessible     = true #인터넷에서 RDS 접근 가능 여부
  skip_final_snapshot     = true #삭제 시 최종 스냅샷 생성 X
  vpc_security_group_ids  = [aws_security_group.appSecurityGroup.id]
  db_subnet_group_name    = aws_db_subnet_group.testDBSubnetGroup.name
  tags = {
    "Name" = "testDB-Read-Replica"
  }
}
