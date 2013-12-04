set default_tablespace=:tablespace_archive;

DROP TABLE IF EXISTS archive_url CASCADE;

CREATE TABLE archive_url (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    archive_id BIGSERIAL NOT NULL,
    url varchar(2048) NOT NULL,
    reporttime TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_archive_url_url ON archive_url (url);
CREATE INDEX idx_archive_url_archive_id ON archive_url (archive_id);
CREATE INDEX idx_archive_url_url_reporttime ON archive_url (url, reporttime);
CREATE INDEX idx_archive_url_url_created ON archive_url (url, created);

