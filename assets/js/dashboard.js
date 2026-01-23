// Dashboard JavaScript - FIXED VERSION

// Get Supabase client from global scope
const supabase = window.supabaseClient || window.supabase?.createClient(
    'https://qqbyxydxxcuklakvjlfr.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxYnl4eWR4eGN1a2xha3ZqbGZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMjg2MTYsImV4cCI6MjA4NDYwNDYxNn0.2I-uy7ghGa6Ou7uuzDfpYbd75qrNivlBEQBthilYHxw'
);

// Check if Supabase is available
if (!supabase) {
    console.error('Supabase client not found! Redirecting to login...');
    window.location.href = '../auth/login.html';
}

// DOM Elements
const usernameEl = document.getElementById('username');
const userLevelEl = document.getElementById('userLevel');
const userXPEl = document.getElementById('userXP');
const userCoinsEl = document.getElementById('userCoins');
const userHintsEl = document.getElementById('userHints');
const logoutBtn = document.getElementById('logoutBtn');
const loadingOverlay = document.getElementById('loadingOverlay');

// Current user data
let currentUser = null;
let userProfile = null;

// ======================
// AUTHENTICATION CHECK
// ======================
async function checkAuthentication() {
    try {
        console.log('Checking authentication...');
        
        const { data: { session }, error } = await supabase.auth.getSession();
        
        if (error) {
            console.error('Session error:', error);
            throw error;
        }
        
        if (!session) {
            console.log('No session found, redirecting to login...');
            window.location.href = '../auth/login.html';
            return false;
        }

        console.log('Session found:', session.user.email);
        currentUser = session.user;
        return true;
    } catch (error) {
        console.error('Auth check error:', error);
        window.location.href = '../auth/login.html';
        return false;
    }
}

// ======================
// LOAD USER PROFILE
// ======================
async function loadUserProfile() {
    if (!currentUser) {
        console.error('No current user!');
        return;
    }

    try {
        console.log('Loading user profile for:', currentUser.id);
        
        const { data, error } = await supabase
            .from('users')
            .select('*')
            .eq('id', currentUser.id)
            .single();

        if (error) {
            console.error('Error loading profile:', error);
            
            // If profile doesn't exist, create it
            if (error.code === 'PGRST116') {
                console.log('Profile not found, creating...');
                await createUserProfile();
                return;
            }
            throw error;
        }

        console.log('Profile loaded successfully:', data);
        userProfile = data;
        updateDashboardUI();
        
    } catch (error) {
        console.error('Error in loadUserProfile:', error);
        // Show error to user but don't redirect
        alert('Error loading profile. Please refresh the page.');
    }
}

// ======================
// CREATE USER PROFILE (if missing)
// ======================
async function createUserProfile() {
    try {
        console.log('Creating user profile...');
        
        const { data, error } = await supabase
            .from('users')
            .insert({
                id: currentUser.id,
                email: currentUser.email,
                username: currentUser.user_metadata?.username || currentUser.email.split('@')[0],
                role: currentUser.user_metadata?.role || 'student',
                year_group: currentUser.user_metadata?.year_group || null,
                xp: 0,
                level: 1,
                brain_coins: 0,
                hint_tokens: 5
            })
            .select()
            .single();

        if (error) {
            console.error('Error creating profile:', error);
            throw error;
        }

        console.log('Profile created successfully:', data);
        userProfile = data;
        updateDashboardUI();
        
    } catch (error) {
        console.error('Error creating user profile:', error);
        alert('Error creating profile. Please try logging in again.');
    }
}

// ======================
// UPDATE DASHBOARD UI
// ======================
function updateDashboardUI() {
    if (!userProfile) {
        console.warn('No user profile to display');
        return;
    }

    console.log('Updating dashboard UI with profile:', userProfile);

    // Update username
    if (usernameEl) {
        usernameEl.textContent = userProfile.username || 'Student';
    }

    // Update stats
    if (userLevelEl) userLevelEl.textContent = userProfile.level || 1;
    if (userXPEl) userXPEl.textContent = (userProfile.xp || 0).toLocaleString();
    if (userCoinsEl) userCoinsEl.textContent = (userProfile.brain_coins || 0).toLocaleString();
    if (userHintsEl) userHintsEl.textContent = userProfile.hint_tokens || 5;

    // Calculate XP progress to next level
    updateLevelProgress();

    // Animate stat cards
    animateStats();
}

// ======================
// CALCULATE LEVEL PROGRESS
// ======================
function updateLevelProgress() {
    if (!userProfile) return;
    
    const currentLevel = userProfile.level || 1;
    const currentXP = userProfile.xp || 0;
    
    // Calculate XP needed for current and next level
    const currentLevelXP = ((currentLevel - 1) * (currentLevel - 1)) * 100;
    const nextLevelXP = (currentLevel * currentLevel) * 100;
    
    // Calculate progress percentage
    const xpInCurrentLevel = currentXP - currentLevelXP;
    const xpNeededForLevel = nextLevelXP - currentLevelXP;
    const progressPercentage = Math.max(0, Math.min(100, (xpInCurrentLevel / xpNeededForLevel) * 100));

    console.log('Level progress:', {
        currentLevel,
        currentXP,
        xpInCurrentLevel,
        xpNeededForLevel,
        progressPercentage
    });

    // Update progress bar
    const progressBar = document.querySelector('.progress-bar-fill');
    if (progressBar) {
        progressBar.style.width = progressPercentage + '%';
    }

    // Update progress label
    const progressLabel = document.querySelector('.progress-label');
    if (progressLabel) {
        progressLabel.innerHTML = `
            <span>Level ${currentLevel}</span>
            <span>${xpInCurrentLevel} / ${xpNeededForLevel} XP</span>
        `;
    }
}

// ======================
// ANIMATE STATS
// ======================
function animateStats() {
    const statValues = document.querySelectorAll('.stat-value');
    
    statValues.forEach((stat, index) => {
        // Add entrance animation
        stat.style.opacity = '0';
        stat.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            stat.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            stat.style.opacity = '1';
            stat.style.transform = 'translateY(0)';
        }, index * 100);
    });
}

// ======================
// LOAD RECENT ACTIVITY
// ======================
async function loadRecentActivity() {
    if (!currentUser) return;

    try {
        // Fetch recent quizzes
        const { data: recentQuizzes, error } = await supabase
            .from('quizzes')
            .select('*, subjects(name)')
            .eq('user_id', currentUser.id)
            .order('completed_at', { ascending: false })
            .limit(5);

        if (error) {
            console.error('Error loading activity:', error);
            return;
        }

        if (recentQuizzes && recentQuizzes.length > 0) {
            displayRecentActivity(recentQuizzes);
        }
    } catch (error) {
        console.error('Error loading recent activity:', error);
    }
}

// ======================
// DISPLAY RECENT ACTIVITY
// ======================
function displayRecentActivity(activities) {
    const activityList = document.getElementById('activityList');
    if (!activityList || !activities || activities.length === 0) return;

    activityList.innerHTML = activities.map(activity => `
        <div class="activity-item">
            <div class="activity-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"/>
                    <polyline points="12 6 12 12 16 14"/>
                </svg>
            </div>
            <div class="activity-content">
                <div class="activity-title">
                    Completed ${activity.subjects?.name || 'Quiz'} - Score: ${activity.score}/${activity.total_questions}
                </div>
                <div class="activity-time">
                    ${formatTimeAgo(activity.completed_at)}
                </div>
            </div>
            <div class="activity-xp">
                +${activity.xp_earned} XP
            </div>
        </div>
    `).join('');
    
    // Show the activity section
    const activitySection = document.querySelector('.recent-activity');
    if (activitySection) {
        activitySection.style.display = 'block';
    }
}

// ======================
// FORMAT TIME AGO
// ======================
function formatTimeAgo(timestamp) {
    const now = new Date();
    const then = new Date(timestamp);
    const seconds = Math.floor((now - then) / 1000);

    if (seconds < 60) return 'Just now';
    if (seconds < 3600) return Math.floor(seconds / 60) + ' minutes ago';
    if (seconds < 86400) return Math.floor(seconds / 3600) + ' hours ago';
    if (seconds < 604800) return Math.floor(seconds / 86400) + ' days ago';
    
    return then.toLocaleDateString();
}

// ======================
// LOGOUT FUNCTION
// ======================
async function handleLogout() {
    try {
        console.log('Logging out...');
        
        const { error } = await supabase.auth.signOut();
        
        if (error) throw error;

        // Clear local storage
        localStorage.removeItem('rememberMe');
        
        console.log('Logout successful');
        
        // Redirect to home page
        window.location.href = '../index.html';
    } catch (error) {
        console.error('Logout error:', error);
        alert('Failed to log out. Please try again.');
    }
}

// ======================
// HIDE LOADING OVERLAY
// ======================
function hideLoading() {
    console.log('Hiding loading overlay...');
    if (loadingOverlay) {
        loadingOverlay.classList.add('hidden');
    }
}

// ======================
// INITIALIZE DASHBOARD
// ======================
async function initializeDashboard() {
    console.log('=== Initializing dashboard ===');

    try {
        // Check authentication
        const isAuthenticated = await checkAuthentication();
        if (!isAuthenticated) {
            console.log('Not authenticated, stopping initialization');
            return;
        }

        // Load user profile
        await loadUserProfile();

        // Load recent activity (optional)
        await loadRecentActivity();

        // Hide loading overlay
        hideLoading();

        console.log('=== Dashboard initialized successfully! ===');
    } catch (error) {
        console.error('Error initializing dashboard:', error);
        hideLoading();
        alert('Error loading dashboard. Please try refreshing the page.');
    }
}

// ======================
// EVENT LISTENERS
// ======================
if (logoutBtn) {
    logoutBtn.addEventListener('click', handleLogout);
}

// Add click handlers for action cards
document.querySelectorAll('.action-card').forEach(card => {
    card.addEventListener('click', (e) => {
        console.log('Navigating to:', card.href);
    });
});

// ======================
// RUN ON PAGE LOAD
// ======================
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded, initializing dashboard...');
    initializeDashboard();
});

// Listen for auth state changes
if (supabase && supabase.auth) {
    supabase.auth.onAuthStateChange((event, session) => {
        console.log('Auth state changed:', event, session ? 'User logged in' : 'No session');
        
        if (event === 'SIGNED_OUT') {
            window.location.href = '../auth/login.html';
        }
    });
}