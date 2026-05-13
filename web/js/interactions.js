/* ─────────────────────────────────────────────────────────────
   Linger — interaction layer (no framework)
   Handles: tab switching, segmented controls, chips, toggles,
            modal open/close, swipe-card affordance, theme toggle,
            staggered reveal indices.
   ───────────────────────────────────────────────────────────── */

(() => {
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));
  const $  = (sel, root = document) => root.querySelector(sel);

  /* ─── allow ?_theme=dark URL param to flip dark ─── */
  const params = new URLSearchParams(location.search);
  if (params.get('_theme') === 'dark') {
    document.documentElement.dataset.theme = 'dark';
  }

  /* ─── staggered reveal: set --i on .stagger children ─── */
  $$('.stagger').forEach(group => {
    Array.from(group.children).forEach((el, i) => {
      el.style.setProperty('--i', i);
      el.classList.add('rise');
    });
  });

  /* ─── group toggles: chips & seg & tabs ─── */
  $$('[data-group]').forEach(group => {
    const items = $$('[role="button"], button', group);
    // initialize CSS vars for layout-animated pill on .seg
    if (group.classList.contains('seg')) {
      group.style.setProperty('--seg-n', items.length);
      const initial = items.findIndex(b => b.getAttribute('aria-selected') === 'true');
      group.style.setProperty('--seg-i', initial < 0 ? 0 : initial);
    }
    items.forEach((btn, idx) => {
      btn.addEventListener('click', () => {
        items.forEach(b => b.setAttribute('aria-selected', 'false'));
        btn.setAttribute('aria-selected', 'true');
        if (group.classList.contains('seg')) {
          group.style.setProperty('--seg-i', idx);
        }
        btn.animate(
          [{ transform: 'scale(.96)' }, { transform: 'scale(1)' }],
          { duration: 220, easing: 'cubic-bezier(.22,1.36,.36,1)' }
        );
      });
    });
  });

  /* ─── smart animate text: word-by-word stagger, preserves nested markup ─── */
  $$('.animate-words').forEach(root => {
    let i = 0;
    const wraps = [];
    const walk = node => {
      if (node.nodeType === Node.TEXT_NODE) {
        const parts = node.textContent.split(/(\s+)/);
        const frag = document.createDocumentFragment();
        for (const tok of parts) {
          if (!tok) continue;
          if (/^\s+$/.test(tok)) { frag.appendChild(document.createTextNode(tok)); continue; }
          const span = document.createElement('span');
          span.textContent = tok;
          span.style.display = 'inline-block';
          span.style.opacity = '0';
          span.style.transform = 'translateY(0.5em)';
          span.style.transitionDelay = (i++ * 55) + 'ms';
          span.classList.add('word-rise');
          wraps.push(span);
          frag.appendChild(span);
        }
        node.replaceWith(frag);
      } else if (node.nodeType === Node.ELEMENT_NODE && node.tagName !== 'BR') {
        Array.from(node.childNodes).forEach(walk);
      }
    };
    Array.from(root.childNodes).forEach(walk);
    requestAnimationFrame(() => requestAnimationFrame(() => {
      wraps.forEach(s => {
        s.style.opacity = '1';
        s.style.transform = 'translateY(0)';
      });
    }));
  });

  /* ─── toggle switches ─── */
  $$('.toggle').forEach(t => {
    t.addEventListener('click', () => {
      t.classList.toggle('on');
      flashHaptic(t.closest('.phone-screen'));
    });
  });

  /* ─── modal sheets ─── */
  $$('[data-open]').forEach(trigger => {
    trigger.addEventListener('click', () => {
      const id = trigger.getAttribute('data-open');
      const sheet = document.getElementById(id);
      if (!sheet) return;
      sheet.style.pointerEvents = 'auto';
      sheet.classList.add('open');
      sheet.querySelector('.sheet')?.animate(
        [{ transform: 'translateY(100%)' }, { transform: 'translateY(0)' }],
        { duration: 420, easing: 'cubic-bezier(.22,1.36,.36,1)', fill: 'both' }
      );
    });
  });
  $$('[data-close]').forEach(trigger => {
    trigger.addEventListener('click', () => {
      const sheet = trigger.closest('.sheet-host');
      if (!sheet) return;
      const anim = sheet.querySelector('.sheet')?.animate(
        [{ transform: 'translateY(0)' }, { transform: 'translateY(100%)' }],
        { duration: 320, easing: 'cubic-bezier(.32,0,.67,0)', fill: 'forwards' }
      );
      if (anim) anim.onfinish = () => sheet.classList.remove('open');
      else sheet.classList.remove('open');
    });
  });

  /* ─── swipe card: drag-right "caught up" ─── */
  $$('.swipe-card').forEach(card => {
    let startX = 0, currentX = 0, dragging = false;
    const onStart = e => {
      const pt = e.touches ? e.touches[0] : e;
      startX = pt.clientX;
      dragging = true;
      card.style.transition = 'none';
    };
    const onMove = e => {
      if (!dragging) return;
      const pt = e.touches ? e.touches[0] : e;
      currentX = pt.clientX - startX;
      const damped = currentX > 0 ? Math.min(currentX * 0.7, 200) : currentX * 0.18;
      card.style.transform = `translateX(${damped}px) scale(${1 - Math.min(Math.abs(damped)/1600, .05)})`;
      card.style.opacity   = `${1 - Math.min(Math.abs(damped)/600, .4)}`;
    };
    const onEnd = () => {
      if (!dragging) return;
      dragging = false;
      card.style.transition = 'transform 380ms cubic-bezier(.22,1.36,.36,1), opacity 380ms ease';
      if (currentX > 90) {
        card.style.transform = 'translateX(120%) scale(.92)';
        card.style.opacity = '0';
        flashHaptic(card.closest('.phone-screen'));
        setTimeout(() => {
          card.style.transition = 'none';
          card.style.transform = 'translateX(0) scale(1)';
          card.style.opacity = '1';
        }, 1100);
      } else {
        card.style.transform = 'translateX(0) scale(1)';
        card.style.opacity = '1';
      }
      currentX = 0;
    };
    card.addEventListener('mousedown', onStart);
    card.addEventListener('touchstart', onStart, { passive: true });
    window.addEventListener('mousemove', onMove);
    window.addEventListener('touchmove', onMove, { passive: true });
    window.addEventListener('mouseup', onEnd);
    window.addEventListener('touchend', onEnd);
  });

  function flashHaptic(scope) {
    if (!scope) return;
    scope.classList.remove('haptic');
    // re-trigger animation
    void scope.offsetWidth;
    scope.classList.add('haptic');
  }
  window.lingerHaptic = flashHaptic;

  /* ─── press feedback on .pressable for non-touch devices ─── */
  $$('.pressable').forEach(el => {
    el.addEventListener('pointerdown', () => {
      el.animate(
        [{ transform: 'scale(.97)' }, { transform: 'scale(1)' }],
        { duration: 240, easing: 'cubic-bezier(.34,1.56,.64,1)' }
      );
    });
  });

  /* ─── showcase theme toggle ─── */
  const themeBtn = document.querySelector('[data-toggle-theme]');
  if (themeBtn) {
    const setIcon = () => {
      themeBtn.textContent = document.documentElement.dataset.theme === 'dark' ? '☀' : '☾';
    };
    setIcon();
    themeBtn.addEventListener('click', () => {
      const root = document.documentElement;
      root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
      setIcon();
    });
  }

  /* ─── live clock for status bars ─── */
  const stamp = () => {
    const now = new Date();
    const h = now.getHours();
    const m = now.getMinutes().toString().padStart(2, '0');
    const t = `${h}:${m}`;
    $$('.status-bar .time').forEach(el => (el.textContent = t));
  };
  stamp();
  setInterval(stamp, 30000);

})();
