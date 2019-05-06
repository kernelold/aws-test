provider "aws" {
  region     = "us-west-1"
}

variable "zones" {
  default = ["us-west-1b", "us-west-1c"]
}

resource "aws_security_group" "allow_22" {
  name        = "allow_22"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "egress" {
  name        = "egress"
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "allow_8000" {
  name        = "allow_8000"

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Quotas"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Quote"
  range_key      = "Category"

  attribute {
    name = "Quote"
    type = "S"
  }

  attribute {
    name = "Category"
    type = "S"
  }

   ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "Quotas"
    Environment = "production"
  }
}

resource "aws_instance" "app" {
  count = 2
  ami           = "ami-0ff7f191316dba328"
  instance_type = "t1.micro"
  key_name = "ruslan-key"
  user_data = "${file("userdata.sh")}"
  vpc_security_group_ids = ["${aws_security_group.allow_22.id}","${aws_security_group.allow_8000.id}","${aws_security_group.egress.id}"]
  availability_zone = "${var.zones[count.index]}"
}

resource "aws_elb" "appelb" {
  name               = "quotas"
  availability_zones = "${var.zones}"
  

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances = ["${aws_instance.app.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}


output "instance_ips" {
  value = ["${aws_instance.app.*.public_ip}"]
}

output "elb_url" {
  value = ["${aws_elb.appelb.dns_name}"]
}


