// Weft — marketing site
// minimal interactions: word-by-word reveal · scroll-in · nav shadow · faq accordion

(() => {
  const prefersReduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // ── word-by-word reveal ─────────────────────────────────────
  document.querySelectorAll('[data-reveal-words]').forEach(el => {
    const text = el.textContent;
    el.textContent = '';
    el.classList.add('reveal-words');
    const words = text.trim().split(/\s+/);
    words.forEach((w, i) => {
      const span = document.createElement('span');
      span.className = 'w';
      span.textContent = w;
      span.style.transitionDelay = `${60 + i * 90}ms`;
      el.appendChild(span);
      if (i < words.length - 1) el.appendChild(document.createTextNode(' '));
    });
  });

  // ── intersection-based reveals ──────────────────────────────
  const revealTargets = document.querySelectorAll('.reveal-words, .reveal-fade');
  if (revealTargets.length) {
    if (prefersReduce) {
      revealTargets.forEach(el => el.classList.add('is-in'));
    } else {
      const io = new IntersectionObserver((entries) => {
        entries.forEach(e => {
          if (e.isIntersecting) {
            e.target.classList.add('is-in');
            io.unobserve(e.target);
          }
        });
      }, { threshold: 0.18, rootMargin: '0px 0px -60px 0px' });
      revealTargets.forEach(el => io.observe(el));
    }
  }

  // ── nav shadow on scroll ────────────────────────────────────
  const nav = document.querySelector('.nav');
  if (nav) {
    const onScroll = () => {
      nav.classList.toggle('is-scrolled', window.scrollY > 8);
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  // ── faq accordion (native <details> with extra polish) ──────
  document.querySelectorAll('.faq-item').forEach(item => {
    const q = item.querySelector('.faq-q');
    if (!q) return;
    q.addEventListener('click', (e) => {
      // allow exclusive accordion: close others
      if (!item.open) {
        document.querySelectorAll('.faq-item[open]').forEach(other => {
          if (other !== item) other.open = false;
        });
      }
    });
  });

  // ── smooth scroll for in-page links ─────────────────────────
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

  // ── form: real submit via Web3Forms (AJAX) ──────────────────
  document.querySelectorAll('form[data-w3form]').forEach(form => {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const sub = form.querySelector('.form-submit');
      if (!sub) return;
      const original = sub.textContent;
      sub.textContent = 'Sending…';
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
          sub.textContent = 'Sent — thank you';
          sub.style.background = 'var(--sage)';
          setTimeout(() => {
            form.reset();
            sub.textContent = original;
            sub.style.background = '';
            sub.disabled = false;
          }, 3200);
        } else {
          throw new Error(data.message || `HTTP ${resp.status}`);
        }
      } catch (err) {
        console.warn('[Weft] form submit failed:', err);
        sub.textContent = "Didn't send — try email instead";
        sub.style.background = 'var(--warm)';
        setTimeout(() => {
          sub.textContent = original;
          sub.style.background = '';
          sub.disabled = false;
        }, 4500);
      }
    });
  });

  // ── year stamp ──────────────────────────────────────────────
  document.querySelectorAll('[data-year]').forEach(el => {
    el.textContent = new Date().getFullYear();
  });

  // ── shared phone hover tilt (subtle) ────────────────────────
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
      stage.addEventListener('mouseleave', () => {
        phone.style.transform = '';
      });
    });
  }
})();
