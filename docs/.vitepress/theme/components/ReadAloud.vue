<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vitepress'

const route = useRoute()

const isSupported = ref(true)
const isPlaying = ref(false)
const isPaused = ref(false)
const isLoadingModel = ref(false)
const loadingProgress = ref('')
const currentRate = ref(1.0)
const rates = [0.8, 1.0, 1.25, 1.5, 2.0]

// Engine selection
const ttsMode = ref<'puter' | 'browser'>('puter')

// Puter OpenAI voices
const puterVoices = [
  { id: 'nova', name: 'Nova (Female - Natural)', provider: 'openai' },
  { id: 'alloy', name: 'Alloy (Neutral - Clear)', provider: 'openai' },
  { id: 'echo', name: 'Echo (Male - Warm)', provider: 'openai' },
  { id: 'fable', name: 'Fable (Expressive - Story)', provider: 'openai' },
  { id: 'onyx', name: 'Onyx (Male - Deep)', provider: 'openai' },
  { id: 'shimmer', name: 'Shimmer (Female - Soft)', provider: 'openai' },
]
const selectedPuterVoice = ref('nova')

// Browser voices
const browserVoices = ref<SpeechSynthesisVoice[]>([])
const selectedBrowserVoiceIndex = ref(0)

const chunks = ref<string[]>([])
const currentChunkIndex = ref(0)
let currentAudio: HTMLAudioElement | null = null
let currentUtterance: SpeechSynthesisUtterance | null = null

// Audio cache and background prefetch maps
const audioCache = new Map<string, HTMLAudioElement>()
const prefetchMap = new Map<string, Promise<HTMLAudioElement | null>>()

const clearAudioCache = () => {
  audioCache.forEach(audio => {
    audio.pause()
    audio.src = ''
  })
  audioCache.clear()
  prefetchMap.clear()
}

const stopSpeech = () => {
  isPlaying.value = false
  isPaused.value = false
  isLoadingModel.value = false
  loadingProgress.value = ''
  currentChunkIndex.value = 0
  chunks.value = []
  
  if (currentAudio) {
    currentAudio.pause()
    currentAudio = null
  }

  if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
    window.speechSynthesis.cancel()
  }
  currentUtterance = null
}

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

// Prefetch audio chunk in background and store in cache
const fetchChunkAudio = (chunkIndex: number): Promise<HTMLAudioElement | null> => {
  if (chunkIndex < 0 || chunkIndex >= chunks.value.length) {
    return Promise.resolve(null)
  }

  const cacheKey = `${selectedPuterVoice.value}:${chunkIndex}:${chunks.value[chunkIndex]}`

  if (audioCache.has(cacheKey)) {
    return Promise.resolve(audioCache.get(cacheKey)!)
  }

  if (prefetchMap.has(cacheKey)) {
    return prefetchMap.get(cacheKey)!
  }

  const promise = (async () => {
    try {
      const puterModule = await import('@heyputer/puter.js')
      const puter = puterModule.default || puterModule.puter || puterModule

      const audio = await puter.ai.txt2speech(chunks.value[chunkIndex], {
        provider: 'openai',
        model: 'tts-1',
        voice: selectedPuterVoice.value,
      })

      audioCache.set(cacheKey, audio)
      prefetchMap.delete(cacheKey)
      return audio
    } catch (err) {
      console.warn(`Failed to prefetch Puter AI chunk ${chunkIndex}:`, err)
      prefetchMap.delete(cacheKey)
      return null
    }
  })()

  prefetchMap.set(cacheKey, promise)
  return promise
}

const speakCurrentPuterChunk = async () => {
  if (currentChunkIndex.value >= chunks.value.length) {
    isPlaying.value = false
    isPaused.value = false
    isLoadingModel.value = false
    loadingProgress.value = ''
    currentChunkIndex.value = 0
    return
  }

  const idx = currentChunkIndex.value
  const cacheKey = `${selectedPuterVoice.value}:${idx}:${chunks.value[idx]}`

  // Show loading indicator only if chunk is not yet cached
  if (!audioCache.has(cacheKey)) {
    isLoadingModel.value = true
    loadingProgress.value = `Loading AI audio (${idx + 1}/${chunks.value.length})...`
  }

  const audio = await fetchChunkAudio(idx)

  if (!audio || !isPlaying.value) {
    isLoadingModel.value = false
    loadingProgress.value = ''
    if (!audio) {
      // Fallback to browser if Puter API fails
      ttsMode.value = 'browser'
      speakCurrentBrowserChunk()
    }
    return
  }

  isLoadingModel.value = false
  loadingProgress.value = ''

  if (currentAudio && currentAudio !== audio) {
    currentAudio.pause()
  }

  currentAudio = audio
  currentAudio.currentTime = 0
  currentAudio.playbackRate = currentRate.value

  // Trigger background pre-fetch for the NEXT 2 chunks so playback never waits!
  fetchChunkAudio(idx + 1)
  fetchChunkAudio(idx + 2)

  audio.onended = () => {
    if (!isPlaying.value || isPaused.value) return
    currentChunkIndex.value++
    if (currentChunkIndex.value < chunks.value.length) {
      speakCurrentPuterChunk()
    } else {
      isPlaying.value = false
      isPaused.value = false
      currentChunkIndex.value = 0
    }
  }

  audio.onerror = (e: any) => {
    console.warn('Puter audio chunk error, skipping to next:', e)
    currentChunkIndex.value++
    if (isPlaying.value && !isPaused.value && currentChunkIndex.value < chunks.value.length) {
      speakCurrentPuterChunk()
    } else {
      isPlaying.value = false
      isPaused.value = false
    }
  }

  await audio.play().catch(() => {})
}

const speakCurrentBrowserChunk = () => {
  if (typeof window === 'undefined' || !('speechSynthesis' in window)) return
  if (currentChunkIndex.value >= chunks.value.length) {
    isPlaying.value = false
    isPaused.value = false
    currentChunkIndex.value = 0
    return
  }

  window.speechSynthesis.cancel()

  const text = chunks.value[currentChunkIndex.value]
  const utterance = new SpeechSynthesisUtterance(text)
  const voice = browserVoices.value[selectedBrowserVoiceIndex.value]
  
  if (voice) {
    utterance.voice = voice
    utterance.lang = voice.lang
  }
  
  utterance.rate = currentRate.value
  utterance.pitch = 1.0
  utterance.volume = 1.0
  
  utterance.onstart = () => {
    isPlaying.value = true
    isPaused.value = false
  }
  
  utterance.onend = () => {
    if (!isPlaying.value || isPaused.value) return
    currentChunkIndex.value++
    if (currentChunkIndex.value < chunks.value.length) {
      speakCurrentBrowserChunk()
    } else {
      isPlaying.value = false
      isPaused.value = false
      currentChunkIndex.value = 0
    }
  }
  
  utterance.onerror = (event) => {
    if (event.error === 'canceled' || event.error === 'interrupted') return
    console.error('Speech synthesis error:', event.error)
    currentChunkIndex.value++
    if (isPlaying.value && !isPaused.value && currentChunkIndex.value < chunks.value.length) {
      speakCurrentBrowserChunk()
    } else {
      isPlaying.value = false
      isPaused.value = false
    }
  }

  currentUtterance = utterance
  window.speechSynthesis.speak(utterance)
}

const togglePlayPause = async () => {
  if (isPlaying.value && !isPaused.value) {
    // Pause
    isPaused.value = true
    if (ttsMode.value === 'browser') {
      if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
        window.speechSynthesis.cancel()
      }
    } else {
      if (currentAudio) {
        currentAudio.pause()
      }
    }
    return
  }

  if (isPaused.value) {
    // Resume
    isPaused.value = false
    isPlaying.value = true
    if (ttsMode.value === 'browser') {
      speakCurrentBrowserChunk()
    } else {
      if (currentAudio && currentAudio.paused) {
        currentAudio.play().catch(() => {
          speakCurrentPuterChunk()
        })
      } else {
        speakCurrentPuterChunk()
      }
    }
    return
  }

  // Start new speech
  stopSpeech()
  const fullText = getArticleText()
  if (!fullText) return

  chunks.value = splitIntoChunks(fullText)
  currentChunkIndex.value = 0
  isPlaying.value = true
  isPaused.value = false

  if (ttsMode.value === 'puter') {
    // Start pre-fetching first 2 chunks immediately
    fetchChunkAudio(0)
    fetchChunkAudio(1)
    await speakCurrentPuterChunk()
  } else {
    speakCurrentBrowserChunk()
  }
}

const setRate = (rate: number) => {
  currentRate.value = rate
  if (ttsMode.value === 'puter') {
    if (currentAudio) {
      currentAudio.playbackRate = rate
    }
  } else {
    if (isPlaying.value && !isPaused.value) {
      speakCurrentBrowserChunk()
    }
  }
}

const onEngineChange = () => {
  if (isPlaying.value || isPaused.value) {
    stopSpeech()
  }
}

const onVoiceChange = () => {
  clearAudioCache()
  if (isPlaying.value || isPaused.value) {
    stopSpeech()
    setTimeout(() => togglePlayPause(), 50)
  }
}

onMounted(() => {
  if (typeof window !== 'undefined') {
    if (!('speechSynthesis' in window)) {
      isSupported.value = false
    } else {
      loadBrowserVoices()
      window.speechSynthesis.onvoiceschanged = loadBrowserVoices
    }
  }
})

watch(() => route.path, () => {
  stopSpeech()
  clearAudioCache()
})

onUnmounted(() => {
  stopSpeech()
  clearAudioCache()
})
</script>

<template>
  <div v-if="isSupported" class="read-aloud-container">
    <div class="read-aloud-bar">
      <div class="read-aloud-left">
        <button 
          class="action-btn main-btn" 
          :class="{ active: isPlaying && !isPaused, loading: isLoadingModel }"
          :disabled="isLoadingModel"
          @click="togglePlayPause"
          :title="isPlaying && !isPaused ? 'Pause Reading' : (isPaused ? 'Resume Reading' : 'Listen to article')"
        >
          <svg v-if="isLoadingModel" class="spinner" viewBox="0 0 24 24" width="18" height="18">
            <circle class="path" cx="12" cy="12" r="10" fill="none" stroke-width="3"></circle>
          </svg>
          <svg v-else-if="!isPlaying || isPaused" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
            <path d="M8 5v14l11-7z"/>
          </svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
            <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
          </svg>
          <span>{{ isLoadingModel ? 'Loading...' : (isPlaying && !isPaused ? 'Pause' : (isPaused ? 'Resume' : 'Listen')) }}</span>
        </button>

        <button 
          v-if="isPlaying || isPaused"
          class="action-btn stop-btn" 
          @click="stopSpeech"
          title="Stop Reading"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
            <path d="M6 6h12v12H6z"/>
          </svg>
        </button>

        <span v-if="isLoadingModel" class="loading-text">{{ loadingProgress }}</span>
      </div>

      <div class="read-aloud-right">
        <!-- TTS Engine Selector -->
        <select 
          v-model="ttsMode" 
          @change="onEngineChange"
          class="mode-select"
          title="Select TTS Engine"
        >
          <option value="puter">Puter AI (Natural OpenAI)</option>
          <option value="browser">Browser Native (Offline)</option>
        </select>

        <!-- Voice Selector for Puter AI -->
        <select 
          v-if="ttsMode === 'puter'"
          v-model="selectedPuterVoice" 
          @change="onVoiceChange"
          class="voice-select"
          title="Select Puter AI Voice"
        >
          <option 
            v-for="voice in puterVoices" 
            :key="voice.id" 
            :value="voice.id"
          >
            {{ voice.name }}
          </option>
        </select>

        <!-- Voice Selector for Browser Native -->
        <select 
          v-else
          v-model="selectedBrowserVoiceIndex" 
          @change="onVoiceChange"
          class="voice-select"
          title="Select Browser Voice"
        >
          <option 
            v-for="(voice, index) in browserVoices" 
            :key="voice.name" 
            :value="index"
          >
            {{ voice.name }} ({{ voice.lang }})
          </option>
        </select>

        <!-- Speed control -->
        <div class="speed-selector">
          <button 
            v-for="rate in rates" 
            :key="rate" 
            class="rate-pill"
            :class="{ active: currentRate === rate }"
            @click="setRate(rate)"
          >
            {{ rate }}x
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.read-aloud-container {
  margin: 1rem 0;
  padding: 0.75rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
}

.read-aloud-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.read-aloud-left,
.read-aloud-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.loading-text {
  font-size: 0.8rem;
  color: var(--vp-c-brand-1);
  font-weight: 500;
}

.action-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg-alt);
  color: var(--vp-c-text-1);
  transition: all 0.2s ease;
}

.action-btn:hover:not(:disabled) {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.action-btn.main-btn {
  background: var(--vp-c-brand-1);
  color: #ffffff;
  border-color: var(--vp-c-brand-1);
}

.action-btn.main-btn:hover:not(:disabled) {
  background: var(--vp-c-brand-2);
  border-color: var(--vp-c-brand-2);
  color: #ffffff;
}

.action-btn.main-btn.active {
  background: #eab308;
  border-color: #eab308;
  color: #000000;
}

.action-btn.stop-btn {
  padding: 0.4rem 0.5rem;
  color: var(--vp-c-text-2);
}

.action-btn.stop-btn:hover {
  border-color: #ef4444;
  color: #ef4444;
}

.mode-select,
.voice-select {
  padding: 0.35rem 0.6rem;
  border-radius: 6px;
  font-size: 0.8rem;
  background: var(--vp-c-bg-alt);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-divider);
  cursor: pointer;
  max-width: 220px;
}

.mode-select:focus,
.voice-select:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
}

.speed-selector {
  display: flex;
  background: var(--vp-c-bg-alt);
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  padding: 2px;
}

.rate-pill {
  border: none;
  background: transparent;
  padding: 0.25rem 0.45rem;
  font-size: 0.75rem;
  font-weight: 500;
  color: var(--vp-c-text-2);
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.15s ease;
}

.rate-pill:hover {
  color: var(--vp-c-text-1);
}

.rate-pill.active {
  background: var(--vp-c-brand-1);
  color: #ffffff;
  font-weight: 600;
}

.spinner {
  animation: rotate 1.5s linear infinite;
}

.spinner .path {
  stroke: currentColor;
  stroke-linecap: round;
  animation: dash 1.5s ease-in-out infinite;
}

@keyframes rotate {
  100% {
    transform: rotate(360deg);
  }
}

@keyframes dash {
  0% {
    stroke-dasharray: 1, 150;
    stroke-dashoffset: 0;
  }
  50% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -35;
  }
  100% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -124;
  }
}

@media (max-width: 640px) {
  .read-aloud-bar {
    flex-direction: column;
    align-items: stretch;
  }
  .read-aloud-right {
    justify-content: space-between;
  }
  .mode-select,
  .voice-select {
    max-width: 100%;
    flex: 1;
  }
}
</style>