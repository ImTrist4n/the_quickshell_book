import { readFileSync } from 'node:fs'
import { globSync } from 'fast-glob'
import { join, dirname, relative } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const docsDir = join(__dirname, '..', 'docs')

const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g
const internalLinkRegex = /^\/[^/]/

const files = globSync('**/*.md', { cwd: docsDir })
let hasErrors = false

for (const file of files) {
  const content = readFileSync(join(docsDir, file), 'utf-8')
  const matches = content.matchAll(linkRegex)

  for (const match of matches) {
    const [, , url] = match
    if (!internalLinkRegex.test(url)) continue
    if (url.includes('#')) continue

    const targetPath = join(docsDir, url.slice(1))
    const mdPath = targetPath.endsWith('.md') ? targetPath : `${targetPath}.md`
    const indexPath = join(targetPath, 'index.md')

    if (!exists(mdPath) && !exists(indexPath)) {
      console.error(`Broken link: ${url} in ${file}`)
      hasErrors = true
    }
  }
}

function exists(p: string): boolean {
  try {
    readFileSync(p)
    return true
  } catch {
    return false
  }
}

if (hasErrors) {
  process.exit(1)
} else {
  console.log('All internal links resolve correctly.')
}
