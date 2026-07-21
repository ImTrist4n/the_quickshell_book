<template>
  <div class="build-it">
    <div class="build-header">
      <span class="build-icon">🛠️</span>
      <span class="build-title">Let's Build It</span>
    </div>
    <div class="build-body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.build-it {
  background: color-mix(in srgb, var(--vp-c-success-1) 8%, transparent);
  border: 1px solid color-mix(in srgb, var(--vp-c-success-1) 20%, transparent);
  border-radius: 8px;
  padding: 20px;
  margin: 24px 0;
}

.build-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.build-icon {
  font-size: 18px;
}

.build-title {
  font-weight: 600;
  font-size: 16px;
  color: var(--vp-c-success-1);
}

.build-body {
  line-height: 1.7;
  font-size: 15px;
}

.build-body :deep(p) {
  margin: 0 0 12px;
}

.build-body :deep(p:last-child) {
  margin-bottom: 0;
}

.build-body :deep(pre) {
  margin: 12px 0;
}
</style>
