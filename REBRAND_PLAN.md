# Rafiki Rebrand Plan

**Status**: Ready for Prometheus Finalization ✅
**Created by**: Sisyphus (Deep Analysis Complete)
**Date**: 2026-03-09

**USER DECISIONS CONFIRMED:**
- **New Brand Name**: Rafiki
- **Supabase Integration**: Phase 1 = Rename only (Supabase later)

---

## Executive Summary

This document outlines a comprehensive rebrand plan for the Rafiki project. Based on deep analysis of the codebase, documentation, and architecture, we've identified:

- **Vercel Deployment**: Already configured! Ready to use.
- **Supabase Integration**: Deferred to Phase 2
- **Rebrand Scope**: 7 packages, multiple config files, design tokens
- **Initial Phase**: Rename + Color Theme Change only

---

## Phase 1: Rebranding (Initial Scope - Rename + Colors)

### 1.1 Package Renaming Scope

| Current Package Name | New Name (TBD) | File Path |
|---------------------|----------------|-----------|
| `@different-ai/openwork-workspace` | | `package.json` (root) |
| `@different-ai/openwork-ui` | | `packages/app/package.json` |
| `@different-ai/openwork` | | `packages/desktop/package.json` |
| `openwork-server` | | `packages/server/package.json` |
| `openwork-orchestrator` | | `packages/orchestrator/package.json` |
| `@different-ai/openwork-web` | | `packages/web/package.json` |
| `@different-ai/openwork-landing` | | `packages/landing/package.json` |

**Files requiring updates for package rename:**
- `package.json` (root) - scripts, workspace config
- `pnpm-workspace.yaml` - workspace packages
- All 7 package.json files - name field
- `packages/orchestrator/package.json` - dependencies on other openwork packages
- `packages/desktop/src-tauri/capabilities/default.json` - capability identifier `openwork-default`

### 1.2 Color Theme Changes

**Current Brand Colors (from DESIGN-LANGUAGE.md):**

| Token | Hex Code | Current Usage |
|-------|----------|---------------|
| `--ow-bg` | `#f6f9fc` | Base background |
| `--ow-ink` | `#011627` | Primary ink (dark navy) |
| `--ow-primary` | `#011627` | Primary actions |
| `--ow-primary-hover` | `#000000` | Primary hover |

**Tailwind Config Brand Colors:**

| Package | Color Name | Hex Code |
|---------|------------|----------|
| packages/web | brandInk | `#161019` |
| packages/web | brandOrange | `#ef7b35` |
| packages/web | brandBlue | `#00a6fb` |
| packages/landing | ink | `#111111` |

**Files requiring color updates:**
- `DESIGN-LANGUAGE.md` - Core design tokens
- `packages/web/tailwind.config.js` - Brand colors
- `packages/landing/tailwind.config.js` - Brand colors
- `packages/app/src/styles/colors.css` - Radix UI colors (if brand colors needed)
- `packages/app/src/app/index.css` - App CSS variables
- `packages/landing/app/globals.css` - Landing styles

### 1.3 Logo Updates

| Logo File | Current Brand Color | Action |
|-----------|---------------------|--------|
| `packages/app/public/openwork-logo.svg` | `#267CE8` blue | Replace with new brand |
| `packages/app/public/openwork-logo-square.svg` | - | Replace with new brand |
| `packages/landing/public/openwork-logo.svg` | `#257CE9` blue | Replace with new brand |

### 1.4 Documentation Updates

| File | Update Required |
|------|-----------------|
| `README.md` | Project name, descriptions |
| `AGENTS.md` | Rafiki references |
| `VISION.md` | Rafiki references |
| `ARCHITECTURE.md` | Rafiki references |
| `INFRASTRUCTURE.md` | Rafiki references |
| `DESIGN-LANGUAGE.md` | Brand name, colors |
| All `packages/*/README.md` | Project descriptions |

---

## Phase 2: Vercel Deployment

### 2.1 Existing Configuration (Already Ready!)

| Package | Vercel Config | Framework | Deploy Status |
|---------|---------------|-----------|----------------|
| packages/web | vercel.json | Next.js | ✅ Configured |
| packages/app | vercel.json | Vite | ✅ Configured |
| packages/landing | vercel.json | Next.js | ✅ Configured |

### 2.2 Environment Variables Required

**packages/web (app.openwork.software):**
```
DEN_API_BASE=https://api.openwork.software
DEN_AUTH_ORIGIN=https://app.openwork.software
DEN_AUTH_FALLBACK_BASE=https://den-control-plane-openwork.onrender.com
NEXT_PUBLIC_OPENWORK_APP_CONNECT_URL=https://openwork.software/app
NEXT_PUBLIC_OPENWORK_AUTH_CALLBACK_URL=https://app.openwork.software
NEXT_PUBLIC_POSTHOG_KEY=<project-key>
NEXT_PUBLIC_POSTHOG_HOST=https://us.i.posthog.com
LOOPS_API_KEY=<api-key>
```

**packages/landing:**
```
NEXT_PUBLIC_CAL_URL=<enterprise-booking-url>
NEXT_PUBLIC_DEN_CHECKOUT_URL=<polar-checkout-url>
```

**services/openwork-share:**
```
BLOB_READ_WRITE_TOKEN=<vercel-blob-token>
PUBLIC_BASE_URL=https://share.openwork.software
PUBLIC_OPENWORK_APP_URL=https://app.openwork.software
```

### 2.3 Custom Domains

- `app.openwork.software` → packages/web
- (landing domain TBD)

### 2.4 Deployment Steps

1. Import projects in Vercel dashboard
2. Set root directories as per table above
3. Configure environment variables
4. Assign custom domains
5. Deploy

---

## Phase 3: Supabase Integration

### 3.1 Current Architecture (No Supabase)

**Current Stack:**
- Authentication: Better Auth
- Database: MySQL (via Drizzle ORM)
- Package: `services/den`

**Files showing current setup:**
- `services/den/package.json` - Dependencies: better-auth, drizzle-orm, mysql2
- `services/den/.env.example` - DATABASE_URL, BETTER_AUTH_SECRET, BETTER_AUTH_URL
- `services/den/src/db/schema.ts` - Database schema

### 3.2 Supabase Integration Required

**New Stack Needed:**
- Authentication: Supabase Auth (@supabase/ssr, @supabase/supabase-js)
- Database: Supabase PostgreSQL
- ORM: Prisma or Kysely (compatible with Supabase)

### 3.3 Migration Steps

1. **Add Supabase packages:**
   ```json
   {
     "@supabase/supabase-js": "^2.39.0",
     "@supabase/ssr": "^0.1.0"
   }
   ```

2. **Create Supabase client configuration:**
   - Environment variables: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - Client initialization in packages

3. **Migrate authentication:**
   - Replace Better Auth with Supabase Auth
   - Update auth providers (GitHub OAuth, etc.)
   - Update session management

4. **Migrate database:**
   - Export MySQL data
   - Import to Supabase PostgreSQL
   - Update Drizzle config or switch ORM
   - Update DATABASE_URL to Supabase connection string

5. **Update services/den:**
   - New package.json dependencies
   - New .env.example with Supabase vars
   - Update auth.ts, schema.ts, db/index.ts

---

## Phase 4: OpenCode Workflow Alignment

### 4.1 Existing Development Workflow (from AGENTS.md)

1. **New Feature Workflow:**
   - Ensure up to date with remotes
   - Create worktree for isolation
   - Implement feature
   - Start dev stack: `packaging/docker/dev-up.sh`
   - Test via Chrome MCP: `.opencode/skills/openwork-docker-chrome-mcp/SKILL.md`
   - Take screenshots
   - Reference screenshots in PR
   - Test the flow implemented

2. **Local Development:**
   - `pnpm dev` - Desktop app
   - `pnpm dev:ui` - Web UI only

3. **Release Workflow:**
   - Version bump: `pnpm bump:patch|minor|major`
   - Tag: `git tag vX.Y.Z`
   - Push: `git push origin vX.Y.Z`

### 4.2 Alignment for Rebrand

**Use worktree for rebrand changes:**
```bash
git worktree add ../rebrand-feature main
```

**Testing required:**
- Docker dev stack must run successfully
- Chrome MCP E2E testing for all UI changes
- Manual verification of all buttons, links, actions

---

## Implementation Order (Recommended)

### Step 1: Branch & Worktree
1. Create feature branch: `git checkout -b rebrand/v1`
2. Create worktree: `git worktree add ../rebrand-work main`

### Step 2: Phase 1 - Rebranding
1. Update all 7 package.json files
2. Update root package.json scripts
3. Update pnpm-workspace.yaml if needed
4. Update Tauri capabilities
5. Update DESIGN-LANGUAGE.md colors
6. Update tailwind.config.js files
7. Replace logo SVGs
8. Update documentation files

### Step 3: Phase 2 - Vercel
1. Update vercel.json if needed for new domain
2. Configure environment variables in Vercel dashboard
3. Deploy and verify

### Step 4: Phase 3 - Supabase
1. Add Supabase packages
2. Create Supabase project
3. Migrate authentication
4. Migrate database
5. Update environment variables

### Step 5: Testing
1. Run `packaging/docker/dev-up.sh`
2. Chrome MCP full testing
3. Manual verification of all pages/buttons/flows

---

## Files to Modify Summary

### Package.json Files (7)
1. `package.json` (root)
2. `packages/app/package.json`
3. `packages/desktop/package.json`
4. `packages/server/package.json`
5. `packages/orchestrator/package.json`
6. `packages/web/package.json`
7. `packages/landing/package.json`

### Configuration Files (8)
8. `packages/desktop/src-tauri/capabilities/default.json`
9. `pnpm-workspace.yaml`
10. `packages/web/tailwind.config.js`
11. `packages/landing/tailwind.config.js`
12. `packages/web/vercel.json` (domain update)
13. `packages/app/vercel.json` (domain update)
14. `packages/landing/vercel.json` (domain update)

### Design Tokens (5)
15. `DESIGN-LANGUAGE.md`
16. `packages/app/src/styles/colors.css`
17. `packages/app/src/app/index.css`
18. `packages/landing/app/globals.css`

### Logo Files (3)
19. `packages/app/public/openwork-logo.svg`
20. `packages/app/public/openwork-logo-square.svg`
21. `packages/landing/public/openwork-logo.svg`

### Documentation (8+)
22. `README.md`
23. `AGENTS.md`
24. `VISION.md`
25. `ARCHITECTURE.md`
26. `INFRASTRUCTURE.md`
27. `packages/app/README.md`
28. `packages/web/README.md`
29. `packages/landing/README.md`

---

## Next Steps

**For Prometheus:**
1. Review this plan
2. Finalize new brand name
3. Finalize color palette
4. Approve or suggest modifications

**After Prometheus Approval:**
1. Sisyphus reviews the finalized plan
2. If approved, hand to Atlas for implementation

---

## Appendix: Current Brand Reference

**Brand Colors:**
- Primary: `#011627` (dark navy)
- Background: `#f6f9fc`
- Accent Blue: `#257CE9`

**Logos:**
- SVG format
- Located in packages/app/public/ and packages/landing/public/

**Website (current):**
- Landing: (to be configured)
- App: app.openwork.software

**GitHub:**
- Repository: github.com/different-ai/openwork
