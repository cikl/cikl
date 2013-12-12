set default_tablespace=:tablespace_archive;

CREATE EXTENSION "btree_gin";

DROP TABLE IF EXISTS archive_guid_map CASCADE;

CREATE TABLE archive_guid_map (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    guid UUID UNIQUE NOT NULL  
);

DROP TABLE IF EXISTS cif_group CASCADE;
DROP SEQUENCE IF EXISTS cif_group_id_seq;
CREATE SEQUENCE cif_group_id_seq START WITH 2;
CREATE TABLE cif_group (
    id INT DEFAULT NEXTVAL('cif_group_id_seq') NOT NULL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Create the default user group;
INSERT INTO cif_group (id, name) VALUES (1, 'everyone');

DROP TABLE IF EXISTS cif_user CASCADE;

CREATE TABLE cif_user (
    id SERIAL NOT NULL PRIMARY KEY,
    apikey UUID UNIQUE NOT NULL,
    name varchar(50) UNIQUE NOT NULL,
    revoked BOOLEAN DEFAULT FALSE NOT NULL,
    write BOOLEAN DEFAULT FALSE NOT NULL,
    created INT NOT NULL DEFAULT (EXTRACT(EPOCH FROM now())::INT),
    expires INT,
    default_group_id INT REFERENCES cif_group(id) DEFAULT 1 NOT NULL
);

DROP TABLE IF EXISTS cif_user_group_map CASCADE;

CREATE TABLE cif_user_group_map (
    user_id INT REFERENCES cif_user(id) NOT NULL,
    group_id INT REFERENCES cif_group(id) NOT NULL
);

CREATE INDEX idx_cif_user_group_map_user_id ON cif_user_group_map (user_id);
CREATE INDEX idx_cif_user_group_map_group_id ON cif_user_group_map (group_id);
CREATE UNIQUE INDEX idx_cif_user_group_map_unique ON cif_user_group_map (user_id, group_id);

DROP TABLE IF EXISTS archive CASCADE;

CREATE TABLE archive (
    id BIGSERIAL NOT NULL PRIMARY KEY,
--    uuid uuid NOT NULL,
    group_id INT REFERENCES cif_group(id) NOT NULL,
--    format text,
    reporttime INT NOT NULL,
    created INT NOT NULL,
    data text not null,
    assessment VARCHAR(64),
    confidence SMALLINT CHECK (confidence >= 0 AND confidence <= 100),
    asn BIGINT[],
    cidr cidr[],
    email VARCHAR(320)[],
    fqdn VARCHAR(255)[],
    url VARCHAR(2048)[]
);

-- CREATE INDEX idx_archive_uuid ON archive (uuid);
CREATE INDEX idx_archive_created ON archive (created);
CREATE INDEX idx_archive_reporttime ON archive (reporttime);
CREATE INDEX idx_archive_assessment ON archive (assessment);
CREATE INDEX idx_archive_confidence ON archive (confidence);
CREATE INDEX idx_archive_asn ON archive USING GIN(asn);
CREATE INDEX idx_archive_cidr ON archive USING GIN(cidr);
CREATE INDEX idx_archive_email ON archive USING GIN(email);
CREATE INDEX idx_archive_fqdn ON archive USING GIN(fqdn);
CREATE INDEX idx_archive_url ON archive USING GIN(url);
