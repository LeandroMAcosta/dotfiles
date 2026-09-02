#!/usr/bin/env bash
set -euo pipefail

# Claude Code skills. Each repo installs an explicit skill list rather than
# everything it ships. `skills add` cannot pin a commit, so without -s any
# skill the upstream adds later is installed silently on the next run, with
# full agent permissions. That is how the Caveman Cloud skills arrived
# uninvited; they were removed. To adopt a new upstream skill, add its name
# here deliberately. Audit reports: https://www.skills.sh/audits
# run_onchange: re-runs when this list changes.
command -v npx &>/dev/null || exit 0

echo "==> Installing Claude Code skills..."
npx -y skills add JuliusBrussee/caveman -g -y --agent claude-code \
  -s caveman,caveman-commit,caveman-compress,caveman-explore,caveman-help,caveman-review,caveman-stats || true
npx -y skills add nextlevelbuilder/ui-ux-pro-max-skill -g -y --agent claude-code \
  -s banner-design,brand,design,design-system,slides,ui-styling,ui-ux-pro-max || true
npx -y skills add shadcn/ui -g -y --agent claude-code \
  -s shadcn,migrate-radix-to-base || true
npx -y skills add forrestchang/andrej-karpathy-skills -g -y --agent claude-code \
  -s karpathy-guidelines || true
