---
title: "Contributing"
description: "How to contribute improvements back to the Quickshell ecosystem"
---

<ChapterMeta reading-time="8 min" :difficulty="1" :prerequisites="['Distribution', 'Git']" you-will-learn="How to contribute to Quickshell and the broader community" />

## The Problem

You've used Quickshell, built your config, and fixed bugs. Now you want to give back. But where do you contribute? Documentation, bug reports, themes, plugins, or upstream code?

## The Naive Approach

Keep everything private:

> "I fixed a bug in Quickshell's CPU service, but I don't know how to submit a patch."

Your fix helps only you. The next person hits the same bug and spends hours debugging.

<MentalModel>

Think of open source contribution like a potluck dinner. Everyone brings a dish they're good at making. Some people bring main courses (core code), some bring side dishes (themes), some bring drinks (documentation). Everyone eats better than they would alone.

</MentalModel>

## Where to Contribute

### 1. Quickshell Upstream

The Quickshell project itself accepts contributions:

- **GitHub:** https://github.com/wardvis/Quickshell
- **Bug reports:** File issues with clear reproduction steps
- **Feature requests:** Describe the need, not the implementation
- **Code contributions:** Follow the existing style and add tests

What to contribute:
- New service types (e.g., a `BatteryService`)
- Bug fixes for existing services
- Performance improvements
- Documentation fixes

### 2. Documentation

This book (the Quickshell Book) is itself a contribution:

- Fix typos or unclear explanations
- Add new chapters for uncovered topics
- Improve code examples
- Update for new Quickshell versions

### 3. Themes and Presets

Share your theme configurations:

```qml
// ~/.config/quickshell/themes/nordic.qml
pragma Singleton
QtObject { /* theme colors */ }
```

Publish on GitHub and link from community pages.

### 4. Community Support

Help others on:

- **GitHub Discussions** — answer questions
- **Reddit:** r/unixporn, r/hyprland — share your setup
- **Discord/Matrix** — real-time help
- **Wiki** — write troubleshooting guides

## How to Submit Code

### For Quickshell Upstream

1. **Fork** the repository on GitHub
2. **Clone** your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Quickshell.git
   ```
3. **Create a branch** for your change:
   ```bash
   git checkout -b fix-cpu-service-nan
   ```
4. **Make your change** and test it
5. **Commit** with a clear message:
   ```bash
   git commit -m "Fix CpuService returning NaN on first poll"
   ```
6. **Push** and create a Pull Request

### For This Book

1. **Fork** the book repository
2. **Edit** the relevant `.md` file in `docs/`
3. **Verify** it builds: `npx vitepress build docs`
4. **Submit a PR** with your changes

## Contribution Guidelines

- **One change per PR.** Don't fix three unrelated bugs in one pull request.
- **Test your changes.** If you add a new service, verify it works with a minimal config.
- **Follow the style.** Match existing code formatting and naming conventions.
- **Update docs.** If you add a feature, document it.
- **Be patient.** Maintainers review in their free time.

## Code of Conduct

All contributions should be respectful and constructive. The Quickshell community follows a standard code of conduct: be excellent to each other.

## Exercises

<ExerciseBlock :difficulty="1">
Find an issue in the Quickshell GitHub repository labeled "good first issue" or "help wanted." Attempt to fix it. If you're stuck, leave a comment describing what you tried.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Improve a chapter in this book. Find a section that could be clearer or an example that doesn't work, fix it, and submit a pull request.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Write a community-contributed chapter for the Appendix. Topics: "Integrating with Hyprland", "Building a custom OSD", "Accessibility in Quickshell". Submit via PR.
</ExerciseBlock>

<Recap :points="['Contribute upstream code, documentation, themes, or community support', 'Follow the contribution guidelines: one change per PR, test, document', 'Good first contributions: bug reports, documentation fixes, answering questions', 'The Quickshell Book is open source — chapters welcome via PR']" next-chapter="/part-13-source-tour/architecture-overview" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/ — Quickshell documentation
- https://github.com/wardvis/Quickshell — Quickshell GitHub
- https://opensource.guide/how-to-contribute/ — Open Source Contribution Guide
-->
