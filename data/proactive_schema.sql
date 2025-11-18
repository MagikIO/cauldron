-- Proactive Intelligence Schema
-- Extends the base schema with tables for intelligent monitoring and assistance

-- Command execution history tracking
CREATE TABLE IF NOT EXISTS "command_history" (
	"id"	INTEGER,
	"session_id"	TEXT NOT NULL,
	"command"	TEXT NOT NULL,
	"exit_code"	INTEGER,
	"duration_ms"	INTEGER,
	"timestamp"	INTEGER NOT NULL,
	"stderr_sample"	TEXT,
	"stdout_sample"	TEXT,
	"working_directory"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("session_id") REFERENCES "sessions"("session_id")
);

-- Proactive alerts and notifications queue
CREATE TABLE IF NOT EXISTS "proactive_alerts" (
	"id"	INTEGER,
	"alert_type"	TEXT NOT NULL CHECK(alert_type IN ('error', 'git', 'process', 'pattern')),
	"priority"	TEXT NOT NULL CHECK(priority IN ('low', 'medium', 'high')) DEFAULT 'medium',
	"message"	TEXT NOT NULL,
	"suggestion"	TEXT,
	"triggered_at"	INTEGER NOT NULL,
	"dismissed_at"	INTEGER,
	"session_id"	TEXT,
	"command_id"	INTEGER,
	"metadata"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("session_id") REFERENCES "sessions"("session_id"),
	FOREIGN KEY("command_id") REFERENCES "command_history"("id")
);

-- Detected command patterns for automation suggestions
CREATE TABLE IF NOT EXISTS "command_patterns" (
	"id"	INTEGER,
	"pattern_hash"	TEXT UNIQUE NOT NULL,
	"commands"	TEXT NOT NULL,
	"frequency"	INTEGER DEFAULT 1,
	"last_seen"	INTEGER NOT NULL,
	"first_seen"	INTEGER NOT NULL,
	"automation_suggestion"	TEXT,
	"dismissed"	INTEGER DEFAULT 0,
	"session_id"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("session_id") REFERENCES "sessions"("session_id")
);

-- Long-running process monitoring
CREATE TABLE IF NOT EXISTS "monitored_processes" (
	"id"	INTEGER,
	"pid"	INTEGER UNIQUE NOT NULL,
	"command"	TEXT NOT NULL,
	"started_at"	INTEGER NOT NULL,
	"completed_at"	INTEGER,
	"alert_threshold_ms"	INTEGER DEFAULT 60000,
	"alerted"	INTEGER DEFAULT 0,
	"session_id"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("session_id") REFERENCES "sessions"("session_id")
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS "idx_command_history_session" ON "command_history" ("session_id");
CREATE INDEX IF NOT EXISTS "idx_command_history_timestamp" ON "command_history" ("timestamp");
CREATE INDEX IF NOT EXISTS "idx_command_history_exit_code" ON "command_history" ("exit_code");
CREATE INDEX IF NOT EXISTS "idx_proactive_alerts_type" ON "proactive_alerts" ("alert_type");
CREATE INDEX IF NOT EXISTS "idx_proactive_alerts_dismissed" ON "proactive_alerts" ("dismissed_at");
CREATE INDEX IF NOT EXISTS "idx_command_patterns_hash" ON "command_patterns" ("pattern_hash");
CREATE INDEX IF NOT EXISTS "idx_monitored_processes_pid" ON "monitored_processes" ("pid");
CREATE INDEX IF NOT EXISTS "idx_monitored_processes_completed" ON "monitored_processes" ("completed_at");

-- Views for easy querying
CREATE VIEW IF NOT EXISTS "recent_errors" AS
SELECT
	ch.id,
	ch.command,
	ch.exit_code,
	ch.stderr_sample,
	ch.timestamp,
	datetime(ch.timestamp, 'unixepoch', 'localtime') as formatted_time,
	ch.working_directory
FROM command_history ch
WHERE ch.exit_code != 0 AND ch.exit_code IS NOT NULL
ORDER BY ch.timestamp DESC
LIMIT 50;

CREATE VIEW IF NOT EXISTS "pending_alerts" AS
SELECT
	pa.id,
	pa.alert_type,
	pa.priority,
	pa.message,
	pa.suggestion,
	pa.triggered_at,
	datetime(pa.triggered_at, 'unixepoch', 'localtime') as formatted_time
FROM proactive_alerts pa
WHERE pa.dismissed_at IS NULL
ORDER BY pa.priority DESC, pa.triggered_at DESC;

CREATE VIEW IF NOT EXISTS "active_patterns" AS
SELECT
	cp.id,
	cp.pattern_hash,
	cp.commands,
	cp.frequency,
	cp.automation_suggestion,
	datetime(cp.last_seen, 'unixepoch', 'localtime') as last_seen_time
FROM command_patterns cp
WHERE cp.dismissed = 0 AND cp.frequency >= 3
ORDER BY cp.frequency DESC, cp.last_seen DESC;

CREATE VIEW IF NOT EXISTS "long_running_commands" AS
SELECT
	ch.command,
	ch.duration_ms,
	ROUND(ch.duration_ms / 1000.0, 2) as duration_seconds,
	datetime(ch.timestamp, 'unixepoch', 'localtime') as executed_at
FROM command_history ch
WHERE ch.duration_ms > 60000
ORDER BY ch.duration_ms DESC
LIMIT 25;

-- Default preferences for proactive intelligence
INSERT OR IGNORE INTO "user_preferences" ("preference_key", "preference_value", "project_path", "created_at", "updated_at")
VALUES
	-- Error Watcher
	('proactive.error_watcher.enabled', 'true', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.error_watcher.auto_suggest', 'false', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.error_watcher.min_delay_ms', '1000', NULL, strftime('%s', 'now'), strftime('%s', 'now')),

	-- Git Guardian
	('proactive.git_guardian.enabled', 'true', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.git_guardian.check_interval', '10', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.git_guardian.uncommitted_threshold', '5', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.git_guardian.time_threshold_minutes', '30', NULL, strftime('%s', 'now'), strftime('%s', 'now')),

	-- Process Monitor
	('proactive.process_monitor.enabled', 'true', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.process_monitor.threshold_ms', '60000', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.process_monitor.show_stats', 'true', NULL, strftime('%s', 'now'), strftime('%s', 'now')),

	-- Pattern Detector
	('proactive.pattern_detector.enabled', 'true', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.pattern_detector.check_interval', '20', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.pattern_detector.min_frequency', '3', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
	('proactive.pattern_detector.lookback_commands', '100', NULL, strftime('%s', 'now'), strftime('%s', 'now'));
