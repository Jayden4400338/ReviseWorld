// Supabase Configuration for BrainMapRevision
// 
// SETUP INSTRUCTIONS:
// 1. Create a Supabase account at https://supabase.com
// 2. Create a new project
// 3. Go to Project Settings > API
// 4. Copy your Project URL and anon/public key
// 5. Add them to .env.local for local development or Vercel env vars for production
// 6. Run the schema.sql file in the SQL Editor
// 7. Run the seed.sql file to populate initial data
// 8. Run the function SQL files (increment_xp.sql, award_coins.sql)
//
// IMPORTANT: Never commit your actual API keys to GitHub!
// Use environment variables in production.
//
// This file reads from window.__ENV__ which is populated by env-config.js
// env-config.js is generated from environment variables during build

// Get configuration from environment (set by env-config.js)
const SUPABASE_URL = window.__ENV__?.SUPABASE_URL || 'https://qqbyxydxxcuklakvjlfr.supabase.co';
const SUPABASE_ANON_KEY = window.__ENV__?.SUPABASE_ANON_KEY || 'your-anon-key-here';

// Initialize Supabase client
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { supabase };
}