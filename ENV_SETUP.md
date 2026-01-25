# Environment Variables Setup Guide

This project uses environment variables to securely manage Supabase credentials. The configuration works for both **local development** and **Vercel deployment**.

## Quick Start

### For Local Development

**Step 1: Create `.env.local` file in the project root**

Create a file named `.env.local` in the root directory of your project (same folder as `index.html`, `package.json`, etc.)

**Step 2: Add your Supabase credentials to `.env.local`**

Open `.env.local` and add your actual Supabase values:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-actual-anon-key-here
```

**Example:**
```
SUPABASE_URL=https://qqbyxydxxcuklakvjlfr.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Step 3: Generate the environment config file**

Choose one of these methods:

   **Option A - Using Node.js directly (recommended):**
   ```bash
   node scripts/setup-local-env.js
   ```
   
   **Option B - Using npm (if you have it):**
   ```bash
   npm run setup:local
   ```
   
   **Option C - Manual setup (no Node.js needed):**
   Open `assets/js/env-config.js` and manually replace the values:
   ```javascript
   window.__ENV__ = window.__ENV__ || {
     SUPABASE_URL: 'https://your-project.supabase.co',
     SUPABASE_ANON_KEY: 'your-actual-key-here'
   };
   ```

**Step 4: Start your local server** (e.g., using Live Server, Python's http.server, etc.)

**File Structure:**
```
BrainMapRevision-web/
├── .env.local          ← Create this file here (in root)
├── .env.example        ← Template (already exists)
├── assets/
│   └── js/
│       └── env-config.js  ← Auto-generated from .env.local
├── scripts/
│   └── setup-local-env.js  ← Reads .env.local
└── ...
```

### For Vercel Deployment

1. **Go to your Vercel project settings**
   - Navigate to Settings → Environment Variables

2. **Add the following environment variables:**
   - `SUPABASE_URL` = `https://your-project.supabase.co`
   - `SUPABASE_ANON_KEY` = `your-actual-anon-key-here`
   
   Or use the alternative names (both work):
   - `NEXT_PUBLIC_SUPABASE_URL` = `https://your-project.supabase.co`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = `your-actual-anon-key-here`

3. **Deploy your project**
   - Vercel will automatically run the build script (`scripts/build-env.js`) during deployment
   - This generates `assets/js/env-config.js` with your environment variables

## How It Works

1. **Environment Config File**: `assets/js/env-config.js` contains the Supabase credentials
   - This file can be auto-generated OR manually edited
   - For local dev: Run the setup script OR edit it directly
   - For Vercel: Auto-generated during build

2. **Build Scripts** (Node.js only - no npm packages needed):
   - `scripts/build-env.js` - Used by Vercel during deployment (runs automatically)
   - `scripts/setup-local-env.js` - Optional helper for local development
   - These scripts only use Node.js built-in modules (fs, path) - no dependencies!

3. **Usage in Code**: All files read from `window.__ENV__` which is populated by `env-config.js`

**Note**: You don't need npm or any packages! The scripts are just Node.js files. You can:
- Run them directly: `node scripts/setup-local-env.js`
- Or manually edit `assets/js/env-config.js` if you prefer

## Files Updated

The following files now use environment variables:
- `assets/js/supabase-config.js`
- `auth/login.html`
- `auth/signup.html`
- `auth/reset-password.html`
- `pages/dashboard.html`
- `pages/past-papers.html`
- `pages/revision-boards.html`
- `pages/subjects.html`
- `pages/quizzes.html`

## Security Notes

- ✅ Never commit `.env.local` to version control (it's in `.gitignore`)
- ✅ Never commit actual API keys to GitHub
- ✅ Use Vercel's environment variables for production
- ✅ The `env-config.js` file is safe to commit (it contains defaults that won't work without proper setup)

## Troubleshooting

**Issue**: Supabase connection fails locally
- Make sure you've run `npm run setup:local` after creating `.env.local`
- Check that `assets/js/env-config.js` contains your actual keys (not the defaults)

**Issue**: Supabase connection fails on Vercel
- Verify environment variables are set in Vercel project settings
- Check that the build command is running (`node scripts/build-env.js`)
- Ensure variable names match exactly (case-sensitive)

**Issue**: Changes to `.env.local` not taking effect
- Re-run `npm run setup:local` after changing `.env.local`
- Clear browser cache and hard refresh
