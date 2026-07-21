<template>
  <div class="under-the-hood">
    <div class="uth-header">
      <span class="uth-icon">🔧</span>
      <span class="uth-title">Under the Hood</span>
    </div>
    <div class="uth-body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.under-the-hood {
  background: color-mix(in srgb, var(--vp-c-brand-1) 6%, transparent);
  border-left: 4px solid var(--vp-c-brand-1);
  border-radius: 0 8px 8px 0;
  padding: 16px 20px;
  margin: 20px 0;
}

.uth-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.uth-icon {
  font-size: 18px;
}

.uth-title {
  font-weight: 600;
  font-size: 15px;
  color: var(--vp-c-brand-1);
}

.uth-body {
  color: var(--vp-c-text-1);
  line-height: 1.7;
  font-size: 15px;
}

.uth-body :deep(p) {
  margin: 0 0 8px;
}

.uth-body :deep(p:last-child) {
  margin-bottom: 0;
}
</style>
