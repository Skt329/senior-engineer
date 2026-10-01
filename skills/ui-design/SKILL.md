---
name: ui-design
description: This skill should be used for any user interface work, for example building or changing screens, pages, components, layouts, forms, styling, themes, or Android Compose UI, reviewing a UI, or writing UI text such as button labels, empty states, and error messages, and whenever the user mentions UI, UX, frontend, design, mockups, or accessibility. It sets the quality bar of a senior product designer, with a clear design direction, a token-based design system, all interaction states, WCAG 2.1 AA accessibility, responsive layouts, Material 3 on Android, purposeful motion, and a UI review checklist, and it defers to an installed frontend-design skill for visual direction when one is available.
---

# UI design

The bar is the work of a senior product designer at a top product company: interfaces that are clear at a glance, consistent everywhere, accessible to everyone, and pleasant to use. Generic, template-looking screens do not meet it.

## Start with direction, not components

1. Ask about the users, the main task on the screen, the brand, and any existing design system, mockups, or reference apps. Follow an existing design system exactly.
2. If a frontend-design skill is installed, load it for visual direction and aesthetics, and use this skill for structure, accessibility, states, and review.
3. For new UI with no system, propose a direction before building: the mood in a few words, the typeface pairing, the color palette with its roles, the spacing scale, the corner radius, and the motion style. One clear direction beats a mix of safe defaults.
4. Build with tokens (references/design-system.md), never with hard-coded values.

## Principles

- Hierarchy: one primary action per screen, and visual weight that follows importance. A user should know what to do within five seconds.
- Consistency: the same thing looks and behaves the same everywhere.
- Every state is designed: loading, empty, error, partial, success, disabled, and offline where relevant. Empty states explain what will appear and how to start.
- Feedback: every action gets a visible response within about 100 milliseconds, and longer work shows progress.
- Forgiveness: confirm destructive actions, offer undo where possible, and keep the user's input when something fails.
- Content first: real copy and realistic data in layouts, never lorem ipsum (references/ux-copy.md).
- Motion has a purpose (showing where something came from or went), is short (about 150 to 300 milliseconds), and respects reduced-motion settings.

## Accessibility is part of the definition of done

Meet WCAG 2.1 AA (references/accessibility.md): color contrast of 4.5:1 for text, keyboard and screen reader access, visible focus, labels for every input, touch targets of at least 44 by 44 CSS pixels on the web and 48 by 48 dp on Android, and support for text scaling.

## Responsive and platform fit

- Web: mobile-first layouts that work from 320 pixels wide up, with content-driven breakpoints. Test at 375, 768, 1280, and 1920 pixels.
- Android: follow Material 3 (color roles, type scale, components, and adaptive layouts for tablets and foldables). Support dark theme and dynamic color where the app allows it. Respect system font size and display size.

## Review before handoff

Check every new or changed screen with references/ui-review-checklist.md. For the pull request, include screenshots of the main states, at mobile and desktop widths for web UI, and in light and dark themes where both exist.
