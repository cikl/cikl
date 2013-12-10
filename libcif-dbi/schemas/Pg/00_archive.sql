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
DROP INDEX IF EXISTS idx_archive_assessment;
DROP INDEX IF EXISTS idx_archive_confidence;
DROP INDEX IF EXISTS idx_archive_asn;
DROP INDEX IF EXISTS idx_archive_cidr;
DROP INDEX IF EXISTS idx_archive_email;
DROP INDEX IF EXISTS idx_archive_fqdn;
DROP INDEX IF EXISTS idx_archive_url;
DROP TABLE IF EXISTS archive CASCADE;

CREATE TABLE archive (
    id BIGSERIAL NOT NULL PRIMARY KEY,
--    uuid uuid NOT NULL,
    guid_id BIGINT REFERENCES archive_guid_map(id) NOT NULL,
--    format text,
    reporttime INT NOT NULL,
    created INT NOT NULL,
    data text not null,
    assessment VARCHAR(64),
    confidence SMALLINT CHECK (confidence >= 0 AND confidence <= 100),
    asn BIGINT[],
    cidr cidr[],
    email VARCHAR(320)[],
    fqdn VARCHAR(255)[],
    url VARCHAR(2048)[]
);

-- CREATE INDEX idx_archive_uuid ON archive (uuid);
CREATE INDEX idx_archive_created ON archive (created);
CREATE INDEX idx_archive_reporttime ON archive (reporttime);
CREATE INDEX idx_archive_assessment ON archive (assessment);
CREATE INDEX idx_archive_confidence ON archive (confidence);
CREATE INDEX idx_archive_asn ON archive USING GIN(asn);
CREATE INDEX idx_archive_cidr ON archive USING GIN(cidr);
CREATE INDEX idx_archive_email ON archive USING GIN(email);
CREATE INDEX idx_archive_fqdn ON archive USING GIN(fqdn);
CREATE INDEX idx_archive_url ON archive USING GIN(url);
