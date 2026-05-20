// Inline the English copy from i18n/en.json into every `data-i18n` element
// across the marketing site, so the pages render the real text *before* the
// i18n JS runs. Search engines and the App Review iPad both load HTML with
// JS disabled or before scripts finish; an empty <div class="faq-a"></div>
// is meaningless to them. After this script, JS still overwrites the same
// content with the same value for English, and with the JA string for ja_JP.
//
// Run from the marketing directory:  node scripts/inline-i18n-defaults.mjs
//
// Heuristics:
//   - Resolves the key from en.json. Skips if missing/non-string.
//   - For elements with `data-i18n-html`, the looked-up value is HTML — we
//     just paste it in. For text-only elements, the value already lacks
//     markup, so it's safe as innerHTML too.
//   - Skips elements that use `data-i18n-attr` only (no inner content key).
//   - Refuses to touch elements with child markup we can't safely replace
//     (i.e. when innerHTML contains a tag *other than* <strong>/<em>/<a>).
//     This keeps complex composed nodes alone.

import { readFile, writeFile } from 'node:fs/promises';
import { dirname, join, basename } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = join(HERE, '..');

const PAGES = [
  'index.html',
  'about.html',
  'feedback.html',
  'support.html',
  'feature-requests.html',
  'press.html',
  'privacy.html',
  'terms.html',
  'launch-day.html',
];

const SAFE_INLINE_TAGS = new Set(['strong', 'em', 'a', 'span', 'br', 'code']);

function lookup(dict, path) {
  return path.split('.').reduce((acc, k) => (acc == null ? undefined : acc[k]), dict);
}

function innerContainsUnsafeNesting(inner) {
  // Find any tag in inner; reject if it's not in our safe inline set.
  const tags = [...inner.matchAll(/<([a-zA-Z][a-zA-Z0-9-]*)\b/g)].map(m => m[1].toLowerCase());
  return tags.some(t => !SAFE_INLINE_TAGS.has(t));
}

function replaceI18nDefaults(html, dict, fileName) {
  // Match a single-line element opening tag that carries data-i18n="path",
  // then capture its innerHTML up to the matching closing tag of the SAME
  // tag name. We assume no nested same-name elements inside (true for our
  // pages — these are leaf <p>/<li>/<span>/<div class="faq-a">/<h1>/<h2> etc).
  //
  // The pattern handles attributes in any order. We deliberately do NOT
  // require data-i18n to be on the opening line only — the opening tag is a
  // single self-contained group.
  const replaced = [];
  const re = /<([a-zA-Z][a-zA-Z0-9-]*)\b([^>]*?\bdata-i18n="([^"]+)"[^>]*)>/g;

  let result = '';
  let cursor = 0;
  let match;
  let changes = 0;
  let skipped = 0;

  while ((match = re.exec(html)) !== null) {
    const [openTag, tagName, attrs, key] = match;
    const openStart = match.index;
    const openEnd = openStart + openTag.length;

    // Find matching close tag, allowing nesting of the same tag inside.
    const closeRe = new RegExp(`</${tagName}>`, 'g');
    const openRe = new RegExp(`<${tagName}\\b`, 'g');
    closeRe.lastIndex = openEnd;
    openRe.lastIndex = openEnd;

    let depth = 1;
    let closeMatch;
    let closeIndex = -1;
    while (depth > 0) {
      closeMatch = closeRe.exec(html);
      if (!closeMatch) break;
      // Count any additional opens of the same tag before this close.
      let nestedOpens = 0;
      let om;
      while ((om = openRe.exec(html)) !== null) {
        if (om.index < closeMatch.index) nestedOpens++;
        else { openRe.lastIndex = om.index; break; }
      }
      depth = depth + nestedOpens - 1;
      if (depth === 0) {
        closeIndex = closeMatch.index;
      } else {
        // Reset openRe to scan after this close for the next iteration.
        openRe.lastIndex = closeMatch.index + closeMatch[0].length;
      }
    }
    if (closeIndex < 0) {
      // Couldn't find a balanced close — copy the rest as-is and bail.
      continue;
    }

    const inner = html.slice(openEnd, closeIndex);
    const fullEnd = closeIndex + `</${tagName}>`.length;

    const value = lookup(dict, key);
    if (typeof value !== 'string') {
      // Append original unchanged.
      result += html.slice(cursor, fullEnd);
      cursor = fullEnd;
      re.lastIndex = fullEnd;
      skipped++;
      continue;
    }

    if (innerContainsUnsafeNesting(inner)) {
      result += html.slice(cursor, fullEnd);
      cursor = fullEnd;
      re.lastIndex = fullEnd;
      skipped++;
      continue;
    }

    result += html.slice(cursor, openEnd);
    result += value;
    result += `</${tagName}>`;
    cursor = fullEnd;
    re.lastIndex = fullEnd;
    changes++;
  }
  result += html.slice(cursor);

  replaced.push({ file: fileName, changes, skipped });
  return { result, changes, skipped };
}

const dict = JSON.parse(await readFile(join(ROOT, 'i18n/en.json'), 'utf8'));

let totalChanges = 0;
let totalSkipped = 0;
for (const page of PAGES) {
  const path = join(ROOT, page);
  let html;
  try {
    html = await readFile(path, 'utf8');
  } catch (e) {
    console.warn(`skip ${page}: ${e.message}`);
    continue;
  }
  const { result, changes, skipped } = replaceI18nDefaults(html, dict, page);
  if (changes > 0) {
    await writeFile(path, result);
  }
  totalChanges += changes;
  totalSkipped += skipped;
  console.log(`${basename(page).padEnd(28)}  +${changes}  skip:${skipped}`);
}
console.log(`---\ntotal updates: ${totalChanges}  total skipped: ${totalSkipped}`);
