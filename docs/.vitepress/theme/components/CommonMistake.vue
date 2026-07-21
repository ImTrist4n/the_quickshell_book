<template>
  <div class="common-mistake">
    <div class="mistake-header">
      <span class="mistake-icon">⚠️</span>
      <span class="mistake-title">Common Mistake</span>
    </div>
    <div class="mistake-body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.common-mistake {
  background: color-mix(in srgb, var(--vp-c-warning-1) 8%, transparent);
  border-left: 4px solid var(--vp-c-warning-1);
  border-radius: 0 8px 8px 0;
  padding: 16px 20px;
  margin: 20px 0;
}

.mistake-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.mistake-icon {
  font-size: 18px;
}

.mistake-title {
  font-weight: 600;
  font-size: 15px;
  color: var(--vp-c-warning-1);
}

.mistake-body {
  color: var(--vp-c-text-1);
  line-height: 1.7;
  font-size: 15px;
}

.mistake-body :deep(p) {
  margin: 0 0 8px;
}

.mistake-body :deep(p:last-child) {
  margin-bottom: 0;
}
</style>
