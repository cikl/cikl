set default_tablespace=:cif_default_tablespace;

DROP TABLE IF EXISTS search CASCADE;
CREATE TABLE search (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    uuid uuid NOT NULL,
    guid uuid,
    hash varchar(40),
    confidence REAL,
    reporttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW()
);
