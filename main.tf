locals {
  rules_ip_whitelist    = var.enabled && var.ip_whitelist_enabled && length(var.ip_set_list) > 0 ? ([
    {
      name              = var.rule_group_name_ip_whitelist
      priority          = var.rule_group_priority_ip_whitelist

      override_action   = "none"

      rule_group_reference_statement = {
          arn = aws_wafv2_rule_group.ip_whitelist[0].arn
      }

      visibility_config = {
        cloudwatch_metrics_enabled    = var.ip_whitelist_sampled_requests_enabled
        metric_name                   = var.prefix_ip_whitelist_metric_name != null ? format("%s%s-%s", var.prefix_ip_whitelist_metric_name, var.name, var.rule_group_name_ip_whitelist) : format("%s-%s", var.name, var.rule_group_name_ip_whitelist)
        # "cw-metric-ecom-test-waf-webacl-web-ext-rule-CUSTOM-IP-Whitelist"
        sampled_requests_enabled      = var.ip_whitelist_sampled_requests_enabled
      }
    }
  ]) : []
}

resource "aws_wafv2_web_acl" "this" {
  count         = var.enabled ? 1 : 0

  name          = var.prefix_web_acl_name != null ? format("%s%s", var.prefix_web_acl_name, var.name) : format("%s", var.name)
  scope         = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.allow_default_action ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.allow_default_action ? [] : [1]
      content {}
    }
  }

  dynamic "rule" {
    for_each = concat(var.rules_managed, local.rules_ip_whitelist)
    content {
      name     = lookup(rule.value, "name")
      priority = lookup(rule.value, "priority")

      # Required for managed_rule_group_statement and rule_group_reference_statement. Set to none, otherwise count to override the default action
      dynamic "override_action" {
        for_each = length(lookup(rule.value, "override_action", {})) == 0 ? [] : [1]
        content {
          dynamic "none" {
            for_each = lookup(rule.value, "override_action", {}) == "none" ? [1] : []
            content {}
          }

          dynamic "count" {
            for_each = lookup(rule.value, "override_action", {}) == "count" ? [1] : []
            content {}
          }
        }
      }

      statement {

        dynamic "managed_rule_group_statement" {
          for_each      = length(lookup(rule.value, "managed_rule_group_statement", {})) == 0 ? [] : [lookup(rule.value, "managed_rule_group_statement", {})]
          content {
            name        = lookup(managed_rule_group_statement.value, "name")
            vendor_name = lookup(managed_rule_group_statement.value, "vendor_name", "AWS")
          }
        }

        dynamic "rule_group_reference_statement" {
          for_each      = length(lookup(rule.value, "rule_group_reference_statement", {})) == 0 ? [] : [lookup(rule.value, "rule_group_reference_statement", {})]
          content {
            arn         = lookup(rule_group_reference_statement.value, "arn")
          }
        }

      }

      dynamic "visibility_config" {
        for_each = length(lookup(rule.value, "visibility_config")) == 0 ? [] : [lookup(rule.value, "visibility_config", {})]
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = lookup(visibility_config.value, "metric_name", "cw-metric-${var.name}-default-rule-metric-name")
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }

  }

  dynamic "visibility_config" {
    for_each = length(var.visibility_config) == 0 ? [] : [var.visibility_config]
    content {
      cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
      metric_name                = lookup(visibility_config.value, "metric_name", "cw-metric-${var.name}-default-web-acl-metric-name")
      sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
    }
  }

  tags = var.tags
}

resource "aws_wafv2_web_acl_association" "this" {
  count         = var.enabled && var.create_alb_association && length(var.arn_list) > 0 ? length(var.arn_list) : 0

  resource_arn  = var.arn_list[count.index]
  web_acl_arn   = aws_wafv2_web_acl.this[0].arn
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.enabled && var.logging_enabled && var.logging_destination_type == "cloudwatch" ? 1 : 0

  name              = var.prefix_web_acl_name != null ? format("aws-waf-logs-%s%s", var.prefix_web_acl_name, var.name) : format("aws-waf-logs-%s", var.name)
  retention_in_days = var.logging_destination_retention
  kms_key_id        = var.logging_destination_kms_key_arn != null ? var.logging_destination_kms_key_arn : null

  tags  = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "cloudwatch" {
  count         = var.enabled && var.logging_enabled && var.logging_destination_type == "cloudwatch" ? 1 : 0

  log_destination_configs = [aws_cloudwatch_log_group.this[0].arn]
  resource_arn            = aws_wafv2_web_acl.this[0].arn

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      condition {
        action_condition {
          action = "COUNT"
        }
      }

      requirement = "MEETS_ANY"
    }
  }
}

resource "aws_wafv2_ip_set" "this" {
  count         = var.enabled&& var.ip_whitelist_enabled && length(var.ip_set_list) > 0 ? length(var.ip_set_list) : 0

  name          = lookup(var.ip_set_list[count.index], "name", format("IPset-%s", count.index))
  scope         = var.scope

  ip_address_version    = lookup(var.ip_set_list[count.index], "ip_address_version", "IPV4")
  addresses             = lookup(var.ip_set_list[count.index], "addresses", [])

  tags  = var.tags
}

resource "aws_wafv2_rule_group" "ip_whitelist" {
  count       = var.enabled && var.ip_whitelist_enabled && length(var.ip_set_list) > 0 ? 1 : 0

  name        = var.prefix_ip_whitelist_rule_group_name != null ? format("%s%s-ip-whitelist", var.prefix_ip_whitelist_rule_group_name, var.name) : format("%s-ip-whitelist", var.name)
  scope       = var.scope
  capacity    = var.ip_whitelist_capacity

  dynamic "rule" {
    for_each = aws_wafv2_ip_set.this
    content {
      name     = lookup(rule.value, "name", null)
      priority = rule.key

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = lookup(rule.value, "arn", null)
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.ip_whitelist_cloudwatch_metrics_enabled
        metric_name                = var.prefix_ip_whitelist_metric_name != null ? format("%s%s-ip-whitelist-%s", var.prefix_ip_whitelist_metric_name, var.name, rule.key) : format("%s-ip-whitelist-%s", var.name, rule.key)
        sampled_requests_enabled   = var.ip_whitelist_sampled_requests_enabled
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.ip_whitelist_cloudwatch_metrics_enabled
    metric_name                = var.prefix_ip_whitelist_metric_name != null ? format("%s%s-ip-whitelist", var.prefix_ip_whitelist_metric_name, var.name) : format("%s-ip-whitelist", var.name)
    sampled_requests_enabled   = var.ip_whitelist_sampled_requests_enabled
  }

  tags = var.tags
}