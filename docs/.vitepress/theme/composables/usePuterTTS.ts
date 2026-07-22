import { ref } from 'vue'

export interface PuterVoice {
  id: string
  name: string
  provider: string
}

export function usePuterTTS() {
  const puterVoices: PuterVoice[] = [
    { id: 'nova', name: 'Nova (Female - Natural)', provider: 'openai' },
    { id: 'alloy', name: 'Alloy (Neutral - Clear)', provider: 'openai' },
    { id: 'echo', name: 'Echo (Male - Warm)', provider: 'openai' },
    { id: 'fable', name: 'Fable (Expressive - Story)', provider: 'openai' },
    { id: 'onyx', name: 'Onyx (Male - Deep)', provider: 'openai' },
    { id: 'shimmer', name: 'Shimmer (Female - Soft)', provider: 'openai' },
  ]
  const selectedPuterVoice = ref('nova')

  let currentAudio: HTMLAudioElement | null = null

  // Lightweight Audio Cache & Prefetch Map using key format: `${voice}:${idx}`
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

  const fetchPuterChunk = (chunkIndex: number, chunks: string[]): Promise<HTMLAudioElement | null> => {
    if (chunkIndex < 0 || chunkIndex >= chunks.length) {
      return Promise.resolve(null)
    }

    // Optimized memory key: voice:index
    const cacheKey = `${selectedPuterVoice.value}:${chunkIndex}`

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

        const audio = await puter.ai.txt2speech(chunks[chunkIndex], {
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

  const isPuterChunkCached = (chunkIndex: number): boolean => {
    const cacheKey = `${selectedPuterVoice.value}:${chunkIndex}`
    return audioCache.has(cacheKey)
  }

  const stopPuterAudio = () => {
    if (currentAudio) {
      currentAudio.pause()
      currentAudio = null
    }
  }

  const playPuterAudio = async (
    audio: HTMLAudioElement,
    rate: number,
    onEnded: () => void,
    onError: (e: any) => void
  ) => {
    if (currentAudio && currentAudio !== audio) {
      currentAudio.pause()
    }

    currentAudio = audio
    currentAudio.currentTime = 0
    currentAudio.playbackRate = rate

    audio.onended = onEnded
    audio.onerror = onError

    await audio.play().catch(() => {})
  }

  const pausePuterAudio = () => {
    if (currentAudio) {
      currentAudio.pause()
    }
  }

  const resumePuterAudio = () => {
    if (currentAudio && currentAudio.paused) {
      return currentAudio.play()
    }
    return Promise.resolve()
  }

  const setPuterRate = (rate: number) => {
    if (currentAudio) {
      currentAudio.playbackRate = rate
    }
  }

  return {
    puterVoices,
    selectedPuterVoice,
    fetchPuterChunk,
    isPuterChunkCached,
    playPuterAudio,
    pausePuterAudio,
    resumePuterAudio,
    stopPuterAudio,
    setPuterRate,
    clearAudioCache,
  }
}
