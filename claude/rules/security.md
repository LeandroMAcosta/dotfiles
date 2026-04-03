## Security

- Never hardcode secrets, API keys, or credentials. Use environment variables.
- Auth tokens via httpOnly cookies, never localStorage.
- Validate all user input at system boundaries.
- Be aware of OWASP top 10: injection, XSS, CSRF, broken auth.
- Always use parameterized queries for database access.
