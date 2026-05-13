/* ──────────────────────────────────────────────────────────────
   Linger — PersonCard.jsx
   The card on the "Today" screen. Imports the same tokens.css
   the HTML mockup uses. Spring values match design/motion.md.

   Usage (React, Vite):
     import { PersonCard } from './components/PersonCard'
     <PersonCard
       name="Sarah"
       reason="It's been three weeks. Her mom's surgery was on the 14th."
       initial="S"
       palette="rose"
       weeks={3}
       state="late"        // "recent" | "rhythm" | "late"
       today                // styles as the warm "today" card
       onTap={() => …}
       onCaughtUp={() => …}
       onSnooze={() => …}
     />
   ────────────────────────────────────────────────────────────── */

import { useRef, useState } from 'react'
import { motion, useMotionValue, useTransform } from 'motion/react'

const SPRING       = { type: 'spring', stiffness: 360, damping: 30 }
const SPRING_PRESS = { type: 'spring', stiffness: 520, damping: 22 }

const PALETTE = {
  rose:  'a-rose',
  warm:  'a-warm',
  slate: 'a-slate',
  clay:  'a-clay',
  lilac: 'a-lilac',
  blue:  'a-blue',
  sage:  '',          // default
}

export function PersonCard({
  name,
  reason,
  initial,
  palette = 'sage',
  weeks,
  state = 'rhythm',
  today = false,
  onTap,
  onCaughtUp,
  onSnooze,
}) {
  const x = useMotionValue(0)
  const scale   = useTransform(x, [-120, 0, 200], [0.94, 1, 0.92])
  const opacity = useTransform(x, [-200, -60, 0, 60, 200], [0, 0.85, 1, 0.85, 0])
  const [resolved, setResolved] = useState(false)

  const onDragEnd = (_, info) => {
    if (info.offset.x > 90) {
      onCaughtUp?.()
      setResolved(true)
    } else if (info.offset.x < -90) {
      onSnooze?.()
    }
  }

  if (resolved) {
    return (
      <motion.div
        initial={{ opacity: 1, scale: 1 }}
        animate={{ opacity: 0, scale: 0.96 }}
        transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
        className="p-card-resolved"
        style={{
          height: 80,
          display: 'grid',
          placeItems: 'center',
          color: 'var(--sage)',
          fontFamily: 'var(--serif)',
          fontStyle: 'italic',
          fontSize: 16,
        }}
      >
        Caught up with {name}.
      </motion.div>
    )
  }

  return (
    <motion.article
      className={`p-card ${today ? 'today' : ''} pressable`}
      style={{ x, scale, opacity, touchAction: 'pan-y' }}
      drag="x"
      dragConstraints={{ left: -80, right: 200 }}
      dragElastic={0.35}
      onDragEnd={onDragEnd}
      whileTap={{ scale: 0.97 }}
      transition={SPRING_PRESS}
      onClick={onTap}
    >
      <div className={`avatar ${PALETTE[palette]}`}>{initial}</div>
      <div className="who">
        <span className="name">{name}</span>
        <span className="reason">{reason}</span>
      </div>
      <div className="meta">
        <span className={`dot ${state}`} />
        <span className="cap tabular">
          {typeof weeks === 'number' ? `${weeks}w` : weeks}
        </span>
      </div>
    </motion.article>
  )
}

/* ── usage example ─────────────────────────────────────────────
import { PersonCard } from './components/PersonCard'
import { AnimatePresence } from 'motion/react'

export default function Today() {
  return (
    <div className="canvas">
      <header className="hero">
        <div className="eyebrow tabular">Wednesday, May 13</div>
        <h1>Who's on your<br/>mind today?</h1>
      </header>
      <AnimatePresence>
        <PersonCard
          name="Sarah"
          reason="It's been three weeks. Her mom's surgery was on the 14th."
          initial="S" palette="rose" weeks={3} state="late" today
          onCaughtUp={() => markCaughtUp('sarah')}
        />
        <PersonCard
          name="David"
          reason="He starts the new job Monday — wish him luck."
          initial="D" palette="slate" weeks="soon" state="recent"
        />
      </AnimatePresence>
    </div>
  )
}
─────────────────────────────────────────────────────────────── */
