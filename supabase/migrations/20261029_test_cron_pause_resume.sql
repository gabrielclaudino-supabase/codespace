-- Test: Pause pg_cron jobs during migration, then resume
-- This tests the solution for SU-528491

-- ============================================================
-- STEP 0: Ensure pg_cron extension exists on this branch
-- ============================================================
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ============================================================
-- PHASE 1: PRE-MIGRATION - Verify jobs exist and unschedule
-- ============================================================

-- Count jobs before
SELECT COUNT(*) as "jobs_count_before" FROM cron.job;

-- List all jobs before unscheduling
SELECT jobid, jobname, schedule, active 
FROM cron.job 
ORDER BY jobid;

-- Unschedule all jobs by name
SELECT cron.unschedule('test-job-1');
SELECT cron.unschedule('test-job-2');
SELECT cron.unschedule('test-job-3');
SELECT cron.unschedule('cleanup-old-records');

-- Verify all jobs are unscheduled
SELECT COUNT(*) as "jobs_after_unschedule" FROM cron.job;

-- ============================================================
-- PHASE 2: MIGRATION - Your actual migration work
-- ============================================================

-- This is where the customer's migration logic goes
CREATE TABLE IF NOT EXISTS migration_events (
  id SERIAL PRIMARY KEY,
  migration_name TEXT,
  executed_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO migration_events (migration_name) 
VALUES ('test_cron_pause_resume_20261029');

SELECT 'Migration executed successfully' as "phase_2_status";

-- ============================================================
-- PHASE 3: POST-MIGRATION - Reschedule all jobs
-- ============================================================

-- Restore all jobs with exact same schedules
SELECT cron.schedule('test-job-1', '0 10 * * *', 'SELECT 1');
SELECT cron.schedule('test-job-2', '0 14 * * *', 'SELECT 2');
SELECT cron.schedule('test-job-3', '0 18 * * *', 'SELECT 3');
SELECT cron.schedule('cleanup-old-records', '0 2 * * *', 'DELETE FROM public.old_data WHERE created_at < NOW() - INTERVAL ''30 days''');

-- Verify all jobs are restored
SELECT COUNT(*) as "jobs_restored" FROM cron.job;

-- Show restored jobs
SELECT jobid, jobname, schedule, active 
FROM cron.job 
ORDER BY jobid;

SELECT 'All pg_cron jobs successfully restored' as "phase_3_status";
