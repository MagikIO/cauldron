-- Migration 002: Fix Relationship Data Corruption
-- Fixes duplicate rows and decimal values in familiar_relationship table

-- Step 1: Round all decimal relationship_level values to integers
-- The schema defines relationship_level as INTEGER but somehow decimals got stored
UPDATE familiar_relationship
SET relationship_level = ROUND(relationship_level);

-- Step 2: Remove duplicate rows from familiar_relationship
-- Keep the row with the highest total_interactions (most data)
-- If total_interactions is tied, keep the one with highest relationship_level
-- If still tied, keep the one with lowest id (oldest)

DELETE FROM familiar_relationship
WHERE id NOT IN (
    SELECT MIN(id)
    FROM (
        SELECT
            id,
            personality_id,
            COALESCE(project_path, '') as norm_path,
            total_interactions,
            relationship_level,
            ROW_NUMBER() OVER (
                PARTITION BY personality_id, COALESCE(project_path, '')
                ORDER BY total_interactions DESC, relationship_level DESC, id ASC
            ) as rn
        FROM familiar_relationship
    )
    WHERE rn = 1
);

-- Step 3: Add unique constraint to prevent future duplicates
-- Note: SQLite doesn't support ALTER TABLE ADD CONSTRAINT directly
-- We need to recreate the table with the constraint

-- First, create a temporary table with the corrected schema
CREATE TABLE familiar_relationship_new (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	project_path TEXT,
	personality_id INTEGER NOT NULL,
	relationship_level INTEGER NOT NULL DEFAULT 0 CHECK(relationship_level >= 0 AND relationship_level <= 100),
	total_interactions INTEGER NOT NULL DEFAULT 0,
	successful_interactions INTEGER NOT NULL DEFAULT 0,
	failed_interactions INTEGER NOT NULL DEFAULT 0,
	last_interaction INTEGER,
	first_interaction INTEGER NOT NULL,
	unlocked_features TEXT,
	FOREIGN KEY(personality_id) REFERENCES personalities(id) ON DELETE CASCADE,
	UNIQUE(personality_id, project_path)
);

-- Copy data from old table to new table
INSERT INTO familiar_relationship_new
SELECT * FROM familiar_relationship;

-- Drop old table
DROP TABLE familiar_relationship;

-- Rename new table to original name
ALTER TABLE familiar_relationship_new RENAME TO familiar_relationship;

-- Recreate the index
CREATE INDEX idx_relationship_project ON familiar_relationship (project_path);

-- Record this migration
INSERT OR REPLACE INTO schema_migrations (version, name, applied_at)
VALUES (2, 'fix_relationship_data', strftime('%s', 'now'));
