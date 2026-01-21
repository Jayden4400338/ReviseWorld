// Dashboard JavaScript

// Get Supabase client (initialized in HTML)
const supabase = window.supabaseClient || window.supabase;

// Check if Supabase is available
if (!supabase) {
    console.error('Supabase client not found! Make sure it is initialized in the HTML.');
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
        const { data: { session } } = await supabase.auth.getSession();
        
        if (!session) {
            console.log('No session found, redirecting to login...');
            window.location.href = '../auth/login.html';
            return false;
        }

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
    if (!currentUser) return;

    try {
        const { data, error } = await supabase
            .from('users')
            .select('*')
            .eq('id', currentUser.id)
            .single();

        if (error) throw error;

        userProfile = data;
        updateDashboardUI();
        
        console.log('User profile loaded:', userProfile);
    } catch (error) {
        console.error('Error loading user profile:', error);
        
        // If profile doesn't exist, create it
        if (error.code === 'PGRST116') {
            await createUserProfile();
        }
    }
}

// ======================
// CREATE USER PROFILE (if missing)
// ======================
async function createUserProfile() {
    try {
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

        if (error) throw error;

        userProfile = data;
        updateDashboardUI();
        
        console.log('User profile created:', userProfile);
    } catch (error) {
        console.error('Error creating user profile:', error);
    }
}

// ======================
// UPDATE DASHBOARD UI
// ======================
function updateDashboardUI() {
    if (!userProfile) return;

    // Update username
    usernameEl.textContent = userProfile.username;

    // Update stats
    userLevelEl.textContent = userProfile.level;
    userXPEl.textContent = userProfile.xp.toLocaleString();
    userCoinsEl.textContent = userProfile.brain_coins.toLocaleString();
    userHintsEl.textContent = userProfile.hint_tokens;

    // Calculate XP progress to next level
    updateLevelProgress();

    // Animate stat cards
    animateStats();
}

// ======================
// CALCULATE LEVEL PROGRESS
// ======================
function updateLevelProgress() {
    const currentLevel = userProfile.level;
    const currentXP = userProfile.xp;
    
    // Calculate XP needed for current and next level
    const currentLevelXP = ((currentLevel - 1) * (currentLevel - 1)) * 100;
    const nextLevelXP = (currentLevel * currentLevel) * 100;
    
    // Calculate progress percentage
    const xpInCurrentLevel = currentXP - currentLevelXP;
    const xpNeededForLevel = nextLevelXP - currentLevelXP;
    const progressPercentage = (xpInCurrentLevel / xpNeededForLevel) * 100;

    // Update progress bar if it exists
    const progressBar = document.querySelector('.progress-bar-fill');
    if (progressBar) {
        progressBar.style.width = Math.min(progressPercentage, 100) + '%';
    }

    // Update progress label if it exists
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

        if (error) throw error;

        displayRecentActivity(recentQuizzes);
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
        const { error } = await supabase.auth.signOut();
        
        if (error) throw error;

        // Clear local storage
        localStorage.removeItem('rememberMe');
        
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
    if (loadingOverlay) {
        loadingOverlay.classList.add('hidden');
    }
}

// ======================
// INITIALIZE DASHBOARD
// ======================
async function initializeDashboard() {
    console.log('Initializing dashboard...');

    // Check authentication
    const isAuthenticated = await checkAuthentication();
    if (!isAuthenticated) return;

    // Load user profile
    await loadUserProfile();

    // Load recent activity (optional)
    await loadRecentActivity();

    // Hide loading overlay
    hideLoading();

    console.log('Dashboard initialized successfully!');
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
        // Add ripple effect or animation here if desired
        console.log('Navigating to:', card.href);
    });
});

// ======================
// RUN ON PAGE LOAD
// ======================
document.addEventListener('DOMContentLoaded', initializeDashboard);

// Listen for auth state changes
supabase.auth.onAuthStateChange((event, session) => {
    console.log('Auth state changed:', event);
    
    if (event === 'SIGNED_OUT') {
        window.location.href = '../auth/login.html';
    }
});