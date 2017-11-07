resource "aws_security_group_rule" "ssh" {
  type        = "${lookup(var.security_group_rules, "rule_0_type")}"
  from_port   = "${lookup(var.security_group_rules, "rule_0_from_port")}"
  to_port     = "${lookup(var.security_group_rules, "rule_0_to_port")}"
  protocol    = "${lookup(var.security_group_rules, "rule_0_protocol")}"
  cidr_blocks = ["${lookup(var.security_group_rules, "rule_0_cidr_block_0")}"]
  security_group_id = "${var.security_group_id}"
}
