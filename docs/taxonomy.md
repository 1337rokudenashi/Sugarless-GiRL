# docs/taxonomy.md

## Purpose

Minimal reference for vulnerability classification, severity assessment, and high-impact security research.

## Classification

- **OWASP Web:** https://owasp.org/www-project-top-ten/
- **OWASP API:** https://owasp.org/www-project-api-security/
- **CWE:** https://cwe.mitre.org/
- **Bugcrowd VRT:** https://bugcrowd.com/vrt

Use the most specific classification supported by reproducible evidence.

## Severity

- **VRT:** P1–P5, based on the applicable taxonomy entry and program context.
- **CVSS v3.1:** https://www.first.org/cvss/v3.1/

Record the vector and score when relevant. Assess demonstrated impact and exploitability; do not equate CVSS, VRT priority, or bounty value.

## High-Bounty Research

Synthesized priorities informed by HackerOne, Bugcrowd, and Intigriti; not an official cross-platform ranking.

1. **Broken Access Control** — IDOR/BOLA, BFLA, privilege escalation.
2. **Authentication & Account Takeover** — Auth/MFA bypass, session flaws.
3. **Sensitive Data Exposure** — Credentials, tokens, PII.
4. **Business Logic** — Workflow, payment, entitlement abuse.
5. **Injection** — SQL injection, command injection, SSTI.
6. **SSRF** — Unauthorized requests to internal resources.
7. **RCE & Unsafe Processing** — Code execution, file inclusion, deserialization.
8. **API Security** — Authorization flaws, mass assignment, data exposure.
9. **XSS** — Stored, reflected, DOM-based.
10. **OAuth/SSO & Misconfiguration** — Token handling, account linking, exposed admin interfaces.

## Research Rules

- Verify scope, authorization, and program policy.
- Prioritize reproducible findings with demonstrable impact.
- Map confirmed findings to VRT, OWASP, and CWE.
- Document minimal PoC evidence, reproduction steps, and impact.
- Check duplicates and program-specific bounty eligibility.
- Avoid unnecessary impact on users or production systems.

## References

- [HackerOne — Top 10](https://www.hackerone.com/lp/top-ten-vulnerabilities)
- [Bugcrowd — Top 10](https://www.bugcrowd.com/resource/top-10-vulnerabilities/)
- [Intigriti — Vulnerability Glossary](https://www.intigriti.com/blog/business-insights/bug-bounty-glossary-common-web-application-vulnerabilities)
- [Intigriti — Vulnerability Trends](https://www.intigriti.com/blog/business-insights/software-industry-top-vulnerabilities-in-2024-and-what-to-watch-for-in-2025)
