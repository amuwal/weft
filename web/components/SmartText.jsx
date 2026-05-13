/* Linger — SmartText.jsx
   Word-by-word staggered reveal. Mirrors the .animate-words helper in
   js/interactions.js but with React state, so it can re-trigger when
   props change (e.g. swapping the headline on a route transition).

   Inspired by @leouiux's "Smart Animate Text" pattern observed in
   the user's X feed — see design/inspiration-x.md.

   Usage:
     <SmartText
       as="h1"
       className="display"
       stagger={55}                  // ms between words
       text={["A ", <em>quiet</em>, " place for the people who matter."]}
     />
   ────────────────────────────────────────────────────────────── */

import { Children, isValidElement, cloneElement, useMemo } from 'react'
import { motion } from 'motion/react'

const SPRING = { type: 'spring', stiffness: 220, damping: 26 }

function tokenize(node, out = [], depth = 0) {
  if (typeof node === 'string') {
    const parts = node.split(/(\s+)/).filter(Boolean)
    for (const p of parts) out.push({ kind: /^\s+$/.test(p) ? 'space' : 'word', text: p })
  } else if (Array.isArray(node)) {
    node.forEach(n => tokenize(n, out, depth + 1))
  } else if (isValidElement(node)) {
    if (node.type === 'br') { out.push({ kind: 'br' }); return out }
    // recurse into the element's children, then wrap the result back in the same element
    const inner = []
    tokenize(node.props.children, inner, depth + 1)
    out.push({ kind: 'wrap', el: node, inner })
  }
  return out
}

function renderTokens(tokens, getDelay) {
  return tokens.map((tok, i) => {
    if (tok.kind === 'space') return tok.text
    if (tok.kind === 'br') return <br key={'br' + i} />
    if (tok.kind === 'word') {
      return (
        <motion.span
          key={'w' + i}
          style={{ display: 'inline-block', willChange: 'transform' }}
          initial={{ opacity: 0, y: '0.5em' }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ ...SPRING, delay: getDelay() }}
        >
          {tok.text}
        </motion.span>
      )
    }
    if (tok.kind === 'wrap') {
      return cloneElement(tok.el, { key: 'wr' + i }, renderTokens(tok.inner, getDelay))
    }
    return null
  })
}

export function SmartText({
  as: Tag = 'span',
  text,
  stagger = 55,
  className,
  style,
  ...rest
}) {
  const tokens = useMemo(() => {
    const out = []
    tokenize(text, out)
    return out
  }, [text])

  let wordIndex = 0
  const getDelay = () => (wordIndex++ * stagger) / 1000

  return (
    <Tag className={className} style={style} {...rest}>
      {renderTokens(tokens, getDelay)}
    </Tag>
  )
}
