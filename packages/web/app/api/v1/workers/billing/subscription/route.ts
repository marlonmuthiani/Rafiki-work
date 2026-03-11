import { NextRequest, NextResponse } from 'next/server'
import { getAuthenticatedUser } from '../../../lib/supabase/server'

export async function GET(request: NextRequest) {
  const user = await getAuthenticatedUser()
  
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const subscription = {
    id: 'sub_demo',
    status: 'active',
    amount: 2900,
    currency: 'USD',
    recurringInterval: 'month',
    recurringIntervalCount: 1,
    currentPeriodStart: new Date().toISOString(),
    currentPeriodEnd: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
    cancelAtPeriodEnd: false,
    canceledAt: null,
    endedAt: null
  }

  return NextResponse.json({ subscription })
}
