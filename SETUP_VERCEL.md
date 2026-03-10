# Vercel Environment Setup

## Required Environment Variables

Add these in Vercel Dashboard → Project Settings → Environment Variables:

| Variable | Value | Environment |
|----------|-------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://ndhqojmcszdqokcklpis.supabase.co` | Production, Preview, Development |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kaHFvam1jc3pkcW9rY2tscGlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwODIwODAsImV4cCI6MjA4ODY1ODA4MH0.MjFD6bsAS4-xYX4tKEbiGlFCrX7kytcI-1ct-Iyf_58` | Production, Preview, Development |

## Supabase Redirect URLs

For auth to work on preview deployments, add these URLs in Supabase Dashboard → Authentication → URL Configuration:

### Site URL
- `https://rafiki-work-web.vercel.app`

### Redirect URLs
```
https://rafiki-work-web.vercel.app
https://rafiki-work-web-marlonmuthianis-projects.vercel.app
https://rafiki-work-*.vercel.app
```

## How to Add Environment Variables via CLI

If you have Vercel CLI installed and authenticated:

```bash
# Add environment variables
vercel env add NEXT_PUBLIC_SUPABASE_URL production
# Enter: https://ndhqojmcszdqokcklpis.supabase.co

vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
# Enter: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kaHFvam1jc3pkcW9rY2tscGlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwODIwODAsImV4cCI6MjA4ODY1ODA4MH0.MjFD6bsAS4-xYX4tKEbiGlFCrX7kytcI-1ct-Iyf_58
```

Or add them in the Vercel Dashboard:
1. Go to https://vercel.com/dashboard
2. Select project "rafiki-work-web"
3. Go to Settings → Environment Variables
4. Add the variables above for all environments
