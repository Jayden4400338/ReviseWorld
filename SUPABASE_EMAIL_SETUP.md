# Supabase Email Verification Setup Guide

## Required Supabase Settings

To enable email verification and resend functionality, you need to configure the following in your Supabase Dashboard:

### 1. Enable Email Confirmation

1. Go to **Authentication** → **Settings** in your Supabase Dashboard
2. Under **Email Auth**, make sure:
   - ✅ **Enable email confirmations** is **ON**
   - ✅ **Secure email change** is enabled (optional but recommended)

### 2. Configure Site URL

1. In **Authentication** → **URL Configuration**:
   - **Site URL**: `http://localhost:5500` (for local) or your production URL
   - **Redirect URLs**: Add your redirect URLs:
     - `http://localhost:5500/auth/login.html`
     - `http://localhost:5500/**` (for local development)
     - Your production URLs

### 3. Email Provider Setup

**Option A: Use Supabase's Built-in Email (Limited)**
- Supabase provides basic email sending
- Limited to development/testing
- For production, use a custom SMTP provider

**Option B: Configure Custom SMTP (Recommended for Production)**
1. Go to **Settings** → **Auth** → **SMTP Settings**
2. Configure your SMTP provider (SendGrid, Mailgun, AWS SES, etc.)
3. Enter SMTP credentials

### 4. Email Templates

1. Go to **Authentication** → **Email Templates**
2. Make sure **Confirm signup** template exists and is enabled
3. The template should include:
   - `{{ .ConfirmationURL }}` - The verification link
   - `{{ .Email }}` - User's email
   - `{{ .SiteURL }}` - Your site URL

### 5. Test Email Sending

1. Go to **Settings** → **Auth** → **Email Templates**
2. Click **Send test email** to verify your email setup works

## Common Issues

### Issue: "Email not sending"
**Solution**: 
- Check SMTP settings are configured
- Verify email templates are enabled
- Check Site URL is set correctly

### Issue: "Resend not working"
**Solution**:
- Make sure email confirmations are enabled
- Check that the user exists in auth.users table
- Verify the email template is configured

### Issue: "Verification link doesn't work"
**Solution**:
- Add your redirect URLs to the allowlist
- Check Site URL matches your actual domain
- Verify email template has correct `{{ .ConfirmationURL }}`

## Quick Checklist

- [ ] Email confirmations enabled in Auth settings
- [ ] Site URL configured correctly
- [ ] Redirect URLs added to allowlist
- [ ] SMTP provider configured (for production)
- [ ] Email templates enabled and configured
- [ ] Test email sending works

## Testing

1. Try signing up a new user
2. Check if verification email is received
3. Try resending verification email
4. Verify the email link works
