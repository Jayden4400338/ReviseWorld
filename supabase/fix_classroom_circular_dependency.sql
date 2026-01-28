-- ============================================
-- FIX CIRCULAR DEPENDENCY IN RLS POLICIES
-- ============================================
-- The problem: classroom_students policy queries classrooms,
-- and classrooms policy queries classroom_students = infinite recursion!
-- This fixes it by breaking the circular dependency

-- Step 1: Disable RLS on both tables
ALTER TABLE classrooms DISABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_students DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL policies on both tables
DO $$
DECLARE
    r RECORD;
BEGIN
    -- Drop policies on classrooms
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'classrooms' AND schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON classrooms', r.policyname);
        RAISE NOTICE 'Dropped policy on classrooms: %', r.policyname;
    END LOOP;
    
    -- Drop policies on classroom_students
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'classroom_students' AND schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON classroom_students', r.policyname);
        RAISE NOTICE 'Dropped policy on classroom_students: %', r.policyname;
    END LOOP;
END $$;

-- Step 3: Re-enable RLS
ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_students ENABLE ROW LEVEL SECURITY;

-- Step 4: Create classrooms policies (NO queries to classroom_students in USING clause)
-- Teachers can manage their own classrooms
CREATE POLICY "Teachers can manage own classrooms" ON classrooms
    FOR ALL 
    USING (teacher_id = auth.uid())
    WITH CHECK (teacher_id = auth.uid());

-- Students can view classrooms they're in (using a function to break recursion)
-- We'll use a security definer function to bypass RLS for the check
CREATE OR REPLACE FUNCTION check_student_in_classroom(classroom_id_param INTEGER)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 
        FROM classroom_students 
        WHERE classroom_students.classroom_id = classroom_id_param 
        AND classroom_students.student_id = auth.uid()
    );
$$;

CREATE POLICY "Students can view classrooms" ON classrooms
    FOR SELECT 
    USING (check_student_in_classroom(id));

-- Step 5: Create classroom_students policies (NO queries to classrooms in USING clause)
-- Students can view their own memberships
CREATE POLICY "Students can view their classrooms" ON classroom_students
    FOR SELECT 
    USING (student_id = auth.uid());

-- Teachers can view students in their classrooms (using a function to break recursion)
CREATE OR REPLACE FUNCTION check_teacher_owns_classroom(classroom_id_param INTEGER)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 
        FROM classrooms 
        WHERE classrooms.id = classroom_id_param 
        AND classrooms.teacher_id = auth.uid()
    );
$$;

CREATE POLICY "Teachers can view classroom students" ON classroom_students
    FOR SELECT 
    USING (check_teacher_owns_classroom(classroom_id));

-- Step 6: Grant execute permissions on the functions
GRANT EXECUTE ON FUNCTION check_student_in_classroom TO authenticated;
GRANT EXECUTE ON FUNCTION check_teacher_owns_classroom TO authenticated;

-- Verify policies
SELECT 
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename IN ('classrooms', 'classroom_students')
ORDER BY tablename, policyname;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Circular dependency fixed!';
    RAISE NOTICE 'Policies now use SECURITY DEFINER functions to break recursion.';
END $$;
