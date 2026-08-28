# Architecture

## Design goals

The lab favors reproducibility, explicit configuration and small upgrade surfaces over hiding CAS behind custom code.

The central rule is:

> Extend CAS through supported modules and configuration first; own Java code only when configuration cannot solve the requirement cleanly.

## Initial topology

```text
                         browser
                            |
                            v
                   +------------------+
                   |   Apereo CAS     |
                   |   8.0.1.2        |
                   +--------+---------+
                            |
                     JDBC authentication
                            |
                            v
                   +------------------+
                   |   PostgreSQL     |
                   |                  |
                   | cas_user         |
                   | cas_role         |
                   | cas_user_role    |
                   +------------------+

Registered applications
        |
        +--> Spring Boot demo :8444
        +--> Node.js          (future)
        +--> Symfony          (future)
```

## Repository boundaries

### `cas-server/overlay`

Generated from the official CAS Initializr and ignored by Git.

This directory is upstream-owned build machinery. It should not become the place where lab configuration accumulates.

### `cas-server/config`

Project-owned CAS configuration. Every property added here should have a concrete reason and, where practical, a link to the relevant CAS documentation in the pull request that introduces it.

### `cas-server/services`

Explicit registered-service definitions. Avoid permissive catch-all expressions such as `https://.*` because they make the lab teach unsafe service-registration habits.

### `infrastructure`

Backing services required by the lab, initially PostgreSQL. Future LDAP, observability or reverse-proxy infrastructure belongs here rather than inside CAS itself.

### `clients`

Small real applications demonstrating protocol integration. Clients should remain independent deployable applications; do not couple application authorization logic into the CAS server.

## Authentication model

Phase 1 uses CAS query-based JDBC authentication:

```text
username + password
       |
       v
CAS Query JDBC Authentication Handler
       |
       | SELECT ... FROM cas_user WHERE username=? AND enabled=true
       v
PostgreSQL
       |
       +--> stored BCrypt hash
```

The built-in CAS `casuser/Mellon` authentication handler is explicitly disabled so successful authentication proves that the configured backend is actually being exercised.

## Roles and attributes

Authentication and authorization are intentionally separated.

- `cas_user` proves identity and carries basic attributes.
- `cas_role` and `cas_user_role` model authorization data.
- CAS may release selected attributes/roles to registered services.
- Client applications remain responsible for enforcing their own authorization rules.

Do not turn CAS into a domain-authorization engine for every application.

## Service registration

Every client must have an explicit service definition. A service definition controls whether CAS trusts the application and later can control attribute release, logout behavior and protocol-specific settings.

The first reserved service is:

```text
https://localhost:8444/*
```

for the Spring Boot demonstration client.

## Versioning strategy

CAS is pinned to a reviewed version. The generated overlay is disposable; project-owned configuration is not.

Upgrade flow:

1. review CAS release/security notes;
2. change the pinned CAS version;
3. regenerate the overlay;
4. build and run integration tests;
5. review configuration/module compatibility;
6. merge the version bump as an isolated change.

This keeps upstream churn out of normal feature pull requests.

## Production boundary

This repository teaches production-like concepts but is not itself a production deployment blueprint. Production deployments require additional work including external secret management, trusted TLS certificates, HA/session/ticket strategy, audit retention, rate limiting, monitoring, backup/restore, hardened networking and organization-specific identity governance.
