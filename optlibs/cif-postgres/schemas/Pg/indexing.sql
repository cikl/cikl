set default_tablespace=:cif_default_tablespace;

CREATE EXTENSION "btree_gin";

DROP TABLE IF EXISTS indexing CASCADE;

CREATE TABLE indexing (
    id BIGINT NOT NULL,
    group_name VARCHAR(50),
    reporttime INT NOT NULL,
    created INT NOT NULL,
    assessment VARCHAR(64),
    confidence SMALLINT CHECK (confidence >= 0 AND confidence <= 100),

    asn BIGINT,
    cidr cidr,
    email VARCHAR(320),
    fqdn VARCHAR(255),
    url VARCHAR(2048)
);

-- CREATE INDEX idx_indexing_uuid ON indexing (uuid);
CREATE INDEX idx_indexing_group_name ON indexing (group_name);
CREATE INDEX idx_indexing_created ON indexing (created);
CREATE INDEX idx_indexing_reporttime ON indexing (reporttime);
CREATE INDEX idx_indexing_assessment ON indexing (assessment);
CREATE INDEX idx_indexing_confidence ON indexing (confidence);
CREATE INDEX idx_indexing_asn ON indexing USING GIN(asn);
CREATE INDEX idx_indexing_cidr ON indexing USING GIN(cidr);
CREATE INDEX idx_indexing_email ON indexing USING GIN(email);
CREATE INDEX idx_indexing_fqdn ON indexing USING GIN(fqdn);
CREATE INDEX idx_indexing_url ON indexing USING GIN(url);
