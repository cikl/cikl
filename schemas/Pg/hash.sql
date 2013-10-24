SET default_tablespace = 'index';
DROP TABLE IF EXISTS hash CASCADE;
CREATE TABLE hash (
    id BIGSERIAL,
    uuid uuid NOT NULL,
    guid uuid NOT NULL,
    hash text not null,
    confidence real,
    reporttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW()
);

CREATE TABLE hash_sha1 () INHERITS (hash);
ALTER TABLE hash_sha1 ADD PRIMARY KEY (id);
