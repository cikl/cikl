set default_tablespace=:tablespace_archive;

DROP TABLE IF EXISTS datastore CASCADE;

CREATE TABLE datastore (
    id BIGINT NOT NULL UNIQUE,
    data TEXT NOT NULL
);

CREATE SEQUENCE datastore_id_seq OWNED BY datastore.id;
