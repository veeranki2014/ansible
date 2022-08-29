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
    Monitor               = yes
  }
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

resource "aws_route53_record" "app_records" {
  count                   = length(var.APP_COMPONENTS)
  name                    = "{element(var.APP_COMPONENTS,count.index )}-${var.ENV}"
  type                    = "A"
  zone_id                 = "Z02280072PQMTU5GAFQA"
  ttl                     = 300
  records                 = [element(aws_spot_instance_request.app_cheap_worker.*.private_ip, count.index)]
}

resource "aws_route53_record" "db_records" {
  count                   = length(var.DB_COMPONENTS)
  name                    = "{element(var.APP_COMPONENTS,count.index )}-${var.ENV}"
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

resource "local_file" "inventory-file" {
  content  = "[FRONTEND]\n${aws_spot_instance_request.app_cheap_worker.*.private_ip[5]}\n[PAYMENT]\n${aws_spot_instance_request.app_cheap_worker.*.
  private_ip[4]}\n[SHIPPING]\n${aws_spot_instance_request.app_cheap_worker.*.private_ip[3]}\n[USER]\n${aws_spot_instance_request.app_cheap_worker.*.
  private_ip[2]}\n[CATALOGUE]\n${aws_spot_instance_request.app_cheap_worker.*.private_ip[1]}\n[CART]\n${aws_spot_instance_request.app_cheap_worker.*.
  private_ip[0]}\n[REDIS]\n${aws_spot_instance_request.db_cheap_worker.*.private_ip[3]}\n[RABBITMQ]\n${aws_spot_instance_request.db_cheap_worker.*.
  private_ip[2]}\n[MONGODB]\n${aws_spot_instance_request.db_cheap_worker.*.private_ip[1]}\n[MYSQL]\n${aws_spot_instance_request.db_cheap_worker.*.private_ip[0]}"
  filename = "/tmp/inv-roboshop"
}
