-- Test: Pause pg_cron jobs, run migrations, then resume
-- This simulates the workflow needed for SU-528491

-- ============================================================
-- PHASE 1: PRE-MIGRATION - Unschedule all active jobs
-- ============================================================
-- Store job definitions before unscheduling
CREATE TEMP TABLE temp_cron_jobs AS
SELECT jobid, schedule, command, nodename, nodeport, database, username, active
FROM cron.job;

-- Unschedule all jobs
SELECT cron.unschedule(jobname) FROM cron.job;

-- Log completion
SELECT 'Pre-migration: All pg_cron jobs unscheduled' as status;

-- ============================================================
-- PHASE 2: MIGRATION - Your actual migrations go here
-- ============================================================
-- Simulate migration work (this is where customer's migration would run)
CREATE TABLE IF NOT EXISTS test_migration_marker (
  id SERIAL PRIMARY KEY,
  migration_name TEXT,
  executed_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO test_migration_marker (migration_name) 
VALUES ('test_cron_pause_resume_20261029');

SELECT 'Phase 2: Migration executed successfully' as status;

-- ============================================================
-- PHASE 3: POST-MIGRATION - Recreate all jobs
-- ============================================================
-- Recreate jobs from temp table
DO $$
DECLARE
  job_record RECORD;
BEGIN
  FOR job_record IN SELECT * FROM temp_cron_jobs LOOP
    PERFORM cron.schedule(
      job_record.jobname::text,
      job_record.schedule::text,
      job_record.command::text,
      job_record.nodename::text,
      job_record.nodeport::int,
      job_record.database::text,
      job_record.username::text
    );
  END LOOP;
  RAISE NOTICE 'All pg_cron jobs restored from temp table';
END $$;

SELECT 'Post-migration: All pg_cron jobs rescheduled' as status;

-- Verify jobs are back
SELECT COUNT(*) as job_count FROM cron.job;
