# HireFlow ATS

Production-ready Applicant Tracking System built with Rails 7.1, PostgreSQL, Redis, and Sidekiq.

## Features

- **Multi-tenant isolation** — Teams are fully isolated; no cross-tenant data leakage
- **Role-based access control** — Owner, Admin, Hiring Manager, Recruiter, Member, Viewer
- **Job lifecycle** — Draft → Published → Closed → Archived (with restore)
- **Versioned pipelines** — Custom stages per job; safe migration when candidates exist
- **Kanban candidates** — Drag-and-drop stage moves with optimistic locking
- **Batch operations** — Async bulk candidate moves via Sidekiq
- **Full audit trail** — ActivityLog + PaperTrail for every change
- **JSON API** — Paginated, serialized, with CORS support

## Quick Start

```bash
# One command to start everything
docker compose up

# Or with the setup script
chmod +x bin/setup
./bin/setup
```

## Architecture

```
├── app/
│   ├── controllers/api/v1/   # JSON API controllers
│   ├── models/               # Core domain models
│   ├── policies/             # Pundit authorization policies
│   ├── serializers/          # API response serializers
│   ├── services/             # Business logic services
│   └── jobs/                 # Sidekiq background jobs
├── config/
│   ├── routes.rb             # API routing
│   └── initializers/         # Devise, Sidekiq, PaperTrail, etc.
├── db/
│   └── migrate/              # PostgreSQL migrations with UUID PKs
├── spec/                     # RSpec test suite
└── docker-compose.yml        # Full stack: Rails, PG, Redis, Sidekiq
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /users/sign_up | Register + create team |
| POST | /users/sign_in | Login |
| GET | /api/v1/jobs | List jobs (paginated) |
| POST | /api/v1/jobs | Create job |
| POST | /api/v1/jobs/:id/publish | Publish job |
| POST | /api/v1/jobs/:id/close | Close job |
| POST | /api/v1/jobs/:id/archive | Archive job |
| POST | /api/v1/jobs/:id/restore | Restore job |
| GET | /api/v1/jobs/:id/candidates | List candidates |
| POST | /api/v1/jobs/:id/candidates | Create candidate |
| PATCH | /api/v1/jobs/:jid/candidates/:id/move_stage | Move candidate |
| PATCH | /api/v1/jobs/:id/candidates/batch_move | Batch move |
| GET | /api/v1/jobs/:id/stages | List pipeline stages |
| PATCH | /api/v1/jobs/:id/stages/reorder | Reorder stages |
| POST | /api/v1/teams/:id/invite_member | Invite to team |
| GET | /api/v1/activity_logs | Audit trail |
| GET | /health | Health check |

## Running Tests

```bash
# Local
bundle exec rspec

# Docker
docker compose --profile test run test
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| DATABASE_HOST | localhost | PostgreSQL host |
| DATABASE_USERNAME | postgres | DB user |
| DATABASE_PASSWORD | postgres | DB password |
| REDIS_URL | redis://localhost:6379/0 | Redis URL |
| RAILS_ENV | development | Environment |
| SECRET_KEY_BASE | — | Required in production |

## Seed Data

```
Admin: admin@hireflow.io / password123
Recruiter: recruiter@hireflow.io / password123
```

## Key Design Decisions

1. **UUID primary keys** — Prevents enumeration attacks, safe for distributed systems
2. **Optimistic locking** (`lock_version`) — Prevents lost updates on concurrent candidate moves
3. **Pipeline versioning** — Stages are versioned per job; modifying stages with active candidates triggers safe migration
4. **Multi-tenancy via ActsAsTenant** — Row-level isolation enforced at model and controller level
5. **Pundit policies** — Fine-grained permission checks per action, per role, per creator
6. **PaperTrail + ActivityLog** — Dual audit: PaperTrail for model-level diffs, ActivityLog for business events
