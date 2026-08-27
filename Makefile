SHELL := /bin/bash

CAS_MODULES := jdbc,json-service-registry,org.postgresql:postgresql
CAS_OVERLAY := cas-server/overlay

.PHONY: help bootstrap db-up db-down db-logs cas-build clean-overlay

help:
	@echo "Available targets:"
	@echo "  make bootstrap      Generate the pinned CAS overlay"
	@echo "  make db-up          Start PostgreSQL"
	@echo "  make db-down        Stop PostgreSQL"
	@echo "  make db-logs        Follow PostgreSQL logs"
	@echo "  make cas-build      Build the generated CAS overlay"
	@echo "  make clean-overlay  Remove generated overlay files"

bootstrap:
	./scripts/bootstrap-cas.sh

db-up:
	docker compose up -d postgres

db-down:
	docker compose down

db-logs:
	docker compose logs -f postgres

cas-build:
	@test -f "$(CAS_OVERLAY)/gradlew" || (echo "CAS overlay missing. Run 'make bootstrap' first." && exit 1)
	cd "$(CAS_OVERLAY)" && ./gradlew clean build -PcasModules="$(CAS_MODULES)"

clean-overlay:
	find "$(CAS_OVERLAY)" -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} +
