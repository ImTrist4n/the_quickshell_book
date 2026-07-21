<script setup lang="ts">
defineProps<{
  chapters: number
  completed: number
  partLabel: string
}>()
</script>

<template>
  <div class="reading-progress">
    <div class="progress-header">
      <span class="progress-label">{{ partLabel }}</span>
      <span class="progress-count">{{ completed }}/{{ chapters }} chapters</span>
    </div>
    <div class="progress-bar">
      <div class="progress-fill" :style="{ width: `${(completed / chapters) * 100}%` }" />
    </div>
  </div>
</template>

<style scoped>
.reading-progress {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 16px 20px;
  margin: 16px 0;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.progress-label {
  font-weight: 600;
  font-size: 14px;
  color: var(--vp-c-text-1);
}

.progress-count {
  font-size: 13px;
  color: var(--vp-c-text-2);
}

.progress-bar {
  height: 6px;
  background: var(--vp-c-divider);
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--vp-c-brand-1), var(--vp-c-brand-2));
  border-radius: 3px;
  transition: width 0.3s ease;
}
</style>
