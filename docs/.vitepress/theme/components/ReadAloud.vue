<script setup lang="ts">
import { useReadAloudEngine } from '../composables/useReadAloudEngine'

const {
  isSupported,
  ttsMode,
  isPlaying,
  isPaused,
  isLoadingModel,
  loadingProgress,
  currentRate,
  rates,
  puterVoices,
  selectedPuterVoice,
  browserVoices,
  selectedBrowserVoiceIndex,
  isBrowserSupported,
  togglePlayPause,
  stopSpeech,
  setRate,
  onEngineChange,
  onVoiceChange,
} = useReadAloudEngine()
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
          <option v-if="isBrowserSupported" value="browser">Browser Native (Offline)</option>
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
          v-else-if="ttsMode === 'browser' && isBrowserSupported"
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