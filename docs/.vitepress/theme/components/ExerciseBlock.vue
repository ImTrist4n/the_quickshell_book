<script setup lang="ts">
defineProps<{
  difficulty?: 1 | 2 | 3
}>()

const stars: Record<number, string> = {
  1: '⭐',
  2: '⭐⭐',
  3: '⭐⭐⭐',
}
</script>

<template>
  <div class="exercise-block" :class="`diff-${difficulty ?? 1}`">
    <div class="exercise-header">
      <span class="exercise-stars">{{ stars[difficulty ?? 1] }}</span>
      <span class="exercise-label">Exercise</span>
    </div>
    <div class="exercise-body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.exercise-block {
  background: color-mix(in srgb, var(--vp-c-exercise-1) 6%, transparent);
  border: 1px solid color-mix(in srgb, var(--vp-c-exercise-1) 20%, transparent);
  border-radius: 8px;
  padding: 16px 20px;
  margin: 16px 0;
}

.exercise-block.diff-2 {
  background: color-mix(in srgb, var(--vp-c-warning-1) 6%, transparent);
  border-color: color-mix(in srgb, var(--vp-c-warning-1) 20%, transparent);
}

.exercise-block.diff-3 {
  background: color-mix(in srgb, var(--vp-c-danger-1) 6%, transparent);
  border-color: color-mix(in srgb, var(--vp-c-danger-1) 20%, transparent);
}

.exercise-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.exercise-stars {
  font-size: 14px;
  letter-spacing: 2px;
}

.exercise-label {
  font-weight: 600;
  font-size: 14px;
  color: var(--vp-c-exercise-1);
}

.exercise-block.diff-2 .exercise-label {
  color: var(--vp-c-warning-1);
}

.exercise-block.diff-3 .exercise-label {
  color: var(--vp-c-danger-1);
}

.exercise-body {
  color: var(--vp-c-text-1);
  line-height: 1.7;
  font-size: 14px;
}

.exercise-body :deep(p) {
  margin: 0 0 8px;
}

.exercise-body :deep(p:last-child) {
  margin-bottom: 0;
}
</style>
