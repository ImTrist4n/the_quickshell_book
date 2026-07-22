import { ref, onMounted, onUnmounted } from 'vue'

export function useBrowserTTS() {
  const isBrowserSupported = ref(false)
  const browserVoices = ref<SpeechSynthesisVoice[]>([])
  const selectedBrowserVoiceIndex = ref(0)
  let currentUtterance: SpeechSynthesisUtterance | null = null

  const loadBrowserVoices = () => {
    if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
      const voices = window.speechSynthesis.getVoices()
      if (!voices || voices.length === 0) return
      
      const scoreVoice = (v: SpeechSynthesisVoice) => {
        let score = 0
        const name = v.name.toLowerCase()
        if (name.includes('google') && name.includes('us english')) score += 1000
        if (name.includes('microsoft') && (name.includes('jenny') || name.includes('guy') || name.includes('aria'))) score += 1000
        if (name.includes('samantha') || name.includes('alex') || name.includes('daniel')) score += 900
        if (name.includes('google') || name.includes('microsoft') || name.includes('natural')) score += 500
        if (v.lang === 'en-US') score += 100
        else if (v.lang.startsWith('en')) score += 50
        if (v.default) score += 200
        return score
      }
      
      const sortedVoices = [...voices].sort((a, b) => scoreVoice(b) - scoreVoice(a))
      const englishVoices = sortedVoices.filter(v => v.lang.startsWith('en'))
      browserVoices.value = englishVoices.length > 0 ? englishVoices : sortedVoices
    }
  }

  onMounted(() => {
    if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
      isBrowserSupported.value = true
      loadBrowserVoices()
      window.speechSynthesis.onvoiceschanged = loadBrowserVoices
    } else {
      isBrowserSupported.value = false
    }
  })

  onUnmounted(() => {
    if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
      if (window.speechSynthesis.onvoiceschanged === loadBrowserVoices) {
        window.speechSynthesis.onvoiceschanged = null
      }
      window.speechSynthesis.cancel()
    }
    currentUtterance = null
  })

  const speakBrowserChunk = (
    text: string,
    rate: number,
    onStart: () => void,
    onEnd: () => void,
    onError: (err: any) => void
  ) => {
    if (typeof window === 'undefined' || !('speechSynthesis' in window)) return

    window.speechSynthesis.cancel()

    const utterance = new SpeechSynthesisUtterance(text)
    const voice = browserVoices.value[selectedBrowserVoiceIndex.value]
    if (voice) {
      utterance.voice = voice
      utterance.lang = voice.lang
    }

    utterance.rate = rate
    utterance.pitch = 1.0
    utterance.volume = 1.0

    utterance.onstart = () => onStart()
    utterance.onend = () => onEnd()
    utterance.onerror = (event) => onError(event)

    currentUtterance = utterance
    window.speechSynthesis.speak(utterance)
  }

  const stopBrowserTTS = () => {
    if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
      window.speechSynthesis.cancel()
    }
    currentUtterance = null
  }

  return {
    isBrowserSupported,
    browserVoices,
    selectedBrowserVoiceIndex,
    speakBrowserChunk,
    stopBrowserTTS,
  }
}
