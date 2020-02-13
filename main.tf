provider "aws" {
   region = "eu-west-1"
}

resource "aws_instance" "app_instance" {
   ami = "${var.app_ami_id}"
   instance_type = "t2.micro"
   associate_public_ip_address = true
   vpc_security_group_ids = ["${aws_security_group.app_security_group.id}"]
   subnet_id = "${aws_subnet.app_subnet.id}"
   user_data = "${data.template_file.app_init.rendered}"
   tags = {
      Name = "jack-eng47-terraform-app"
   }
}

resource "aws_instance" "db_instance" {
   ami = "${var.db_ami_id}"
   instance_type = "t2.micro"
   associate_public_ip_address = true
   vpc_security_group_ids = ["${aws_security_group.db_security_group.id}"]
   subnet_id = "${aws_subnet.db_subnet.id}"
   tags = {
      Name = "jack-eng47-terraform-db"
   }
}

resource "aws_security_group" "app_security_group" {
   name = "app_security_group"
   description = "TF lesson example security group"
   vpc_id = "${var.vpc_id}"

   ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
      from_port = 1024
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "jack-eng47-terraform-app-sec-group"
   }
}

resource "aws_security_group" "db_security_group" {
   name = "db_security_group"
   description = "TF lesson example security group"
   vpc_id = "${var.vpc_id}"

   ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["10.0.103.0/24"]
   }

   ingress {
   from_port = 27017
   to_port = 27017
   protocol = "tcp"
   cidr_blocks = ["10.0.103.0/24"]
   }

   tags = {
      Name = "jack-eng47-terraform-db-sec-group"
   }

}

resource "aws_subnet" "app_subnet" {
   vpc_id = "${var.vpc_id}"
   cidr_block = "10.0.103.0/24"
   tags = {
      Name = "jack-eng47-terraform-app-subnet"
   }
}

resource "aws_subnet" "db_subnet" {
   vpc_id = "${var.vpc_id}"
   cidr_block = "10.0.104.0/24"
   tags = {
      Name = "jack-eng47-terraform-db-subnet"
   }
}

resource "aws_route_table" "app_route_table" {
   vpc_id = "${var.vpc_id}"

   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${data.aws_internet_gateway.app_gateway.id}"
   }
   tags = {
      Name = "jack-eng47-terraform-app-route-table"
   }
}

resource "aws_route_table_association" "app-asos" {
   subnet_id = "${aws_subnet.app_subnet.id}"
   route_table_id = "${aws_route_table.app_route_table.id}"
}

data "aws_internet_gateway" "app_gateway" {
   filter {
      name = "attachment.vpc-id"
      values = ["${var.vpc_id}"]
   }
}

data "template_file" "app_init" {
   template = "${file("./scripts/app/init.sh.tpl")}"
   vars = {
   db_host="mongodb://${aws_instance.db_instance.private_ip}:27017/posts"
   }
}
