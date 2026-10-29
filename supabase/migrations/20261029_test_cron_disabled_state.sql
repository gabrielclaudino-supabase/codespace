-- Test: Create pg_cron jobs in disabled state, then enable after migration
-- This is the SUPPORTED solution for SU-528491

-- ============================================================
-- PHASE 1: Create jobs in DISABLED state
-- ============================================================

-- Create a test job that will NOT launch yet
INSERT INTO cron.job (jobname, schedule, command, nodename, nodeport, database, username, active)
VALUES 
  ('migration-job-1', '0 10 * * *', 'SELECT 1', 'localhost', 5432, 'postgres', 'postgres', false),
  ('migration-job-2', '0 14 * * *', 'SELECT 2', 'localhost', 5432, 'postgres', 'postgres', false),
  ('migration-job-3', '0 18 * * *', 'SELECT 3', 'localhost', 5432, 'postgres', 'postgres', false);

SELECT 'Phase 1: Jobs created in disabled state' as status;
SELECT jobname, active FROM cron.job WHERE jobname LIKE 'migration-job-%' ORDER BY jobname;

-- ============================================================
-- PHASE 2: Your actual migration work
-- ============================================================

CREATE TABLE IF NOT EXISTS test_migration_log (
  id SERIAL PRIMARY KEY,
  migration_name TEXT,
  executed_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO test_migration_log (migration_name) 
VALUES ('cron_disabled_state_test');

SELECT 'Phase 2: Migration executed successfully' as status;

-- ============================================================
-- PHASE 3: Re-enable jobs after migration
-- ============================================================

UPDATE cron.job SET active = true WHERE jobname LIKE 'migration-job-%';

SELECT 'Phase 3: Jobs re-enabled after migration' as status;
SELECT jobname, active, schedule FROM cron.job WHERE jobname LIKE 'migration-job-%' ORDER BY jobname;

-- ============================================================
-- VERIFICATION
-- ============================================================

SELECT COUNT(*) as "active_migration_jobs" FROM cron.job WHERE jobname LIKE 'migration-job-%' AND active = true;
