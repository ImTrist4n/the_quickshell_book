import { ref, watch, onUnmounted, computed } from 'vue'
import { useRoute } from 'vitepress'
import { useArticleText, type ChunkItem } from './useArticleText'
import { useBrowserTTS } from './useBrowserTTS'
import { usePuterTTS } from './usePuterTTS'

export function useReadAloudEngine() {
  const route = useRoute()
  const { getArticleChunks, highlightElement, clearHighlight } = useArticleText()
  const browserTTS = useBrowserTTS()
  const puterTTS = usePuterTTS()

  const ttsMode = ref<'puter' | 'browser'>('puter')
  const isPlaying = ref(false)
  const isPaused = ref(false)
  const isLoadingModel = ref(false)
  const loadingProgress = ref('')
  const currentRate = ref(1.0)
  const rates = [0.8, 1.0, 1.25, 1.5, 2.0]

  const chunks = ref<ChunkItem[]>([])
  const currentChunkIndex = ref(0)

  const isSupported = computed(() => true)

  const stopSpeech = () => {
    isPlaying.value = false
    isPaused.value = false
    isLoadingModel.value = false
    loadingProgress.value = ''
    currentChunkIndex.value = 0
    chunks.value = []

    clearHighlight()
    puterTTS.stopPuterAudio()
    browserTTS.stopBrowserTTS()
  }

  const speakNextPuterChunk = async () => {
    if (currentChunkIndex.value >= chunks.value.length) {
      stopSpeech()
      return
    }

    const idx = currentChunkIndex.value
    const currentChunk = chunks.value[idx]

    // Highlight active DOM element in yellow
    highlightElement(currentChunk ? currentChunk.element : null)

    if (!puterTTS.isPuterChunkCached(idx)) {
      isLoadingModel.value = true
      loadingProgress.value = `Loading AI audio (${idx + 1}/${chunks.value.length})...`
    }

    const audio = await puterTTS.fetchPuterChunk(idx, chunks.value)

    if (!audio || !isPlaying.value) {
      isLoadingModel.value = false
      loadingProgress.value = ''
      if (!audio) {
        if (browserTTS.isBrowserSupported.value) {
          ttsMode.value = 'browser'
          speakNextBrowserChunk()
        } else {
          stopSpeech()
        }
      }
      return
    }

    isLoadingModel.value = false
    loadingProgress.value = ''

    // Pre-fetch next 2 chunks in parallel
    puterTTS.fetchPuterChunk(idx + 1, chunks.value)
    puterTTS.fetchPuterChunk(idx + 2, chunks.value)

    await puterTTS.playPuterAudio(
      audio,
      currentRate.value,
      () => {
        if (!isPlaying.value || isPaused.value) return
        currentChunkIndex.value++
        speakNextPuterChunk()
      },
      (err) => {
        console.warn('Puter audio chunk playback error:', err)
        currentChunkIndex.value++
        if (isPlaying.value && !isPaused.value) {
          speakNextPuterChunk()
        }
      }
    )
  }

  const speakNextBrowserChunk = () => {
    if (currentChunkIndex.value >= chunks.value.length) {
      stopSpeech()
      return
    }

    const idx = currentChunkIndex.value
    const currentChunk = chunks.value[idx]

    // Highlight active DOM element in yellow
    highlightElement(currentChunk ? currentChunk.element : null)

    browserTTS.speakBrowserChunk(
      currentChunk.text,
      currentRate.value,
      () => {
        isPlaying.value = true
        isPaused.value = false
      },
      () => {
        if (!isPlaying.value || isPaused.value) return
        currentChunkIndex.value++
        speakNextBrowserChunk()
      },
      (event) => {
        if (event.error === 'canceled' || event.error === 'interrupted') return
        currentChunkIndex.value++
        if (isPlaying.value && !isPaused.value) {
          speakNextBrowserChunk()
        }
      }
    )
  }

  const togglePlayPause = async () => {
    if (isPlaying.value && !isPaused.value) {
      // Pause: Keep highlight visible on current element
      isPaused.value = true
      if (ttsMode.value === 'browser') {
        browserTTS.stopBrowserTTS()
      } else {
        puterTTS.pausePuterAudio()
      }
      return
    }

    if (isPaused.value) {
      // Resume
      isPaused.value = false
      isPlaying.value = true
      if (ttsMode.value === 'browser') {
        speakNextBrowserChunk()
      } else {
        puterTTS.resumePuterAudio().catch(() => {
          speakNextPuterChunk()
        })
      }
      return
    }

    // Start fresh
    stopSpeech()
    const articleChunks = getArticleChunks()
    if (!articleChunks || articleChunks.length === 0) return

    chunks.value = articleChunks
    currentChunkIndex.value = 0
    isPlaying.value = true
    isPaused.value = false

    if (ttsMode.value === 'puter') {
      puterTTS.fetchPuterChunk(0, chunks.value)
      puterTTS.fetchPuterChunk(1, chunks.value)
      await speakNextPuterChunk()
    } else {
      speakNextBrowserChunk()
    }
  }

  const setRate = (rate: number) => {
    currentRate.value = rate
    if (ttsMode.value === 'puter') {
      puterTTS.setPuterRate(rate)
    } else {
      if (isPlaying.value && !isPaused.value) {
        speakNextBrowserChunk()
      }
    }
  }

  const onEngineChange = () => {
    if (isPlaying.value || isPaused.value) {
      stopSpeech()
    }
  }

  const onVoiceChange = () => {
    puterTTS.clearAudioCache()
    if (isPlaying.value || isPaused.value) {
      stopSpeech()
      setTimeout(() => togglePlayPause(), 50)
    }
  }

  watch(() => route.path, () => {
    stopSpeech()
    puterTTS.clearAudioCache()
  })

  onUnmounted(() => {
    stopSpeech()
    puterTTS.clearAudioCache()
  })

  return {
    isSupported,
    ttsMode,
    isPlaying,
    isPaused,
    isLoadingModel,
    loadingProgress,
    currentRate,
    rates,
    togglePlayPause,
    stopSpeech,
    setRate,
    onEngineChange,
    onVoiceChange,
    puterVoices: puterTTS.puterVoices,
    selectedPuterVoice: puterTTS.selectedPuterVoice,
    browserVoices: browserTTS.browserVoices,
    selectedBrowserVoiceIndex: browserTTS.selectedBrowserVoiceIndex,
    isBrowserSupported: browserTTS.isBrowserSupported,
  }
}
