import { NextRequest, NextResponse } from 'next/server'
import { createServerClient, getAuthenticatedUser } from '../../lib/supabase/server'

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = await getAuthenticatedUser()
  
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { id } = await params
  const supabase = await createServerClient()

  const { data: worker, error: workerError } = await supabase
    .from('worker')
    .select('id, created_by_user_id')
    .eq('id', id)
    .single()

  if (workerError || !worker) {
    return NextResponse.json({ error: 'Worker not found' }, { status: 404 })
  }

  if (worker.created_by_user_id !== user.id) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }

  const { data: tokens, error } = await supabase
    .from('worker_token')
    .select('scope, token, created_at, revoked_at')
    .eq('worker_id', id)
    .is('revoked_at', null)
    .order('created_at', { ascending: false })

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  const clientToken = tokens?.find(t => t.scope === 'client')?.token
  const hostToken = tokens?.find(t => t.scope === 'host')?.token

  return NextResponse.json({
    tokens: {
      client: clientToken,
      host: hostToken
    }
  })
}
