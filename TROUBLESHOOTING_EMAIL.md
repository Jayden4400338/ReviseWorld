# Troubleshooting Email Verification

## If Resend Verification Doesn't Work

### Step 1: Check Supabase Dashboard Settings

1. **Go to Supabase Dashboard** → **Authentication** → **Settings**

2. **Check Email Auth Settings:**
   - ✅ **Enable email confirmations** must be **ON**
   - If it's OFF, turn it ON and save

3. **Check URL Configuration:**
   - **Site URL**: Should be your domain (e.g., `http://localhost:5500` for local)
   - **Redirect URLs**: Must include:
     - `http://localhost:5500/**` (for local dev)
     - Your production domain

### Step 2: Check Email Provider

1. **Go to Settings** → **Auth** → **SMTP Settings**

2. **If using Supabase's built-in email:**
   - Limited to development
   - May have rate limits
   - Check email templates are enabled

3. **If using custom SMTP:**
   - Verify SMTP credentials are correct
   - Test connection
   - Check provider's sending limits

### Step 3: Check Email Templates

1. **Go to Authentication** → **Email Templates**

2. **Verify "Confirm signup" template exists:**
   - Should contain `{{ .ConfirmationURL }}`
   - Should be enabled/active

3. **Test the template:**
   - Click "Send test email"
   - Check if you receive it

### Step 4: Check Browser Console

Open browser console (F12) and look for:
- Error messages from Supabase
- Network requests to Supabase API
- Any JavaScript errors

Common errors:
- `Email confirmation is disabled` → Enable it in Dashboard
- `Rate limit exceeded` → Wait a few minutes
- `User not found` → User needs to sign up first

### Step 5: Alternative Method (If resend doesn't work)

If `auth.resend()` doesn't work, you can manually trigger by:

1. **Using Supabase Dashboard:**
   - Go to Authentication → Users
   - Find the user
   - Click "Send magic link" or "Resend confirmation"

2. **Using SQL (Admin only):**
   ```sql
   -- This doesn't actually send email, but you can check user status
   SELECT email, email_confirmed_at, created_at 
   FROM auth.users 
   WHERE email = 'user@example.com';
   ```

### Step 6: Verify User Exists

Run this SQL in Supabase SQL Editor:
```sql
SELECT 
    email,
    email_confirmed_at,
    created_at,
    CASE 
        WHEN email_confirmed_at IS NULL THEN 'Not Verified'
        ELSE 'Verified'
    END as status
FROM auth.users
WHERE email = 'your-email@example.com';
```

### Common Fixes

**Problem**: "Email confirmation is disabled"
**Fix**: Go to Authentication → Settings → Enable email confirmations

**Problem**: "Rate limit exceeded"  
**Fix**: Wait 5-10 minutes, then try again

**Problem**: "User not found"
**Fix**: User needs to sign up first, or email is incorrect

**Problem**: No email received
**Fix**: 
- Check spam folder
- Verify SMTP is configured
- Check email templates are enabled
- Verify Site URL is correct

### Testing

1. **Sign up a new test user**
2. **Check if verification email arrives**
3. **If not, try resend**
4. **Check console for errors**
5. **Verify Supabase settings**

### Still Not Working?

1. Check Supabase status page
2. Verify your Supabase project is active
3. Check if you're on free tier (may have limits)
4. Contact Supabase support with error messages from console
