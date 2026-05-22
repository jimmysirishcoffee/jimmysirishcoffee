/**
 * Jimmy's Coffee — Core App Script
 * Brand: Black & White / Monochromatic
 */

if ('scrollRestoration' in history) {
  history.scrollRestoration = 'manual';
}
window.addEventListener('beforeunload', () => window.scrollTo(0, 0));

document.addEventListener('DOMContentLoaded', () => {
  window.scrollTo(0, 0);

  // =========================================================================
  // 1. PRELOADER
  // =========================================================================
  const preloader      = document.getElementById('preloader');
  const loaderLiquid   = document.getElementById('loader-liquid');
  const loaderPct      = document.getElementById('loader-percentage');
  const loaderBarInner = document.getElementById('loader-bar-inner');

  if (preloader) {
    let progress = 0;
    const DURATION  = 1600; // ms
    const TICK      = 16;   // ~60fps
    const increment = 100 / (DURATION / TICK);

    const tick = setInterval(() => {
      progress = Math.min(progress + increment, 100);
      const pct = Math.floor(progress);

      if (loaderPct)      loaderPct.textContent      = `${pct}%`;
      if (loaderBarInner) loaderBarInner.style.width  = `${pct}%`;
      if (loaderLiquid)   loaderLiquid.setAttribute('y', String(90 - (progress / 100) * 60));

      if (progress >= 100) {
        clearInterval(tick);
        setTimeout(() => {
          preloader.style.opacity    = '0';
          preloader.style.visibility = 'hidden';
          setTimeout(() => { preloader.style.display = 'none'; }, 700);
        }, 250);
      }
    }, TICK);
  }


  // =========================================================================
  // 2. TOAST UTILITY
  // =========================================================================
  function showToast(message, icon = '☕') {
    document.querySelector('.toast-notification')?.remove();

    const toast = document.createElement('div');
    toast.className = 'toast-notification';
    toast.innerHTML = `<span class="toast-icon">${icon}</span><span class="toast-message">${message}</span>`;
    document.body.appendChild(toast);

    requestAnimationFrame(() => {
      requestAnimationFrame(() => toast.classList.add('show'));
    });

    setTimeout(() => {
      toast.classList.remove('show');
      setTimeout(() => toast.remove(), 500);
    }, 3500);
  }


  // =========================================================================
  // 3. HEADER SCROLL STATE + PARALLAX HERO rAF DRIVER
  // =========================================================================
  const mainHeader  = document.getElementById('main-header');
  const heroSection = document.getElementById('hero');

  let rafPending = false;

  const onScroll = () => {
    if (rafPending) return;
    rafPending = true;
    requestAnimationFrame(() => {
      rafPending = false;
      const sy = window.scrollY;

      // Header frosted glass / nav reveal at 80px
      if (mainHeader) {
        mainHeader.classList.toggle('scrolled', sy > 80);
      }

      // Parallax: set --scroll-y on the hero section so all layers pick it up
      if (heroSection) {
        heroSection.style.setProperty('--scroll-y', `${sy}px`);
      }
    });
  };

  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll(); // set initial state


  // =========================================================================
  // 4. SECTION ENTRANCE ANIMATIONS — IntersectionObserver
  // =========================================================================
  const entranceObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        entranceObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });

  // Observe section containers (stagger not needed — each is a single element)
  document.querySelectorAll('.section-container').forEach(el => {
    entranceObserver.observe(el);
  });

  // Observe card groups with per-card stagger delay.
  // .location-card and .menu-item-card are also handled by GSAP when available;
  // only register them with IO when GSAP is absent (handled in the GSAP block below).
  const gsapAvailable = typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined';

  const ioCardSelectors = gsapAvailable
    ? ['.hero-feature-card']
    : ['.menu-item-card', '.location-card', '.hero-feature-card'];

  ioCardSelectors.forEach(selector => {
    const cards = document.querySelectorAll(selector);
    cards.forEach((card, i) => {
      card.style.transitionDelay = `${i * 0.1}s`;
      entranceObserver.observe(card);
    });
  });


  // =========================================================================
  // 5. LOCATION HOURS ENGINE — IRELAND TIME (Intl.DateTimeFormat)
  // =========================================================================
  const SCHEDULES = {
    swinford: {
      0: { open: 510,  close: 960  },  // Sun 08:30-16:00
      1: { open: 420,  close: 990  },  // Mon 07:00–16:30
      2: { open: 420,  close: 990  },
      3: { open: 420,  close: 990  },
      4: { open: 420,  close: 990  },
      5: { open: 420,  close: 990  },  // Fri
      6: { open: 510,  close: 1020 },  // Sat 08:30-17:00
    },
    cavan: {
      0: { open: 420,  close: 1020 },  // Daily 07:00-17:00
      1: { open: 420,  close: 1020 },
      2: { open: 420,  close: 1020 },
      3: { open: 420,  close: 1020 },
      4: { open: 420,  close: 1020 },
      5: { open: 420,  close: 1020 },
      6: { open: 420,  close: 1020 },
    },
    tuam: {
      0: { open: 480,  close: 1020 },  // Sun 08:00-17:00
      1: { open: 420,  close: 990  },  // Mon 07:00-16:30
      2: { open: 420,  close: 990  },
      3: { open: 420,  close: 990  },
      4: { open: 420,  close: 990  },
      5: { open: 420,  close: 990  },
      6: { open: 480,  close: 1020 },  // Sat 08:00-17:00
    },
    ballina: {
      0: { open: 510,  close: 1020 },  // Sun 08:30-17:00
      1: { open: 420,  close: 1020 },
      2: { open: 420,  close: 1020 },
      3: { open: 420,  close: 1020 },
      4: { open: 420,  close: 1020 },
      5: { open: 420,  close: 1020 },
      6: { open: 480,  close: 1020 },  // Sat 08:00-17:00
    }
  };

  const DAY_NAMES = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];

  function getIrishTime() {
    try {
      const fmt = new Intl.DateTimeFormat('en-IE', {
        timeZone: 'Europe/Dublin',
        weekday: 'long', hour: '2-digit', minute: '2-digit', hour12: false
      });
      const parts = fmt.formatToParts(new Date());
      const get   = (t) => parts.find(p => p.type === t)?.value ?? '0';
      const dayStr = get('weekday');
      const dayMap = { Sunday:0, Monday:1, Tuesday:2, Wednesday:3, Thursday:4, Friday:5, Saturday:6 };
      const day  = dayMap[dayStr] ?? 0;
      let   hour = parseInt(get('hour'), 10);
      if (hour === 24) hour = 0; // midnight edge case
      const mins = hour * 60 + parseInt(get('minute'), 10);
      return { day, mins };
    } catch {
      const d = new Date();
      return { day: d.getDay(), mins: d.getHours() * 60 + d.getMinutes() };
    }
  }

  function fmtMins(m) {
    return `${String(Math.floor(m / 60)).padStart(2,'0')}:${String(m % 60).padStart(2,'0')}`;
  }

  function highlightActiveDay(cardId, day) {
    const card = document.getElementById(cardId);
    if (!card) return;
    card.querySelectorAll('.hours-row').forEach(r => r.classList.remove('active-day'));
    const isWeekday = day >= 1 && day <= 5;
    if (cardId === 'location-cavan') {
      card.querySelector('[data-day="daily"]')
          ?.classList.add('active-day');
    } else if (cardId === 'location-tuam') {
      card.querySelector(isWeekday ? '[data-day="weekday"]' : '[data-day="weekend"]')
          ?.classList.add('active-day');
    } else {
      const map = { 0: 'sunday', 6: 'saturday' };
      card.querySelector(`[data-day="${isWeekday ? 'weekday' : (map[day] || 'weekend')}"]`)
          ?.classList.add('active-day');
    }
  }

  function updateStatus() {
    const { day, mins } = getIrishTime();

    ['swinford', 'cavan', 'tuam', 'ballina'].forEach(loc => {
      const schedule = SCHEDULES[loc][day];
      const badge    = document.getElementById(`status-${loc}`);
      const dotEl    = badge?.querySelector('.status-dot');
      const textEl   = badge?.querySelector('.status-text');
      if (!badge || !textEl || !dotEl) return;

      const isOpen = mins >= schedule.open && mins < schedule.close;

      badge.classList.toggle('open',   isOpen);
      badge.classList.toggle('closed', !isOpen);

      if (isOpen) {
        dotEl.style.background  = '#22c55e';
        dotEl.style.boxShadow   = '0 0 6px #22c55e';
        textEl.textContent      = 'Open Now';
      } else {
        dotEl.style.background  = '#ef4444';
        dotEl.style.boxShadow   = 'none';
        // Find next opening time
        if (mins < schedule.open) {
          textEl.textContent = `Closed · Opens ${fmtMins(schedule.open)}`;
        } else {
          let dAhead = 1;
          while (dAhead <= 7) {
            const nextDay   = (day + dAhead) % 7;
            const nextSched = SCHEDULES[loc][nextDay];
            if (nextSched) {
              const label = dAhead === 1 ? 'tomorrow' : DAY_NAMES[nextDay];
              textEl.textContent = `Closed · Opens ${label} ${fmtMins(nextSched.open)}`;
              break;
            }
            dAhead++;
          }
        }
      }

      highlightActiveDay(`location-${loc}`, day);
    });
  }

  updateStatus();
  setInterval(updateStatus, 60_000);


  // =========================================================================
  // 6. MENU FILTER — animated card-exit / card-enter
  // =========================================================================
  const filterBtns = document.querySelectorAll('.filter-btn');
  const menuCards  = Array.from(document.querySelectorAll('.menu-item-card'));
  let filterBusy   = false;

  // Set initial state: show only the active tab's category on load
  const initialFilter = document.querySelector('.filter-btn.active')?.dataset.filter;
  if (initialFilter) {
    menuCards.forEach(c => {
      if (c.dataset.category !== initialFilter) c.style.display = 'none';
    });
  }

  filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      if (filterBusy) return;
      filterBusy = true;

      filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const filter = btn.dataset.filter;
      const showing = menuCards.filter(c => c.style.display !== 'none');
      const toShow  = menuCards.filter(c => c.dataset.category === filter);
      const toHide  = menuCards.filter(c => c.dataset.category !== filter);

      // HIDE phase: add .card-exit to all currently visible cards
      showing.forEach(c => c.classList.add('card-exit'));

      setTimeout(() => {
        // After exit transition, hide filtered-out cards and clean up
        toHide.forEach(c => {
          c.style.display = 'none';
          c.classList.remove('card-exit', 'card-enter', 'card-enter--active');
        });
        showing.forEach(c => c.classList.remove('card-exit'));

        // SHOW phase: reveal matching cards and animate them in
        toShow.forEach((c, i) => {
          c.style.display = 'flex';
          c.classList.remove('card-enter--active');
          c.classList.add('card-enter');

          setTimeout(() => {
            requestAnimationFrame(() => c.classList.add('card-enter--active'));
          }, i * 60);
        });

        // Clean enter classes after all transitions settle
        const totalDelay = toShow.length * 60 + 320;
        setTimeout(() => {
          toShow.forEach(c => c.classList.remove('card-enter', 'card-enter--active'));
          filterBusy = false;
        }, totalDelay);

      }, 220);
    });
  });

  function openMenuFilterFromFooter(e, filterButtonId) {
    e.preventDefault();
    const filterButton = document.getElementById(filterButtonId);
    if (filterButton && !filterButton.classList.contains('active')) {
      filterButton.click();
    }
    document.getElementById('menu')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  document.getElementById('footer-hot-coffee-link')?.addEventListener('click', e => {
    openMenuFilterFromFooter(e, 'filter-hot-coffee');
  });

  document.getElementById('footer-bakery-link')?.addEventListener('click', e => {
    openMenuFilterFromFooter(e, 'filter-bakery');
  });


  // =========================================================================
  // 7. CONTACT & NEWSLETTER FORMS
  // =========================================================================
  const contactForm    = document.getElementById('contact-form');
  const contactSuccess = document.getElementById('form-success-msg');

  contactForm?.addEventListener('submit', e => {
    e.preventDefault();
    const btn = document.getElementById('btn-send-message');
    if (btn) { btn.textContent = 'Sending...'; btn.disabled = true; }

    setTimeout(() => {
      if (btn) { btn.textContent = 'Send Message'; btn.disabled = false; }
      contactForm.reset();
      if (contactSuccess) {
        contactSuccess.style.display = 'block';
        setTimeout(() => { contactSuccess.style.display = 'none'; }, 5000);
      }
      showToast('Message sent! We\'ll be in touch soon.', '✉️');
    }, 1000);
  });

  const newsletterForm    = document.getElementById('newsletter-form');
  const newsletterSuccess = document.getElementById('newsletter-success');

  newsletterForm?.addEventListener('submit', e => {
    e.preventDefault();
    const btn = document.getElementById('btn-newsletter-signup');
    if (btn) { btn.textContent = 'Signing up...'; btn.disabled = true; }

    setTimeout(() => {
      if (btn) { btn.textContent = 'Sign Up'; btn.disabled = false; }
      newsletterForm.reset();
      if (newsletterSuccess) {
        newsletterSuccess.style.display = 'block';
        setTimeout(() => { newsletterSuccess.style.display = 'none'; }, 5000);
      }
      showToast('Welcome to the Brew Club!', '🎉');
    }, 900);
  });


  // =========================================================================
  // 8. GSAP PARALLAX SHOWCASE (PINNED VIEWPORT SPLIT-REVEAL SYSTEM)
  // =========================================================================
  if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
    gsap.registerPlugin(ScrollTrigger);

    const beanContainer = document.getElementById('bean-container');
    const beanLeft      = document.getElementById('bean-half-left');
    const beanRight     = document.getElementById('bean-half-right');
    
    const cupBlackLid   = document.getElementById('pcup-black-lid');
    const cupIcedLatte  = document.getElementById('pcup-iced-latte');
    const cupLatteArt   = document.getElementById('pcup-latte-art');
    const cupAlmond     = document.getElementById('pcup-almond');
    
    const cupHalo       = document.getElementById('pcup-halo');
    const shTitle       = document.querySelector('.sh-title');
    const shLabel       = document.querySelector('.sh-label');
    const ambientBeans  = document.getElementById('ambient-beans');

    if (beanContainer && cupBlackLid && cupIcedLatte && cupLatteArt && cupAlmond) {
      const mm = gsap.matchMedia();

      // --- DESKTOP ANIMATION SETUP (> 768px) ---
      mm.add("(min-width: 769px)", () => {
        const pinTimeline = gsap.timeline({
          scrollTrigger: {
            trigger: '#showcase',
            start: 'top top',
            end: '+=280%', // Smooth scrolling length
            scrub: 1.2,
            pin: true,
            anticipatePin: 1
          }
        });

        // --- INITIAL STATE SETUP ---
        gsap.set(beanContainer, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0.9, opacity: 1, rotate: 0 });
        gsap.set(beanLeft, { xPercent: 0, rotate: 0, opacity: 1 });
        gsap.set(beanRight, { xPercent: 0, rotate: 0, opacity: 1 });

        gsap.set(cupBlackLid, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0, opacity: 0, rotate: -20 });
        gsap.set(cupIcedLatte, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0, opacity: 0, rotate: -10 });
        gsap.set(cupLatteArt, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0, opacity: 0, rotate: 10 });
        gsap.set(cupAlmond, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0, opacity: 0, rotate: 20 });
        
        gsap.set(cupHalo, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0.2, opacity: 0 });
        
        if (shTitle) gsap.set(shTitle, { y: 30, opacity: 0 });
        if (shLabel) gsap.set(shLabel, { x: -20, opacity: 0 });

        // --- TIMELINE SEQUENCES ---
        
        // 1. Cinematic Intro: Title/Label Stagger In + Bean Focus
        if (shTitle) pinTimeline.to(shTitle, { y: 0, opacity: 1, duration: 0.7, ease: 'power2.out' }, 0);
        if (shLabel) pinTimeline.to(shLabel, { x: 0, opacity: 1, duration: 0.7, ease: 'power2.out' }, 0.1);
        pinTimeline.to(beanContainer, { scale: 1.15, rotate: 12, duration: 0.8, ease: 'power1.out' }, 0);

        // Spacer to hold focal state
        pinTimeline.to({}, { duration: 0.3 });

        // 2. The Organic Split Reveal
        pinTimeline.to(beanLeft, {
          xPercent: -180,
          rotate: -25,
          opacity: 0,
          duration: 2.0,
          ease: 'power3.inOut'
        }, 'split');

        pinTimeline.to(beanRight, {
          xPercent: 180,
          rotate: 25,
          opacity: 0,
          duration: 2.0,
          ease: 'power3.inOut'
        }, 'split');

        // Simultaneously, the 4 premium cups emerge outward in a gorgeous staggered layout
        pinTimeline.to(cupBlackLid, {
          left: '16%',
          yPercent: -45, // Staggered lower
          scale: 1.05,
          rotate: -6,
          opacity: 1,
          duration: 2.2,
          ease: 'back.out(1.2)'
        }, 'split+=0.1');

        pinTimeline.to(cupIcedLatte, {
          left: '38%',
          yPercent: -55, // Staggered higher
          scale: 1.05,
          rotate: -2,
          opacity: 1,
          duration: 2.2,
          ease: 'back.out(1.2)'
        }, 'split+=0.25');

        pinTimeline.to(cupLatteArt, {
          left: '62%',
          yPercent: -45, // Staggered lower
          scale: 1.05,
          rotate: 2,
          opacity: 1,
          duration: 2.2,
          ease: 'back.out(1.2)'
        }, 'split+=0.4');

        pinTimeline.to(cupAlmond, {
          left: '84%',
          yPercent: -55, // Staggered higher
          scale: 1.05,
          rotate: 6,
          opacity: 1,
          duration: 2.2,
          ease: 'back.out(1.2)'
        }, 'split+=0.55');

        // Halo expands behind emerging cups
        pinTimeline.to(cupHalo, {
          scale: 1.25,
          opacity: 1,
          duration: 2.2,
          ease: 'power2.out'
        }, 'split+=0.2');

        // 3. Ambient Sparks float outwards
        const beans = document.querySelectorAll('.amb-bean');
        beans.forEach((bean, i) => {
          const dirX = i % 2 === 0 ? -90 : 90;
          const dirY = i % 3 === 0 ? -60 : 60;
          pinTimeline.fromTo(bean,
            { scale: 0, opacity: 0, y: 0, x: 0 },
            {
              scale: 1.3,
              opacity: 0.35,
              x: dirX,
              y: dirY,
              rotate: dirX * 1.5,
              duration: 2.0,
              ease: 'power2.out'
            },
            'split+=0.4'
          );
        });

        // 4. Hold reveal state for users to enjoy
        pinTimeline.to({}, { duration: 1.2 });

        // 5. Elegant Fade Out transition
        pinTimeline.to([cupBlackLid, cupIcedLatte, cupLatteArt, cupAlmond, cupHalo, shTitle, shLabel, ambientBeans], {
          opacity: 0,
          scale: 0.95,
          y: -20,
          duration: 1.2,
          ease: 'power2.inOut'
        });
      });

      // --- MOBILE ANIMATION SETUP (<= 768px) ---
      mm.add("(max-width: 768px)", () => {
        const pinTimeline = gsap.timeline({
          scrollTrigger: {
            trigger: '#showcase',
            start: 'top top',
            end: '+=280%',
            scrub: 1.2,
            pin: true,
            anticipatePin: 1
          }
        });

        // --- INITIAL STATE SETUP ---
        gsap.set(beanContainer, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0.75, opacity: 1, rotate: 0 });
        gsap.set(beanLeft, { xPercent: 0, rotate: 0, opacity: 1 });
        gsap.set(beanRight, { xPercent: 0, rotate: 0, opacity: 1 });

        gsap.set(cupBlackLid, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0, opacity: 0, rotate: -15 });
        gsap.set(cupIcedLatte, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0, opacity: 0, rotate: -8 });
        gsap.set(cupLatteArt, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0, opacity: 0, rotate: 8 });
        gsap.set(cupAlmond, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0, opacity: 0, rotate: 15 });
        
        gsap.set(cupHalo, { left: '50%', top: '50%', xPercent: -50, yPercent: -50, scale: 0.2, opacity: 0 });
        
        if (shTitle) gsap.set(shTitle, { y: 20, opacity: 0 });
        if (shLabel) gsap.set(shLabel, { y: -10, opacity: 0 });

        // --- TIMELINE SEQUENCES ---
        
        // 1. Cinematic Intro (Mobile)
        if (shTitle) pinTimeline.to(shTitle, { y: 0, opacity: 1, duration: 0.7, ease: 'power2.out' }, 0);
        if (shLabel) pinTimeline.to(shLabel, { y: 0, opacity: 1, duration: 0.7, ease: 'power2.out' }, 0.1);
        pinTimeline.to(beanContainer, { scale: 0.95, rotate: 10, duration: 0.8, ease: 'power1.out' }, 0);

        pinTimeline.to({}, { duration: 0.3 });

        // 2. The Organic Split (Mobile)
        pinTimeline.to(beanLeft, {
          xPercent: -150,
          rotate: -20,
          opacity: 0,
          duration: 2.0,
          ease: 'power3.inOut'
        }, 'split');

        pinTimeline.to(beanRight, {
          xPercent: 150,
          rotate: 20,
          opacity: 0,
          duration: 2.0,
          ease: 'power3.inOut'
        }, 'split');


        // Staggered horizontal zigzag layout to prevent overlap on narrow screen widths
        pinTimeline.to(cupBlackLid, {
          left: '12%',
          yPercent: -58, // staggered higher
          scale: 0.85,
          rotate: -6,
          opacity: 1,
          duration: 2.2,
          ease: 'back.out(1.2)'
        }, 'split+=0.1');

        pinTimeline.to(cupIcedLatte, {
          left: '37%',
          yPercent: -42, // staggered lower
          scale: 0.85,
          rotate: -2,
          opacity: 1,
          duration: 2.2,
          ease: 'back.out(1.2)'
        }, 'split+=0.25');

        pinTimeline.to(cupLatteArt, {
          left: '63%',
          yPercent: -58, // staggered higher
          scale: 0.85,
          rotate: 2,
          opacity: 1,
          duration: 2.2,
          ease: 'back.out(1.2)'
        }, 'split+=0.4');

        pinTimeline.to(cupAlmond, {
          left: '88%',
          yPercent: -42, // staggered lower
          scale: 0.85,
          rotate: 6,
          opacity: 1,
          duration: 2.2,
          ease: 'back.out(1.2)'
        }, 'split+=0.55');

        // Halo expands behind emerging cups
        pinTimeline.to(cupHalo, {
          scale: 0.85,
          opacity: 0.8,
          duration: 2.2,
          ease: 'power2.out'
        }, 'split+=0.2');

        // 3. Ambient Sparks (Mobile)
        const beans = document.querySelectorAll('.amb-bean');
        beans.forEach((bean, i) => {
          const dirX = i % 2 === 0 ? -45 : 45;
          const dirY = i % 3 === 0 ? -35 : 35;
          pinTimeline.fromTo(bean,
            { scale: 0, opacity: 0, y: 0, x: 0 },
            {
              scale: 1.0,
              opacity: 0.25,
              x: dirX,
              y: dirY,
              rotate: dirX * 1.5,
              duration: 2.0,
              ease: 'power2.out'
            },
            'split+=0.4'
          );
        });

        // 4. Hold reveal state
        pinTimeline.to({}, { duration: 1.2 });

        // 5. Elegant Fade Out
        pinTimeline.to([cupBlackLid, cupIcedLatte, cupLatteArt, cupAlmond, cupHalo, shTitle, shLabel, ambientBeans], {
          opacity: 0,
          scale: 0.8,
          y: -15,
          duration: 1.2,
          ease: 'power2.inOut'
        });
      });
    }

    function bindReplaySection({ trigger, start = 'top 75%', end = 'bottom 25%', items }) {
      items.forEach(item => gsap.set(item.selector, item.hidden));

      const show = () => {
        items.forEach(item => {
          gsap.to(item.selector, {
            ...item.visible,
            duration: item.duration ?? 0.85,
            ease: item.ease ?? 'power3.out',
            stagger: item.stagger ?? 0,
            overwrite: 'auto'
          });
        });
      };

      const hide = () => {
        items.forEach(item => {
          gsap.to(item.selector, {
            ...item.hidden,
            duration: item.hideDuration ?? 0.45,
            ease: item.hideEase ?? 'power2.inOut',
            stagger: item.stagger ? item.stagger * 0.5 : 0,
            overwrite: 'auto'
          });
        });
      };

      ScrollTrigger.create({
        trigger,
        start,
        end,
        onEnter: show,
        onEnterBack: show,
        onLeave: hide,
        onLeaveBack: hide
      });
    }

    // --- About section replay reveal ---
    bindReplaySection({
      trigger: '.about-section',
      start: 'top 75%',
      end: 'bottom 25%',
      items: [
        {
          selector: '.about-text-content',
          hidden: { x: 50, opacity: 0 },
          visible: { x: 0, opacity: 1 }
        },
        {
          selector: '.about-image-card',
          hidden: { x: -50, opacity: 0 },
          visible: { x: 0, opacity: 1 }
        }
      ]
    });

    // --- Location cards stagger ---
    gsap.fromTo('.location-card',
      { y: 50, opacity: 0 },
      {
        y: 0, opacity: 1,
        stagger: 0.2,
        duration: 0.8,
        ease: 'power3.out',
        scrollTrigger: {
          trigger: '.locations-section',
          start: 'top 80%',
          toggleActions: 'play reverse play reverse',
        }
      }
    );

    // --- Menu cards stagger ---
    gsap.fromTo('.menu-item-card',
      { y: 40, opacity: 0 },
      {
        y: 0, opacity: 1,
        stagger: 0.1,
        duration: 0.7,
        ease: 'power2.out',
        scrollTrigger: {
          trigger: '.menu-section',
          start: 'top 80%',
          toggleActions: 'play reverse play reverse',
        }
      }
    );

    // --- Brew Stars replay reveal ---
    bindReplaySection({
      trigger: '.rewards-section',
      start: 'top 78%',
      end: 'bottom 25%',
      items: [
        {
          selector: '.rstep',
          hidden: { x: -30, opacity: 0 },
          visible: { x: 0, opacity: 1 },
          duration: 0.7,
          ease: 'power2.out',
          stagger: 0.15
        },
        {
          selector: '.star-card',
          hidden: { y: 40, opacity: 0 },
          visible: { y: 0, opacity: 1 },
          duration: 0.9,
          ease: 'power3.out'
        }
      ]
    });

    // --- Hero content animation on load ---
    gsap.fromTo('.hero-content',
      { y: 30, opacity: 0 },
      { y: 0, opacity: 1, duration: 1, delay: 0.1, ease: 'power3.out' }
    );

    gsap.fromTo('.hero-image-wrapper',
      { y: 40, opacity: 0 },
      { y: 0, opacity: 1, duration: 1, delay: 0.3, ease: 'power3.out' }
    );

  } else {
    // Fallback: no GSAP — reveal GSAP-owned elements immediately
    document.querySelectorAll(
      '.about-text-content, .about-image-card, .rstep, .star-card'
    ).forEach(el => { el.style.opacity = '1'; });
    document.querySelectorAll('.location-card, .menu-item-card').forEach(el => {
      el.classList.add('is-visible');
    });
    // IntersectionObserver handles .hero-feature-card
  }

  // =========================================================================
  // 10. CUSTOM COFFEE CUP CURSOR
  // =========================================================================
  const cursor = document.createElement('div');
  cursor.id = 'custom-cursor';
  cursor.innerHTML = `
    <svg width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M6 11 L20 11 L18 22 C17.6 24 16 25 14 25 L12 25 C10 25 8.4 24 8 22 Z"
            fill="none" stroke="var(--color-gold)" stroke-width="1.6" stroke-linejoin="round"/>
      <path d="M20 13 C22 13 24 14.5 24 16.5 C24 18.5 22 20 20 20"
            fill="none" stroke="var(--color-gold)" stroke-width="1.6" stroke-linecap="round"/>
      <path d="M11 8 C10 6 11.5 4.5 11 3" fill="none" stroke="var(--color-gold)"
            stroke-width="1.4" stroke-linecap="round"/>
      <path d="M14 7 C13 5.5 14.5 4 14 2.5" fill="none" stroke="var(--color-gold)"
            stroke-width="1.4" stroke-linecap="round"/>
    </svg>`;
  document.body.appendChild(cursor);

  let cursorX = -100, cursorY = -100;
  let cursorRaf = false;

  document.addEventListener('mousemove', e => {
    cursorX = e.clientX;
    cursorY = e.clientY;
    if (!cursorRaf) {
      cursorRaf = true;
      requestAnimationFrame(() => {
        cursor.style.left = `${cursorX}px`;
        cursor.style.top  = `${cursorY}px`;
        cursorRaf = false;
      });
    }
  });

  document.addEventListener('mousedown', () => cursor.classList.add('cursor--click'));
  document.addEventListener('mouseup',   () => cursor.classList.remove('cursor--click'));

  // Hover: all interactive elements — use event delegation for robustness
  const HOVER_SELECTOR = 'a, button, [role="button"], label, ' +
    '.btn, .filter-btn, .logo-link, .nav-link, .social-icon, ' +
    '.menu-item-card, .star-slot, .nav-cta-btn, .newsletter-btn, ' +
    '.btn-outline, .btn-primary, #theme-toggle';

  document.addEventListener('mouseover', e => {
    if (e.target.closest(HOVER_SELECTOR)) {
      cursor.classList.add('cursor--hover');
    }
  });
  document.addEventListener('mouseout', e => {
    if (e.target.closest(HOVER_SELECTOR)) {
      cursor.classList.remove('cursor--hover');
    }
  });

  // Text cursor indicator on inputs
  const TEXT_SELECTOR = 'input, textarea, select, [contenteditable]';
  document.addEventListener('mouseover', e => {
    if (e.target.closest(TEXT_SELECTOR)) {
      cursor.classList.add('cursor--text');
    }
  });
  document.addEventListener('mouseout', e => {
    if (e.target.closest(TEXT_SELECTOR)) {
      cursor.classList.remove('cursor--text');
    }
  });


  // =========================================================================
  // 11. DARK / LIGHT MODE TOGGLE
  // =========================================================================
  const themeToggle = document.getElementById('theme-toggle');
  const htmlEl      = document.documentElement;

  function applyTheme(theme) {
    if (theme === 'light') {
      htmlEl.setAttribute('data-theme', 'light');
      if (themeToggle) themeToggle.textContent = '☀️';
    } else {
      htmlEl.removeAttribute('data-theme');
      if (themeToggle) themeToggle.textContent = '🌙';
    }
  }

  // Restore saved preference
  applyTheme(localStorage.getItem('jc-theme') || 'dark');

  themeToggle?.addEventListener('click', () => {
    const current = htmlEl.getAttribute('data-theme') === 'light' ? 'light' : 'dark';
    const next    = current === 'light' ? 'dark' : 'light';
    localStorage.setItem('jc-theme', next);
    applyTheme(next);
  });


  // =========================================================================
  // 12. BREW STARS COUNT-UP ANIMATION
  // =========================================================================
  const starCard    = document.querySelector('.star-card');
  const starGrid    = document.getElementById('star-grid');
  const scpBarFill  = document.querySelector('.scp-bar-fill');
  const scpLabel    = document.querySelector('.scp-label');

  if (starCard && scpBarFill && scpLabel) {
    const TARGET_STARS    = 7;
    const TARGET_WIDTH    = 70;
    const DURATION_MS     = 1400;
    const EASE_CB         = 'cubic-bezier(0.22, 1, 0.36, 1)';
    const COUNT_INTERVAL  = 200;
    let countTick = null;

    const resetBrewStarsProgress = () => {
      if (countTick) clearInterval(countTick);
      countTick = null;
      scpBarFill.style.transition = 'none';
      scpBarFill.style.width = '0%';
      scpLabel.textContent = '0 / 10 Stars';
      starGrid?.classList.remove('star-animate');
    };

    const playBrewStarsProgress = () => {
      resetBrewStarsProgress();

      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          scpBarFill.style.transition = `width ${DURATION_MS}ms ${EASE_CB}`;
          scpBarFill.style.width = `${TARGET_WIDTH}%`;
          starGrid?.classList.add('star-animate');
        });
      });

      let count = 0;
      const steps = Math.floor(DURATION_MS / COUNT_INTERVAL);
      countTick = setInterval(() => {
        count = Math.min(count + Math.ceil(TARGET_STARS / steps), TARGET_STARS);
        scpLabel.textContent = `${count} / 10 Stars\u00a0\u00b7\u00a0${10 - count} more until your free drink!`;
        if (count >= TARGET_STARS) {
          clearInterval(countTick);
          countTick = null;
        }
      }, COUNT_INTERVAL);
    };

    resetBrewStarsProgress();

    if (typeof ScrollTrigger !== 'undefined') {
      ScrollTrigger.create({
        trigger: '.rewards-section',
        start: 'top 78%',
        end: 'bottom 25%',
        onEnter: playBrewStarsProgress,
        onEnterBack: playBrewStarsProgress,
        onLeave: resetBrewStarsProgress,
        onLeaveBack: resetBrewStarsProgress
      });
    } else {
      const brewStarsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) playBrewStarsProgress();
          else resetBrewStarsProgress();
        });
      }, { threshold: 0.5 });

      brewStarsObserver.observe(starCard);
    }
  }

});
