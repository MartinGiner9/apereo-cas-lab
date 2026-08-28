# Client applications

This directory will contain intentionally small, real applications that authenticate against the lab CAS server.

Planned clients:

```text
clients/
├── spring-boot/    # first reference CAS client
├── node/           # protocol integration outside Java
└── symfony/        # PHP/Symfony integration
```

Each client should:

- be independently runnable;
- have its own explicit CAS registered-service definition;
- validate tickets server-side;
- never treat the browser as a trusted CAS ticket validator;
- keep application authorization inside the application;
- include a minimal integration/smoke test where practical.

The first implementation will be Spring Boot because it gives us the cleanest baseline for observing the CAS protocol before introducing framework-specific differences in Node or Symfony.
