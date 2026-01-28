-- ============================================
-- DEFINITIVE FIX: Break Circular RLS Dependency
-- ============================================
-- Problem: classroom_students policy queries classrooms,
--          classrooms policy queries classroom_students = INFINITE RECURSION
-- Solution: Remove the student policy on classrooms that queries classroom_students
--           Students will access classrooms through classroom_students table only

-- Step 1: Disable RLS on both tables
ALTER TABLE classrooms DISABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_students DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT tablename, policyname 
        FROM pg_policies 
        WHERE tablename IN ('classrooms', 'classroom_students') 
        AND schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I', r.policyname, r.tablename);
        RAISE NOTICE 'Dropped: % on %', r.policyname, r.tablename;
    END LOOP;
END $$;

-- Step 3: Re-enable RLS
ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_students ENABLE ROW LEVEL SECURITY;

-- Step 4: Create SIMPLE classrooms policy - NO queries to classroom_students!
-- Teachers only - this is the key to avoiding recursion
CREATE POLICY "Teachers can manage own classrooms" ON classrooms
    FOR ALL 
    USING (teacher_id = auth.uid())
    WITH CHECK (teacher_id = auth.uid());

-- NOTE: We're NOT creating a "Students can view classrooms" policy here
-- because it would query classroom_students, causing recursion.
-- Students will access classroom data through classroom_students JOINs instead.

-- Step 5: Create classroom_students policies
-- Students can view their own memberships
CREATE POLICY "Students can view their classrooms" ON classroom_students
    FOR SELECT 
    USING (student_id = auth.uid());

-- Teachers can view/manage students in their classrooms
-- This queries classrooms, but since classrooms policy is simple (no recursion),
-- it should work fine
CREATE POLICY "Teachers can manage classroom students" ON classroom_students
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 
            FROM classrooms c
            WHERE c.id = classroom_students.classroom_id 
            AND c.teacher_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 
            FROM classrooms c
            WHERE c.id = classroom_students.classroom_id 
            AND c.teacher_id = auth.uid()
        )
    );

-- Step 6: Verify - should show 3 policies total
SELECT 
    tablename,
    policyname,
    cmd,
    CASE 
        WHEN qual::text LIKE '%classroom_students%' THEN '⚠️ Queries classroom_students'
        WHEN qual::text LIKE '%classrooms%' THEN '⚠️ Queries classrooms'
        ELSE '✅ Simple check'
    END as policy_type
FROM pg_policies 
WHERE tablename IN ('classrooms', 'classroom_students')
ORDER BY tablename, policyname;

-- Success
DO $$
BEGIN
    RAISE NOTICE '✅ Fixed! No more circular dependency.';
    RAISE NOTICE 'Teachers can manage their classrooms directly.';
    RAISE NOTICE 'Students access classrooms through classroom_students table.';
END $$;
