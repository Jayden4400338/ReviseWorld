-- ============================================
-- CLASSROOM FUNCTIONS AND TRIGGERS
-- ============================================
-- This file contains SQL functions and triggers needed for classroom functionality
-- Run this in your Supabase SQL Editor after the main schema

-- ============================================
-- FUNCTION: Generate Unique Invite Code
-- ============================================
-- Generates a random 8-character alphanumeric invite code
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS VARCHAR(10) AS $$
DECLARE
    chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- Excludes confusing characters (0, O, I, 1)
    result VARCHAR(10) := '';
    i INTEGER;
    random_char CHAR(1);
BEGIN
    -- Generate 8-character code
    FOR i IN 1..8 LOOP
        random_char := SUBSTR(chars, FLOOR(RANDOM() * LENGTH(chars) + 1)::INTEGER, 1);
        result := result || random_char;
    END LOOP;
    
    -- Check if code already exists, regenerate if needed
    WHILE EXISTS (SELECT 1 FROM classrooms WHERE invite_code = result) LOOP
        result := '';
        FOR i IN 1..8 LOOP
            random_char := SUBSTR(chars, FLOOR(RANDOM() * LENGTH(chars) + 1)::INTEGER, 1);
            result := result || random_char;
        END LOOP;
    END LOOP;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: Auto-generate Invite Code
-- ============================================
-- Automatically generates a unique invite code when a classroom is created
CREATE OR REPLACE FUNCTION auto_generate_invite_code()
RETURNS TRIGGER AS $$
BEGIN
    -- Only generate if invite_code is not provided or is empty
    IF NEW.invite_code IS NULL OR NEW.invite_code = '' THEN
        NEW.invite_code := generate_invite_code();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_generate_invite_code
    BEFORE INSERT ON classrooms
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_invite_code();

-- ============================================
-- FUNCTION: Create Classroom
-- ============================================
-- Helper function to create a classroom with validation
CREATE OR REPLACE FUNCTION create_classroom(
    p_teacher_id UUID,
    p_name VARCHAR(200),
    p_subject_id INTEGER DEFAULT NULL,
    p_year_group VARCHAR(20) DEFAULT NULL
)
RETURNS TABLE (
    id INTEGER,
    teacher_id UUID,
    name VARCHAR(200),
    subject_id INTEGER,
    year_group VARCHAR(20),
    invite_code VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    v_user_role VARCHAR(20);
    v_classroom_id INTEGER;
BEGIN
    -- Check if user is a teacher
    SELECT role INTO v_user_role
    FROM users
    WHERE id = p_teacher_id;
    
    IF v_user_role IS NULL THEN
        RAISE EXCEPTION 'User not found';
    END IF;
    
    IF v_user_role != 'teacher' THEN
        RAISE EXCEPTION 'Only teachers can create classrooms';
    END IF;
    
    -- Validate name
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        RAISE EXCEPTION 'Classroom name is required';
    END IF;
    
    -- Insert classroom (trigger will auto-generate invite_code)
    INSERT INTO classrooms (teacher_id, name, subject_id, year_group)
    VALUES (p_teacher_id, TRIM(p_name), p_subject_id, p_year_group)
    RETURNING classrooms.id INTO v_classroom_id;
    
    -- Return the created classroom
    RETURN QUERY
    SELECT 
        c.id,
        c.teacher_id,
        c.name,
        c.subject_id,
        c.year_group,
        c.invite_code,
        c.created_at
    FROM classrooms c
    WHERE c.id = v_classroom_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: Join Classroom by Invite Code
-- ============================================
-- Allows students to join a classroom using an invite code
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
    -- Check if user is a student
    SELECT role INTO v_user_role
    FROM users
    WHERE id = p_student_id;
    
    IF v_user_role IS NULL THEN
        RETURN QUERY SELECT FALSE, 'User not found'::TEXT, NULL::INTEGER, NULL::VARCHAR(200);
        RETURN;
    END IF;
    
    IF v_user_role != 'student' THEN
        RETURN QUERY SELECT FALSE, 'Only students can join classrooms'::TEXT, NULL::INTEGER, NULL::VARCHAR(200);
        RETURN;
    END IF;
    
    -- Find classroom by invite code
    SELECT id, name INTO v_classroom_id, v_classroom_name
    FROM classrooms
    WHERE invite_code = UPPER(TRIM(p_invite_code));
    
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

-- ============================================
-- FUNCTION: Get Classroom Statistics
-- ============================================
-- Returns statistics for a specific classroom
CREATE OR REPLACE FUNCTION get_classroom_stats(p_classroom_id INTEGER)
RETURNS TABLE (
    total_students BIGINT,
    total_assignments BIGINT,
    active_assignments BIGINT,
    completed_submissions BIGINT,
    pending_submissions BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM classroom_students WHERE classroom_id = p_classroom_id)::BIGINT AS total_students,
        (SELECT COUNT(*) FROM assignments WHERE classroom_id = p_classroom_id)::BIGINT AS total_assignments,
        (SELECT COUNT(*) FROM assignments 
         WHERE classroom_id = p_classroom_id 
         AND (due_date IS NULL OR due_date >= NOW()))::BIGINT AS active_assignments,
        (SELECT COUNT(*) FROM assignment_submissions 
         WHERE assignment_id IN (SELECT id FROM assignments WHERE classroom_id = p_classroom_id))::BIGINT AS completed_submissions,
        (SELECT 
            COUNT(*)::BIGINT AS pending
         FROM assignments a
         CROSS JOIN classroom_students cs
         WHERE a.classroom_id = p_classroom_id
         AND cs.classroom_id = p_classroom_id
         AND NOT EXISTS (
             SELECT 1 FROM assignment_submissions sub
             WHERE sub.assignment_id = a.id
             AND sub.student_id = cs.student_id
         )
        ) AS pending_submissions;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- ADDITIONAL RLS POLICIES
-- ============================================

-- Students can view classrooms they're in (for viewing classroom details)
CREATE POLICY "Students can view their classroom details" ON classrooms
    FOR SELECT USING (
        id IN (
            SELECT classroom_id 
            FROM classroom_students 
            WHERE student_id = auth.uid()
        )
    );

-- Students can view assignments for their classrooms
CREATE POLICY "Students can view classroom assignments" ON assignments
    FOR SELECT USING (
        classroom_id IN (
            SELECT classroom_id 
            FROM classroom_students 
            WHERE student_id = auth.uid()
        )
    );

-- Teachers can view all students in their classrooms
CREATE POLICY "Teachers can view classroom students" ON classroom_students
    FOR SELECT USING (
        classroom_id IN (
            SELECT id 
            FROM classrooms 
            WHERE teacher_id = auth.uid()
        )
    );

-- Students can insert themselves into classrooms (via function)
-- This is handled by the join_classroom_by_code function

-- Students can view their own submissions
CREATE POLICY "Students can view own submissions" ON assignment_submissions
    FOR SELECT USING (auth.uid() = student_id);

-- Students can insert their own submissions
CREATE POLICY "Students can create own submissions" ON assignment_submissions
    FOR INSERT WITH CHECK (auth.uid() = student_id);

-- Teachers can view all submissions in their classrooms
CREATE POLICY "Teachers can view classroom submissions" ON assignment_submissions
    FOR SELECT USING (
        assignment_id IN (
            SELECT id 
            FROM assignments 
            WHERE classroom_id IN (
                SELECT id 
                FROM classrooms 
                WHERE teacher_id = auth.uid()
            )
        )
    );

-- Teachers can update submissions in their classrooms (for grading)
CREATE POLICY "Teachers can grade submissions" ON assignment_submissions
    FOR UPDATE USING (
        assignment_id IN (
            SELECT id 
            FROM assignments 
            WHERE classroom_id IN (
                SELECT id 
                FROM classrooms 
                WHERE teacher_id = auth.uid()
            )
        )
    );

-- ============================================
-- INDEXES for Performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_classrooms_teacher ON classrooms(teacher_id);
CREATE INDEX IF NOT EXISTS idx_classrooms_invite_code ON classrooms(invite_code);
CREATE INDEX IF NOT EXISTS idx_classroom_students_classroom ON classroom_students(classroom_id);
CREATE INDEX IF NOT EXISTS idx_classroom_students_student ON classroom_students(student_id);
CREATE INDEX IF NOT EXISTS idx_assignments_classroom ON assignments(classroom_id);
CREATE INDEX IF NOT EXISTS idx_assignments_due_date ON assignments(due_date);
CREATE INDEX IF NOT EXISTS idx_submissions_assignment ON assignment_submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_submissions_student ON assignment_submissions(student_id);

-- ============================================
-- GRANT PERMISSIONS
-- ============================================
-- Ensure functions are accessible
GRANT EXECUTE ON FUNCTION create_classroom TO authenticated;
GRANT EXECUTE ON FUNCTION join_classroom_by_code TO authenticated;
GRANT EXECUTE ON FUNCTION get_classroom_stats TO authenticated;
GRANT EXECUTE ON FUNCTION generate_invite_code TO authenticated;
