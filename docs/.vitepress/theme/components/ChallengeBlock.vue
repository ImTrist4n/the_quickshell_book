<template>
  <div class="challenge-block">
    <div class="challenge-header">
      <span class="challenge-icon">🏆</span>
      <span class="challenge-title">Challenge</span>
    </div>
    <div class="challenge-body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.challenge-block {
  background: linear-gradient(135deg, color-mix(in srgb, var(--vp-c-danger-1) 6%, transparent), color-mix(in srgb, var(--vp-c-warning-1) 6%, transparent));
  border: 2px solid var(--vp-c-danger-1);
  border-radius: 8px;
  padding: 20px;
  margin: 24px 0;
}

.challenge-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.challenge-icon {
  font-size: 22px;
}

.challenge-title {
  font-weight: 700;
  font-size: 16px;
  color: var(--vp-c-danger-1);
}

.challenge-body {
  color: var(--vp-c-text-1);
  line-height: 1.7;
  font-size: 15px;
}

.challenge-body :deep(p) {
  margin: 0 0 8px;
}

.challenge-body :deep(p:last-child) {
  margin-bottom: 0;
}
</style>
