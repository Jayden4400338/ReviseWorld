-- Function to increment user XP and handle level-ups
-- Run this in your Supabase SQL Editor

CREATE OR REPLACE FUNCTION increment_xp(
    user_uuid UUID,
    xp_amount INTEGER
) 
RETURNS TABLE(
    new_xp INTEGER, 
    new_level INTEGER, 
    leveled_up BOOLEAN,
    coins_earned INTEGER
) AS $$
DECLARE
    current_xp INTEGER;
    current_level INTEGER;
    current_coins INTEGER;
    new_total_xp INTEGER;
    calculated_level INTEGER;
    level_difference INTEGER;
    bonus_coins INTEGER := 0;
BEGIN
    -- Get current stats
    SELECT xp, level, brain_coins 
    INTO current_xp, current_level, current_coins
    FROM users 
    WHERE id = user_uuid;
    
    -- Calculate new XP
    new_total_xp := current_xp + xp_amount;
    
    -- Calculate new level
    calculated_level := calculate_level(new_total_xp);
    
    -- Calculate level difference
    level_difference := calculated_level - current_level;
    
    -- Award bonus coins for level up (50 coins per level)
    IF level_difference > 0 THEN
        bonus_coins := level_difference * 50;
    END IF;
    
    -- Update user stats
    UPDATE users
    SET 
        xp = new_total_xp,
        level = calculated_level,
        brain_coins = current_coins + bonus_coins,
        updated_at = NOW()
    WHERE id = user_uuid;
    
    -- Return results
    RETURN QUERY
    SELECT 
        new_total_xp,
        calculated_level,
        (calculated_level > current_level),
        bonus_coins;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION increment_xp(UUID, INTEGER) TO authenticated;