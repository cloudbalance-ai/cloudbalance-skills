# CloudBalance Skills — Installation Guide

CloudBalance skills give Claude Code and Claude.ai deep knowledge of AWS FinOps best
practices and live access to your CloudBalance data via the CloudBalance MCP server.

---

## Option 1: One-liner install (recommended for Claude Code)

Run this from any directory. By default it installs into the **current directory's**
`.claude/skills/` folder (project-local). Use `--global` to install for all projects.

```bash
# Project-local install (run from your project root)
curl -sL https://raw.githubusercontent.com/cloudbalance-ai/cloudbalance-skills/main/install.sh | bash

# Global install — available in all Claude Code projects
curl -sL https://raw.githubusercontent.com/cloudbalance-ai/cloudbalance-skills/main/install.sh | bash -s -- --global

# Install into a specific project directory
curl -sL https://raw.githubusercontent.com/cloudbalance-ai/cloudbalance-skills/main/install.sh | bash -s -- --dir ~/my-project
```

The installer clones the repo, copies the `cloudbalance/` skill folder to the target
directory, verifies the installation, and cleans up. Git is required.

---

## Option 2: Manual install (Claude Code)

### Global install — available in all Claude Code projects

```bash
git clone --depth 1 https://github.com/cloudbalance-ai/cloudbalance-skills.git
cp -r cloudbalance-skills/cloudbalance ~/.claude/skills/cloudbalance
rm -rf cloudbalance-skills
```

Claude Code automatically detects skills placed in `~/.claude/skills/`.

### Project-local install — active only in this project

```bash
git clone --depth 1 https://github.com/cloudbalance-ai/cloudbalance-skills.git
mkdir -p .claude/skills
cp -r cloudbalance-skills/cloudbalance .claude/skills/cloudbalance
rm -rf cloudbalance-skills
```

Run from your project root. The skill is only active when Claude Code is opened in
that directory.

### Global vs project-local — which should I use?

| | Global (`~/.claude/skills/`) | Project-local (`.claude/skills/`) |
|---|---|---|
| Available in | All Claude Code projects | This project only |
| Best for | Most users — always have FinOps knowledge available | Teams that want per-project version control of skills |
| Update method | Re-run installer with `--global` | Re-run installer from project root |

**Most users should use the global install.** Project-local makes sense if you want to
pin a specific version of the skills to a project, or if your team manages skills in
version control alongside the codebase.

---

## Option 3: Claude.ai (Connectors + Skills)

### Connect the MCP servers

1. Go to [claude.ai → Customize → Connectors](https://claude.ai/customize/connectors) and click **+** to add a custom connector.

2. Add the CloudBalance server (cost data and recommendations):
   `https://mcp.cloudbalance.ai/mcp`

3. Add the CloudBalance BCM server (live AWS Cost Explorer data):
   `https://mcp.cloudbalance.ai/mcp-bcm`

4. Click **Connect** on each and authorize when prompted. Each issues its own OAuth token.

### Upload the skills package

1. Download the skills zip from your CloudBalance account at
   `Integrations → Claude Setup → Download cloudbalance-skills.zip`
   or directly: `https://www.cloudbalance.ai/cb/skills/cloudbalance.zip/`

2. Go to [claude.ai → Customize → Skills](https://claude.ai/customize) and click **+**.

3. Drag and drop the zip into the upload dialog.

The **cloudbalance** skill will appear under Personal plugins and activate automatically
for FinOps and AWS cost questions.

---

## Verifying the installation

After installing, open Claude Code and run:

```
/cloudbalance
```

Claude should greet you and offer to pull your AWS cost data or answer FinOps questions.

If the skill isn't detected, verify the directory structure:

```
~/.claude/skills/cloudbalance/SKILL.md          # global
.claude/skills/cloudbalance/SKILL.md            # project-local
```

---

## Updating

Re-run the original install command. The installer replaces the existing skill folder
with the latest version.

---

## MCP server setup

The skill works best with the CloudBalance MCP server configured so Claude can pull
live data from your AWS accounts. See your CloudBalance account at:

`Settings → Claude Setup` for the MCP configuration snippet and API token generation.

---

## License

See [LICENSE.md](cloudbalance/LICENSE.md) for full license details.

CloudBalance platform content: CC BY-SA 4.0, Copyright (c) CloudBalance.
FinOps domain knowledge: CC BY-SA 4.0, adapted from
[OptimNow cloud-finops-skills](https://github.com/OptimNow/cloud-finops-skills).
