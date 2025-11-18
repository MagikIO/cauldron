-- Migration 000: Baseline Schema Version Tracking
-- This migration establishes the schema versioning system

CREATE TABLE IF NOT EXISTS "schema_migrations" (
	"version"	INTEGER PRIMARY KEY,
	"name"	TEXT NOT NULL,
	"applied_at"	INTEGER NOT NULL,
	"checksum"	TEXT
);

-- Record this baseline migration
INSERT OR IGNORE INTO "schema_migrations" ("version", "name", "applied_at", "checksum")
VALUES (0, 'baseline', strftime('%s', 'now'), 'baseline');
