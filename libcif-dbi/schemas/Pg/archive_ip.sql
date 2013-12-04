set default_tablespace=:tablespace_archive;

DROP TABLE IF EXISTS archive_ip CASCADE;

CREATE TABLE archive_ip (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    archive_id BIGSERIAL NOT NULL,
    ip inet NOT NULL,
    reporttime TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_archive_ip_ip ON archive_ip (ip);
CREATE INDEX idx_archive_ip_archive_id ON archive_ip (archive_id);
CREATE INDEX idx_archive_ip_ip_reporttime ON archive_ip (ip, reporttime);
CREATE INDEX idx_archive_ip_ip_created ON archive_ip (ip, created);

