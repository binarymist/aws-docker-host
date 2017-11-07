resource "aws_security_group_rule" "egress" {
  type        = "${lookup(var.security_group_rules, "rule_2_type")}"
  from_port   = "${lookup(var.security_group_rules, "rule_2_from_port")}"
  to_port     = "${lookup(var.security_group_rules, "rule_2_to_port")}"
  protocol    = "${lookup(var.security_group_rules, "rule_2_protocol")}"
  cidr_blocks = ["${lookup(var.security_group_rules, "rule_2_cidr_block_0")}"]
  security_group_id = "${var.security_group_id}"
}
