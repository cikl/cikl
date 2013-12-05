set default_tablespace=:tablespace_archive;

-- CREATE EXTENSION btree_gin;

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
    guid_id BIGINT REFERENCES archive_guid_map(id) NOT NULL,
--    format text,
    reporttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    data text not null
);

-- CREATE INDEX idx_archive_uuid ON archive (uuid);
CREATE INDEX idx_archive_created ON archive (created);
CREATE INDEX idx_archive_reporttime ON archive (reporttime);

-- Lookup table
DROP INDEX IF EXISTS idx_archive_lookup_asn;
DROP INDEX IF EXISTS idx_archive_lookup_cidr;
DROP INDEX IF EXISTS idx_archive_lookup_email;
DROP INDEX IF EXISTS idx_archive_lookup_fqdn;
DROP INDEX IF EXISTS idx_archive_lookup_url;
DROP TABLE IF EXISTS archive_lookup CASCADE;

CREATE TABLE archive_lookup (
    id BIGINT REFERENCES archive(id) NOT NULL,
    asn BIGINT,
    cidr CIDR,
    email VARCHAR(320),
    fqdn VARCHAR(255),
    url VARCHAR(2048)
);

CREATE INDEX idx_archive_lookup_asn ON archive_lookup (asn);
CREATE INDEX idx_archive_lookup_cidr ON archive_lookup (cidr);
CREATE INDEX idx_archive_lookup_email ON archive_lookup (email);
CREATE INDEX idx_archive_lookup_fqdn ON archive_lookup (fqdn);
CREATE INDEX idx_archive_lookup_url ON archive_lookup (url);
