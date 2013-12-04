set default_tablespace=:tablespace_archive;

DROP TABLE IF EXISTS archive_asn CASCADE;

CREATE TABLE archive_asn (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    archive_id BIGSERIAL NOT NULL,
    asn BIGINT NOT NULL,
    reporttime TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_archive_asn_asn ON archive_asn (asn);
CREATE INDEX idx_archive_asn_archive_id ON archive_asn (archive_id);
CREATE INDEX idx_archive_asn_asn_reporttime ON archive_asn (asn, reporttime);
CREATE INDEX idx_archive_asn_asn_created ON archive_asn (asn, created);

