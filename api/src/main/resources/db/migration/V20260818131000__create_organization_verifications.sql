ALTER TABLE organizations
    ADD COLUMN verified boolean NOT NULL DEFAULT false;

CREATE TABLE organization_verification_requests (
    id bigserial PRIMARY KEY,
    organization_id bigint NOT NULL,
    requested_by_id bigint NOT NULL,
    note text,
    proof_url text NOT NULL,
    proof_file_id varchar(255) NOT NULL,
    status varchar(255) NOT NULL DEFAULT 'PENDING',
    reviewed_by_id bigint,
    admin_note text,
    reviewed_at timestamp(6),
    created_at timestamp(6),
    updated_at timestamp(6),
    CONSTRAINT fk_org_verification_requests_organization
        FOREIGN KEY (organization_id) REFERENCES organizations(id),
    CONSTRAINT fk_org_verification_requests_requested_by
        FOREIGN KEY (requested_by_id) REFERENCES users(id),
    CONSTRAINT fk_org_verification_requests_reviewed_by
        FOREIGN KEY (reviewed_by_id) REFERENCES admins(id),
    CONSTRAINT chk_org_verification_requests_status
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

CREATE INDEX idx_org_verification_requests_organization
    ON organization_verification_requests(organization_id);

CREATE INDEX idx_org_verification_requests_status_created
    ON organization_verification_requests(status, created_at DESC);

CREATE UNIQUE INDEX uk_org_verification_requests_pending
    ON organization_verification_requests(organization_id)
    WHERE status = 'PENDING';
