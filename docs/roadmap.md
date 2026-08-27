# Roadmap

The roadmap is intentionally incremental. Each phase should leave the repository runnable and understandable before another identity feature is added.

## Phase 0 - Repository scaffold

- [x] Define repository boundaries.
- [x] Pin CAS `8.0.1.2` and JDK `25` baseline.
- [x] Add PostgreSQL Docker service.
- [x] Add demo identity schema with BCrypt passwords.
- [x] Add project-owned CAS configuration.
- [x] Add explicit JSON service registry.
- [x] Add reproducible CAS Initializr bootstrap scripts.

## Phase 1 - Real CAS login

- [ ] Validate the CAS 8.0.1.2 generated overlay.
- [ ] Build with JDBC + JSON registry + PostgreSQL driver modules.
- [ ] Generate/manage a local development keystore.
- [ ] Add CAS to Docker Compose.
- [ ] Wait for PostgreSQL health before CAS startup.
- [ ] Verify `admin` and `user` authenticate through PostgreSQL.
- [ ] Verify invalid/disabled users are rejected.
- [ ] Add a smoke-test script.

**Exit criterion:** CAS login works against PostgreSQL without the built-in demo authentication handler.

## Phase 2 - First client and SSO

- [ ] Create a minimal Spring Boot client.
- [ ] Protect one endpoint with CAS.
- [ ] Validate service-ticket issuance and validation.
- [ ] Add a second protected application/instance.
- [ ] Demonstrate that the second application does not request credentials again.

**Exit criterion:** a browser demonstrates real CAS SSO across two registered services.

## Phase 3 - Attributes, roles and logout

- [ ] Resolve user roles from PostgreSQL.
- [ ] Configure explicit attribute release.
- [ ] Display released attributes in the demo client.
- [ ] Add application-side role checks.
- [ ] Implement and verify Single Logout.

**Exit criterion:** identity, attribute release, authorization and logout responsibilities are clearly demonstrated end-to-end.

## Phase 4 - More client stacks

- [ ] Node.js client.
- [ ] Symfony/PHP client.
- [ ] Document Angular SPA architecture through a backend/BFF instead of placing CAS credentials or ticket validation logic in the browser.

## Phase 5 - LDAP profile

- [ ] Add OpenLDAP infrastructure.
- [ ] Add LDAP users/groups fixtures.
- [ ] Add a Compose profile for LDAP-backed authentication.
- [ ] Compare JDBC and LDAP identity models.

## Phase 6 - Security controls

- [ ] Login throttling / brute-force protection.
- [ ] TOTP MFA.
- [ ] Audit events.
- [ ] Security headers and hardened cookie settings.
- [ ] Secret-management examples.

## Phase 7 - Modern protocols

- [ ] OAuth2 provider capabilities.
- [ ] OpenID Connect provider capabilities.
- [ ] OIDC client example.

## Phase 8 - SAML

- [ ] SAML IdP support.
- [ ] Metadata management.
- [ ] SAML service-provider example.

## Non-goals

The project should not become:

- a fork of Apereo CAS;
- a replacement CAS implementation;
- a giant all-features-enabled CAS distribution;
- a production deployment copied blindly without understanding the security model.
