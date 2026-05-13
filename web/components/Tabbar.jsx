/* Linger — Tabbar.jsx
   iOS 26 Liquid Glass tab bar with FAB. */

import { motion } from 'motion/react'
import { useState } from 'react'

const SPRING = { type: 'spring', stiffness: 360, damping: 30 }

export function Tabbar({ tabs = ['Today', 'People'], active = 'Today', onTab, onAdd }) {
  return (
    <div className="tabbar-host">
      <div className="glass tab-bar fab-tabbar refraction">
        <div className="tabbar">
          {tabs.map(t => (
            <motion.button
              key={t}
              className="tab"
              aria-selected={t === active}
              onClick={() => onTab?.(t)}
              whileTap={{ scale: 0.94 }}
              transition={SPRING}
            >
              <span className="label">{t}</span>
            </motion.button>
          ))}
        </div>
      </div>
      <motion.button
        className="fab"
        aria-label="Add"
        whileTap={{ scale: 0.9 }}
        transition={SPRING}
        onClick={onAdd}
      >
        +
      </motion.button>
    </div>
  )
}
