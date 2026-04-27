# Security Policy

## Scope

Future Kids is a web application that manages a mentoring program for primary school children. It
stores personally identifiable information (PII) about minors, their families, mentors, and school
staff. Security issues in this application carry elevated real-world risk and are taken seriously.

The following are in scope for vulnerability reports:

- Authentication and session management (Devise)
- Authorisation bypasses (CanCanCan roles: Admin, Principal, Teacher, Mentor)
- Insecure direct object reference (IDOR) on kid, mentor, journal, or document records
- File upload/download vulnerabilities (Active Storage, Google Cloud Storage)
- SQL injection or mass assignment
- Cross-site scripting (XSS) or cross-site request forgery (CSRF)
- Sensitive data exposure (PII, documents, assessment reports)
- Privilege escalation between user roles
- Dependency vulnerabilities with a credible exploit path

Out of scope: denial-of-service attacks, spam, social engineering, issues requiring physical access,
and vulnerabilities in third-party services outside our control.

## Supported Versions

Only the latest commit on the `master` branch receives security fixes.

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Report findings by email to: [github.booted220@simplelogin.com](mailto:github.booted220@simplelogin.com)

Please include:

- A description of the vulnerability and its potential impact
- Steps to reproduce or a proof-of-concept (against a local instance, not production)
- The affected component(s) and any relevant request/response details
- Your suggested severity (Critical / High / Medium / Low)

We will acknowledge your report and aim to provide a fix or mitigation
plan as quickly as the severity warrants. We will keep you informed of progress and credit you in
the release notes unless you prefer to remain anonymous.

## Data Protection Context

This application is subject to the Swiss Federal Act on Data Protection (revDSG) and, where
applicable, the EU General Data Protection Regulation (GDPR). Vulnerabilities that could lead to
unauthorised access to or disclosure of personal data about minors are treated as highest priority.
