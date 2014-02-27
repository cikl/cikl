set default_tablespace=:cikl_default_tablespace;

CREATE EXTENSION "btree_gin";
CREATE EXTENSION "ip4r";

DROP TABLE IF EXISTS cikl_index_main CASCADE;

CREATE TABLE cikl_index_main (
    id BIGINT NOT NULL,
    group_name VARCHAR(50) NOT NULL,
    reporttime INT NOT NULL,
    created INT NOT NULL,
    assessment VARCHAR(64),
    confidence SMALLINT -- CHECK (confidence >= 0 AND confidence <= 100)
);

-- CREATE INDEX idx_cikl_index_main_uuid ON cikl_index_main (uuid);
CREATE INDEX idx_cikl_index_main_id ON cikl_index_main (id);
CREATE INDEX idx_cikl_index_main_group_name ON cikl_index_main (group_name);
CREATE INDEX idx_cikl_index_main_created ON cikl_index_main (created);
CREATE INDEX idx_cikl_index_main_reporttime ON cikl_index_main (reporttime);
CREATE INDEX idx_cikl_index_main_assessment ON cikl_index_main (assessment);
CREATE INDEX idx_cikl_index_main_confidence ON cikl_index_main (confidence);

DROP TABLE IF EXISTS cikl_index_asn CASCADE;
CREATE TABLE cikl_index_asn (
    id BIGINT NOT NULL,
    asn BIGINT NOT NULL
);
CREATE INDEX idx_cikl_index_asn_id ON cikl_index_asn (id);
CREATE INDEX idx_cikl_index_asn ON cikl_index_asn (asn);

DROP TABLE IF EXISTS cikl_index_cidr CASCADE;
CREATE TABLE cikl_index_cidr (
    id BIGINT NOT NULL,
    cidr iprange NOT NULL
);
CREATE INDEX idx_cikl_index_cidr_id ON cikl_index_cidr (id);
CREATE INDEX idx_cikl_index_cidr ON cikl_index_cidr USING GIST (cidr);

DROP TABLE IF EXISTS cikl_index_email CASCADE;
CREATE TABLE cikl_index_email (
    id BIGINT NOT NULL,
    email VARCHAR(320) NOT NULL
);
CREATE INDEX idx_cikl_index_email_id ON cikl_index_email (id);
CREATE INDEX idx_cikl_index_email ON cikl_index_email (email);

DROP TABLE IF EXISTS cikl_index_fqdn CASCADE;
CREATE TABLE cikl_index_fqdn (
    id BIGINT NOT NULL,
    fqdn VARCHAR(255) NOT NULL
);
CREATE INDEX idx_cikl_index_fqdn_id ON cikl_index_fqdn (id);
CREATE INDEX idx_cikl_index_fqdn ON cikl_index_fqdn (fqdn);

DROP TABLE IF EXISTS cikl_index_url CASCADE;
CREATE TABLE cikl_index_url (
    id BIGINT NOT NULL,
    url VARCHAR(2048) NOT NULL
);
CREATE INDEX idx_cikl_index_url_id ON cikl_index_url (id);
CREATE INDEX idx_cikl_index_url ON cikl_index_url (url);
