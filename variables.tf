variable "allow_default_action" {
  type        = bool
  description = "Set to `true` for WAF to allow requests by default. Set to `false` for WAF to block requests by default."
  default     = true
}

variable "arn_list" {
  description   = "List of ARN from that are associated with Web ACL"
  type          = list(string)
  default       = null
}

variable "create_alb_association" {
  description   = "Whether to create alb association with WAF web acl"
  type          = bool
  default       = true
}

variable "enabled" {
  description   = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  type          = bool
  default       = true
}

variable "ip_whitelist_capacity" {
  description   = "Capacity of the IP whitelist rule group. See https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statements-list.html"
  type          = number
  default       = 5
}

variable "ip_whitelist_enabled" {
  description   = "Whether to enabled the IP whitelist"
  type          = bool
  default       = false
}

variable "ip_whitelist_cloudwatch_metrics_enabled" {
  description   = "Whether to enabled the IP whitelist Cloudwatch metrics"
  type          = bool
  default       = true
}

variable "ip_whitelist_sampled_requests_enabled" {
  description   = "Whether to enabled the IP whitelist sample requests"
  type          = bool
  default       = true
}

variable "ip_set_list" {
  description = "List of IP Sets with IP addresses for WAF IP set"
  type        = any
  default     = []
}

variable "name" {
  description   = "Name to be used on all resources as prefix"
  type          = string
}

variable "prefix_ip_whitelist_metric_name" {
  description   = "Name to be used on IP Whitelist's CLoudwatch metric name as prefix"
  type          = string
  default       = null
}

variable "prefix_ip_whitelist_rule_group_name" {
  description   = "Name to be used on IP Whitelist's rule group name as prefix"
  type          = string
  default       = null
}

variable "prefix_web_acl_name" {
  description   = "Name to be used on Web ACL name as prefix"
  type          = string
  default       = null
}

variable "rule_group_capacity_ip_whitelist" {
  description   = "Capacity of IP Whitelisting rule group for external WAF."
  type          = number
  default       = 50
}

variable "rule_group_name_ip_whitelist" {
  description   = "Name of IP Whitelisting rule group for external WAF."
  type          = string
  default       = "CUSTOM-IP-Whitelist"
}

variable "rule_group_priority_ip_whitelist" {
  description   = "Priority of the IP whitelist rule group."
  type          = number
  default       = 5
}

variable "rules_managed" {
  description = "List of managed WAF rules."
  type        = any
  default     = []
}

variable "scope" {
  description   = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL. To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider."
  type          = string
  default       = "REGIONAL"
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}

variable "visibility_config" {
  description = "Visibility config for WAFv2 web acl. https://www.terraform.io/docs/providers/aws/r/wafv2_web_acl.html#visibility-configuration"
  type        = map(string)
  default     = {}
}