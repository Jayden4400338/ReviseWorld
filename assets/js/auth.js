// Authentication Functions for BrainMapRevision

// Get Supabase client from global scope
const supabase = window.supabaseClient;

// ======================
// SIGN UP
// ======================
const signupForm = document.getElementById('signupForm');
if (signupForm) {
    // Show/hide year group based on role selection
    const roleInputs = document.querySelectorAll('input[name="role"]');
    const yearGroupSection = document.getElementById('yearGroupSection');
    
    roleInputs.forEach(input => {
        input.addEventListener('change', (e) => {
            if (e.target.value === 'student') {
                yearGroupSection.style.display = 'block';
            } else {
                yearGroupSection.style.display = 'none';
            }
        });
    });

    signupForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const username = document.getElementById('username').value.trim();
        const email = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const role = document.querySelector('input[name="role"]:checked').value;
        const yearGroup = document.getElementById('yearGroup').value;
        
        const errorMessage = document.getElementById('errorMessage');
        const submitBtn = document.getElementById('submitBtn');
        
        // Clear previous errors
        errorMessage.style.display = 'none';
        
        // Validation
        if (password !== confirmPassword) {
            showError('Passwords do not match');
            return;
        }
        
        if (password.length < 8) {
            showError('Password must be at least 8 characters long');
            return;
        }
        
        if (role === 'student' && !yearGroup) {
            showError('Please select your year group');
            return;
        }
        
        // Show loading state
        submitBtn.classList.add('btn-loading');
        submitBtn.disabled = true;
        
        try {
            // Sign up with Supabase
            const { data, error } = await supabase.auth.signUp({
                email: email,
                password: password,
                options: {
                    data: {
                        username: username,
                        role: role,
                        year_group: role === 'student' ? yearGroup : null
                    }
                }
            });
            
            if (error) throw error;
            
            // Create user profile in database
            const { error: profileError } = await supabase
                .from('users')
                .insert({
                    id: data.user.id,
                    email: email,
                    username: username,
                    role: role,
                    year_group: role === 'student' ? yearGroup : null,
                    xp: 0,
                    level: 1,
                    brain_coins: 0,
                    hint_tokens: 5
                });
            
            if (profileError) throw profileError;
            
            // Show success message
            alert('Account created successfully! Please check your email to verify your account.');
            window.location.href = 'login.html';
            
        } catch (error) {
            console.error('Sign up error:', error);
            showError(error.message || 'An error occurred during sign up');
        } finally {
            submitBtn.classList.remove('btn-loading');
            submitBtn.disabled = false;
        }
    });
}

// ======================
// LOGIN
// ======================
const loginForm = document.getElementById('loginForm');
if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const email = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value;
        const rememberMe = document.getElementById('rememberMe').checked;
        
        const errorMessage = document.getElementById('errorMessage');
        const submitBtn = document.getElementById('submitBtn');
        
        // Clear previous errors
        errorMessage.style.display = 'none';
        
        // Show loading state
        submitBtn.classList.add('btn-loading');
        submitBtn.disabled = true;
        
        try {
            // Sign in with Supabase
            const { data, error } = await supabase.auth.signInWithPassword({
                email: email,
                password: password
            });
            
            if (error) throw error;
            
            // Update last login time
            await supabase
                .from('users')
                .update({ last_login: new Date().toISOString() })
                .eq('id', data.user.id);
            
            // Store session if remember me is checked
            if (rememberMe) {
                localStorage.setItem('rememberMe', 'true');
            }
            
            // Redirect to dashboard/home
            window.location.href = '../pages/subjects.html';
            
        } catch (error) {
            console.error('Login error:', error);
            showError('Invalid email or password');
        } finally {
            submitBtn.classList.remove('btn-loading');
            submitBtn.disabled = false;
        }
    });
    
    // Google Sign In
    const googleLoginBtn = document.getElementById('googleLoginBtn');
    if (googleLoginBtn) {
        googleLoginBtn.addEventListener('click', async () => {
            try {
                const { data, error } = await supabase.auth.signInWithOAuth({
                    provider: 'google',
                    options: {
                        redirectTo: window.location.origin + '/pages/subjects.html'
                    }
                });
                
                if (error) throw error;
            } catch (error) {
                console.error('Google login error:', error);
                showError('Google login failed');
            }
        });
    }
}

// ======================
// RESET PASSWORD
// ======================
const resetPasswordForm = document.getElementById('resetPasswordForm');
if (resetPasswordForm) {
    resetPasswordForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const email = document.getElementById('email').value.trim();
        const errorMessage = document.getElementById('errorMessage');
        const successMessage = document.getElementById('successMessage');
        const submitBtn = document.getElementById('submitBtn');
        
        // Clear previous messages
        errorMessage.style.display = 'none';
        successMessage.style.display = 'none';
        
        // Show loading state
        submitBtn.classList.add('btn-loading');
        submitBtn.disabled = true;
        
        try {
            const { error } = await supabase.auth.resetPasswordForEmail(email, {
                redirectTo: window.location.origin + '/auth/reset-password.html'
            });
            
            if (error) throw error;
            
            // Show success message
            successMessage.textContent = 'Password reset link sent! Check your email.';
            successMessage.style.display = 'block';
            
            // Clear form
            resetPasswordForm.reset();
            
        } catch (error) {
            console.error('Password reset error:', error);
            errorMessage.textContent = error.message || 'Failed to send reset link';
            errorMessage.style.display = 'block';
        } finally {
            submitBtn.classList.remove('btn-loading');
            submitBtn.disabled = false;
        }
    });
}

// ======================
// UPDATE PASSWORD (from email link)
// ======================
const updatePasswordForm = document.getElementById('updatePasswordForm');
if (updatePasswordForm) {
    // Check if user came from password reset link
    const hashParams = new URLSearchParams(window.location.hash.substring(1));
    const accessToken = hashParams.get('access_token');
    const type = hashParams.get('type');
    
    if (type === 'recovery' && accessToken) {
        // Show update password form instead of reset form
        document.getElementById('resetPasswordForm').style.display = 'none';
        updatePasswordForm.style.display = 'block';
    }
    
    updatePasswordForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const errorMessage = document.getElementById('updateErrorMessage');
        const submitBtn = document.getElementById('updateBtn');
        
        // Clear previous errors
        errorMessage.style.display = 'none';
        
        // Validation
        if (newPassword !== confirmPassword) {
            errorMessage.textContent = 'Passwords do not match';
            errorMessage.style.display = 'block';
            return;
        }
        
        if (newPassword.length < 8) {
            errorMessage.textContent = 'Password must be at least 8 characters long';
            errorMessage.style.display = 'block';
            return;
        }
        
        // Show loading state
        submitBtn.classList.add('btn-loading');
        submitBtn.disabled = true;
        
        try {
            const { error } = await supabase.auth.updateUser({
                password: newPassword
            });
            
            if (error) throw error;
            
            // Show success and redirect
            alert('Password updated successfully! Please log in with your new password.');
            window.location.href = 'login.html';
            
        } catch (error) {
            console.error('Update password error:', error);
            errorMessage.textContent = error.message || 'Failed to update password';
            errorMessage.style.display = 'block';
        } finally {
            submitBtn.classList.remove('btn-loading');
            submitBtn.disabled = false;
        }
    });
}

// ======================
// HELPER FUNCTIONS
// ======================
function showError(message) {
    const errorMessage = document.getElementById('errorMessage');
    if (errorMessage) {
        errorMessage.textContent = message;
        errorMessage.style.display = 'block';
    }
}

// Check if user is already logged in
async function checkAuth() {
    const { data: { session } } = await supabase.auth.getSession();
    
    if (session) {
        // User is logged in, redirect to dashboard
        const currentPage = window.location.pathname;
        if (currentPage.includes('login.html') || currentPage.includes('signup.html')) {
            window.location.href = '../pages/subjects.html';
        }
    }
}

// Get current user
async function getCurrentUser() {
    const { data: { user } } = await supabase.auth.getUser();
    return user;
}

// Get user profile from database
async function getUserProfile(userId) {
    const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .single();
    
    if (error) {
        console.error('Error fetching user profile:', error);
        return null;
    }
    
    return data;
}

// Sign out
async function signOut() {
    const { error } = await supabase.auth.signOut();
    
    if (!error) {
        localStorage.removeItem('rememberMe');
        window.location.href = '../index.html';
    } else {
        console.error('Sign out error:', error);
    }
}

// Check authentication on page load
document.addEventListener('DOMContentLoaded', () => {
    checkAuth();
});