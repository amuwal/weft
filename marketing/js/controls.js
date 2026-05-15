// Weft — nav controls (language dropdown + theme toggle)
// Injected into <div data-nav-controls></div> on every page so adding/changing
// these controls is a one-file change.
//
// Theme behavior:
//   - first visit: respect `prefers-color-scheme` (no <html data-theme> applied)
//   - explicit click: persists to localStorage as "light" or "dark"
//   - icon shows current effective theme (sun = light, moon = dark)
//
// Language: defers to i18n.js — controls.js only renders the dropdown UI.
//   Buttons carry `data-lang-set="en|ja"`, which i18n.js wires up on its own.
//   We listen for `i18n:applied` events to update the trigger label.

(() => {
  const THEME_KEY = 'weft.theme';
  const LANG_LABEL = { en: 'EN', ja: 'JA' };
  const LANG_FULL  = { en: 'English', ja: '日本語' };

  // ── theme ─────────────────────────────────────────────────
  function readStoredTheme() {
    try { return localStorage.getItem(THEME_KEY); } catch (_) { return null; }
  }
  function writeStoredTheme(theme) {
    try {
      if (theme) localStorage.setItem(THEME_KEY, theme);
      else localStorage.removeItem(THEME_KEY);
    } catch (_) { /* private mode */ }
  }
  function applyTheme(theme) {
    if (theme === 'light' || theme === 'dark') {
      document.documentElement.setAttribute('data-theme', theme);
    } else {
      document.documentElement.removeAttribute('data-theme');
    }
    // Update <meta name="theme-color"> live so iOS browser chrome matches
    const isDark = effectiveTheme(theme) === 'dark';
    const colorTags = document.querySelectorAll('meta[name="theme-color"]');
    colorTags.forEach(tag => {
      const media = tag.getAttribute('media') || '';
      if (!media || media.includes(isDark ? 'dark' : 'light')) {
        tag.setAttribute('content', isDark ? '#161410' : '#F8F5EF');
      }
    });
  }
  function effectiveTheme(explicit) {
    if (explicit === 'light' || explicit === 'dark') return explicit;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
  function paintThemeIcon(theme) {
    const eff = effectiveTheme(theme);
    document.querySelectorAll('[data-theme-toggle]').forEach(btn => {
      btn.dataset.effective = eff;
      btn.setAttribute('aria-label', eff === 'dark' ? 'Switch to light mode' : 'Switch to dark mode');
    });
  }

  // Apply stored theme immediately (before paint, to avoid flash)
  const initialTheme = readStoredTheme();
  if (initialTheme) applyTheme(initialTheme);

  // ── markup ────────────────────────────────────────────────
  const SUN_SVG = `<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" aria-hidden="true">
      <circle cx="10" cy="10" r="3.4"/>
      <path d="M10 2.6v1.5M10 15.9v1.5M2.6 10h1.5M15.9 10h1.5M4.4 4.4l1 1M14.6 14.6l1 1M4.4 15.6l1-1M14.6 5.4l1-1"/>
    </svg>`;
  const MOON_SVG = `<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <path d="M16.5 12.5A6.5 6.5 0 0 1 7.5 3.5a6.5 6.5 0 1 0 9 9z"/>
    </svg>`;
  const CHEV_SVG = `<svg class="lang-chev" viewBox="0 0 12 12" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <path d="M3 4.5L6 7.5L9 4.5"/>
    </svg>`;

  function controlsHTML(currentLang) {
    return `
      <button type="button"
              class="theme-toggle"
              data-theme-toggle
              aria-label="Toggle theme">
        <span class="theme-icon icon-sun">${SUN_SVG}</span>
        <span class="theme-icon icon-moon">${MOON_SVG}</span>
      </button>
      <div class="lang-dropdown" data-lang-dropdown>
        <button type="button"
                class="lang-trigger"
                aria-haspopup="listbox"
                aria-expanded="false">
          <span class="lang-current" data-current-lang>${LANG_LABEL[currentLang] || 'EN'}</span>
          ${CHEV_SVG}
        </button>
        <ul class="lang-menu" role="listbox">
          <li role="option">
            <button type="button" class="lang-option" data-lang-set="en">${LANG_FULL.en}</button>
          </li>
          <li role="option">
            <button type="button" class="lang-option" data-lang-set="ja">${LANG_FULL.ja}</button>
          </li>
        </ul>
      </div>
    `;
  }

  // ── inject + wire ─────────────────────────────────────────
  function detectLang() {
    // Mirror i18n.js's resolution so trigger shows the right code before i18n boots
    try {
      const stored = localStorage.getItem('weft.lang');
      if (stored && LANG_LABEL[stored]) return stored;
    } catch (_) {}
    const prefs = navigator.languages || [navigator.language || ''];
    for (const pref of prefs) {
      const base = (pref || '').toLowerCase().split('-')[0];
      if (LANG_LABEL[base]) return base;
    }
    return 'en';
  }

  function wireDropdown(dropdown) {
    const trigger = dropdown.querySelector('.lang-trigger');
    const menu = dropdown.querySelector('.lang-menu');
    if (!trigger || !menu) return;

    const open = () => {
      dropdown.classList.add('is-open');
      trigger.setAttribute('aria-expanded', 'true');
    };
    const close = () => {
      dropdown.classList.remove('is-open');
      trigger.setAttribute('aria-expanded', 'false');
    };

    trigger.addEventListener('click', (e) => {
      e.stopPropagation();
      dropdown.classList.contains('is-open') ? close() : open();
    });

    // Close on outside click
    document.addEventListener('click', (e) => {
      if (!dropdown.contains(e.target)) close();
    });

    // Close on escape
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') close();
    });

    // Close after a language is picked (i18n.js handles the actual switch)
    menu.querySelectorAll('[data-lang-set]').forEach(btn => {
      btn.addEventListener('click', () => close());
    });
  }

  function wireThemeButton(btn) {
    btn.addEventListener('click', () => {
      const current = readStoredTheme() || effectiveTheme(null);
      const next = current === 'dark' ? 'light' : 'dark';
      writeStoredTheme(next);
      applyTheme(next);
      paintThemeIcon(next);
    });
  }

  function paintLangActive(lang) {
    document.querySelectorAll('[data-current-lang]').forEach(el => {
      el.textContent = LANG_LABEL[lang] || lang.toUpperCase();
    });
    document.querySelectorAll('.lang-option').forEach(opt => {
      const target = opt.getAttribute('data-lang-set');
      opt.classList.toggle('is-active', target === lang);
    });
  }

  function boot() {
    const lang = detectLang();
    document.querySelectorAll('[data-nav-controls]').forEach(slot => {
      slot.innerHTML = controlsHTML(lang);
    });
    document.querySelectorAll('[data-lang-dropdown]').forEach(wireDropdown);
    document.querySelectorAll('[data-theme-toggle]').forEach(wireThemeButton);
    paintLangActive(lang);
    paintThemeIcon(readStoredTheme());

    // Keep the icon in sync if the system theme flips while user is on auto
    if (window.matchMedia) {
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
        if (!readStoredTheme()) paintThemeIcon(null);
      });
    }
  }

  // When i18n applies a (possibly different) language, repaint label + active option
  document.addEventListener('i18n:applied', (e) => {
    if (e.detail && e.detail.lang) paintLangActive(e.detail.lang);
  });

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
