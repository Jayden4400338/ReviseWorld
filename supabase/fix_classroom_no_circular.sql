-- ============================================
-- FIX CIRCULAR DEPENDENCY - SIMPLE VERSION
-- ============================================
-- The issue: Policies on classroom_students query classrooms,
-- and policies on classrooms query classroom_students = recursion!
-- Solution: Remove the circular reference

-- Step 1: Disable RLS
ALTER TABLE classrooms DISABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_students DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL policies
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
    END LOOP;
END $$;

-- Step 3: Re-enable RLS
ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_students ENABLE ROW LEVEL SECURITY;

-- Step 4: Create classrooms policies
-- Teachers: Simple direct check, no subqueries
CREATE POLICY "Teachers can manage own classrooms" ON classrooms
    FOR ALL 
    USING (teacher_id = auth.uid())
    WITH CHECK (teacher_id = auth.uid());

-- Students: We'll remove this for now and handle it differently
-- The issue is this queries classroom_students which queries classrooms
-- Instead, we'll let students access via classroom_students table only

-- Step 5: Create classroom_students policies  
-- Students can view their own memberships (no query to classrooms)
CREATE POLICY "Students can view their classrooms" ON classroom_students
    FOR SELECT 
    USING (student_id = auth.uid());

-- Teachers: Instead of querying classrooms, we'll use a JOIN approach
-- But actually, we can't easily do this without querying classrooms
-- So let's use a different approach: teachers can view classroom_students
-- for any classroom where they are the teacher, but we'll check this
-- by allowing teachers to see classroom_students if the classroom_id
-- exists in a list of their classroom IDs - but that still queries classrooms!

-- Better approach: Create a view or use a function, OR
-- Just allow teachers to see all classroom_students for classrooms they own
-- by checking the classroom directly in the policy using a JOIN

-- Actually, the simplest: Teachers can insert/update/delete classroom_students
-- if they own the classroom, but we check this by joining to classrooms
-- in a way that doesn't cause recursion

-- Let's try: Use a subquery that doesn't trigger RLS recursion
-- by checking the classroom table directly without going through policies
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

-- The key: The subquery in classroom_students policy checks classrooms,
-- but since we're checking teacher_id directly (not through another policy),
-- it shouldn't cause recursion IF the classrooms policy is simple.

-- Verify
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('classrooms', 'classroom_students')
ORDER BY tablename, policyname;
