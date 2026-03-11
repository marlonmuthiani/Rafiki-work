import { NextRequest, NextResponse } from 'next/server'
import { createServerClient, getAuthenticatedUser } from '../../../lib/supabase/server'

export async function GET(request: NextRequest) {
  const user = await getAuthenticatedUser()
  
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const supabase = await createServerClient()
  const { searchParams } = new URL(request.url)
  const limit = searchParams.get('limit') || '20'

  const { data: workers, error } = await supabase
    .from('worker')
    .select(`
      id,
      name,
      status,
      destination,
      created_at,
      created_by_user_id,
      worker_instance (
        id,
        provider,
        region,
        url,
        status
      )
    `)
    .eq('created_by_user_id', user.id)
    .order('created_at', { ascending: false })
    .limit(parseInt(limit))

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  const formattedWorkers = workers.map((w: any) => ({
    id: w.id,
    name: w.name,
    status: w.status,
    isMine: w.created_by_user_id === user.id,
    instance: w.worker_instance?.[0] ? {
      provider: w.worker_instance[0].provider,
      url: w.worker_instance[0].url
    } : null
  }))

  return NextResponse.json({ workers: formattedWorkers })
}

export async function POST(request: NextRequest) {
  const user = await getAuthenticatedUser()
  
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const supabase = await createServerClient()
  const body = await request.json()
  const { name, destination = 'cloud' } = body

  const { data: worker, error } = await supabase
    .from('worker')
    .insert({
      name: name || 'Cloud Worker',
      destination,
      status: 'provisioning',
      created_by_user_id: user.id
    })
    .select()
    .single()

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({
    worker: {
      id: worker.id,
      name: worker.name,
      status: worker.status
    },
    instance: null,
    tokens: null
  })
}
