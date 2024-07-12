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
	"display_name"	TEXT COLLATE RTRIM,
	"familiar_type"	TEXT NOT NULL COLLATE RTRIM,
	"unlocked"	INTEGER NOT NULL DEFAULT 0,
	"cow_src_ext"	INTEGER DEFAULT 0,
	"nickname"	TEXT COLLATE NOCASE,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE VIEW "unlocked_familiars" AS SELECT * FROM familiars WHERE unlocked = 1;

INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('1', 'koala', NULL, 'Woodland-Cute', '1', NULL, NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('2', 'hellokitty', 'Hello Kitty', 'Mascot-Cute', '1', NULL, NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('3', 'suse', NULL, 'Jungle-Cute', '1', NULL, NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('4', 'tux', NULL, 'Artic-Cute', '1', NULL, NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('5', 'cock', 'Rooster', 'Farm', '1', NULL, NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('6', 'duck', NULL, 'Farm-Urban-Cute', '1', NULL, NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('7', 'trogdor', NULL, 'Meme', '1', '1', NULL);
