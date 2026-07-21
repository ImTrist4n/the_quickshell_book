# Contributing

Contributions to The Quickshell Book are welcome. This document outlines the process.

## Types of Contributions

- **Content**: New chapters, sections, or improvements to existing content
- **Corrections**: Fixes to technical inaccuracies, typos, or broken links
- **Examples**: Runnable QML example code that accompanies chapters
- **Translations**: Localization of the book into other languages

## Process

1. Open an issue describing your proposed change before starting work
2. Fork the repository and create a branch for your changes
3. Ensure content follows the book's existing style and structure
4. Verify that all internal links are valid
5. Submit a pull request with a clear description of the changes

## Guidelines

- Each pull request should address a single concern
- Content should be accurate, concise, and free of marketing language
- Code examples must be syntactically valid QML
- New chapters require a `ChapterMeta` component and a `Recap` component
- External sources should be cited in an HTML comment at the end of the file
- Run `npm run build` and `npm run validate:links` before submitting

## Development Setup

```sh
npm install
npm run dev
```

The book uses VitePress. Content is written in Markdown with Vue components for interactive elements. See the `docs/` directory structure for existing chapters.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
