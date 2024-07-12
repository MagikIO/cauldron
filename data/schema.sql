CREATE TABLE "cauldron" (
	"version"	TEXT NOT NULL COLLATE RTRIM,
	PRIMARY KEY("version")
);
CREATE TABLE "dependencies" (
	"id"	INTEGER,
	"name"	TEXT NOT NULL UNIQUE,
	"version"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE "familiars" (
	"id"	integer,
	"name"	TEXT NOT NULL UNIQUE COLLATE RTRIM,
	"familiar_type"	TEXT NOT NULL COLLATE RTRIM,
	"display_name"	TEXT COLLATE RTRIM,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE "unlocked" (
	"id"	INTEGER NOT NULL,
	"name"	text,
	"selected"	boolean DEFAULT 0,
	FOREIGN KEY("id") REFERENCES "familiars"("id")
);

INSERT INTO "familiars" ("id", "name", "familiar_type", "display_name") VALUES ('1', 'koala', 'Woodland-Cute', NULL);
INSERT INTO "familiars" ("id", "name", "familiar_type", "display_name") VALUES ('2', 'hellokitty', 'Mascot-Cute', 'Hello Kitty');
INSERT INTO "familiars" ("id", "name", "familiar_type", "display_name") VALUES ('3', 'suse', 'Jungle-Cute', NULL);
INSERT INTO "familiars" ("id", "name", "familiar_type", "display_name") VALUES ('4', 'tux', 'Artic-Cute', NULL);
INSERT INTO "familiars" ("id", "name", "familiar_type", "display_name") VALUES ('5', 'cock', 'Farm', 'Rooster');
INSERT INTO "familiars" ("id", "name", "familiar_type", "display_name") VALUES ('6', 'duck', 'Farm-Urban-Cute', NULL);
