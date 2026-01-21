-- BrainMapRevision Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    role VARCHAR(20) DEFAULT 'student' CHECK (role IN ('student', 'teacher')),
    year_group VARCHAR(20),
    xp INTEGER DEFAULT 0 CHECK (xp >= 0),
    level INTEGER DEFAULT 1 CHECK (level >= 1),
    brain_coins INTEGER DEFAULT 0 CHECK (brain_coins >= 0),
    hint_tokens INTEGER DEFAULT 5 CHECK (hint_tokens >= 0),
    study_streak INTEGER DEFAULT 0 CHECK (study_streak >= 0),
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- SUBJECTS TABLE
-- ============================================
CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon VARCHAR(50),
    description TEXT,
    year_groups TEXT[] DEFAULT ARRAY['Year 7-9', 'Year 10-11'],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- REVISION GUIDES TABLE
-- ============================================
CREATE TABLE revision_guides (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    topic VARCHAR(200) NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    key_concepts TEXT[],
    worked_examples TEXT,
    common_mistakes TEXT,
    exam_tips TEXT,
    author_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- PAST PAPER QUESTIONS TABLE
-- ============================================
CREATE TABLE past_paper_questions (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    exam_board VARCHAR(50) NOT NULL CHECK (exam_board IN ('AQA', 'Edexcel', 'OCR', 'WJEC', 'SQA')),
    year INTEGER NOT NULL CHECK (year >= 2000 AND year <= 2030),
    paper_number VARCHAR(20),
    question_number VARCHAR(20),
    marks INTEGER CHECK (marks > 0),
    question_text TEXT NOT NULL,
    mark_scheme TEXT,
    examiner_comments TEXT,
    revision_guide_id INTEGER REFERENCES revision_guides(id) ON DELETE SET NULL,
    difficulty VARCHAR(20) CHECK (difficulty IN ('Foundation', 'Higher', 'Easy', 'Medium', 'Hard')),
    topics TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- QUIZ QUESTIONS TABLE
-- ============================================
CREATE TABLE quiz_questions (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    topic VARCHAR(200) NOT NULL,
    question TEXT NOT NULL,
    question_type VARCHAR(50) DEFAULT 'multiple_choice' CHECK (question_type IN ('multiple_choice', 'short_answer', 'true_false', 'fill_blank')),
    options JSONB, -- For multiple choice: ["Option A", "Option B", "Option C", "Option D"]
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    difficulty VARCHAR(20) DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- QUIZZES (User Quiz Attempts) TABLE
-- ============================================
CREATE TABLE quizzes (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    score INTEGER NOT NULL CHECK (score >= 0),
    total_questions INTEGER NOT NULL CHECK (total_questions > 0),
    xp_earned INTEGER DEFAULT 0 CHECK (xp_earned >= 0),
    coins_earned INTEGER DEFAULT 0 CHECK (coins_earned >= 0),
    hints_used INTEGER DEFAULT 0 CHECK (hints_used >= 0),
    completion_time INTEGER, -- in seconds
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- USER PROGRESS TABLE
-- ============================================
CREATE TABLE user_progress (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    topic VARCHAR(200),
    questions_attempted INTEGER DEFAULT 0 CHECK (questions_attempted >= 0),
    questions_correct INTEGER DEFAULT 0 CHECK (questions_correct >= 0),
    mastery_percentage DECIMAL(5,2) DEFAULT 0.00 CHECK (mastery_percentage >= 0 AND mastery_percentage <= 100),
    last_studied TIMESTAMP WITH TIME ZONE,
    total_study_time INTEGER DEFAULT 0, -- in minutes
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, subject_id, topic)
);

-- ============================================
-- REVISION BOARDS TABLE
-- ============================================
CREATE TABLE revision_boards (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
    content JSONB DEFAULT '{}', -- Flexible content structure
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- FLASHCARDS TABLE
-- ============================================
CREATE TABLE flashcards (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    deck_name VARCHAR(200) NOT NULL,
    front TEXT NOT NULL,
    back TEXT NOT NULL,
    mastery_level INTEGER DEFAULT 0 CHECK (mastery_level >= 0 AND mastery_level <= 5),
    last_reviewed TIMESTAMP WITH TIME ZONE,
    next_review TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- SHOP ITEMS TABLE
-- ============================================
CREATE TABLE shop_items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) CHECK (category IN ('theme', 'hint_pack', 'power_up', 'cosmetic')),
    price INTEGER NOT NULL CHECK (price > 0),
    min_level INTEGER DEFAULT 1 CHECK (min_level >= 1),
    image_url VARCHAR(255),
    properties JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- USER INVENTORY TABLE
-- ============================================
CREATE TABLE user_inventory (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES shop_items(id) ON DELETE CASCADE,
    purchased_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_equipped BOOLEAN DEFAULT FALSE,
    UNIQUE(user_id, item_id)
);

-- ============================================
-- CLASSROOMS TABLE (for teachers)
-- ============================================
CREATE TABLE classrooms (
    id SERIAL PRIMARY KEY,
    teacher_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
    year_group VARCHAR(20),
    invite_code VARCHAR(10) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- CLASSROOM STUDENTS TABLE
-- ============================================
CREATE TABLE classroom_students (
    id SERIAL PRIMARY KEY,
    classroom_id INTEGER REFERENCES classrooms(id) ON DELETE CASCADE,
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(classroom_id, student_id)
);

-- ============================================
-- ASSIGNMENTS TABLE
-- ============================================
CREATE TABLE assignments (
    id SERIAL PRIMARY KEY,
    classroom_id INTEGER REFERENCES classrooms(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    content_type VARCHAR(50) CHECK (content_type IN ('quiz', 'past_papers', 'board')),
    content_id INTEGER, -- references quiz_questions, past_paper_questions, or revision_boards
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ASSIGNMENT SUBMISSIONS TABLE
-- ============================================
CREATE TABLE assignment_submissions (
    id SERIAL PRIMARY KEY,
    assignment_id INTEGER REFERENCES assignments(id) ON DELETE CASCADE,
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(assignment_id, student_id)
);

-- ============================================
-- ACHIEVEMENTS TABLE
-- ============================================
CREATE TABLE achievements (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    xp_reward INTEGER DEFAULT 0,
    coin_reward INTEGER DEFAULT 0,
    requirement_type VARCHAR(50), -- 'quiz_count', 'perfect_score', 'streak', etc.
    requirement_value INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- USER ACHIEVEMENTS TABLE
-- ============================================
CREATE TABLE user_achievements (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    achievement_id INTEGER REFERENCES achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- ============================================
-- INDEXES for better performance
-- ============================================
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_past_papers_subject ON past_paper_questions(subject_id);
CREATE INDEX idx_past_papers_exam_board ON past_paper_questions(exam_board);
CREATE INDEX idx_quiz_questions_subject ON quiz_questions(subject_id);
CREATE INDEX idx_quizzes_user ON quizzes(user_id);
CREATE INDEX idx_user_progress_user_subject ON user_progress(user_id, subject_id);
CREATE INDEX idx_revision_boards_user ON revision_boards(user_id);
CREATE INDEX idx_flashcards_user ON flashcards(user_id);
CREATE INDEX idx_classroom_students_classroom ON classroom_students(classroom_id);
CREATE INDEX idx_classroom_students_student ON classroom_students(student_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE revision_guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE past_paper_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE revision_boards ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Anyone can view subjects
CREATE POLICY "Anyone can view subjects" ON subjects
    FOR SELECT USING (true);

-- Anyone can view revision guides
CREATE POLICY "Anyone can view revision guides" ON revision_guides
    FOR SELECT USING (true);

-- Users can create revision guides
CREATE POLICY "Users can create revision guides" ON revision_guides
    FOR INSERT WITH CHECK (auth.uid() = author_id);

-- Anyone can view past papers
CREATE POLICY "Anyone can view past papers" ON past_paper_questions
    FOR SELECT USING (true);

-- Anyone can view quiz questions
CREATE POLICY "Anyone can view quiz questions" ON quiz_questions
    FOR SELECT USING (true);

-- Users can view their own quizzes
CREATE POLICY "Users can view own quizzes" ON quizzes
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own quiz attempts
CREATE POLICY "Users can insert own quizzes" ON quizzes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can view their own progress
CREATE POLICY "Users can view own progress" ON user_progress
    FOR ALL USING (auth.uid() = user_id);

-- Users can view their own and public revision boards
CREATE POLICY "Users can view revision boards" ON revision_boards
    FOR SELECT USING (auth.uid() = user_id OR is_public = true);

-- Users can manage their own revision boards
CREATE POLICY "Users can manage own boards" ON revision_boards
    FOR ALL USING (auth.uid() = user_id);

-- Users can view their own flashcards
CREATE POLICY "Users can view own flashcards" ON flashcards
    FOR ALL USING (auth.uid() = user_id);

-- Anyone can view shop items
CREATE POLICY "Anyone can view shop items" ON shop_items
    FOR SELECT USING (true);

-- Users can view their own inventory
CREATE POLICY "Users can view own inventory" ON user_inventory
    FOR ALL USING (auth.uid() = user_id);

-- Teachers can manage their classrooms
CREATE POLICY "Teachers can manage own classrooms" ON classrooms
    FOR ALL USING (auth.uid() = teacher_id);

-- Students can view classrooms they're in
CREATE POLICY "Students can view their classrooms" ON classroom_students
    FOR SELECT USING (auth.uid() = student_id);

-- Users can view their achievements
CREATE POLICY "Users can view own achievements" ON user_achievements
    FOR SELECT USING (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to calculate level from XP
CREATE OR REPLACE FUNCTION calculate_level(xp_amount INTEGER)
RETURNS INTEGER AS $$
BEGIN
    -- Simple level calculation: Level = floor(sqrt(XP / 100)) + 1
    RETURN FLOOR(SQRT(xp_amount::FLOAT / 100.0)) + 1;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to get XP needed for next level
CREATE OR REPLACE FUNCTION xp_for_level(target_level INTEGER)
RETURNS INTEGER AS $$
BEGIN
    -- XP needed = (level - 1)^2 * 100
    RETURN ((target_level - 1) * (target_level - 1)) * 100;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- TRIGGERS
-- ============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_revision_boards_updated_at BEFORE UPDATE ON revision_boards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_revision_guides_updated_at BEFORE UPDATE ON revision_guides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();