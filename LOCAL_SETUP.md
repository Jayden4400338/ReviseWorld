# Quick Local Setup Guide

## Where to Put Your Variables for Local Testing

### Option 1: Using `.env.local` file (Recommended)

1. **Create a file named `.env.local` in your project root** (same folder as `index.html`)

2. **Add your Supabase credentials:**
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-actual-anon-key-here
   ```

3. **Run the setup script:**
   ```bash
   node scripts/setup-local-env.js
   ```

   This will read `.env.local` and generate `assets/js/env-config.js` with your values.

### Option 2: Manual Edit (No Node.js needed)

1. **Open `assets/js/env-config.js`**

2. **Replace the values directly:**
   ```javascript
   window.__ENV__ = window.__ENV__ || {
     SUPABASE_URL: 'https://your-project.supabase.co',
     SUPABASE_ANON_KEY: 'your-actual-anon-key-here'
   };
   ```

3. **Save the file** - That's it! No scripts needed.

## File Locations

```
Your Project Root/
├── .env.local              ← Create this file here (for Option 1)
├── assets/
│   └── js/
│       └── env-config.js  ← Edit this file directly (for Option 2)
└── scripts/
    └── setup-local-env.js  ← Reads .env.local (for Option 1)
```

## Important Notes

- ✅ `.env.local` is in `.gitignore` - it won't be committed to GitHub
- ✅ `env-config.js` can be committed (it has safe defaults)
- ✅ After editing `.env.local`, re-run the setup script
- ✅ After manually editing `env-config.js`, just save and refresh your browser

## Finding Your Supabase Keys

1. Go to [supabase.com](https://supabase.com) and log in
2. Select your project
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** → Use for `SUPABASE_URL`
   - **anon/public key** → Use for `SUPABASE_ANON_KEY`
