import { NextRequest, NextResponse } from 'next/server'
import { getAuthenticatedUser } from '../../lib/supabase/server'

export async function GET(request: NextRequest) {
  const user = await getAuthenticatedUser()
  
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  return NextResponse.json({
    user: {
      id: user.id,
      email: user.email,
      name: user.user_metadata?.name || null
    }
  })
}
