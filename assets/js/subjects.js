   // Subject icon mapping
        const subjectIcons = {
            'english': 'fa-book',
            'mathematics': 'fa-calculator',
            'science': 'fa-flask',
            'geography': 'fa-globe',
            'history': 'fa-scroll',
            'art': 'fa-palette',
            'computer-science': 'fa-laptop',
            'languages': 'fa-language'
        };

        // Subject color mapping (for gradients)
        const subjectColors = {
            'english': { primary: '#EF4444', secondary: '#F87171' },
            'mathematics': { primary: '#3B82F6', secondary: '#60A5FA' },
            'science': { primary: '#10B981', secondary: '#34D399' },
            'geography': { primary: '#14B8A6', secondary: '#2DD4BF' },
            'history': { primary: '#F59E0B', secondary: '#FBBF24' },
            'art': { primary: '#EC4899', secondary: '#F472B6' },
            'computer-science': { primary: '#8B5CF6', secondary: '#A78BFA' },
            'languages': { primary: '#06B6D4', secondary: '#22D3EE' }
        };

        let allSubjects = [];
        let currentFilter = 'all';

        // Load subjects from database
        async function loadSubjects() {
            const loadingState = document.getElementById('loadingState');
            const errorState = document.getElementById('errorState');
            const subjectsGrid = document.getElementById('subjectsGrid');

            try {
                loadingState.style.display = 'flex';
                errorState.style.display = 'none';
                subjectsGrid.innerHTML = '';

                const { data, error } = await window.supabaseClient
                    .from('subjects')
                    .select('*')
                    .order('name', { ascending: true });

                if (error) throw error;

                allSubjects = data;
                loadingState.style.display = 'none';
                
                if (data.length === 0) {
                    subjectsGrid.innerHTML = '<p class="no-results">No subjects found. Please contact support.</p>';
                    return;
                }

                renderSubjects(data);

            } catch (error) {
                console.error('Error loading subjects:', error);
                loadingState.style.display = 'none';
                errorState.style.display = 'flex';
            }
        }

        // Render subjects to the grid
        function renderSubjects(subjects) {
            const subjectsGrid = document.getElementById('subjectsGrid');
            
            if (subjects.length === 0) {
                subjectsGrid.innerHTML = '<p class="no-results">No subjects match your filter</p>';
                return;
            }

            subjectsGrid.innerHTML = subjects.map(subject => {
                const icon = subjectIcons[subject.slug] || 'fa-book';
                const colors = subjectColors[subject.slug] || { primary: '#A78BFA', secondary: '#C4B5FD' };
                
                return `
                    <div class="subject-card" data-slug="${subject.slug}">
                        <div class="subject-icon" style="background: linear-gradient(135deg, ${colors.primary} 0%, ${colors.secondary} 100%);">
                            <i class="fa-solid ${icon}"></i>
                        </div>
                        <h3 class="subject-name">${subject.name}</h3>
                        <p class="subject-description">${subject.description}</p>
                        
                        <div class="subject-stats">
                            <div class="stat-item">
                                <i class="fa-solid fa-file-lines"></i>
                                <span>Past Papers</span>
                            </div>
                            <div class="stat-item">
                                <i class="fa-solid fa-circle-question"></i>
                                <span>Quizzes</span>
                            </div>
                            <div class="stat-item">
                                <i class="fa-solid fa-book-open"></i>
                                <span>Guides</span>
                            </div>
                        </div>

                        <div class="year-groups-badge">
                            ${subject.year_groups.map(yg => `<span class="year-badge">${yg}</span>`).join('')}
                        </div>

                        <div class="subject-actions">
                            <a href="../subjects/${subject.slug}.html" class="btn btn-primary btn-small">
                                Explore Subject
                                <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                `;
            }).join('');

            // Add animation to cards
            animateCards();
        }

        // Filter subjects by year group
        function filterSubjects(yearGroup) {
            currentFilter = yearGroup;

            if (yearGroup === 'all') {
                renderSubjects(allSubjects);
            } else {
                const filtered = allSubjects.filter(subject => 
                    subject.year_groups.includes(yearGroup)
                );
                renderSubjects(filtered);
            }

            // Update active filter button
            document.querySelectorAll('.filter-btn').forEach(btn => {
                btn.classList.remove('active');
                if (btn.dataset.filter === yearGroup) {
                    btn.classList.add('active');
                }
            });
        }

        // Animate cards on load
        function animateCards() {
            const cards = document.querySelectorAll('.subject-card');
            cards.forEach((card, index) => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0)';
                }, index * 100);
            });
        }

        // Event listeners
        document.addEventListener('DOMContentLoaded', () => {
            loadSubjects();

            // Filter buttons
            document.querySelectorAll('.filter-btn').forEach(btn => {
                btn.addEventListener('click', () => {
                    filterSubjects(btn.dataset.filter);
                });
            });
        });