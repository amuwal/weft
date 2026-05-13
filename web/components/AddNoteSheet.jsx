/* Linger — AddNoteSheet.jsx
   The 5-second capture sheet. Spring-in, drag-down dismiss. */

import { motion, AnimatePresence } from 'motion/react'
import { useState } from 'react'

const SPRING = { type: 'spring', stiffness: 360, damping: 30 }

export function AddNoteSheet({ open, person, onClose, onSave }) {
  const [body, setBody] = useState('')
  const [followUp, setFollowUp] = useState(false)
  const [date, setDate] = useState(null)

  const handleSave = () => {
    onSave?.({ personId: person?.id, body, followUp, date })
    setBody(''); setFollowUp(false); setDate(null)
    onClose?.()
  }

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          className="sheet-host open"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.22 }}
        >
          <div className="backdrop" onClick={onClose} />
          <motion.div
            className="sheet"
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={SPRING}
            drag="y"
            dragConstraints={{ top: 0, bottom: 0 }}
            dragElastic={0.3}
            onDragEnd={(_, info) => info.offset.y > 100 && onClose?.()}
          >
            <div className="grabber" />
            <div className="hero" style={{ padding: '6px 0 18px' }}>
              <h1 style={{ fontSize: 24 }}>Note about…</h1>
            </div>

            <button className="pressable" style={{
              display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px',
              borderRadius: 14, background: 'var(--surface-2)',
              border: '0.5px solid var(--line-strong)', marginBottom: 18, textAlign: 'left'
            }}>
              <div className="av-sm a-rose" style={{ width: 32, height: 32, fontSize: 14 }}>
                {person?.initial}
              </div>
              <span style={{ flex: 1, fontSize: 17 }}>{person?.name}</span>
            </button>

            <div className="field" style={{ flex: 1 }}>
              <textarea
                placeholder="Coffee at Verve. She mentioned…"
                value={body}
                onChange={e => setBody(e.target.value)}
                autoFocus
              />
            </div>

            <div className="toggle-row" style={{ borderBottom: 0, padding: '8px 0 16px' }}>
              <span style={{ fontSize: 15 }}>Follow up on this</span>
              <div
                className={`toggle ${followUp ? 'on' : ''}`}
                onClick={() => setFollowUp(!followUp)}
              />
            </div>

            <motion.button
              className="btn primary block"
              whileTap={{ scale: 0.97 }}
              transition={SPRING}
              onClick={handleSave}
            >
              Save
            </motion.button>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
