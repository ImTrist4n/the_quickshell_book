<script setup lang="ts">
defineProps<{
  src: string
  caption?: string
  alt?: string
}>()
</script>

<template>
  <figure class="project-result">
    <div class="result-image-wrapper">
      <img :src="src" :alt="alt ?? caption ?? 'Project result'" class="result-image" loading="lazy" />
    </div>
    <figcaption v-if="caption" class="result-caption">{{ caption }}</figcaption>
  </figure>
</template>

<style scoped>
.project-result {
  margin: 32px 0;
  text-align: center;
}

.result-image-wrapper {
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid var(--vp-c-divider);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.result-image {
  width: 100%;
  height: auto;
  display: block;
}

.result-caption {
  margin-top: 12px;
  font-size: 14px;
  color: var(--vp-c-text-2);
  font-style: italic;
}
</style>
