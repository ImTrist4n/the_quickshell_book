export function useArticleText() {
  const getArticleText = (): string => {
    if (typeof document === 'undefined') return ''
    const docElement = document.querySelector('.vp-doc')
    if (!docElement) return ''

    const clone = docElement.cloneNode(true) as HTMLElement
    
    // Remove non-text UI elements
    clone.querySelectorAll('.line-numbers-wrapper, .copy, .header-anchor, script, style, .read-aloud-container, nav, footer, .VPNav, .VPFooter, button, img, svg, .vp-code, pre, code').forEach(el => el.remove())
    
    let text = clone.innerText || clone.textContent || ''
    
    // Normalize text for natural speech pacing
    text = text
      .replace(/#{1,6}\s+/g, '. ')
      .replace(/^[\s]*[-*+]\s+/gm, '. ')
      .replace(/\n+/g, '. ')
      .replace(/\s+/g, ' ')
      .replace(/\b(e\.g\.|i\.e\.|vs\.|etc\.)/gi, match => match.replace(/\./g, ''))
      .replace(/([.!?])\s*([A-Z])/g, '$1 $2')
      .replace(/`([^`]+)`/g, '$1')
      .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
      .trim()
      
    return text
  }

  const splitIntoChunks = (text: string): string[] => {
    const rawSentences = text.match(/[^.!?\n]+[.!?\n]+/g) || [text]
    const result: string[] = []
    let current = ''

    for (const sentence of rawSentences) {
      const trimmed = sentence.trim()
      if (!trimmed) continue
      if ((current + ' ' + trimmed).length > 250) {
        if (current) result.push(current.trim())
        current = trimmed
      } else {
        current = current ? current + ' ' + trimmed : trimmed
      }
    }
    if (current.trim()) result.push(current.trim())
    return result.length > 0 ? result : [text]
  }

  return {
    getArticleText,
    splitIntoChunks,
  }
}
