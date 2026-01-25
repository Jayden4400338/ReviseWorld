-- add everytime new sql is added and you dont know where to put it
-- Sample Past Paper Questions for BrainMapRevision
-- Run this in Supabase SQL Editor AFTER your seed_data.sql
-- This adds 2 questions from each exam board (AQA, Edexcel, OCR, WJEC, SQA)

-- First, get subject IDs (run this to check your IDs)
-- SELECT id, name FROM subjects;

-- ============================================
-- AQA QUESTIONS (2 questions)
-- ============================================

-- AQA Mathematics Question 1
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    2, -- Mathematics (change if your ID is different)
    'AQA',
    2024,
    '1',
    '5',
    4,
    'Solve the equation: 3x - 7 = 14',
    '3x = 21 (1 mark for rearranging)
x = 7 (1 mark for correct answer)
Show working clearly (1 mark)
Check answer by substitution (1 mark)',
    'Students should show all working. Common mistake: forgetting to add 7 to both sides first.',
    'Foundation',
    ARRAY['Algebra', 'Linear Equations', 'Solving Equations']
);

-- AQA English Question 2
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    1, -- English
    'AQA',
    2023,
    '1',
    '8',
    8,
    'How does Priestley present the theme of social responsibility in "An Inspector Calls"? Write about:
• How Priestley presents social responsibility in the extract
• How Priestley presents social responsibility in the play as a whole',
    'Level 4 (7-8 marks): Perceptive, detailed analysis
- Clear understanding of social responsibility theme
- Analysis of Inspector Goole as moral voice
- References to "chain of events" and collective responsibility
- Comparison of older (Birlings) vs younger (Sheila/Eric) generation
- Context: 1945 audience after two world wars

Level 3 (5-6 marks): Clear explanation with support
Level 2 (3-4 marks): Some understanding shown
Level 1 (1-2 marks): Simple awareness',
    'Stronger responses linked the play to post-war Britain and Priestley''s socialist message. Weaker responses just retold the plot without analysis.',
    'Higher',
    ARRAY['An Inspector Calls', 'Social Responsibility', 'Themes', 'J.B. Priestley']
);

-- ============================================
-- EDEXCEL QUESTIONS (2 questions)
-- ============================================

-- Edexcel Mathematics Question 1
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    2, -- Mathematics
    'Edexcel',
    2023,
    '2',
    '12',
    5,
    'A rectangle has length (2x + 3) cm and width (x - 1) cm.
(a) Write an expression for the area of the rectangle. (2 marks)
(b) The area is 35 cm². Form and solve an equation to find the value of x. (3 marks)',
    '(a) Area = (2x + 3)(x - 1) (1 mark)
     = 2x² - 2x + 3x - 3 (1 mark)
     = 2x² + x - 3

(b) 2x² + x - 3 = 35 (1 mark for forming equation)
    2x² + x - 38 = 0
    (2x + 19)(x - 2) = 0 (1 mark for factorising)
    x = -19/2 or x = 2
    x = 2 (1 mark, rejecting negative as length must be positive)',
    'Common errors included not expanding brackets correctly and accepting negative values for x. Length cannot be negative.',
    'Higher',
    ARRAY['Algebra', 'Expanding Brackets', 'Quadratic Equations', 'Area']
);

-- Edexcel Science (Biology) Question 2
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    3, -- Science
    'Edexcel',
    2024,
    '1',
    '3',
    6,
    'Describe the process of photosynthesis. Include:
• The word equation
• Where it takes place in the plant cell
• Why it is important for life on Earth',
    'Word equation (2 marks):
Carbon dioxide + Water → Glucose + Oxygen
(Light energy and chlorophyll should be mentioned)

Location (2 marks):
- Takes place in chloroplasts
- In the leaves of plants (mostly)

Importance (2 marks):
- Produces oxygen for respiration
- Produces glucose/food for plant growth
- Base of food chains/webs
- Removes carbon dioxide from atmosphere',
    'Many students knew the word equation but failed to mention chlorophyll or light energy. Full credit requires stating these are needed but not used up.',
    'Foundation',
    ARRAY['Biology', 'Photosynthesis', 'Plants', 'Chloroplasts']
);

-- ============================================
-- OCR QUESTIONS (2 questions)
-- ============================================

-- OCR Mathematics Question 1
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    2, -- Mathematics
    'OCR',
    2023,
    '3',
    '7',
    3,
    'Work out the size of angle x.
[Diagram shows two parallel lines cut by a transversal, with one angle marked 65° and angle x on alternate interior position]',
    'Angle x = 65° (3 marks for correct answer with reason)

Alternative marking:
- Identifies alternate angles (1 mark)
- States they are equal (1 mark)
- Correct answer of 65° (1 mark)

OR
- Co-interior angles add to 180° (1 mark)
- Calculation: 180° - 115° = 65° (2 marks)',
    'Students must give a reason (alternate angles are equal). Answer alone earns only 1 mark.',
    'Foundation',
    ARRAY['Geometry', 'Angles', 'Parallel Lines', 'Alternate Angles']
);

-- OCR History Question 2
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    4, -- History
    'OCR',
    2024,
    '1',
    '4',
    10,
    'Explain why the Treaty of Versailles caused problems for Germany after World War One.
You may use the following in your answer:
• War guilt clause
• Reparations
You must also use information of your own.',
    'Level 4 (9-10 marks):
Complex explanation of multiple causes with links shown
- War Guilt (Article 231) damaged national pride
- £6.6 billion reparations crippled economy
- Loss of territory (Alsace-Lorraine, Polish Corridor)
- Military restrictions (100,000 army, no air force)
- Led to hyperinflation 1923 and political instability

Level 3 (6-8 marks): Developed explanation of causes
Level 2 (3-5 marks): Simple explanation
Level 1 (1-2 marks): Basic knowledge shown',
    'Best answers linked multiple terms together (e.g., reparations → economic crisis → political extremism). Weaker answers just described the terms without explaining consequences.',
    'Higher',
    ARRAY['World War I', 'Treaty of Versailles', 'Weimar Germany', 'Causes and Consequences']
);

-- ============================================
-- WJEC QUESTIONS (2 questions)
-- ============================================

-- WJEC Mathematics Question 1
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    2, -- Mathematics
    'WJEC',
    2024,
    '1',
    '9',
    4,
    'The probability that it rains on Monday is 0.3
The probability that it rains on Tuesday is 0.4
Calculate the probability that it rains on both days.',
    'P(rain both days) = P(Monday) × P(Tuesday) (1 mark for method)
= 0.3 × 0.4 (1 mark)
= 0.12 (2 marks for correct answer)

Accept equivalent fractions: 12/100 or 3/25',
    'Common error: adding probabilities instead of multiplying. Students must understand "AND" means multiply in probability.',
    'Foundation',
    ARRAY['Probability', 'Combined Events', 'Multiplication']
);

-- WJEC Geography Question 2
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    5, -- Geography
    'WJEC',
    2023,
    '2',
    '5',
    6,
    'Explain how a waterfall is formed. You may use a diagram to help your answer.',
    'Formation process (6 marks total):

Band 3 (5-6 marks): Clear, detailed explanation
- River flows over hard rock layer on top of soft rock
- Soft rock erodes faster (hydraulic action/abrasion)
- Undercuts hard rock creating overhang
- Hard rock eventually collapses due to gravity
- Process repeats, waterfall retreats upstream
- Plunge pool forms at base from fallen rocks
- Gorge of recession may form

Band 2 (3-4 marks): Basic explanation with some detail
Band 1 (1-2 marks): Simple points made

Diagram can earn up to 2 marks if well-labelled.',
    'Better answers used geographical terminology (erosion processes, retreat, plunge pool). Diagrams must be clearly labelled to gain credit.',
    'Foundation',
    ARRAY['Rivers', 'Erosion', 'Waterfalls', 'Landforms']
);

-- ============================================
-- SQA QUESTIONS (2 questions)
-- ============================================

-- SQA Mathematics Question 1
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    2, -- Mathematics
    'SQA',
    2024,
    '1',
    '11',
    3,
    'Factorise fully: 6x² + 9x',
    'Taking out common factor:
3x(2x + 3) (3 marks for fully factorised)

Partial credit:
- 3(2x² + 3x) scores 1 mark (not fully factorised)
- x(6x + 9) scores 1 mark (not fully factorised)
- Must take out both 3 AND x for full marks',
    'Common error: only factoring out 3 or only factoring out x. "Fully factorise" means take out ALL common factors.',
    'Foundation',
    ARRAY['Algebra', 'Factorising', 'Common Factors']
);

-- SQA Science (Physics) Question 2
INSERT INTO past_paper_questions (
    subject_id,
    exam_board,
    year,
    paper_number,
    question_number,
    marks,
    question_text,
    mark_scheme,
    examiner_comments,
    difficulty,
    topics
) VALUES (
    3, -- Science
    'SQA',
    2023,
    '2',
    '8',
    5,
    'A car accelerates from rest to 20 m/s in 4 seconds.
(a) Calculate the acceleration of the car. (3 marks)
(b) State the formula you used. (1 mark)
(c) Give the unit for acceleration. (1 mark)',
    '(a) Using a = (v - u) / t
    a = (20 - 0) / 4 (1 mark for substitution)
    a = 20 / 4 (1 mark for calculation)
    a = 5 (1 mark for answer)

(b) a = (v - u) / t  OR  a = Δv / t (1 mark)

(c) m/s² (1 mark)
    Accept: metres per second squared',
    'Many students forgot units or gave m/s instead of m/s². The formula must be stated in part (b) even if used correctly in part (a).',
    'Higher',
    ARRAY['Physics', 'Forces', 'Acceleration', 'Motion', 'Calculations']
);

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

-- Display confirmation
DO $$
BEGIN
    RAISE NOTICE '✅ Successfully inserted 10 past paper questions:';
    RAISE NOTICE '   - 2 from AQA (Maths, English)';
    RAISE NOTICE '   - 2 from Edexcel (Maths, Science)';
    RAISE NOTICE '   - 2 from OCR (Maths, History)';
    RAISE NOTICE '   - 2 from WJEC (Maths, Geography)';
    RAISE NOTICE '   - 2 from SQA (Maths, Science)';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Run this to verify:';
    RAISE NOTICE '   SELECT exam_board, COUNT(*) FROM past_paper_questions GROUP BY exam_board;';
END $$;