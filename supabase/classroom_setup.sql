-- ============================================
-- QUICK SETUP: Classroom Functions
-- ============================================
-- Run this in Supabase SQL Editor to enable classroom saving
-- This is a simplified version - see classroom_functions.sql for full implementation

-- 1. Function to generate unique invite codes
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS VARCHAR(10) AS $$
DECLARE
    chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    result VARCHAR(10) := '';
    i INTEGER;
BEGIN
    FOR i IN 1..8 LOOP
        result := result || SUBSTR(chars, FLOOR(RANDOM() * LENGTH(chars) + 1)::INTEGER, 1);
    END LOOP;
    
    WHILE EXISTS (SELECT 1 FROM classrooms WHERE invite_code = result) LOOP
        result := '';
        FOR i IN 1..8 LOOP
            result := result || SUBSTR(chars, FLOOR(RANDOM() * LENGTH(chars) + 1)::INTEGER, 1);
        END LOOP;
    END LOOP;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 2. Trigger to auto-generate invite code on insert
CREATE OR REPLACE FUNCTION auto_generate_invite_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.invite_code IS NULL OR NEW.invite_code = '' THEN
        NEW.invite_code := generate_invite_code();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_auto_generate_invite_code ON classrooms;
CREATE TRIGGER trigger_auto_generate_invite_code
    BEFORE INSERT ON classrooms
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_invite_code();

-- 3. Additional RLS policies for students
CREATE POLICY IF NOT EXISTS "Students can view their classroom details" ON classrooms
    FOR SELECT USING (
        id IN (SELECT classroom_id FROM classroom_students WHERE student_id = auth.uid())
    );

-- 4. Indexes for performance
CREATE INDEX IF NOT EXISTS idx_classrooms_teacher ON classrooms(teacher_id);
CREATE INDEX IF NOT EXISTS idx_classrooms_invite_code ON classrooms(invite_code);

-- Done! Classrooms will now auto-generate invite codes when created.
