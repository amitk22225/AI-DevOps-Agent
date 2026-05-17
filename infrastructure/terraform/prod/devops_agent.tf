# AWS DevOps Agent — Demo
# Docs: https://docs.aws.amazon.com/devopsagent/latest/userguide/
# Supported regions: us-east-1, us-west-2, ap-southeast-2, ap-northeast-1, eu-central-1, eu-west-1

# Capability: GitHub CI/CD correlation
# Capability: MCP Server Connections
# Capability: Amazon EventBridge

resource "time_sleep" "iam_propagation" {
  create_duration = "30s"
}

resource "aws_iam_role" "devops_agent_space" {
  count = 1
  name  = "DevOpsAgentRole-AgentSpace"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "aidevops.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = { "aws:SourceAccount" = var.monitoring_account_id }
      }
    }]
  })

  tags = {
    Name = "Demo-agentspace-role"
  }
}

resource "aws_iam_role_policy_attachment" "devops_agent_space" {
  count      = 1
  role       = aws_iam_role.devops_agent_space[0].name
  policy_arn = "arn:aws:iam::aws:policy/AIDevOpsAgentAccessPolicy"
}

resource "aws_iam_role" "devops_operator" {
  count = 1
  name  = "DevOpsAgentRole-WebappAdmin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "aidevops.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "devops_operator" {
  count      = 1
  role       = aws_iam_role.devops_operator[0].name
  policy_arn = "arn:aws:iam::aws:policy/AIDevOpsOperatorAppAccessPolicy"
}

resource "awscc_devopsagent_agent_space" "main" {
  depends_on = [time_sleep.iam_propagation]

  agent_space_name        = "Demo"
  description             = "Agent space for platform automation"
  agent_response_language = "en"

  agent_space_role_name = "DevOpsAgentRole-AgentSpace"
  operator_role_name = "DevOpsAgentRole-WebappAdmin"

  tags = [
    { key = "Project", value = "prod-agents" },
    { key = "Environment", value = "prod" },
    { key = "ManagedBy", value = "agentforge" },
    { key = "Team", value = "platform" },
    { key = "CostCenter", value = "engineering" },
    { key = "Compliance", value = "high" },
    { key = "AgentSpace", value = "Demo" }
  ]
}

resource "awscc_devopsagent_association" "primary_monitor" {
  agent_space_id = awscc_devopsagent_agent_space.main.agent_space_id
  association_type = "AWS_ACCOUNT"
  account_id       = var.monitoring_account_id
}

resource "aws_cloudwatch_event_rule" "devops_agent_lifecycle" {
  name        = "prod-agents-prod-devops-agent-events"
  description = "Route DevOps Agent investigation lifecycle events"
  event_pattern = jsonencode({
    source = ["aws.devopsagent"]
  })
}

resource "aws_cloudwatch_event_target" "devops_agent_bus" {
  rule      = aws_cloudwatch_event_rule.devops_agent_lifecycle.name
  target_id = "eventbridge-bus"
  arn       = "arn:aws:events:us-east-1:123456789012:event-bus/default"
}

output "devops_agent_space_id" {
  value = awscc_devopsagent_agent_space.main.agent_space_id
}

output "devops_agent_space_arn" {
  value = awscc_devopsagent_agent_space.main.agent_space_arn
}
