# Push to GitHub and run Terraform Plan

Generated for **my-agents** (`dev`).

## 1. Create GitHub repository

```bash
git init
git add .
git commit -m "Initial AgentForge infrastructure"
git branch -M main
git remote add origin https://github.com/amitk22225/AI-DevOps-Agent.git
git push -u origin main
```

## 2. Configure GitHub repository

In **Settings → Secrets and variables → Actions → Variables**, add:

| Variable | Value |
|----------|-------|
| `AWS_ACCOUNT_ID` | `123456789012` |

## 3. AWS IAM OIDC (one-time)

1. Create OIDC identity provider for `https://token.actions.githubusercontent.com`
2. Create IAM role `my-agents-dev-deploy` with trust policy from `oidc-trust-policy.json`
3. Attach permissions (e.g. PowerUserAccess or scoped Terraform policy)
4. Optional: apply `infrastructure/terraform/dev/bootstrap-oidc.tf` first

## 4. Terraform remote state (one-time)

Create S3 bucket and DynamoDB table referenced in `main.tf` backend block before CI runs.

## 5. Run Terraform Plan on Pull Request

Workflows included:

- `.github/workflows/terraform-plan-dev.yml` — **plan only** on every PR (+ comment)
- `.github/workflows/deploy-dev.yml` — plan on PR, **apply** on push to `main`

```bash
git checkout -b feature/my-change
# edit files under infrastructure/terraform/dev/
git add .
git commit -m "Update infrastructure"
git push -u origin feature/my-change
# Open Pull Request on GitHub → Actions runs terraform plan
```

## 6. Local plan (optional)

```bash
cd infrastructure/terraform/dev
terraform init
terraform plan
```
