-- Function to award Brain Coins to users
-- Run this in your Supabase SQL Editor

CREATE OR REPLACE FUNCTION award_coins(
    user_uuid UUID,
    coin_amount INTEGER
) 
RETURNS TABLE(
    new_balance INTEGER,
    amount_awarded INTEGER
) AS $$
DECLARE
    current_coins INTEGER;
    new_total_coins INTEGER;
BEGIN
    -- Get current coin balance
    SELECT brain_coins 
    INTO current_coins
    FROM users 
    WHERE id = user_uuid;
    
    -- Calculate new balance
    new_total_coins := current_coins + coin_amount;
    
    -- Update user coins
    UPDATE users
    SET 
        brain_coins = new_total_coins,
        updated_at = NOW()
    WHERE id = user_uuid;
    
    -- Return results
    RETURN QUERY
    SELECT 
        new_total_coins,
        coin_amount;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION award_coins(UUID, INTEGER) TO authenticated;


-- Function to spend Brain Coins (for shop purchases)
CREATE OR REPLACE FUNCTION spend_coins(
    user_uuid UUID,
    coin_amount INTEGER
) 
RETURNS TABLE(
    success BOOLEAN,
    new_balance INTEGER,
    message TEXT
) AS $$
DECLARE
    current_coins INTEGER;
    new_total_coins INTEGER;
BEGIN
    -- Get current coin balance
    SELECT brain_coins 
    INTO current_coins
    FROM users 
    WHERE id = user_uuid;
    
    -- Check if user has enough coins
    IF current_coins < coin_amount THEN
        RETURN QUERY
        SELECT 
            FALSE,
            current_coins,
            'Insufficient coins'::TEXT;
        RETURN;
    END IF;
    
    -- Calculate new balance
    new_total_coins := current_coins - coin_amount;
    
    -- Update user coins
    UPDATE users
    SET 
        brain_coins = new_total_coins,
        updated_at = NOW()
    WHERE id = user_uuid;
    
    -- Return success
    RETURN QUERY
    SELECT 
        TRUE,
        new_total_coins,
        'Purchase successful'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION spend_coins(UUID, INTEGER) TO authenticated;