# Supabase pg_cron config.toml Test

This repository tests whether pg_cron startup parameters defined in `config.toml` are applied when Supabase creates preview branches via GitHub integration.

## Test Objective

Verify if the following configuration in `supabase/config.toml`:

```toml
[db.settings]
cron.launch_active_jobs = false
cron.max_running_jobs = 0
cron.log_run = off
```

...gets applied to new branches created via GitHub push (Supabase Branching 1.0).

## Expected Behavior

When a feature branch is created:
1. Supabase reads `config.toml` from the repository
2. Applies settings during PostgreSQL initialization
3. Preview branch should have:
   - `cron.launch_active_jobs = false` (instead of `on`)
   - `cron.max_running_jobs = 0` (instead of `32`)
   - `cron.log_run = off` (instead of `on`)

## Test Status

🧪 Testing in progress...

Check Supabase Dashboard → Branching → Preview Branches for test results.

## Related Issue

Case: SU-528491 - pg_cron scheduler containment during migration replay

## Setup Instructions

1. Enable Supabase Branching in project `zddkkqdzwkxyvzakriab`
2. Connect GitHub repo: `gabrielclaudino-supabase/codespace`
3. Create a feature branch to trigger automatic branch creation
4. Monitor logs and check applied settings
# Test branch for pg_cron config.toml verification
