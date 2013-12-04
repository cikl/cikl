set default_tablespace=:tablespace_archive;

DROP TABLE IF EXISTS archive_fqdn CASCADE;

CREATE TABLE archive_fqdn (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    archive_id BIGSERIAL NOT NULL,
    fqdn VARCHAR(255) NOT NULL,
    reporttime TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_archive_fqdn_fqdn ON archive_fqdn (fqdn);
CREATE INDEX idx_archive_fqdn_archive_id ON archive_fqdn (archive_id);
CREATE INDEX idx_archive_fqdn_fqdn_reporttime ON archive_fqdn (fqdn, reporttime);
CREATE INDEX idx_archive_fqdn_fqdn_created ON archive_fqdn (fqdn, created);
