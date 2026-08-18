// Highlight nav link for the section currently in view
const sections = document.querySelectorAll('main section[id]');
const navLinks = document.querySelectorAll('.nav a');

const setActive = (id) => {
  navLinks.forEach((link) => {
    link.style.color = link.getAttribute('href') === `#${id}` ? '#ffb000' : '';
  });
};

if ('IntersectionObserver' in window && sections.length) {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) setActive(entry.target.id);
      });
    },
    { rootMargin: '-40% 0px -50% 0px', threshold: 0 }
  );
  sections.forEach((section) => observer.observe(section));
}

// Simple fade-in on scroll for project cards
const cards = document.querySelectorAll('.project-card, .status-card');
if ('IntersectionObserver' in window && cards.length) {
  cards.forEach((card) => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(12px)';
    card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
  });

  const revealObserver = new IntersectionObserver(
    (entries, obs) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'translateY(0)';
          obs.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.15 }
  );
  cards.forEach((card) => revealObserver.observe(card));
}