CREATE INDEX organizations_name_trgm_idx
ON organizations USING gin (name gin_trgm_ops);

CREATE INDEX organizations_description_trgm_idx
ON organizations USING gin (description gin_trgm_ops);
