set default_tablespace=:cif_default_tablespace;

CREATE EXTENSION "btree_gin";
CREATE EXTENSION "ip4r";

DROP TABLE IF EXISTS cif_index_main CASCADE;

CREATE TABLE cif_index_main (
    id BIGINT NOT NULL,
    group_name VARCHAR(50) NOT NULL,
    reporttime INT NOT NULL,
    created INT NOT NULL,
    assessment VARCHAR(64),
    confidence SMALLINT -- CHECK (confidence >= 0 AND confidence <= 100)
);

-- CREATE INDEX idx_cif_index_main_uuid ON cif_index_main (uuid);
CREATE INDEX idx_cif_index_main_id ON cif_index_main (id);
CREATE INDEX idx_cif_index_main_group_name ON cif_index_main (group_name);
CREATE INDEX idx_cif_index_main_created ON cif_index_main (created);
CREATE INDEX idx_cif_index_main_reporttime ON cif_index_main (reporttime);
CREATE INDEX idx_cif_index_main_assessment ON cif_index_main (assessment);
CREATE INDEX idx_cif_index_main_confidence ON cif_index_main (confidence);

DROP TABLE IF EXISTS cif_index_asn CASCADE;
CREATE TABLE cif_index_asn (
    id BIGINT NOT NULL,
    asn BIGINT NOT NULL
);
CREATE INDEX idx_cif_index_asn_id ON cif_index_asn (id);
CREATE INDEX idx_cif_index_asn ON cif_index_asn (asn);

DROP TABLE IF EXISTS cif_index_cidr CASCADE;
CREATE TABLE cif_index_cidr (
    id BIGINT NOT NULL,
    cidr iprange NOT NULL
);
CREATE INDEX idx_cif_index_cidr_id ON cif_index_cidr (id);
CREATE INDEX idx_cif_index_cidr ON cif_index_cidr USING GIST (cidr);

DROP TABLE IF EXISTS cif_index_email CASCADE;
CREATE TABLE cif_index_email (
    id BIGINT NOT NULL,
    email VARCHAR(320) NOT NULL
);
CREATE INDEX idx_cif_index_email_id ON cif_index_email (id);
CREATE INDEX idx_cif_index_email ON cif_index_email (email);

DROP TABLE IF EXISTS cif_index_fqdn CASCADE;
CREATE TABLE cif_index_fqdn (
    id BIGINT NOT NULL,
    fqdn VARCHAR(255) NOT NULL
);
CREATE INDEX idx_cif_index_fqdn_id ON cif_index_fqdn (id);
CREATE INDEX idx_cif_index_fqdn ON cif_index_fqdn (fqdn);

DROP TABLE IF EXISTS cif_index_url CASCADE;
CREATE TABLE cif_index_url (
    id BIGINT NOT NULL,
    url VARCHAR(2048) NOT NULL
);
CREATE INDEX idx_cif_index_url_id ON cif_index_url (id);
CREATE INDEX idx_cif_index_url ON cif_index_url (url);
