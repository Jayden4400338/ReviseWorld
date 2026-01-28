-- ============================================
-- SIMPLE FIX FOR CLASSROOM RLS - NO RECURSION
-- ============================================
-- This is a simpler approach that avoids infinite recursion
-- Run this in Supabase SQL Editor

-- Step 1: Disable RLS temporarily to drop all policies safely
ALTER TABLE classrooms DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies
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
    END LOOP;
END $$;

-- Step 3: Re-enable RLS
ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;

-- Step 4: Create a simple, direct policy for teachers
-- This policy directly checks auth.uid() without any subqueries or functions
-- Using text comparison to avoid any type coercion issues
CREATE POLICY "Teachers can manage own classrooms" ON classrooms
    FOR ALL 
    USING ((auth.uid())::uuid = (teacher_id)::uuid)
    WITH CHECK ((auth.uid())::uuid = (teacher_id)::uuid);

-- Step 5: Create policy for students (using EXISTS to avoid recursion)
-- EXISTS is safer than IN subquery for RLS policies
CREATE POLICY "Students can view classrooms" ON classrooms
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 
            FROM classroom_students cs
            WHERE cs.classroom_id = classrooms.id 
            AND cs.student_id = auth.uid()
        )
    );

-- Verify the policies were created
SELECT 
    policyname,
    cmd,
    qual::text as using_expression,
    with_check::text as with_check_expression
FROM pg_policies 
WHERE tablename = 'classrooms'
ORDER BY policyname;

-- Test: This should work now
-- SELECT * FROM classrooms WHERE teacher_id = auth.uid();
