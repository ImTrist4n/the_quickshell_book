<script setup lang="ts">
import { useRouter } from 'vitepress'

const props = defineProps<{
  points: string[]
  nextChapter?: string
}>()

const router = useRouter()

function goToNext() {
  if (props.nextChapter) {
    router.go(props.nextChapter)
  }
}
</script>

<template>
  <div class="recap">
    <div class="recap-header">
      <span class="recap-icon">✅</span>
      <span class="recap-title">What You've Learned</span>
    </div>
    <ul class="recap-list">
      <li v-for="(point, i) in points" :key="i" class="recap-point">{{ point }}</li>
    </ul>
    <div v-if="nextChapter" class="next-chapter">
      <button class="next-link" @click="goToNext">
        Next Chapter →
      </button>
    </div>
  </div>
</template>

<style scoped>
.recap {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 20px;
  margin: 32px 0;
}

.recap-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.recap-icon {
  font-size: 18px;
}

.recap-title {
  font-weight: 600;
  font-size: 16px;
  color: var(--vp-c-brand-1);
}

.recap-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.recap-point {
  position: relative;
  padding: 6px 0 6px 20px;
  font-size: 15px;
  line-height: 1.6;
  color: var(--vp-c-text-1);
}

.recap-point::before {
  content: '•';
  position: absolute;
  left: 4px;
  color: var(--vp-c-brand-1);
  font-weight: 700;
}

.next-chapter {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--vp-c-divider);
}

.next-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-weight: 600;
  color: var(--vp-c-brand-1);
  text-decoration: none;
  font-size: 15px;
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
  font-family: inherit;
  transition: color 0.2s ease, gap 0.2s ease;
}

.next-link:hover {
  color: var(--vp-c-brand-2);
  gap: 8px;
}
</style>
