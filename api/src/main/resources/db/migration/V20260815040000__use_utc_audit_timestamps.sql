-- Java audit timestamps now use Instant, so the database columns must store
-- absolute instants instead of server-local timestamps.
--
-- Existing timestamp values are interpreted as UTC during conversion. If old
-- production data was intentionally written in another timezone, adjust the
-- timezone in the USING clause before applying this migration there.

DO $$
DECLARE
    audit_column record;
BEGIN
    FOR audit_column IN
        SELECT table_schema, table_name, column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND column_name IN ('created_at', 'updated_at')
          AND data_type = 'timestamp without time zone'
    LOOP
        EXECUTE format(
                'ALTER TABLE %I.%I ALTER COLUMN %I TYPE timestamp(6) with time zone USING %I AT TIME ZONE ''UTC''',
                audit_column.table_schema,
                audit_column.table_name,
                audit_column.column_name,
                audit_column.column_name
                );
    END LOOP;
END $$;

ALTER TABLE conversations
    ALTER COLUMN last_message_at TYPE timestamp(6) with time zone
        USING last_message_at AT TIME ZONE 'UTC';
