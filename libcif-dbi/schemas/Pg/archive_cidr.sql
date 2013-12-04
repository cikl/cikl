set default_tablespace=:tablespace_archive;

DROP TABLE IF EXISTS archive_cidr CASCADE;

CREATE TABLE archive_cidr (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    archive_id BIGSERIAL NOT NULL,
    cidr cidr NOT NULL,
    reporttime TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_archive_cidr_cidr ON archive_cidr (cidr);
CREATE INDEX idx_archive_cidr_archive_id ON archive_cidr (archive_id);
CREATE INDEX idx_archive_cidr_cidr_reporttime ON archive_cidr (cidr, reporttime);
CREATE INDEX idx_archive_cidr_cidr_created ON archive_cidr (cidr, created);


