CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE public."user" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  email_verified BOOLEAN DEFAULT false,
  image TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.session (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public."user"(id) ON DELETE CASCADE,
  token TEXT UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.account (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public."user"(id) ON DELETE CASCADE,
  account_id TEXT NOT NULL,
  provider_id TEXT NOT NULL,
  access_token TEXT,
  refresh_token TEXT,
  access_token_expires_at TIMESTAMPTZ,
  refresh_token_expires_at TIMESTAMPTZ,
  scope TEXT,
  id_token TEXT,
  password TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.verification (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  identifier TEXT NOT NULL,
  value TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.org (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  owner_user_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.org_membership (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES public.org(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('owner', 'member')),
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(org_id, user_id)
);

CREATE TABLE public.worker (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES public.org(id) ON DELETE CASCADE,
  created_by_user_id TEXT,
  name TEXT NOT NULL,
  description TEXT,
  destination TEXT NOT NULL CHECK (destination IN ('local', 'cloud')),
  status TEXT NOT NULL CHECK (status IN ('provisioning', 'healthy', 'failed', 'stopped')),
  image_version TEXT,
  workspace_path TEXT,
  sandbox_backend TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.worker_instance (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id UUID REFERENCES public.worker(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  region TEXT,
  url TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.worker_token (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id UUID REFERENCES public.worker(id) ON DELETE CASCADE,
  scope TEXT NOT NULL CHECK (scope IN ('client', 'host')),
  token TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  revoked_at TIMESTAMPTZ
);

CREATE TABLE public.worker_bundle (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id UUID REFERENCES public.worker(id) ON DELETE CASCADE,
  storage_url TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.audit_event (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES public.org(id) ON DELETE CASCADE,
  worker_id UUID REFERENCES public.worker(id) ON DELETE SET NULL,
  actor_user_id TEXT NOT NULL,
  action TEXT NOT NULL,
  payload JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_session_user_id ON public.session(user_id);
CREATE INDEX idx_account_user_id ON public.account(user_id);
CREATE INDEX idx_verification_identifier ON public.verification(identifier);
CREATE INDEX idx_org_owner_user_id ON public.org(owner_user_id);
CREATE INDEX idx_org_membership_org_id ON public.org_membership(org_id);
CREATE INDEX idx_org_membership_user_id ON public.org_membership(user_id);
CREATE INDEX idx_worker_org_id ON public.worker(org_id);
CREATE INDEX idx_worker_created_by_user_id ON public.worker(created_by_user_id);
CREATE INDEX idx_worker_status ON public.worker(status);
CREATE INDEX idx_worker_instance_worker_id ON public.worker_instance(worker_id);
CREATE INDEX idx_worker_token_worker_id ON public.worker_token(worker_id);
CREATE INDEX idx_worker_token_token ON public.worker_token(token);
CREATE INDEX idx_worker_bundle_worker_id ON public.worker_bundle(worker_id);
CREATE INDEX idx_audit_event_org_id ON public.audit_event(org_id);
CREATE INDEX idx_audit_event_worker_id ON public.audit_event(worker_id);

ALTER TABLE public."user" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org_membership ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worker ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worker_instance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worker_token ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worker_bundle ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_event ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can sign up" ON public."user" FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can read own profile" ON public."user" FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update own profile" ON public."user" FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Users can manage own sessions" ON public.session FOR ALL USING (
  user_id IN (SELECT id FROM public."user" WHERE id = auth.uid())
);

CREATE POLICY "Users can manage own accounts" ON public.account FOR ALL USING (
  user_id IN (SELECT id FROM public."user" WHERE id = auth.uid())
);

CREATE POLICY "Anyone can verify" ON public.verification FOR ALL USING (true);

CREATE POLICY "Users can view own orgs" ON public.org FOR SELECT USING (owner_user_id = auth.uid()::text);
CREATE POLICY "Users can create orgs" ON public.org FOR INSERT WITH CHECK (owner_user_id = auth.uid()::text);
CREATE POLICY "Users can update own orgs" ON public.org FOR UPDATE USING (owner_user_id = auth.uid()::text);

CREATE POLICY "Members can view org memberships" ON public.org_membership FOR SELECT USING (user_id = auth.uid()::text);
CREATE POLICY "Members can manage org memberships" ON public.org_membership FOR ALL USING (user_id = auth.uid()::text);

CREATE POLICY "Members can view workers" ON public.worker FOR SELECT USING (
  org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text)
);
CREATE POLICY "Members can create workers" ON public.worker FOR INSERT WITH CHECK (
  org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text)
);
CREATE POLICY "Members can update workers" ON public.worker FOR UPDATE USING (
  org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text)
);
CREATE POLICY "Members can delete workers" ON public.worker FOR DELETE USING (
  org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text)
);

CREATE POLICY "Members can view worker instances" ON public.worker_instance FOR SELECT USING (
  worker_id IN (SELECT id FROM public.worker WHERE org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text))
);

CREATE POLICY "Members can view worker tokens" ON public.worker_token FOR SELECT USING (
  worker_id IN (SELECT id FROM public.worker WHERE org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text))
);
CREATE POLICY "Members can create worker tokens" ON public.worker_token FOR INSERT WITH CHECK (
  worker_id IN (SELECT id FROM public.worker WHERE org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text))
);

CREATE POLICY "Members can view worker bundles" ON public.worker_bundle FOR SELECT USING (
  worker_id IN (SELECT id FROM public.worker WHERE org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text))
);

CREATE POLICY "Members can view audit events" ON public.audit_event FOR SELECT USING (
  org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text)
);
CREATE POLICY "Members can create audit events" ON public.audit_event FOR INSERT WITH CHECK (
  org_id IN (SELECT org_id FROM public.org_membership WHERE user_id = auth.uid()::text)
);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  org_id UUID;
BEGIN
  INSERT INTO public.org (name, slug, owner_user_id)
  VALUES (
    COALESCE(NEW.raw_user_meta_data->>'name', 'Personal'),
    LOWER(COALESCE(NEW.raw_user_meta_data->>'slug', 'personal-' || SUBSTRING(NEW.id::TEXT, 1, 8))),
    NEW.id
  )
  RETURNING id INTO org_id;

  INSERT INTO public.org_membership (org_id, user_id, role)
  VALUES (org_id, NEW.id, 'owner');

  INSERT INTO public."user" (id, name, email, email_verified)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'name', 'User'), NEW.email, true);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
