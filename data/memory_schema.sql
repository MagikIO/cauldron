-- Conversation History Table
-- Stores all interactions with the familiar/ask function
CREATE TABLE IF NOT EXISTS "conversation_history" (
	"id"	INTEGER,
	"session_id"	TEXT NOT NULL,
	"timestamp"	INTEGER NOT NULL, -- Unix timestamp
	"query"	TEXT NOT NULL,
	"response"	TEXT,
	"context_snapshot"	TEXT, -- JSON string of context at time of query
	"model"	TEXT DEFAULT 'llama3.2',
	"command_type"	TEXT NOT NULL, -- 'ask', 'familiar', etc.
	"success"	INTEGER DEFAULT 1,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("session_id") REFERENCES "sessions"("session_id")
);

-- Project Context Table
-- Stores project-specific information
CREATE TABLE IF NOT EXISTS "project_context" (
	"id"	INTEGER,
	"project_path"	TEXT NOT NULL UNIQUE,
	"project_name"	TEXT,
	"git_remote"	TEXT,
	"primary_language"	TEXT,
	"languages"	TEXT, -- JSON array of detected languages
	"framework"	TEXT,
	"package_manager"	TEXT,
	"last_updated"	INTEGER NOT NULL, -- Unix timestamp
	"metadata"	TEXT, -- JSON object for additional project info
	PRIMARY KEY("id" AUTOINCREMENT)
);

-- User Preferences Table
-- Stores global and project-specific user preferences
CREATE TABLE IF NOT EXISTS "user_preferences" (
	"id"	INTEGER,
	"preference_key"	TEXT NOT NULL,
	"preference_value"	TEXT NOT NULL,
	"project_path"	TEXT, -- NULL for global preferences
	"created_at"	INTEGER NOT NULL,
	"updated_at"	INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	UNIQUE("preference_key", "project_path")
);

-- Sessions Table
-- Tracks terminal sessions for conversation continuity
CREATE TABLE IF NOT EXISTS "sessions" (
	"id"	INTEGER,
	"session_id"	TEXT NOT NULL UNIQUE,
	"started_at"	INTEGER NOT NULL,
	"ended_at"	INTEGER,
	"working_directory"	TEXT,
	"project_path"	TEXT,
	"shell_pid"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS "idx_conversation_session" ON "conversation_history" ("session_id");
CREATE INDEX IF NOT EXISTS "idx_conversation_timestamp" ON "conversation_history" ("timestamp");
CREATE INDEX IF NOT EXISTS "idx_project_path" ON "project_context" ("project_path");
CREATE INDEX IF NOT EXISTS "idx_user_prefs_project" ON "user_preferences" ("project_path");
CREATE INDEX IF NOT EXISTS "idx_sessions_id" ON "sessions" ("session_id");

-- Create views for common queries
CREATE VIEW IF NOT EXISTS "recent_conversations" AS
SELECT
	ch.id,
	ch.timestamp,
	ch.query,
	ch.response,
	ch.command_type,
	s.working_directory,
	datetime(ch.timestamp, 'unixepoch', 'localtime') as formatted_time
FROM conversation_history ch
LEFT JOIN sessions s ON ch.session_id = s.session_id
ORDER BY ch.timestamp DESC
LIMIT 100;

CREATE VIEW IF NOT EXISTS "current_session_history" AS
SELECT
	ch.id,
	ch.timestamp,
	ch.query,
	ch.response,
	ch.command_type,
	datetime(ch.timestamp, 'unixepoch', 'localtime') as formatted_time
FROM conversation_history ch
WHERE ch.session_id = (
	SELECT session_id FROM sessions
	WHERE ended_at IS NULL
	ORDER BY started_at DESC
	LIMIT 1
)
ORDER BY ch.timestamp DESC;

-- Insert some default user preferences
INSERT OR IGNORE INTO "user_preferences" ("preference_key", "preference_value", "project_path", "created_at", "updated_at")
VALUES
	('default_familiar', 'default', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('default_emotion', 'normal', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('conversation_memory_limit', '50', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('enable_context_awareness', 'true', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('enable_proactive_suggestions', 'false', NULL, strftime('%s', 'now'), strftime('%s', 'now'));
