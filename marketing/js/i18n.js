// Weft — runtime i18n (English / Japanese)
// Single source of truth: /i18n/en.json + /i18n/ja.json
// HTML opts in via data-i18n="dot.path"
// Attribute targets via data-i18n-attr="attrName:dot.path[, attrName:dot.path]"
// Document-level (title, meta description) via the "meta" key in the dictionary.

(() => {
  const SUPPORTED = ['en', 'ja'];
  const STORAGE_KEY = 'weft.lang';
  const DEFAULT = 'en';

  // ── language resolution ────────────────────────────────────
  function detect() {
    // 1. URL ?lang=xx wins (shareable links)
    const url = new URL(window.location.href);
    const urlLang = url.searchParams.get('lang');
    if (urlLang && SUPPORTED.includes(urlLang)) return urlLang;

    // 2. explicit user choice in localStorage
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored && SUPPORTED.includes(stored)) return stored;
    } catch (e) { /* private mode */ }

    // 3. browser preference — first supported language match
    const prefs = navigator.languages || [navigator.language || ''];
    for (const pref of prefs) {
      const base = (pref || '').toLowerCase().split('-')[0];
      if (SUPPORTED.includes(base)) return base;
    }

    return DEFAULT;
  }

  function persist(lang) {
    try { localStorage.setItem(STORAGE_KEY, lang); } catch (e) { /* private mode */ }
  }

  // ── dictionary ────────────────────────────────────────────
  const cache = {};

  async function load(lang) {
    if (cache[lang]) return cache[lang];
    const url = new URL(`i18n/${lang}.json`, document.baseURI);
    const resp = await fetch(url.toString(), { cache: 'no-cache' });
    if (!resp.ok) throw new Error(`i18n: failed to load ${lang} (${resp.status})`);
    cache[lang] = await resp.json();
    return cache[lang];
  }

  function lookup(dict, path) {
    return path.split('.').reduce((acc, key) => (acc == null ? undefined : acc[key]), dict);
  }

  // ── application ───────────────────────────────────────────
  function apply(dict) {
    // Text content
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const path = el.getAttribute('data-i18n');
      const value = lookup(dict, path);
      if (value == null) {
        console.warn(`[i18n] missing key:`, path);
        return;
      }
      if (typeof value === 'string') {
        // If element has data-i18n-html, allow inline markup (e.g. <em>); else textContent.
        if (el.hasAttribute('data-i18n-html')) {
          el.innerHTML = value;
        } else {
          el.textContent = value;
        }
      }
    });

    // Attribute targets — data-i18n-attr="placeholder:form.email.placeholder, aria-label:..."
    document.querySelectorAll('[data-i18n-attr]').forEach(el => {
      const spec = el.getAttribute('data-i18n-attr');
      spec.split(',').forEach(pair => {
        const [attr, path] = pair.split(':').map(s => s.trim());
        if (!attr || !path) return;
        const value = lookup(dict, path);
        if (value == null) {
          console.warn(`[i18n] missing key for ${attr}:`, path);
          return;
        }
        el.setAttribute(attr, value);
      });
    });

    // Hidden form fields that should be localized
    document.querySelectorAll('[data-i18n-value]').forEach(el => {
      const path = el.getAttribute('data-i18n-value');
      const value = lookup(dict, path);
      if (value != null) el.value = value;
    });
  }

  // ── toggle UI ─────────────────────────────────────────────
  function paintToggle(lang) {
    document.querySelectorAll('[data-lang-set]').forEach(btn => {
      const target = btn.getAttribute('data-lang-set');
      btn.classList.toggle('is-active', target === lang);
      btn.setAttribute('aria-pressed', target === lang ? 'true' : 'false');
    });
  }

  function wireToggle() {
    document.querySelectorAll('[data-lang-set]').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        e.preventDefault();
        const target = btn.getAttribute('data-lang-set');
        if (!SUPPORTED.includes(target) || target === current) return;
        await setLanguage(target, { persist: true });
      });
    });
  }

  // ── orchestrator ──────────────────────────────────────────
  let current = DEFAULT;

  async function setLanguage(lang, { persist: shouldPersist } = {}) {
    try {
      const dict = await load(lang);
      current = lang;
      document.documentElement.setAttribute('lang', lang);
      document.documentElement.setAttribute('data-i18n-booted', 'true');
      apply(dict);
      paintToggle(lang);
      if (shouldPersist) persist(lang);
      // Notify other scripts (e.g. site.js word-reveal) that copy changed
      document.dispatchEvent(new CustomEvent('i18n:applied', { detail: { lang } }));
    } catch (err) {
      console.error('[i18n]', err);
    }
  }

  // ── boot ──────────────────────────────────────────────────
  // Run before site.js so word-by-word reveal targets translated copy
  const initial = detect();
  // Set <html lang> immediately so screen readers / fonts pick up early
  document.documentElement.setAttribute('lang', initial);

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      setLanguage(initial);
      wireToggle();
    });
  } else {
    setLanguage(initial);
    wireToggle();
  }
})();
