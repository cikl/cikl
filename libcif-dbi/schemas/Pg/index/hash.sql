set default_tablespace=:cif_default_tablespace;

DROP INDEX IF EXISTS idx_hash_1;
CREATE INDEX idx_hash_1 ON hash (hash,confidence);

DROP INDEX IF EXISTS idx_hash_2;
CREATE INDEX idx_hash_2 ON hash (uuid);

DROP INDEX IF EXISTS idx_hash_3;
CREATE INDEX idx_hash_3 ON hash (reporttime);
