resource "cloudflare_record" "cloudflare" {
  # Domain name.
  domain = "${var.cloudflare_domain}"
  # Record name.
  name   = "${var.cloudflare_domain}"  
  value  = "${var.aws_eip_lb_host}"
  # Ideally we could use the public DNS of aws_eip, and set type to CNAME, but public_dns is not available on aws_eip.
  type = "A"
  #ttl    = 3600
  proxied = true
}