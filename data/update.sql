-- Add date column to dependencies table if it doesn't exist (for parallel installation tracking)
ALTER TABLE dependencies ADD COLUMN date TEXT;

INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('8', 'vault-boy', NULL, 'Meme', '1', '1', NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('9', 'wheatley', NULL, 'Meme', '1', '1', NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('10', 'wilfred', NULL, 'Meme', '1', '1', NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('11', 'woodstock', NULL, 'Meme', '1', '1', NULL);
INSERT INTO "familiars" ("id", "name", "display_name", "familiar_type", "unlocked", "cow_src_ext", "nickname") VALUES ('12', 'yoda', NULL, 'Meme', '1', '1', NULL);
