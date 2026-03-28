# CloudBalance Skills for Claude

Give Claude deep AWS FinOps knowledge and live access to your CloudBalance data.

## What this includes

**CloudBalance skill** — a Claude skill package that activates for AWS cost and FinOps questions. It includes:

- Rightsizing guidance for EC2, EBS, and RDS
- Savings Plans and Reserved Instance strategy
- Cost optimization frameworks for AWS, Azure, and GCP
- FinOps methodology and best practices
- Automated change management and tagging strategy
- Live cost data and recommendations via the CloudBalance MCP server

## Quick install (Claude Code)

```bash
curl -sL https://raw.githubusercontent.com/cloudbalance-ai/cloudbalance-skills/main/install.sh | bash
```

The installer will prompt you to choose a global or project-local install. See [INSTALLATION.md](INSTALLATION.md) for manual install options and Claude.ai setup.

## MCP servers

The skill works best with the CloudBalance MCP servers connected, giving Claude live access to your AWS cost data, rightsizing recommendations, and commitment performance.

Configure in `~/.claude/.mcp.json`:

```json
{
  "mcpServers": {
    "cloudbalance": {
      "type": "http",
      "url": "https://mcp.cloudbalance.ai/mcp"
    },
    "cloudbalance-bcm": {
      "type": "http",
      "url": "https://mcp.cloudbalance.ai/mcp-bcm"
    }
  }
}
```

Claude Code will open a browser to authorize on first use. No manual token required.

See your CloudBalance account under **Integrations → Claude Setup** for the full setup guide and token management.

## Requirements

- A CloudBalance account ([cloudbalance.ai](https://www.cloudbalance.ai))
- Claude Code or Claude.ai

## License

CloudBalance platform content: CC BY-SA 4.0, Copyright (c) CloudBalance.
FinOps domain knowledge: CC BY-SA 4.0. See [cloudbalance/LICENSE.md](cloudbalance/LICENSE.md) for full details.
