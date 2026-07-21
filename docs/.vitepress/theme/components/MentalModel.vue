<template>
  <div class="mental-model">
    <div class="mental-header">
      <span class="mental-icon">💡</span>
      <span class="mental-title">Mental Model</span>
    </div>
    <div class="mental-body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.mental-model {
  background: linear-gradient(135deg, color-mix(in srgb, var(--vp-c-example-1) 8%, transparent), color-mix(in srgb, var(--vp-c-brand-1) 4%, transparent));
  border-left: 4px solid var(--vp-c-example-1);
  border-radius: 0 8px 8px 0;
  padding: 16px 20px;
  margin: 20px 0;
}

.mental-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.mental-icon {
  font-size: 18px;
}

.mental-title {
  font-weight: 600;
  font-size: 15px;
  color: var(--vp-c-example-1);
}

.mental-body {
  color: var(--vp-c-text-1);
  line-height: 1.7;
  font-size: 15px;
}

.mental-body :deep(p) {
  margin: 0 0 8px;
}

.mental-body :deep(p:last-child) {
  margin-bottom: 0;
}
</style>
