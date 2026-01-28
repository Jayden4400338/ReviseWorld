-- ============================================
-- FIX CLASSROOM RLS POLICIES - PREVENTS INFINITE RECURSION
-- ============================================
-- Run this if you're getting "infinite recursion detected in policy" errors
-- This will drop ALL existing policies and recreate them correctly

-- Step 1: Drop ALL existing policies on classrooms table (prevents conflicts)
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

-- Step 2: Create a SINGLE comprehensive policy for teachers
-- Using FOR ALL covers SELECT, INSERT, UPDATE, DELETE in one policy (prevents recursion)
CREATE POLICY "Teachers can manage own classrooms" ON classrooms
    FOR ALL 
    USING (auth.uid() = teacher_id)
    WITH CHECK (auth.uid() = teacher_id);

-- Step 3: Create policy for students to view classrooms they're members of
CREATE POLICY "Students can view their classroom details" ON classrooms
    FOR SELECT 
    USING (
        id IN (
            SELECT classroom_id 
            FROM classroom_students 
            WHERE student_id = auth.uid()
        )
    );

-- Verify the table exists and has the correct structure
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'classrooms') THEN
        RAISE EXCEPTION 'Classrooms table does not exist. Please run the main schema.sql first.';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'classrooms' AND column_name = 'teacher_id') THEN
        RAISE EXCEPTION 'Classrooms table is missing teacher_id column. Please run the main schema.sql first.';
    END IF;
END $$;

-- Test query (this should work if policies are correct)
-- SELECT * FROM classrooms WHERE teacher_id = auth.uid();
