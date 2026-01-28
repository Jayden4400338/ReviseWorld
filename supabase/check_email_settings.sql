-- ============================================
-- CHECK EMAIL VERIFICATION SETTINGS
-- ============================================
-- This query helps verify your email settings
-- Run this in Supabase SQL Editor to check your configuration

-- Check if email confirmations are required
-- Note: This setting is in the Dashboard, not SQL
-- Go to: Authentication → Settings → Email Auth
-- Make sure "Enable email confirmations" is ON

-- Check users who haven't verified their email
SELECT 
    id,
    email,
    email_confirmed_at,
    created_at,
    CASE 
        WHEN email_confirmed_at IS NULL THEN 'Not Verified'
        ELSE 'Verified'
    END as verification_status
FROM auth.users
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC
LIMIT 10;

-- Count unverified users
SELECT 
    COUNT(*) as unverified_count,
    COUNT(*) FILTER (WHERE email_confirmed_at IS NOT NULL) as verified_count,
    COUNT(*) as total_users
FROM auth.users;

-- Check recent signups
SELECT 
    email,
    created_at,
    email_confirmed_at,
    EXTRACT(EPOCH FROM (NOW() - created_at))/3600 as hours_since_signup
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;
