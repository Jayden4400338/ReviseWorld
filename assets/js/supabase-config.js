// Supabase Configuration for BrainMapRevision
// 
// SETUP INSTRUCTIONS:
// 1. Create a Supabase account at https://supabase.com
// 2. Create a new project
// 3. Go to Project Settings > API
// 4. Copy your Project URL and anon/public key
// 5. Replace the values below with your own
// 6. Run the schema.sql file in the SQL Editor
// 7. Run the seed.sql file to populate initial data
// 8. Run the function SQL files (increment_xp.sql, award_coins.sql)
//
// IMPORTANT: Never commit your actual API keys to GitHub!
// Use environment variables in production.

const SUPABASE_URL = 'https://qqbyxydxxcuklakvjlfr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxYnl4eWR4eGN1a2xha3ZqbGZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMjg2MTYsImV4cCI6MjA4NDYwNDYxNn0.2I-uy7ghGa6Ou7uuzDfpYbd75qrNivlBEQBthilYHxw';

// Initialize Supabase client
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { supabase };
}