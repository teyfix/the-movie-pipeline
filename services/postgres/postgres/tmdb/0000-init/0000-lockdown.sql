-- ===============================
-- 1️⃣ Lock down public schema
-- ===============================
REVOKE ALL ON SCHEMA "public"
FROM
  "public";

ALTER DEFAULT PRIVILEGES IN SCHEMA "public"
REVOKE ALL ON TABLES
FROM
  "public";

ALTER DEFAULT PRIVILEGES IN SCHEMA "public"
REVOKE ALL ON SEQUENCES
FROM
  "public";

ALTER DEFAULT PRIVILEGES IN SCHEMA "public"
REVOKE ALL ON FUNCTIONS
FROM
  "public";

-- ===============================
-- 2️⃣ Disable logging statements
-- ===============================
ALTER ROLE postgres
SET
  log_statement TO 'none';

ALTER ROLE postgres
SET
  log_min_duration_statement TO -1;
