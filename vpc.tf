#vpc
resource "aws_vpc" "groomVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "groomVPC"
  }
}

#퍼블릭 서브넷
resource "aws_subnet" "publicWebA" {
  vpc_id            = aws_vpc.groomVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "Public Web A"
  }

}

#프라이빗 서브넷
resource "aws_subnet" "privateAppA" {
  vpc_id            = aws_vpc.groomVPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "Private App A"
  }
}

#퍼블릭 서브넷
resource "aws_subnet" "publicWebC" {
  vpc_id            = aws_vpc.groomVPC.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "Public Web C"
  }
}

#프라이빗 서브넷
resource "aws_subnet" "privateAppC" {
  vpc_id            = aws_vpc.groomVPC.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "Private App c"
  }
}

#IGW (인터넷 게이트웨이 추가)
resource "aws_internet_gateway" "internetGW" {
  vpc_id = aws_vpc.groomVPC.id
  tags = {
    Name = "Internet GW"
  }

}

/*
라우팅 테이블 작성
*/

# 퍼블릭 라우팅 테이블 (모든 퍼블릭 서브넷에 대해 하나의 라우팅 테이블 사용)
resource "aws_route_table" "webRouteTable" {
  vpc_id = aws_vpc.groomVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetGW.id
  }
  tags = {
    Name = "WebRouteTable"
  }
}

# 프라이빗 라우팅 테이블 (모든 프라이빗 서브넷에 대해 하나의 라우팅 테이블 사용)
resource "aws_route_table" "appRouteTable" {
  vpc_id = aws_vpc.groomVPC.id
  tags = {
    Name = "AppRouteTable"
  }
}

# 퍼블릭 라우팅 테이블 연결 (퍼블릭 서브넷 모두 이 라우팅 테이블을 사용)
resource "aws_route_table_association" "publicRouteAssociation" {
  subnet_id      = aws_subnet.publicWebA.id
  route_table_id = aws_route_table.webRouteTable.id
}

resource "aws_route_table_association" "publicRouteAssociation2" {
  subnet_id      = aws_subnet.publicWebC.id
  route_table_id = aws_route_table.webRouteTable.id
}

# 프라이빗 라우팅 테이블 연결 (프라이빗 서브넷 모두 이 라우팅 테이블을 사용)
resource "aws_route_table_association" "privateRouteAssociation" {
  subnet_id      = aws_subnet.privateAppA.id
  route_table_id = aws_route_table.appRouteTable.id
}

resource "aws_route_table_association" "privateRouteAssociation2" {
  subnet_id      = aws_subnet.privateAppC.id
  route_table_id = aws_route_table.appRouteTable.id
}


/*
보안그륩 생성
*/

#퍼블릭 보안 그륩
resource "aws_security_group" "publicWebSecurityGroup" {
  vpc_id      = aws_vpc.groomVPC.id
  name        = "publicWebSecurityGroup"
  description = "Security group for public web servers"
  tags = {
    Name = "publicWebSecurityGroup"
  }
}

#퍼블릭 보안 그륩 규칙
resource "aws_security_group_rule" "publicWebSecurityGroupRulesHTTPingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.publicWebSecurityGroup.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "publicWebSecurityGroupRulesSSHingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.publicWebSecurityGroup.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "publicWebSecurityGroupRulesALLegress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "ALL"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.publicWebSecurityGroup.id
  lifecycle {
    create_before_destroy = true
  }
}

#프라이빗 보안 그룹
resource "aws_security_group" "appSecurityGroup" {
  vpc_id      = aws_vpc.groomVPC.id
  name        = "appSecurityGroup"
  description = "appSecurityGroup"
  tags = {
    Name = "appSecurityGroup"
  }
}
#프라이빗 보안 그룹 규칙
resource "aws_security_group_rule" "DBSecurityGroupRulesRDSingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "TCP"
  security_group_id        = aws_security_group.appSecurityGroup.id
  source_security_group_id = aws_security_group.appSecurityGroup.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "DBSecurityGroupRulesegress" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "TCP"
  security_group_id        = aws_security_group.appSecurityGroup.id
  source_security_group_id = aws_security_group.appSecurityGroup.id
  lifecycle {
    create_before_destroy = true
  }
}
