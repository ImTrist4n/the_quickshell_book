import { h, nextTick, watch } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import { useData } from 'vitepress'
import { createMermaidRenderer } from 'vitepress-mermaid-renderer'
import { type App } from 'vue'
import ChapterMeta from './components/ChapterMeta.vue'
import MentalModel from './components/MentalModel.vue'
import CommonMistake from './components/CommonMistake.vue'
import ProfessionalTip from './components/ProfessionalTip.vue'
import UnderTheHood from './components/UnderTheHood.vue'
import BuildIt from './components/BuildIt.vue'
import ExerciseBlock from './components/ExerciseBlock.vue'
import ChallengeBlock from './components/ChallengeBlock.vue'
import Recap from './components/Recap.vue'
import ProjectResult from './components/ProjectResult.vue'
import ReadingProgress from './components/ReadingProgress.vue'
import './style.css'

export default {
  extends: DefaultTheme,
  Layout: () => {
    const { isDark } = useData()

    const initMermaid = () => {
      createMermaidRenderer({
        theme: 'default',
      })
    }

    nextTick(() => initMermaid())
    watch(
      () => isDark.value,
      () => initMermaid(),
    )

    return h(DefaultTheme.Layout)
  },
  enhanceApp({ app }: { app: App }) {
    app.component('ChapterMeta', ChapterMeta)
    app.component('MentalModel', MentalModel)
    app.component('CommonMistake', CommonMistake)
    app.component('ProfessionalTip', ProfessionalTip)
    app.component('UnderTheHood', UnderTheHood)
    app.component('BuildIt', BuildIt)
    app.component('ExerciseBlock', ExerciseBlock)
    app.component('ChallengeBlock', ChallengeBlock)
    app.component('Recap', Recap)
    app.component('ProjectResult', ProjectResult)
    app.component('ReadingProgress', ReadingProgress)
  },
} satisfies Theme
