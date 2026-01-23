// dashboard.js - Enhanced with loading states and error handling
(() => {
  // ======================
  // SUPABASE CLIENT
  // ======================
  const supabaseClient = window.supabaseClient;

  if (!supabaseClient) {
    console.error('❌ Supabase not initialized!');
    window.location.href = '../auth/login.html';
    return;
  }

  // ======================
  // DOM ELEMENTS
  // ======================
  const usernameEl = document.getElementById('username');
  const userLevelEl = document.getElementById('userLevel');
  const userXPEl = document.getElementById('userXP');
  const userCoinsEl = document.getElementById('userCoins');
  const userHintsEl = document.getElementById('userHints');
  const logoutBtn = document.getElementById('logoutBtn');

  let currentUser = null;
  let userProfile = null;

  // ======================
  // LOADING STATE
  // ======================
  function showLoading(show = true) {
    const container = document.querySelector('.dashboard-container');
    if (!container) return;

    if (show) {
      container.style.opacity = '0.5';
      container.style.pointerEvents = 'none';
    } else {
      container.style.opacity = '1';
      container.style.pointerEvents = 'auto';
    }
  }

  // ======================
  // ERROR NOTIFICATION
  // ======================
  function showError(message) {
    console.error('❌', message);
    
    // Create toast notification
    const toast = document.createElement('div');
    toast.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      background: #F56565;
      color: white;
      padding: 16px 24px;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      z-index: 9999;
      animation: slideIn 0.3s ease;
    `;
    toast.textContent = message;
    document.body.appendChild(toast);

    setTimeout(() => {
      toast.style.animation = 'slideOut 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 4000);
  }

  // ======================
  // CHECK AUTHENTICATION
  // ======================
  async function checkAuthentication() {
    try {
      const { data: { session }, error } = await supabaseClient.auth.getSession();

      if (error) throw error;

      if (!session) {
        console.log('No session found, redirecting to login...');
        window.location.href = '../auth/login.html';
        return false;
      }

      currentUser = session.user;
      console.log('✅ User authenticated:', currentUser.email);
      return true;
    } catch (error) {
      console.error('❌ Auth error:', error);
      showError('Authentication failed. Please log in again.');
      
      setTimeout(() => {
        window.location.href = '../auth/login.html';
      }, 2000);
      
      return false;
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

    console.log('Updating dashboard UI...');

    // Update username
    if (usernameEl) {
      usernameEl.textContent = userProfile.username || 'Student';
    }

    // Update stats
    if (userLevelEl) userLevelEl.textContent = userProfile.level || 1;
    if (userXPEl) userXPEl.textContent = (userProfile.xp || 0).toLocaleString();
    if (userCoinsEl) userCoinsEl.textContent = (userProfile.brain_coins || 0).toLocaleString();
    if (userHintsEl) userHintsEl.textContent = userProfile.hint_tokens || 5;

    updateLevelProgress();
    animateDashboardStats();
    
    // Show teacher-specific content if user is a teacher
    if (userProfile.role === 'teacher') {
      showTeacherDashboard();
    } else {
      showStudentDashboard();
    }
  }
  
  // ======================
  // TEACHER DASHBOARD
  // ======================
  function showTeacherDashboard() {
    const quickActionsGrid = document.querySelector('.quick-actions');
    if (!quickActionsGrid) return;
    
    // Add teacher-specific action cards
    const teacherCard = document.createElement('a');
    teacherCard.href = 'classroom/dashboard.html';
    teacherCard.className = 'action-card teacher-only';
    teacherCard.innerHTML = `
      <div class="action-icon" style="background: linear-gradient(135deg, #10B981 0%, #34D399 100%);">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
          <circle cx="9" cy="7" r="4"/>
          <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
          <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
        </svg>
      </div>
      <h3 class="action-title">My Classrooms</h3>
      <p class="action-description">Manage your classes and students</p>
    `;
    
    // Insert teacher card at the beginning
    quickActionsGrid.insertBefore(teacherCard, quickActionsGrid.firstChild);
    
    // Update welcome message
    const welcomeTitle = document.querySelector('.welcome-title');
    if (welcomeTitle) {
      welcomeTitle.innerHTML = `Welcome back, <span id="username">${userProfile.username}</span>! 👨‍🏫`;
    }
    
    console.log('✅ Teacher dashboard loaded');
  }
  
  // ======================
  // STUDENT DASHBOARD
  // ======================
  function showStudentDashboard() {
    // Remove any teacher-only elements that might exist
    const teacherElements = document.querySelectorAll('.teacher-only');
    teacherElements.forEach(el => el.remove());
    
    console.log('✅ Student dashboard loaded');
  }
  // ======================
  // LOAD USER PROFILE
  // ======================
  async function loadUserProfile(retryCount = 0) {
    if (!currentUser) return;

    try {
      showLoading(true);
      
      const { data, error } = await supabaseClient
        .from('users')
        .select('*')
        .eq('id', currentUser.id)
        .single();

      if (error) {
        // Profile doesn't exist - create it
        if (error.code === 'PGRST116') {
          console.log('Profile not found, creating new profile...');
          await createUserProfile();
          return;
        }
        
        // RLS policy error - might need to wait for trigger
        if (error.message?.includes('row-level security') && retryCount < 3) {
          console.log(`RLS policy issue, retrying... (${retryCount + 1}/3)`);
          await new Promise(resolve => setTimeout(resolve, 1000));
          return loadUserProfile(retryCount + 1);
        }
        
        throw error;
      }

      userProfile = data;
      console.log('✅ Profile loaded:', userProfile);
      updateDashboardUI();
      showLoading(false);
      
    } catch (error) {
      console.error('❌ Error loading profile:', error);
      showError('Failed to load profile data. Please refresh the page.');
      showLoading(false);
    }
  }

  // ======================
  // CREATE USER PROFILE
  // ======================
  async function createUserProfile() {
    try {
      console.log('Creating profile for user:', currentUser.id);
      
      const profileData = {
        id: currentUser.id,
        email: currentUser.email,
        username: currentUser.user_metadata?.username || currentUser.email.split('@')[0],
        role: currentUser.user_metadata?.role || 'student',
        year_group: currentUser.user_metadata?.year_group || null,
        xp: 0,
        level: 1,
        brain_coins: 0,
        hint_tokens: 5
      };

      const { data, error } = await supabaseClient
        .from('users')
        .insert(profileData)
        .select()
        .single();

      if (error) {
        // Profile might have been created by trigger
        if (error.code === '23505') { // Unique constraint violation
          console.log('Profile already exists, fetching...');
          await loadUserProfile();
          return;
        }
        throw error;
      }

      userProfile = data;
      console.log('✅ Profile created:', userProfile);
      updateDashboardUI();
      showLoading(false);
      
    } catch (error) {
      console.error('❌ Error creating profile:', error);
      showError('Failed to create user profile. Please contact support.');
      showLoading(false);
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

    console.log('Updating dashboard UI...');

    // Update username
    if (usernameEl) {
      usernameEl.textContent = userProfile.username || 'Student';
    }

    // Update stats
    if (userLevelEl) userLevelEl.textContent = userProfile.level || 1;
    if (userXPEl) userXPEl.textContent = (userProfile.xp || 0).toLocaleString();
    if (userCoinsEl) userCoinsEl.textContent = (userProfile.brain_coins || 0).toLocaleString();
    if (userHintsEl) userHintsEl.textContent = userProfile.hint_tokens || 5;

    updateLevelProgress();
    animateDashboardStats();
  }

  // ======================
  // LEVEL PROGRESS
  // ======================
  function updateLevelProgress() {
    if (!userProfile) return;
    
    const level = userProfile.level || 1;
    const xp = userProfile.xp || 0;

    // XP formula: (level - 1)^2 * 100
    const currentLevelXP = (level - 1) ** 2 * 100;
    const nextLevelXP = level ** 2 * 100;

    const xpInLevel = xp - currentLevelXP;
    const xpNeeded = nextLevelXP - currentLevelXP;
    const progress = Math.max(0, Math.min(100, (xpInLevel / xpNeeded) * 100));

    const bar = document.querySelector('.progress-bar-fill');
    if (bar) {
      bar.style.width = `${progress}%`;
    }

    const label = document.querySelector('.progress-label');
    if (label) {
      label.innerHTML = `
        <span>Level ${level}</span>
        <span>${xpInLevel} / ${xpNeeded} XP</span>
      `;
    }
  }

  // ======================
  // DASHBOARD-ONLY STAT ANIMATION
  // ======================
  function animateDashboardStats() {
    const statCards = document.querySelectorAll('.stat-card');
    
    statCards.forEach((card, i) => {
      card.style.opacity = '0';
      card.style.transform = 'translateY(20px)';

      setTimeout(() => {
        card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        card.style.opacity = '1';
        card.style.transform = 'translateY(0)';
      }, i * 100);
    });
  }

  // ======================
  // LOGOUT
  // ======================
  async function handleLogout() {
    try {
      showLoading(true);
      
      const { error } = await supabaseClient.auth.signOut();
      if (error) throw error;

      localStorage.removeItem('rememberMe');
      
      // Show success message briefly before redirect
      console.log('✅ Logged out successfully');
      
      setTimeout(() => {
        window.location.href = '../index.html';
      }, 500);
      
    } catch (error) {
      console.error('❌ Logout error:', error);
      showError('Failed to log out. Please try again.');
      showLoading(false);
    }
  }

  // ======================
  // INIT
  // ======================
  async function init() {
    console.log('🚀 Initializing dashboard...');
    
    const isAuth = await checkAuthentication();
    if (!isAuth) return;

    await loadUserProfile();
  }

  // ======================
  // EVENT LISTENERS
  // ======================
  if (logoutBtn) {
    logoutBtn.addEventListener('click', handleLogout);
  }

  // Initialize on page load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    // DOM already loaded
    init();
  }

  // Auth state listener
  supabaseClient.auth.onAuthStateChange((event, session) => {
    console.log('Auth state changed:', event);
    
    if (event === 'SIGNED_OUT') {
      window.location.href = '../auth/login.html';
    } else if (event === 'SIGNED_IN' && !userProfile) {
      // User just signed in, load profile
      loadUserProfile();
    }
  });

  // Add CSS for animations
  const style = document.createElement('style');
  style.textContent = `
    @keyframes slideIn {
      from {
        transform: translateX(400px);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }
    @keyframes slideOut {
      from {
        transform: translateX(0);
        opacity: 1;
      }
      to {
        transform: translateX(400px);
        opacity: 0;
      }
    }
  `;
  document.head.appendChild(style);
})();