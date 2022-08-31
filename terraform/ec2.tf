# Request a spot instance at $0.03
resource "aws_spot_instance_request" "app_cheap_worker" {
  count                   = length(var.APP_COMPONENTS)
  ami                     = "ami-0bb6af715826253bf"
  spot_price              = "0.0031"
  instance_type           = "t3.micro"
  vpc_security_group_ids  = ["sg-0bcba096b73fa353d"]
  wait_for_fulfillment    = true
    tags                    = {
      Name                  = "${element(var.APP_COMPONENTS,count.index )}-${var.ENV}"
      Monitor               = "yes"
    }

}

resource "aws_ec2_tag" "app-name-tag" {
  count                     = length(var.APP_COMPONENTS)
  resource_id               = element(aws_spot_instance_request.app_cheap_worker.*.spot_instance_id, count.index)
  key                       = "Name"
  value                     = "${element(var.APP_COMPONENTS, count.index)}-${var.ENV}"
  key                       = "Monitor"
  value                     = "yes"
}

resource "aws_ec2_tag" "app-name-tag" {
  count                     = length(var.APP_COMPONENTS)
  resource_id               = element(aws_spot_instance_request.app_cheap_worker.*.spot_instance_id, count.index)
  key                       = "Monitor"
  value                     = "yes"
}

resource "aws_spot_instance_request" "db_cheap_worker" {
  count                   = length (var.DB_COMPONENTS)
  ami                     = "ami-0bb6af715826253bf"
  spot_price              = "0.0031"
  instance_type           = "t3.micro"
  vpc_security_group_ids  = ["sg-0bcba096b73fa353d"]
  wait_for_fulfillment    = true
    tags                    = {
      Name                  = "${element(var.DB_COMPONENTS,count.index )}-${var.ENV}"
    }
}

resource "aws_ec2_tag" "db-name-tag" {
  count                     = length(var.DB_COMPONENTS)
  resource_id               = element(aws_spot_instance_request.db_cheap_worker.*.spot_instance_id, count.index)
  key                       = "Name"
  value                     = "${element(var.DB_COMPONENTS, count.index)}-${var.ENV}"
}

resource "aws_route53_record" "app_records" {
  count                   = length(var.APP_COMPONENTS)
  name                    = "${element(var.APP_COMPONENTS,count.index )}-${var.ENV}"
  type                    = "A"
  zone_id                 = "Z02280072PQMTU5GAFQA"
  ttl                     = 300
  records                 = [element(aws_spot_instance_request.app_cheap_worker.*.private_ip, count.index)]
}

resource "aws_route53_record" "db_records" {
  count                   = length(var.DB_COMPONENTS)
  name                    = "${element(var.DB_COMPONENTS,count.index )}-${var.ENV}"
  type                    = "A"
  zone_id                 = "Z02280072PQMTU5GAFQA"
  ttl                     = 300
  records                 = [element(aws_spot_instance_request.db_cheap_worker.*.private_ip, count.index)]
}
#locals {
#  LENGTH                  = length(var.COMPONENTS)
#}

#COMPONENTS = ["mysql", "mongodb", "rabbitmq", "redis", "cart", "catalogue", "user", "shipping", "payment", "frontend"]
/*resource "local_file" "inventory-file" {
  content  = "[FRONTEND]\n${aws_spot_instance_request.cheap_worker.*.private_ip[9]}\n[PAYMENT]\n${aws_spot_instance_request.cheap_worker.*.
  private_ip[8]}\n[SHIPPING]\n${aws_spot_instance_request.cheap_worker.*.private_ip[7]}\n[USER]\n${aws_spot_instance_request.cheap_worker.*.
  private_ip[6]}\n[CATALOGUE]\n${aws_spot_instance_request.cheap_worker.*.private_ip[5]}\n[CART]\n${aws_spot_instance_request.cheap_worker.*.
  private_ip[4]}\n[REDIS]\n${aws_spot_instance_request.cheap_worker.*.private_ip[3]}\n[RABBITMQ]\n${aws_spot_instance_request.cheap_worker.*.
  private_ip[2]}\n[MONGODB]\n${aws_spot_instance_request.cheap_worker.*.private_ip[1]}\n[MYSQL]\n${aws_spot_instance_request.cheap_worker.*.private_ip[0]}"
  filename = "/tmp/inv-roboshop"
}*/

##  Approach one ##############
/*resource "local_file" "inventory-file" {
  content  = "[FRONTEND]\n${aws_spot_instance_request.app_cheap_worker.*.private_ip[5]}\n[PAYMENT]\n${aws_spot_instance_request.app_cheap_worker.*.
  private_ip[4]}\n[SHIPPING]\n${aws_spot_instance_request.app_cheap_worker.*.private_ip[3]}\n[USER]\n${aws_spot_instance_request.app_cheap_worker.*.
  private_ip[2]}\n[CATALOGUE]\n${aws_spot_instance_request.app_cheap_worker.*.private_ip[1]}\n[CART]\n${aws_spot_instance_request.app_cheap_worker.*.
  private_ip[0]}\n[REDIS]\n${aws_spot_instance_request.db_cheap_worker.*.private_ip[3]}\n[RABBITMQ]\n${aws_spot_instance_request.db_cheap_worker.*.
  private_ip[2]}\n[MONGODB]\n${aws_spot_instance_request.db_cheap_worker.*.private_ip[1]}\n[MYSQL]\n${aws_spot_instance_request.db_cheap_worker.*.private_ip[0]}"
  filename = "/tmp/inv-roboshop-${var.ENV}"
}*/

## Approach TWO ##############
locals {
  COMPONENTS = concat(aws_spot_instance_request.db_cheap_worker.*.private_ip, aws_spot_instance_request.app_cheap_worker.*.private_ip)
}

resource "local_file" "inventory-file" {
  content     = "[FRONTEND]\n${local.COMPONENTS[9]}\n[PAYMENT]\n${local.COMPONENTS[8]}\n[SHIPPING]\n${local.COMPONENTS[7]}\n[USER]\n${local.COMPONENTS[6]}\n[CATALOGUE]\n${local.COMPONENTS[5]}\n[CART]\n${local.COMPONENTS[4]}\n[REDIS]\n${local.COMPONENTS[3]}\n[RABBITMQ]\n${local.COMPONENTS[2]}\n[MONGODB]\n${local.COMPONENTS[1]}\n[MYSQL]\n${local.COMPONENTS[0]}"
  filename    = "/tmp/inv-roboshop-${var.ENV}"
}
