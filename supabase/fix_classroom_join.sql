-- ============================================
-- FIX: Allow Students to Join Classrooms by Invite Code
-- ============================================
-- Students need to be able to look up classrooms by invite code to join
-- This creates a function that bypasses RLS for invite code lookup

-- Function to get classroom by invite code (for joining)
CREATE OR REPLACE FUNCTION get_classroom_by_invite_code(p_invite_code VARCHAR(10))
RETURNS TABLE (
    id INTEGER,
    name VARCHAR(200),
    teacher_id UUID,
    subject_id INTEGER,
    year_group VARCHAR(20),
    invite_code VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        c.teacher_id,
        c.subject_id,
        c.year_group,
        c.invite_code
    FROM classrooms c
    WHERE c.invite_code = UPPER(TRIM(p_invite_code))
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_classroom_by_invite_code TO authenticated;

-- Also ensure the join_classroom_by_code function exists and has correct permissions
-- (This should already exist from classroom_functions.sql, but let's make sure)
CREATE OR REPLACE FUNCTION join_classroom_by_code(
    p_student_id UUID,
    p_invite_code VARCHAR(10)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    classroom_id INTEGER,
    classroom_name VARCHAR(200)
) AS $$
DECLARE
    v_classroom_id INTEGER;
    v_classroom_name VARCHAR(200);
    v_user_role VARCHAR(20);
    v_already_joined BOOLEAN;
BEGIN
    -- Check if user is a student (or allow any authenticated user)
    SELECT role INTO v_user_role
    FROM users
    WHERE id = p_student_id;
    
    IF v_user_role IS NULL THEN
        RETURN QUERY SELECT FALSE, 'User not found'::TEXT, NULL::INTEGER, NULL::VARCHAR(200);
        RETURN;
    END IF;
    
    -- Allow both students and teachers to join (in case teacher wants to join another's class)
    -- Remove the strict student-only check
    
    -- Find classroom by invite code using the helper function
    SELECT id, name INTO v_classroom_id, v_classroom_name
    FROM get_classroom_by_invite_code(p_invite_code);
    
    IF v_classroom_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid invite code'::TEXT, NULL::INTEGER, NULL::VARCHAR(200);
        RETURN;
    END IF;
    
    -- Check if already joined
    SELECT EXISTS(
        SELECT 1 FROM classroom_students
        WHERE classroom_id = v_classroom_id
        AND student_id = p_student_id
    ) INTO v_already_joined;
    
    IF v_already_joined THEN
        RETURN QUERY SELECT FALSE, 'Already a member of this classroom'::TEXT, v_classroom_id, v_classroom_name;
        RETURN;
    END IF;
    
    -- Add student to classroom
    INSERT INTO classroom_students (classroom_id, student_id)
    VALUES (v_classroom_id, p_student_id)
    ON CONFLICT (classroom_id, student_id) DO NOTHING;
    
    RETURN QUERY SELECT TRUE, 'Successfully joined classroom'::TEXT, v_classroom_id, v_classroom_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION join_classroom_by_code TO authenticated;

-- Also allow students to INSERT into classroom_students (for joining)
DROP POLICY IF EXISTS "Students can join classrooms" ON classroom_students;
CREATE POLICY "Students can join classrooms" ON classroom_students
    FOR INSERT
    WITH CHECK (auth.uid() = student_id);

-- Also allow students to view classroom_students for their own records (for checking duplicates)
-- This should already exist, but let's make sure
DROP POLICY IF EXISTS "Students can view their classrooms" ON classroom_students;
CREATE POLICY "Students can view their classrooms" ON classroom_students
    FOR SELECT
    USING (auth.uid() = student_id);

-- Function for students to get classroom details (if they're a member)
CREATE OR REPLACE FUNCTION get_classroom_for_student(
    p_classroom_id INTEGER,
    p_student_id UUID
)
RETURNS TABLE (
    id INTEGER,
    name VARCHAR(200),
    teacher_id UUID,
    subject_id INTEGER,
    year_group VARCHAR(20),
    invite_code VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    -- Check if student is a member
    IF NOT EXISTS (
        SELECT 1 FROM classroom_students
        WHERE classroom_id = p_classroom_id
        AND student_id = p_student_id
    ) THEN
        RETURN; -- Return empty if not a member
    END IF;

    -- Return classroom details
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        c.teacher_id,
        c.subject_id,
        c.year_group,
        c.invite_code,
        c.created_at
    FROM classrooms c
    WHERE c.id = p_classroom_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_classroom_for_student TO authenticated;

-- Verify functions exist
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('get_classroom_by_invite_code', 'join_classroom_by_code', 'get_classroom_for_student')
ORDER BY routine_name;
