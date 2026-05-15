// Weft — marketing site
// minimal interactions: word-by-word reveal · scroll-in · nav shadow · faq accordion · form submit

(() => {
  const prefersReduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // ── word-by-word reveal (runs after i18n applies translated text) ─
  function initWordReveal() {
    document.querySelectorAll('[data-reveal-words]').forEach(el => {
      // i18n just set textContent (or no i18n: original markup). Read fresh.
      const text = el.textContent.trim();
      if (!text) return;
      el.textContent = '';
      el.classList.add('reveal-words');
      el.classList.remove('is-in');
      // For languages without spaces between words (Japanese, Chinese),
      // fall back to character-level segmentation so the stagger still reads.
      const hasSpaces = /\s/.test(text);
      const units = hasSpaces ? text.split(/\s+/) : Array.from(text);
      units.forEach((unit, i) => {
        const span = document.createElement('span');
        span.className = 'w';
        span.textContent = unit;
        // Slow the stagger when there are many units (e.g. per-character JP)
        const delay = hasSpaces ? 60 + i * 90 : 30 + i * 45;
        span.style.transitionDelay = `${delay}ms`;
        el.appendChild(span);
        if (hasSpaces && i < units.length - 1) el.appendChild(document.createTextNode(' '));
      });
    });
  }

  // ── intersection-based reveals ──────────────────────────────
  let revealObserver = null;
  function initRevealObserver() {
    if (revealObserver) revealObserver.disconnect();
    const revealTargets = document.querySelectorAll('.reveal-words, .reveal-fade');
    if (!revealTargets.length) return;
    if (prefersReduce) {
      revealTargets.forEach(el => el.classList.add('is-in'));
      return;
    }
    revealObserver = new IntersectionObserver((entries) => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          e.target.classList.add('is-in');
          revealObserver.unobserve(e.target);
        }
      });
    }, { threshold: 0.18, rootMargin: '0px 0px -60px 0px' });
    revealTargets.forEach(el => revealObserver.observe(el));
  }

  // ── chrome that doesn't depend on copy ──────────────────────
  function initChrome() {
    // Nav shadow on scroll
    const nav = document.querySelector('.nav');
    if (nav) {
      const onScroll = () => nav.classList.toggle('is-scrolled', window.scrollY > 8);
      window.addEventListener('scroll', onScroll, { passive: true });
      onScroll();
    }

    // FAQ accordion — exclusive open
    document.querySelectorAll('.faq-item').forEach(item => {
      const q = item.querySelector('.faq-q');
      if (!q) return;
      q.addEventListener('click', () => {
        if (!item.open) {
          document.querySelectorAll('.faq-item[open]').forEach(other => {
            if (other !== item) other.open = false;
          });
        }
      });
    });

    // Smooth scroll for in-page links
    document.querySelectorAll('a[href^="#"]').forEach(a => {
      const id = a.getAttribute('href').slice(1);
      if (!id) return;
      a.addEventListener('click', e => {
        const target = document.getElementById(id);
        if (!target) return;
        e.preventDefault();
        target.scrollIntoView({ behavior: prefersReduce ? 'auto' : 'smooth', block: 'start' });
      });
    });

    // Phone hover tilt
    if (!prefersReduce) {
      document.querySelectorAll('.phone').forEach(phone => {
        const stage = phone.closest('.phone-stage');
        if (!stage) return;
        stage.addEventListener('mousemove', (e) => {
          const r = stage.getBoundingClientRect();
          const x = (e.clientX - r.left) / r.width - 0.5;
          const y = (e.clientY - r.top) / r.height - 0.5;
          phone.style.transform = `rotate(${-1.2 + x * 1.6}deg) translate3d(${x * 6}px, ${y * 4}px, 0)`;
        });
        stage.addEventListener('mouseleave', () => { phone.style.transform = ''; });
      });
    }

    // Year stamp
    document.querySelectorAll('[data-year]').forEach(el => {
      el.textContent = new Date().getFullYear();
    });
  }

  // ── form: real submit via Web3Forms (AJAX) ──────────────────
  // Submit button label localization: data-w3-label-{state} attributes carry
  // localized strings ("Sending…", "Sent — thank you", "Didn't send — try email instead").
  // i18n.js sets these via data-i18n-attr. Falls back to English if not set.
  function initForms() {
    document.querySelectorAll('form[data-w3form]').forEach(form => {
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const sub = form.querySelector('.form-submit');
        if (!sub) return;
        const original = sub.dataset.original ?? sub.textContent;
        sub.dataset.original = original;
        const labels = {
          sending: sub.getAttribute('data-w3-label-sending') ?? 'Sending…',
          sent:    sub.getAttribute('data-w3-label-sent')    ?? 'Sent — thank you',
          failed:  sub.getAttribute('data-w3-label-failed')  ?? "Didn't send — try email instead",
        };

        sub.textContent = labels.sending;
        sub.style.background = '';
        sub.disabled = true;

        try {
          const resp = await fetch(form.action, {
            method: 'POST',
            body: new FormData(form),
            headers: { Accept: 'application/json' }
          });
          const data = await resp.json().catch(() => ({}));

          if (resp.ok && data.success) {
            sub.textContent = labels.sent;
            sub.style.background = 'var(--sage)';
            setTimeout(() => {
              form.reset();
              sub.textContent = sub.dataset.original;
              sub.style.background = '';
              sub.disabled = false;
            }, 3200);
          } else {
            throw new Error(data.message || `HTTP ${resp.status}`);
          }
        } catch (err) {
          console.warn('[Weft] form submit failed:', err);
          sub.textContent = labels.failed;
          sub.style.background = 'var(--warm)';
          setTimeout(() => {
            sub.textContent = sub.dataset.original;
            sub.style.background = '';
            sub.disabled = false;
          }, 4500);
        }
      });
    });
  }

  // ── wiring ──────────────────────────────────────────────────
  // initWordReveal needs translated text. Run on every i18n:applied
  // (initial + any language toggle). initChrome / initForms run once.
  document.addEventListener('i18n:applied', () => {
    initWordReveal();
    initRevealObserver();
  });

  // Fallback for pages without i18n.js: init immediately.
  // (All marketing pages currently load i18n.js, so this is a safety net.)
  function bootIfNoI18n() {
    if (!document.documentElement.hasAttribute('data-i18n-booted')) {
      initWordReveal();
      initRevealObserver();
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      initChrome();
      initForms();
      // give i18n a tick; fall back if it never dispatches
      setTimeout(bootIfNoI18n, 2000);
    });
  } else {
    initChrome();
    initForms();
    setTimeout(bootIfNoI18n, 2000);
  }
})();
