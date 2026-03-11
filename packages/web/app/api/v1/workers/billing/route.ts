import { NextRequest, NextResponse } from 'next/server'
import { createServerClient, getAuthenticatedUser } from '../../../lib/supabase/server'

export async function GET(request: NextRequest) {
  const user = await getAuthenticatedUser()
  
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { searchParams } = new URL(request.url)
  const includeCheckout = searchParams.get('includeCheckout') === '1'

  const billing = {
    featureGateEnabled: true,
    hasActivePlan: true,
    checkoutRequired: false,
    checkoutUrl: null,
    portalUrl: null,
    price: {
      amount: 2900,
      currency: 'USD',
      recurringInterval: 'month',
      recurringIntervalCount: 1
    },
    subscription: {
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
    },
    invoices: [],
    productId: 'prod_demo',
    benefitId: 'ben_demo'
  }

  return NextResponse.json({ billing })
}
