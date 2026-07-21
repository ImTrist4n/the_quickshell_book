import { writeFileSync, mkdirSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const rootDir = join(__dirname, '..')

const slug = process.argv[2]
const title = process.argv[3] ?? slug
const part = process.argv[4] ?? 'part-0-fundamentals'

if (!slug) {
  console.error('Usage: npx tsx scripts/new-chapter.ts <slug> [title] [part-folder]')
  console.error('Example: npx tsx scripts/new-chapter.ts hello-world "Hello World" part-1-qml')
  process.exit(1)
}

const exampleFolder = join(rootDir, 'examples', slug)
const docsFolder = join(rootDir, 'docs', part)

const exampleReadme = `# ${title}

Run this example with Quickshell:

\`\`\`bash
quickshell ./shell.qml
\`\`\`
`

const chapterContent = `---
title: "${title}"
description: ""
---

<ChapterMeta reading-time="X min" :difficulty="2" :prerequisites="['']" you-will-build="" />

## The Problem



## The Naive Approach



<MentalModel>



</MentalModel>

## The Idea



## Let's Build It

<BuildIt>

\`\`\`qml

\`\`\`

</BuildIt>

## Let's Improve It



<CommonMistake>



</CommonMistake>

## Under the Hood

<UnderTheHood>



</UnderTheHood>

<ProfessionalTip>



</ProfessionalTip>

## Diagram

\`\`\`mermaid

\`\`\`

## Exercises

<ExerciseBlock :difficulty="1">

</ExerciseBlock>

<ExerciseBlock :difficulty="2">

</ExerciseBlock>

<ExerciseBlock :difficulty="3">

</ExerciseBlock>

<Recap :points="['', '', '']" next-chapter="" />

<!--
Sources verified for this chapter:
-
-->
`

try {
  mkdirSync(join(docsFolder), { recursive: true })
  mkdirSync(join(exampleFolder), { recursive: true })

  writeFileSync(join(exampleFolder, 'shell.qml'), '')
  writeFileSync(join(exampleFolder, 'README.md'), exampleReadme)
  writeFileSync(join(docsFolder, `${slug}.md`), chapterContent)

  console.log(`Created chapter: docs/${part}/${slug}.md`)
  console.log(`Created example: examples/${slug}/`)
} catch (err) {
  console.error('Failed to create chapter:', err)
  process.exit(1)
}
