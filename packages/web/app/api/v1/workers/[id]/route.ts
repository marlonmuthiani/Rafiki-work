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

  const { data: worker, error } = await supabase
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
    .eq('id', id)
    .single()

  if (error || !worker) {
    return NextResponse.json({ error: 'Worker not found' }, { status: 404 })
  }

  return NextResponse.json({
    worker: {
      id: worker.id,
      name: worker.name,
      status: worker.status,
      isMine: worker.created_by_user_id === user.id
    },
    instance: worker.worker_instance?.[0] ? {
      provider: worker.worker_instance[0].provider,
      url: worker.worker_instance[0].url
    } : null
  })
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = await getAuthenticatedUser()
  
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { id } = await params
  const supabase = await createServerClient()

  const { error } = await supabase
    .from('worker')
    .delete()
    .eq('id', id)
    .eq('created_by_user_id', user.id)

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ success: true })
}
