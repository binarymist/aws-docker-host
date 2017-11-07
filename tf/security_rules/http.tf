resource "aws_security_group_rule" "http" {
  type        = "${lookup(var.security_group_rules, "rule_1_type")}"
  from_port   = "${lookup(var.security_group_rules, "rule_1_from_port")}"
  to_port     = "${lookup(var.security_group_rules, "rule_1_to_port")}"
  protocol    = "${lookup(var.security_group_rules, "rule_1_protocol")}"
  cidr_blocks = ["${lookup(var.security_group_rules, "rule_1_cidr_block_0")}"]
  security_group_id = "${var.security_group_id}"
}
