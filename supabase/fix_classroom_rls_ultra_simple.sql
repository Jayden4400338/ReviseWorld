-- ============================================
-- ULTRA SIMPLE FIX: Minimal Policy Setup
-- ============================================
-- This is the absolute simplest approach - just one policy for teachers
-- Students can be handled separately if needed

-- Disable RLS
ALTER TABLE classrooms DISABLE ROW LEVEL SECURITY;

-- Drop all policies
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'classrooms'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON classrooms', r.policyname);
    END LOOP;
END $$;

-- Re-enable RLS
ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;

-- Create ONLY teacher policy - simplest possible
CREATE POLICY "teacher_policy" ON classrooms
    FOR ALL 
    USING (teacher_id = auth.uid())
    WITH CHECK (teacher_id = auth.uid());

-- That's it! This should work without recursion.
-- If you need student access, add it separately after testing this works.
