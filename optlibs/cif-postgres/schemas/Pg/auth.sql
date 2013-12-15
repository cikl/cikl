set default_tablespace=:cif_default_tablespace;

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

