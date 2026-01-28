-- ============================================
-- EMERGENCY FIX: Remove ALL RLS from classrooms temporarily
-- ============================================
-- Use this if you're still getting infinite recursion errors
-- This will completely disable RLS on classrooms so you can access it
-- WARNING: This removes security! Only use for testing or if you have other security measures

-- Disable RLS completely
ALTER TABLE classrooms DISABLE ROW LEVEL SECURITY;

-- Drop all policies
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'classrooms' AND schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON classrooms', r.policyname);
        RAISE NOTICE 'Dropped policy: %', r.policyname;
    END LOOP;
END $$;

-- Verify RLS is disabled
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'classrooms';

-- If you want to re-enable with a simple policy later, run:
-- ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Teachers can manage own classrooms" ON classrooms
--     FOR ALL USING (auth.uid() = teacher_id);
