set default_tablespace=:tablespace_archive;

DROP INDEX IF EXISTS idx_archive_guid_map_guid;
DROP TABLE IF EXISTS archive_guid_map CASCADE;

CREATE TABLE archive_guid_map (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    guid uuid
);

CREATE UNIQUE INDEX idx_archive_guid_map_guid ON archive_guid_map(guid);

DROP INDEX IF EXISTS idx_archive_created;
DROP INDEX IF EXISTS idx_archive_reporttime;
DROP TABLE IF EXISTS archive CASCADE;

CREATE TABLE archive (
    id BIGSERIAL NOT NULL PRIMARY KEY,
--    uuid uuid NOT NULL,
    guid_id BIGINT REFERENCES archive_guid_map(id) ON DELETE CASCADE NOT NULL,
--    format text,
    reporttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    data text not null
);

-- CREATE INDEX idx_archive_uuid ON archive (uuid);
CREATE INDEX idx_archive_created ON archive (created);
CREATE INDEX idx_archive_reporttime ON archive (reporttime);
