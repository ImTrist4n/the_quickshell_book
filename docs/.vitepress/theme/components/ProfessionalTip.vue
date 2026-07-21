<template>
  <div class="professional-tip">
    <div class="tip-header">
      <span class="tip-icon">⚡</span>
      <span class="tip-title">Professional Tip</span>
    </div>
    <div class="tip-body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.professional-tip {
  background: color-mix(in srgb, var(--vp-c-tip-1) 8%, transparent);
  border-left: 4px solid var(--vp-c-tip-1);
  border-radius: 0 8px 8px 0;
  padding: 16px 20px;
  margin: 20px 0;
}

.tip-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.tip-icon {
  font-size: 18px;
}

.tip-title {
  font-weight: 600;
  font-size: 15px;
  color: var(--vp-c-tip-1);
}

.tip-body {
  color: var(--vp-c-text-1);
  line-height: 1.7;
  font-size: 15px;
}

.tip-body :deep(p) {
  margin: 0 0 8px;
}

.tip-body :deep(p:last-child) {
  margin-bottom: 0;
}
</style>
