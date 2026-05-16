"use client";

import { useEffect, useRef, useState } from "react";
import { toPng } from "html-to-image";

// ── Canvas (design at the largest required iPhone size: 6.9") ────────────────
const W = 1320;
const H = 2868;

// ── Export sizes Apple wants for iPhone (portrait) ───────────────────────────
const IPHONE_SIZES = [
  { label: '6.9"', w: 1320, h: 2868 },
  { label: '6.5"', w: 1284, h: 2778 },
  { label: '6.3"', w: 1206, h: 2622 },
] as const;

// ── Phone mockup metrics (pre-measured for the bundled mockup.png) ───────────
const MK_W = 1022;
const MK_H = 2082;
const SC_L = (52 / MK_W) * 100;
const SC_T = (46 / MK_H) * 100;
const SC_W = (918 / MK_W) * 100;
const SC_H = (1990 / MK_H) * 100;
const SC_RX = (126 / 918) * 100;
const SC_RY = (126 / 1990) * 100;

// ── Brand palette ────────────────────────────────────────────────────────────
const CREAM = "#F8F5EF";
const INK = "#161410";
const SAGE = "#5C7A66";
const SAGE_INK = "#3F5849";
const WARM = "#C68A3A";
const MUTED = "#6E665C";

type Locale = "en" | "ja";
const LOCALES: Locale[] = ["en", "ja"];

// ── Copy (one idea per slide, two lines max) ─────────────────────────────────
type Copy = { label: string; head1: string; head2?: string };
type SlideCopy = Record<Locale, Copy>;

const COPY: SlideCopy[] = [
  // 1 — Hero
  {
    en: { label: "WEFT", head1: "Stay close to the", head2: "people who matter." },
    ja: { label: "WEFT", head1: "大切な人と、", head2: "近くいよう。" },
  },
  // 2 — Specific differentiator
  {
    en: { label: "BUILT FOR FEW", head1: "5 to 25 people.", head2: "Not 500." },
    ja: { label: "ほんの数人のために", head1: "5〜25人。", head2: "500人じゃない。" },
  },
  // 3 — Privacy / anti-AI (dark contrast)
  {
    en: { label: "PRIVATE BY DESIGN", head1: "No cloud LLM ever", head2: "reads your notes." },
    ja: { label: "プライバシーは前提", head1: "クラウドAIは、", head2: "メモを読みません。" },
  },
  // 4 — The note
  {
    en: { label: "A LINE A WEEK", head1: "A line.", head2: "A timestamp. Enough." },
    ja: { label: "週に一行", head1: "一行。日付。", head2: "それだけ。" },
  },
  // 5 — Widget
  {
    en: { label: "ALWAYS THERE", head1: "Today,", head2: "on your home screen." },
    ja: { label: "いつでもそこに", head1: "今日を、", head2: "ホーム画面に。" },
  },
  // 6 — Anti-features (dark contrast)
  {
    en: { label: "CALM BY DESIGN", head1: "No streaks.", head2: "No nudges. No AI." },
    ja: { label: "静けさを設計に", head1: "ストリーク無し。", head2: "通知無し。AI無し。" },
  },
];

const TODAY_LABEL: Record<Locale, string> = { en: "Today", ja: "今日" };

// ── Theme per slide ──────────────────────────────────────────────────────────
type SlideTheme = "cream" | "ink";
const SLIDE_THEMES: SlideTheme[] = ["cream", "cream", "ink", "cream", "cream", "ink"];

function isDark(t: SlideTheme): boolean {
  return t === "ink";
}
function bgColor(t: SlideTheme): string {
  return isDark(t) ? INK : CREAM;
}
function fgColor(t: SlideTheme): string {
  return isDark(t) ? CREAM : INK;
}
function labelColor(t: SlideTheme): string {
  return isDark(t) ? "rgba(248, 245, 239, 0.55)" : "rgba(22, 20, 16, 0.5)";
}

// ── Phone (mockup.png + screenshot inside) ───────────────────────────────────
function Phone({
  src,
  width,
  style,
}: {
  src: string;
  width: number;
  style?: React.CSSProperties;
}) {
  return (
    <div
      style={{
        position: "relative",
        width,
        aspectRatio: `${MK_W}/${MK_H}`,
        ...style,
      }}
    >
      <img
        src="/mockup.png"
        alt=""
        style={{ display: "block", width: "100%", height: "100%" }}
        draggable={false}
      />
      <div
        style={{
          position: "absolute",
          zIndex: 10,
          overflow: "hidden",
          left: `${SC_L}%`,
          top: `${SC_T}%`,
          width: `${SC_W}%`,
          height: `${SC_H}%`,
          borderRadius: `${SC_RX}% / ${SC_RY}%`,
        }}
      >
        <img
          src={src}
          alt=""
          style={{
            display: "block",
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: "top",
          }}
          draggable={false}
        />
      </div>
    </div>
  );
}

// ── Caption ─────────────────────────────────────────────────────────────────
function Caption({
  label,
  head1,
  head2,
  theme,
  serifJa = false,
}: {
  label: string;
  head1: string;
  head2?: string;
  theme: SlideTheme;
  serifJa?: boolean;
}) {
  const serifStack = serifJa
    ? '"Noto Serif JP", var(--font-serif), ui-serif, Georgia, serif'
    : "var(--font-serif), ui-serif, Georgia, serif";
  const sansStack = serifJa
    ? '"Noto Sans JP", var(--font-sans), -apple-system, system-ui, sans-serif'
    : "var(--font-sans), -apple-system, system-ui, sans-serif";

  return (
    <div
      style={{
        textAlign: "center",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 28,
        width: "100%",
      }}
    >
      <div
        style={{
          fontFamily: sansStack,
          fontSize: 30,
          letterSpacing: 6,
          fontWeight: 500,
          color: labelColor(theme),
          textTransform: "uppercase",
        }}
      >
        {label}
      </div>
      <div
        style={{
          fontFamily: serifStack,
          fontWeight: 500,
          fontSize: 124,
          lineHeight: 1.05,
          letterSpacing: -1.8,
          color: fgColor(theme),
        }}
      >
        {head1}
        {head2 && (
          <>
            <br />
            {head2}
          </>
        )}
      </div>
    </div>
  );
}

// ── Widget mocks (iOS Small / Medium / Large) ───────────────────────────────
const ROWS = (locale: Locale) => [
  { letter: "S", name: "Sarah", sub: locale === "ja" ? "3週間" : "3 weeks", color: "#F0DEE1" },
  { letter: "A", name: "Alex", sub: locale === "ja" ? "8週間" : "8 weeks", color: "#EBD7BE" },
  { letter: "D", name: "Dad", sub: locale === "ja" ? "2週間" : "2 weeks", color: "#E7D1C0" },
  { letter: "M", name: "Mom", sub: locale === "ja" ? "1週間" : "1 week", color: "#DDD4C5" },
  { letter: "P", name: "Priya", sub: locale === "ja" ? "5週間" : "5 weeks", color: "#EFD4BA" },
];

function widgetFonts(locale: Locale) {
  const serifJa = locale === "ja";
  return {
    serif: serifJa
      ? '"Noto Serif JP", var(--font-serif), ui-serif, Georgia, serif'
      : "var(--font-serif), ui-serif, Georgia, serif",
    sans: serifJa
      ? '"Noto Sans JP", var(--font-sans), -apple-system, system-ui, sans-serif'
      : "var(--font-sans), -apple-system, system-ui, sans-serif",
  };
}

const WIDGET_SHADOW =
  "0 1px 0 rgba(255,255,255,0.6) inset, 0 24px 60px rgba(22,20,16,0.18), 0 60px 120px rgba(22,20,16,0.10)";

function WidgetSmall({ locale }: { locale: Locale }) {
  const { serif, sans } = widgetFonts(locale);
  const r = ROWS(locale)[0];
  return (
    <div
      style={{
        width: 360,
        height: 360,
        background: "#FFFFFF",
        borderRadius: 52,
        padding: "30px 34px",
        boxShadow: WIDGET_SHADOW,
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
      }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
        <div style={{ fontFamily: serif, fontWeight: 500, fontSize: 36, color: INK }}>
          {TODAY_LABEL[locale]}
        </div>
        <div style={{ fontFamily: serif, fontSize: 20, color: MUTED }}>Weft.</div>
      </div>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-start", gap: 14 }}>
        <div
          style={{
            width: 84,
            height: 84,
            borderRadius: "50%",
            background: r.color,
            display: "grid",
            placeItems: "center",
            fontFamily: serif,
            fontSize: 42,
            color: INK,
          }}
        >
          {r.letter}
        </div>
        <div style={{ fontFamily: sans, fontWeight: 600, fontSize: 38, color: INK }}>{r.name}</div>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <div style={{ width: 10, height: 10, borderRadius: "50%", background: WARM }} />
          <div style={{ fontFamily: sans, fontSize: 22, color: MUTED }}>{r.sub}</div>
        </div>
      </div>
    </div>
  );
}

function WidgetMedium({ locale }: { locale: Locale }) {
  const { serif, sans } = widgetFonts(locale);
  const rows = ROWS(locale).slice(0, 3);
  return (
    <div
      style={{
        width: 760,
        height: 360,
        background: "#FFFFFF",
        borderRadius: 52,
        padding: "28px 36px",
        boxShadow: WIDGET_SHADOW,
        display: "flex",
        flexDirection: "column",
        gap: 16,
      }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
        <div style={{ fontFamily: serif, fontWeight: 500, fontSize: 42, color: INK }}>
          {TODAY_LABEL[locale]}
        </div>
        <div style={{ fontFamily: serif, fontSize: 22, color: MUTED }}>Weft.</div>
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 18 }}>
        {rows.map((r) => (
          <div key={r.letter} style={{ display: "flex", alignItems: "center", gap: 20 }}>
            <div
              style={{
                width: 56,
                height: 56,
                borderRadius: "50%",
                background: r.color,
                display: "grid",
                placeItems: "center",
                fontFamily: serif,
                fontSize: 28,
                color: INK,
              }}
            >
              {r.letter}
            </div>
            <div style={{ fontFamily: sans, fontWeight: 600, fontSize: 28, color: INK, flex: 1 }}>
              {r.name}
            </div>
            <div style={{ fontFamily: sans, fontSize: 22, color: MUTED }}>{r.sub}</div>
            <div style={{ width: 10, height: 10, borderRadius: "50%", background: WARM }} />
          </div>
        ))}
      </div>
    </div>
  );
}

function WidgetLarge({ locale }: { locale: Locale }) {
  const { serif, sans } = widgetFonts(locale);
  const rows = ROWS(locale);
  return (
    <div
      style={{
        width: 1160,
        height: 760,
        background: "#FFFFFF",
        borderRadius: 56,
        padding: "40px 48px",
        boxShadow: WIDGET_SHADOW,
        display: "flex",
        flexDirection: "column",
        gap: 26,
      }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
        <div style={{ fontFamily: serif, fontWeight: 500, fontSize: 56, color: INK }}>
          {TODAY_LABEL[locale]}
        </div>
        <div style={{ fontFamily: serif, fontSize: 28, color: MUTED }}>Weft.</div>
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 22 }}>
        {rows.map((r) => (
          <div key={r.letter} style={{ display: "flex", alignItems: "center", gap: 24 }}>
            <div
              style={{
                width: 72,
                height: 72,
                borderRadius: "50%",
                background: r.color,
                display: "grid",
                placeItems: "center",
                fontFamily: serif,
                fontSize: 36,
                color: INK,
              }}
            >
              {r.letter}
            </div>
            <div style={{ fontFamily: sans, fontWeight: 600, fontSize: 36, color: INK, flex: 1 }}>
              {r.name}
            </div>
            <div style={{ fontFamily: sans, fontSize: 28, color: MUTED }}>{r.sub}</div>
            <div style={{ width: 12, height: 12, borderRadius: "50%", background: WARM }} />
          </div>
        ))}
      </div>
    </div>
  );
}

// ── Slide chrome ────────────────────────────────────────────────────────────
function SlideFrame({
  theme,
  children,
}: {
  theme: SlideTheme;
  children: React.ReactNode;
}) {
  return (
    <div
      style={{
        width: W,
        height: H,
        background: bgColor(theme),
        position: "relative",
        overflow: "hidden",
      }}
    >
      {children}
    </div>
  );
}

// ── Slide layouts (varied per slot) ─────────────────────────────────────────
type SlideProps = { locale: Locale; copyIndex: number };

function SlideHero({ locale, copyIndex }: SlideProps) {
  const theme = SLIDE_THEMES[copyIndex];
  const c = COPY[copyIndex][locale];
  return (
    <SlideFrame theme={theme}>
      <div
        style={{
          padding: "200px 100px 0",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 100,
          height: "100%",
        }}
      >
        <Caption {...c} theme={theme} serifJa={locale === "ja"} />
        <Phone src={`/screenshots/${locale}/today.png`} width={900} />
      </div>
    </SlideFrame>
  );
}

function SlideSpecific({ locale, copyIndex }: SlideProps) {
  const theme = SLIDE_THEMES[copyIndex];
  const c = COPY[copyIndex][locale];
  return (
    <SlideFrame theme={theme}>
      <div
        style={{
          padding: "200px 100px 0",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 100,
          height: "100%",
        }}
      >
        <Caption {...c} theme={theme} serifJa={locale === "ja"} />
        <Phone src={`/screenshots/${locale}/people.png`} width={900} />
      </div>
    </SlideFrame>
  );
}

function SlidePrivacy({ locale, copyIndex }: SlideProps) {
  const theme = SLIDE_THEMES[copyIndex];
  const c = COPY[copyIndex][locale];
  return (
    <SlideFrame theme={theme}>
      <div
        style={{
          padding: "200px 100px 0",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 90,
          height: "100%",
          position: "relative",
        }}
      >
        <Caption {...c} theme={theme} serifJa={locale === "ja"} />
        <div style={{ position: "relative", display: "flex", justifyContent: "center" }}>
          <div
            style={{
              position: "absolute",
              inset: -80,
              background:
                "radial-gradient(circle at 50% 50%, rgba(92, 122, 102, 0.30), transparent 70%)",
              filter: "blur(40px)",
              zIndex: 0,
            }}
          />
          <Phone src={`/screenshots/${locale}/settings.png`} width={860} style={{ position: "relative", zIndex: 1 }} />
        </div>
      </div>
    </SlideFrame>
  );
}

function SlideNote({ locale, copyIndex }: SlideProps) {
  const theme = SLIDE_THEMES[copyIndex];
  const c = COPY[copyIndex][locale];
  return (
    <SlideFrame theme={theme}>
      <div
        style={{
          padding: "200px 100px 0",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 100,
          height: "100%",
        }}
      >
        <Caption {...c} theme={theme} serifJa={locale === "ja"} />
        <Phone src={`/screenshots/${locale}/person-detail.png`} width={900} />
      </div>
    </SlideFrame>
  );
}

function SlideWidget({ locale, copyIndex }: SlideProps) {
  const theme = SLIDE_THEMES[copyIndex];
  const c = COPY[copyIndex][locale];
  return (
    <SlideFrame theme={theme}>
      {/* Soft sage glow centered behind the widget cluster */}
      <div
        style={{
          position: "absolute",
          left: "50%",
          top: 1900,
          transform: "translate(-50%, -50%)",
          width: 1300,
          height: 1500,
          background:
            "radial-gradient(ellipse at 50% 50%, rgba(92, 122, 102, 0.22) 0%, transparent 65%)",
          filter: "blur(60px)",
          zIndex: 0,
        }}
      />
      <div
        style={{
          padding: "200px 80px 0",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 90,
          height: "100%",
          position: "relative",
          zIndex: 1,
        }}
      >
        <Caption {...c} theme={theme} serifJa={locale === "ja"} />
        {/* Widget cluster: small + medium top row, large below */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 40,
          }}
        >
          <div style={{ display: "flex", alignItems: "flex-start", gap: 40 }}>
            <WidgetSmall locale={locale} />
            <WidgetMedium locale={locale} />
          </div>
          <WidgetLarge locale={locale} />
        </div>
      </div>
    </SlideFrame>
  );
}

function SlideAnti({ locale, copyIndex }: SlideProps) {
  const theme = SLIDE_THEMES[copyIndex];
  const c = COPY[copyIndex][locale];
  const serifStack =
    locale === "ja"
      ? '"Noto Serif JP", var(--font-serif), ui-serif, Georgia, serif'
      : "var(--font-serif), ui-serif, Georgia, serif";
  return (
    <SlideFrame theme={theme}>
      <div
        style={{
          padding: "100px",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          height: "100%",
          gap: 60,
        }}
      >
        <Caption {...c} theme={theme} serifJa={locale === "ja"} />
        <div
          style={{
            fontFamily: serifStack,
            fontStyle: "italic",
            fontSize: 40,
            color: "rgba(248, 245, 239, 0.55)",
            marginTop: 30,
            letterSpacing: 0.3,
          }}
        >
          {locale === "ja" ? "—  ただ、近くにいる。" : "—  just be near."}
        </div>
      </div>
    </SlideFrame>
  );
}

const SLIDES = [SlideHero, SlideSpecific, SlidePrivacy, SlideNote, SlideWidget, SlideAnti];

// ── Page ────────────────────────────────────────────────────────────────────
export default function Page() {
  const [locale, setLocale] = useState<Locale>("en");
  const [busy, setBusy] = useState(false);

  return (
    <div
      style={{
        minHeight: "100vh",
        background: "#1a1916",
        color: "#efece6",
        padding: 24,
        position: "relative",
        overflowX: "hidden",
      }}
    >
      <Toolbar locale={locale} setLocale={setLocale} busy={busy} setBusy={setBusy} />

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(3, 1fr)",
          gap: 32,
          marginTop: 24,
        }}
      >
        {SLIDES.map((S, i) => (
          <SlideCard key={i} index={i}>
            <S locale={locale} copyIndex={i} />
          </SlideCard>
        ))}
      </div>
    </div>
  );
}

function Toolbar({
  locale,
  setLocale,
  busy,
  setBusy,
}: {
  locale: Locale;
  setLocale: (l: Locale) => void;
  busy: boolean;
  setBusy: (b: boolean) => void;
}) {
  async function exportSet(sizes: typeof IPHONE_SIZES | readonly { label: string; w: number; h: number }[]) {
    setBusy(true);
    try {
      for (let i = 0; i < SLIDES.length; i++) {
        for (const size of sizes) {
          await exportOne(i, size.w, size.h, size.label, locale);
        }
      }
    } finally {
      setBusy(false);
    }
  }
  return (
    <div
      style={{
        display: "flex",
        gap: 12,
        alignItems: "center",
        padding: "12px 16px",
        background: "#26241f",
        borderRadius: 12,
      }}
    >
      <strong style={{ marginRight: 12 }}>Weft screenshots</strong>
      <label style={{ display: "flex", alignItems: "center", gap: 8 }}>
        Locale:
        <select
          value={locale}
          onChange={(e) => setLocale(e.target.value as Locale)}
          style={{
            background: "#3a3833",
            color: "inherit",
            border: "1px solid #4a4842",
            borderRadius: 6,
            padding: "4px 8px",
          }}
        >
          {LOCALES.map((l) => (
            <option key={l} value={l}>
              {l.toUpperCase()}
            </option>
          ))}
        </select>
      </label>
      <div style={{ flex: 1 }} />
      <button disabled={busy} onClick={() => exportSet([IPHONE_SIZES[0]])} style={btn(busy)}>
        Export 6.9″ ({locale})
      </button>
      <button disabled={busy} onClick={() => exportSet(IPHONE_SIZES)} style={btn(busy, true)}>
        Export ALL sizes ({locale})
      </button>
    </div>
  );
}

function btn(busy: boolean, primary = false): React.CSSProperties {
  return {
    padding: "8px 16px",
    background: busy ? "#3a3833" : primary ? SAGE : "#3a3833",
    color: primary ? "#fff" : "#efece6",
    border: "1px solid " + (primary ? SAGE_INK : "#4a4842"),
    borderRadius: 6,
    opacity: busy ? 0.5 : 1,
    cursor: busy ? "wait" : "pointer",
  };
}

function SlideCard({ index, children }: { index: number; children: React.ReactNode }) {
  const wrapRef = useRef<HTMLDivElement>(null);
  const innerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!wrapRef.current || !innerRef.current) return;
    const fit = () => {
      const card = wrapRef.current!.getBoundingClientRect();
      const s = card.width / W;
      innerRef.current!.style.transform = `scale(${s})`;
      innerRef.current!.style.transformOrigin = "top left";
      wrapRef.current!.style.height = `${H * s}px`;
    };
    fit();
    const ro = new ResizeObserver(fit);
    ro.observe(wrapRef.current);
    return () => ro.disconnect();
  }, []);

  return (
    <div
      data-slide-index={index}
      style={{
        background: "#0e0d0b",
        borderRadius: 16,
        overflow: "hidden",
        position: "relative",
      }}
    >
      <div ref={wrapRef} style={{ position: "relative", width: "100%", overflow: "hidden" }}>
        <div ref={innerRef} style={{ width: W, height: H }}>
          {children}
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          left: 8,
          top: 8,
          padding: "4px 8px",
          background: "rgba(0,0,0,0.6)",
          borderRadius: 6,
          fontSize: 12,
          pointerEvents: "none",
        }}
      >
        #{index + 1}
      </div>
    </div>
  );
}

// ── Export logic ────────────────────────────────────────────────────────────
async function exportOne(
  slideIndex: number,
  outW: number,
  outH: number,
  sizeLabel: string,
  locale: Locale,
) {
  const inner = document.querySelector(
    `[data-slide-index="${slideIndex}"] [style*="width: ${W}px"]`,
  ) as HTMLElement | null;
  if (!inner) return;

  const prevTransform = inner.style.transform;
  inner.style.transform = "scale(1)";
  inner.style.transformOrigin = "top left";

  try {
    const dataUrl = await toPng(inner, {
      width: W,
      height: H,
      canvasWidth: outW,
      canvasHeight: outH,
      pixelRatio: 1,
      backgroundColor: "#FFFFFF",
      cacheBust: true,
    });

    const a = document.createElement("a");
    const sizeTag = sizeLabel.replace(/[".]/g, "_");
    a.download = `${String(slideIndex + 1).padStart(2, "0")}_${locale}_${sizeTag}.png`;
    a.href = dataUrl;
    a.click();
    await new Promise((r) => setTimeout(r, 250));
  } finally {
    inner.style.transform = prevTransform;
  }
}
