# AWS DevOps Agent — test
# Docs: https://docs.aws.amazon.com/devopsagent/latest/userguide/
# Supported regions: us-east-1, us-west-2, ap-southeast-2, ap-northeast-1, eu-central-1, eu-west-1

# Capability: GitHub CI/CD correlation
# Capability: MCP Server Connections

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
    Name = "test-agentspace-role"
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

  name        = "test"
  description = "Agent space for platform automation"

  # operator_app_role_arn = aws_iam_role.devops_operator[0].arn
  

  tags = [
    { key = "Project", value = "my-agents1234" },
    { key = "Environment", value = "dev" },
    { key = "ManagedBy", value = "agentforge" },
    { key = "Team", value = "platform" },
    { key = "AgentSpace", value = "test" }
  ]
}

resource "awscc_devopsagent_association" "primary_monitor" {
  agent_space_id = awscc_devopsagent_agent_space.main.agent_space_id
  association_type = "AWS_ACCOUNT"
  account_id       = var.monitoring_account_id
}

output "devops_agent_space_id" {
  value = awscc_devopsagent_agent_space.main.agent_space_id
}

output "devops_agent_space_arn" {
  value = awscc_devopsagent_agent_space.main.agent_space_arn
}
