set default_tablespace=:tablespace_archive;

DROP TABLE IF EXISTS archive_email CASCADE;

CREATE TABLE archive_email (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    archive_id BIGSERIAL NOT NULL,
    email varchar(320) NOT NULL,
    reporttime TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_archive_email_email ON archive_email (email);
CREATE INDEX idx_archive_email_archive_id ON archive_email (archive_id);
CREATE INDEX idx_archive_email_email_reporttime ON archive_email (email, reporttime);
CREATE INDEX idx_archive_email_email_created ON archive_email (email, created);
