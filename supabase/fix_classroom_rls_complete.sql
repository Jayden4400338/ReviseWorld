-- ============================================
-- COMPLETE FIX FOR CLASSROOM RLS POLICIES
-- ============================================
-- Run this to completely fix the infinite recursion error
-- This will drop ALL existing policies and recreate them correctly

-- Step 1: Drop ALL existing policies on classrooms table
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'classrooms') LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON classrooms', r.policyname);
    END LOOP;
END $$;

-- Step 2: Create a SINGLE policy for teachers (FOR ALL covers SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY "Teachers can manage own classrooms" ON classrooms
    FOR ALL 
    USING (auth.uid() = teacher_id)
    WITH CHECK (auth.uid() = teacher_id);

-- Step 3: Create policy for students to view classrooms they're in
CREATE POLICY "Students can view their classroom details" ON classrooms
    FOR SELECT 
    USING (
        id IN (
            SELECT classroom_id 
            FROM classroom_students 
            WHERE student_id = auth.uid()
        )
    );

-- Verify policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'classrooms'
ORDER BY policyname;

-- Test message
DO $$
BEGIN
    RAISE NOTICE 'Classroom RLS policies have been fixed!';
    RAISE NOTICE 'Teachers can now manage their own classrooms.';
    RAISE NOTICE 'Students can view classrooms they are members of.';
END $$;
