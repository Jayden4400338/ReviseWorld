
        // Check authentication before loading page
        (async function checkAuth() {
            try {
                const { data: { session }, error } = await window.supabaseClient.auth.getSession();
                
                if (error) throw error;
                
                if (!session) {
                    console.log('No session found, redirecting to login...');
                    window.location.href = '../auth/login.html';
                    return;
                }
                
                console.log('✅ User authenticated:', session.user.email);
            } catch (error) {
                console.error('❌ Auth check failed:', error);
                window.location.href = '../auth/login.html';
            }
        })();

