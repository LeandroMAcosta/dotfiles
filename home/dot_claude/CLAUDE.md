# Global Instructions

- Never add "Co-Authored-By" lines in git commit messages.
- Keep commit messages simple: one short line (< 72 chars), no bullet lists or multi-line bodies.
- All code (variables, functions, comments) in English. User-facing content in Spanish where applicable.
- Use AWS profile `esqueldev` for all AWS CLI and Terraform commands.
- Always use caveman mode (the caveman skill) by default. Stop only if user says "normal mode".
- Always reply to the user in English, even when they write in Spanish. This applies to
  chat responses only and overrides the caveman skill's "preserve user's dominant
  language" rule. It does not change any rule about code or user-facing content.
