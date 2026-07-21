<script setup lang="ts">
defineProps<{
  readingTime: string
  difficulty?: 1 | 2 | 3 | 4 | 5
  prerequisites?: string[]
  youWillBuild?: string
}>()
</script>

<template>
  <div class="chapter-meta">
    <div class="meta-row">
      <span class="meta-item">
        <span class="meta-icon">📖</span>
        {{ readingTime }}
      </span>
      <span v-if="difficulty" class="meta-item">
        <span class="meta-icon">🎯</span>
        <span class="difficulty-label">Difficulty: </span>
        <span v-for="i in 5" :key="i" class="diff-dot" :class="{ filled: i <= difficulty! }" />
      </span>
    </div>
    <div v-if="prerequisites && prerequisites.length" class="prerequisites">
      <span class="prereq-label">Prerequisites:</span>
      <span v-for="(prereq, i) in prerequisites" :key="i" class="prereq-chip">{{ prereq }}</span>
    </div>
    <div v-if="youWillBuild" class="you-will-build">
      <span class="build-label">You'll build:</span>
      <span class="build-value">{{ youWillBuild }}</span>
    </div>
  </div>
</template>

<style scoped>
.chapter-meta {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 16px 20px;
  margin-bottom: 24px;
  font-size: 14px;
}

.meta-row {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--vp-c-text-2);
}

.meta-icon {
  font-size: 16px;
}

.difficulty-label {
  margin-right: 4px;
}

.diff-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--vp-c-divider);
  margin-right: 2px;
}

.diff-dot.filled {
  background: var(--vp-c-brand-1);
}

.prerequisites {
  margin-top: 10px;
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.prereq-label {
  color: var(--vp-c-text-2);
  font-weight: 500;
}

.prereq-chip {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  padding: 2px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.you-will-build {
  margin-top: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.build-label {
  color: var(--vp-c-text-2);
  font-weight: 500;
}

.build-value {
  color: var(--vp-c-brand-1);
  font-weight: 500;
}
</style>
