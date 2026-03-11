'use client';

import { useEffect, useState } from 'react';
import { createClient } from '../../lib/supabase/client';

export default function OAuthConsentPage() {
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [message, setMessage] = useState('Completing authentication...');

  useEffect(() => {
    const handleCallback = async () => {
      const supabase = createClient();
      
      // Get the session from URL hash (Supabase puts tokens there)
      const { data: { session }, error } = await supabase.auth.getSession();
      
      if (error) {
        setStatus('error');
        setMessage(`Authentication failed: ${error.message}`);
        return;
      }
      
      if (session) {
        setStatus('success');
        setMessage('Authentication successful! Redirecting...');
        
        // Redirect to home after brief delay
        setTimeout(() => {
          window.location.href = '/';
        }, 1500);
      } else {
        // No session - check if there's a code in URL to exchange
        const params = new URLSearchParams(window.location.search);
        const code = params.get('code');
        
        if (code) {
          // Exchange code for session
          const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);
          
          if (exchangeError) {
            setStatus('error');
            setMessage(`Authentication failed: ${exchangeError.message}`);
          } else {
            setStatus('success');
            setMessage('Authentication successful! Redirecting...');
            setTimeout(() => {
              window.location.href = '/';
            }, 1500);
          }
        } else {
          setStatus('error');
          setMessage('No authentication code found. Please try signing in again.');
        }
      }
    };

    handleCallback();
  }, []);

  return (
    <main className="ow-shell">
      <div className="ow-ambient" aria-hidden>
        <span className="ow-blob ow-blob-one" />
        <span className="ow-blob ow-blob-two" />
        <span className="ow-blob ow-blob-three" />
      </div>

      <header className="ow-brand">
        <span className="ow-brand-icon" aria-hidden>
          <span className="ow-brand-icon-core" />
        </span>
        <span className="ow-brand-text">OpenWork</span>
      </header>

      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: '1rem',
        padding: '2rem',
        textAlign: 'center',
      }}>
        {status === 'loading' && (
          <div style={{
            width: '48px',
            height: '48px',
            border: '3px solid rgba(255,255,255,0.2)',
            borderTopColor: '#fff',
            borderRadius: '50%',
            animation: 'spin 1s linear infinite',
          }} />
        )}
        
        {status === 'success' && (
          <div style={{
            fontSize: '48px',
          }}>
            ✓
          </div>
        )}
        
        {status === 'error' && (
          <div style={{
            fontSize: '48px',
            color: '#ef4444',
          }}>
            ✕
          </div>
        )}
        
        <p style={{ color: '#fff', fontSize: '1.125rem' }}>
          {message}
        </p>
      </div>
      
      <style jsx global>{`
        @keyframes spin {
          to { transform: rotate(360deg); }
        }
      `}</style>
    </main>
  );
}
