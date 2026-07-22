export interface ChunkItem {
  text: string
  element: Element | null
}

export function useArticleText() {
  const getArticleChunks = (): ChunkItem[] => {
    if (typeof document === 'undefined') return []
    const docElement = document.querySelector('.vp-doc')
    if (!docElement) return []

    const elements = docElement.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, blockquote')
    const chunks: ChunkItem[] = []

    elements.forEach((el) => {
      // Exclude UI controls, read-aloud component, pre & code blocks
      if (el.closest('.read-aloud-container, pre, .vp-code')) return

      const clone = el.cloneNode(true) as HTMLElement
      clone.querySelectorAll('.line-numbers-wrapper, .copy, .header-anchor, script, style, .read-aloud-container, button, img, svg, code').forEach(child => child.remove())

      let text = clone.innerText || clone.textContent || ''
      text = text
        .replace(/\s+/g, ' ')
        .replace(/\b(e\.g\.|i\.e\.|vs\.|etc\.)/gi, match => match.replace(/\./g, ''))
        .replace(/`([^`]+)`/g, '$1')
        .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
        .trim()

      if (!text) return

      const rawSentences = text.match(/[^.!?\n]+[.!?\n]+/g) || [text]
      let current = ''

      for (const sentence of rawSentences) {
        const trimmed = sentence.trim()
        if (!trimmed) continue
        if ((current + ' ' + trimmed).length > 250) {
          if (current) chunks.push({ text: current.trim(), element: el })
          current = trimmed
        } else {
          current = current ? current + ' ' + trimmed : trimmed
        }
      }
      if (current.trim()) {
        chunks.push({ text: current.trim(), element: el })
      }
    })

    return chunks
  }

  const highlightElement = (el: Element | null) => {
    if (typeof document === 'undefined') return

    document.querySelectorAll('.read-aloud-highlight').forEach(item => {
      item.classList.remove('read-aloud-highlight')
    })

    if (el) {
      el.classList.add('read-aloud-highlight')
      el.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
    }
  }

  const clearHighlight = () => {
    if (typeof document === 'undefined') return
    document.querySelectorAll('.read-aloud-highlight').forEach(item => {
      item.classList.remove('read-aloud-highlight')
    })
  }

  return {
    getArticleChunks,
    highlightElement,
    clearHighlight,
  }
}
