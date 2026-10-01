# Database migrations without downtime

During a deploy, old and new versions of the code run at the same time. Every migration must work with both. The expand and contract pattern makes that possible.

## Expand and contract
1. Expand: add the new structure in a way the old code ignores. New nullable columns, new tables, new indexes (created concurrently on PostgreSQL), new columns with safe defaults.
2. Migrate: deploy code that writes to both the old and new structures, then backfill existing rows in batches.
3. Switch: deploy code that reads from the new structure.
4. Contract: once nothing reads or writes the old structure, remove it in a later release.

Each step is its own deploy, and usually its own slice.

## Example: rename a column
Renaming `users.name` to `users.full_name` in one migration breaks every running instance of the old code. Instead:
1. Add `full_name` (nullable).
2. Write to both columns; backfill `full_name` from `name` in batches.
3. Read from `full_name`.
4. Stop writing `name`; drop it in a later release.

## Rules
- Never drop or rename a column or table that the running code still uses.
- Add NOT NULL only after the column is fully backfilled, and use a default or a check constraint validated separately on large tables.
- Create indexes concurrently on large PostgreSQL tables (in Alembic, `op.create_index(..., postgresql_concurrently=True)` inside an autocommit block).
- Backfill in batches of a few thousand rows, with a pause between batches, and make the backfill resumable.
- Every migration has a tested downgrade, or a written reason why it cannot be undone and how to restore instead.
- Run migrations against a copy of production data before the real run when the table is large or the change is risky.
- Running a migration against a real database is the user's call; the shell guard asks before `alembic upgrade` and `alembic downgrade`.

## Firestore and other schemaless stores
There is no migration step, so the code must handle both old and new document shapes until a backfill finishes. Version the document shape with a field when it changes in incompatible ways.
