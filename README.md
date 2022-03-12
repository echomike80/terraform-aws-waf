# AWS WAF Terraform module

Terraform module which creates an AWS Web Application Firewall (WebACL with managed rules and IP Whitelist) on AWS.

## Terraform versions

Terraform 0.12 and newer. 

## Usage

```hcl
module "waf" {
  source    = "/path/to/terraform-aws-waf"

  name      = var.name
  scope     = "REGIONAL"

  allow_default_action      = true
  arn_list                  = var.arn_list
  create_alb_association    = true

  name_prefix = "test-waf-setup"

  rules = [
    {
      name     = "AWS-AWSManagedRulesAmazonIpReputationList"
      priority = "10"

      override_action = "block"

      managed_rule_group_statement = {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }

      visibility_config = {
        metric_name = "AWSManagedRulesCommonRuleSet-metric"
      }
    },
    {
      name     = "AWS-AWSManagedRulesCommonRuleSet"
      priority = "11"

      override_action = "count"

      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }

      visibility_config = {
        metric_name = "AWSManagedRulesCommonRuleSet-metric"
      }
    }
  ]

  ip_set_list = [
    {
      name                  = "waf-ipset-1"
      ip_address_version    = "IPV4"
      addresses             = [
        "1.2.3.4/32",
        "5.6.7.8/32"
      ]
    },
    {
      name                  = "waf-ipset-2"
      ip_address_version    = "IPV4"
      addresses             = [
        "4.3.2.1/32",
        "8.7.6.5/32"
      ]
    }
  ]

  visibility_config = {
    metric_name = format("%s-main-metrics", var.name)
  }

  tags  = {
    Name    = var.name
    Env     = var.environment
  }
}
```

## Issue

An existing IP set which was provisioned with this module cannot be destroyed, because it won't be removed from the rule group actually.
```Error: Error deleting WAFv2 IPSet: WAFAssociatedItemException: AWS WAF couldn’t perform the operation because your resource is being used by another resource or it’s associated with another resource.```

Solution: Remove (detach) IP set manually from rule group and run terraform afterwards. Terraform then will remove the IP set.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.65 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.65 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_ip_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_rule_group.ip_whitelist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_rule_group) | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_default_action"></a> [allow\_default\_action](#input\_allow\_default\_action) | Set to `true` for WAF to allow requests by default. Set to `false` for WAF to block requests by default. | `bool` | `true` | no |
| <a name="input_arn_list"></a> [arn\_list](#input\_arn\_list) | List of ARN from that are associated with Web ACL | `list(string)` | `null` | no |
| <a name="input_create_alb_association"></a> [create\_alb\_association](#input\_create\_alb\_association) | Whether to create alb association with WAF web acl | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the resources. Set to `false` to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_ip_set_list"></a> [ip\_set\_list](#input\_ip\_set\_list) | List of IP Sets with IP addresses for WAF IP set | `any` | `[]` | no |
| <a name="input_ip_whitelist_capacity"></a> [ip\_whitelist\_capacity](#input\_ip\_whitelist\_capacity) | Capacity of the IP whitelist rule group. See https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statements-list.html | `number` | `5` | no |
| <a name="input_ip_whitelist_cloudwatch_metrics_enabled"></a> [ip\_whitelist\_cloudwatch\_metrics\_enabled](#input\_ip\_whitelist\_cloudwatch\_metrics\_enabled) | Whether to enabled the IP whitelist Cloudwatch metrics | `bool` | `true` | no |
| <a name="input_ip_whitelist_enabled"></a> [ip\_whitelist\_enabled](#input\_ip\_whitelist\_enabled) | Whether to enabled the IP whitelist | `bool` | `false` | no |
| <a name="input_ip_whitelist_sampled_requests_enabled"></a> [ip\_whitelist\_sampled\_requests\_enabled](#input\_ip\_whitelist\_sampled\_requests\_enabled) | Whether to enabled the IP whitelist sample requests | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all resources as prefix | `string` | n/a | yes |
| <a name="input_prefix_ip_whitelist_metric_name"></a> [prefix\_ip\_whitelist\_metric\_name](#input\_prefix\_ip\_whitelist\_metric\_name) | Name to be used on IP Whitelist's CLoudwatch metric name as prefix | `string` | `null` | no |
| <a name="input_prefix_ip_whitelist_rule_group_name"></a> [prefix\_ip\_whitelist\_rule\_group\_name](#input\_prefix\_ip\_whitelist\_rule\_group\_name) | Name to be used on IP Whitelist's rule group name as prefix | `string` | `null` | no |
| <a name="input_prefix_web_acl_name"></a> [prefix\_web\_acl\_name](#input\_prefix\_web\_acl\_name) | Name to be used on Web ACL name as prefix | `string` | `null` | no |
| <a name="input_rule_group_capacity_ip_whitelist"></a> [rule\_group\_capacity\_ip\_whitelist](#input\_rule\_group\_capacity\_ip\_whitelist) | Capacity of IP Whitelisting rule group for external WAF. | `number` | `50` | no |
| <a name="input_rule_group_name_ip_whitelist"></a> [rule\_group\_name\_ip\_whitelist](#input\_rule\_group\_name\_ip\_whitelist) | Name of IP Whitelisting rule group for external WAF. | `string` | `"CUSTOM-IP-Whitelist"` | no |
| <a name="input_rule_group_priority_ip_whitelist"></a> [rule\_group\_priority\_ip\_whitelist](#input\_rule\_group\_priority\_ip\_whitelist) | Priority of the IP whitelist rule group. | `number` | `5` | no |
| <a name="input_rules_managed"></a> [rules\_managed](#input\_rules\_managed) | List of managed WAF rules. | `any` | `[]` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL. To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider. | `string` | `"REGIONAL"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags (key-value pairs) passed to resources. | `map(string)` | `{}` | no |
| <a name="input_visibility_config"></a> [visibility\_config](#input\_visibility\_config) | Visibility config for WAFv2 web acl. https://www.terraform.io/docs/providers/aws/r/wafv2_web_acl.html#visibility-configuration | `map(string)` | `{}` | no |

## Outputs

No outputs.

## Authors

Module managed by [Marcel Emmert](https://github.com/echomike80). Inspired by [umotif-public](https://github.com/umotif-public/terraform-aws-waf-webaclv2).

## License

Apache 2 Licensed. See LICENSE for full details.
