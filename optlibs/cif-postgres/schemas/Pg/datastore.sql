set default_tablespace=:tablespace_archive;

DROP TABLE IF EXISTS datastore CASCADE;

CREATE TABLE datastore (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    data TEXT NOT NULL
);

