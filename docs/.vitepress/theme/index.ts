import { h, nextTick, watch } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import { useData } from 'vitepress'
import { createMermaidRenderer } from 'vitepress-mermaid-renderer'
import type { App } from 'vue'

import './style.css'

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
import ReadAloud from './components/ReadAloud.vue'

export default {
  extends: DefaultTheme,

  Layout() {
    const { isDark } = useData()

    const renderMermaid = () => {
      createMermaidRenderer({
        theme: isDark.value ? 'dark' : 'default',
      })
    }

    nextTick(renderMermaid)

    watch(isDark, () => {
      nextTick(renderMermaid)
    })

    return h(DefaultTheme.Layout, null, {
      'doc-before': () => h(ReadAloud),
    })
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
    app.component('ReadAloud', ReadAloud)
  },
} satisfies Theme