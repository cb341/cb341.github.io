# Agent Instructions for cb341.dev Portfolio

This file contains project-specific guidelines for AI agents working on this Astro portfolio site.

## Project Overview

- **Site**: https://cb341.dev
- **Framework**: Astro 4.x (static site generation)
- **Developer**: Dani Bengl - Full-Stack Developer
- **License**: CC-BY-4.0
- **Package Manager**: npm (package-lock.json present)
- **Dev Server**: `localhost:4321`

## Core Principles

### Priorities (in order of importance)
1. **Consistency** - Match existing patterns and conventions throughout the codebase
2. **Performance** - Optimize for speed, minimal bundle size, fast load times
3. **Accessibility (a11y)** - ARIA labels, semantic HTML, keyboard navigation
4. **SEO** - Meta tags, structured data, semantic markup
5. **Developer Experience** - Readable, maintainable, clear patterns

### Philosophy
- Keep it minimal and fast
- Static-first, avoid client-side JavaScript
- Semantic HTML over divs and classes
- Let it fail fast - minimal error handling except at system boundaries
- No unnecessary abstractions or over-engineering

## File & Component Naming Conventions

**Follow existing patterns:**
- Components: `PascalCase.astro` (e.g., `BlogPostCard.astro`, `NavLink.astro`)
- Layouts: `PascalCase.astro` (e.g., `BaseLayout.astro`)
- Pages: `kebab-case.astro` or `[...slug].astro` for dynamic routes
- Utilities: `camelCase.ts` (e.g., `dateHelpers.ts`)
- Directories: `lowercase` (e.g., `components/`, `layouts/`, `pages/`)

## Code Structure

### Directory Organization
```
src/
├── assets/        # Static assets (images, etc.)
│   └── blog/      # Blog post images (WebP format)
├── components/    # Reusable Astro components
├── content/       # Content collections
├── data/          # Data files
├── layouts/       # Layout components
├── pages/         # Routes (file-based routing)
└── utils/         # Utility functions
```

## Styling Guidelines

### When to Add Styles
- **Only add CSS when explicitly requested**
- Don't add styling to components unless the user asks for it
- Rely on semantic HTML and existing styles when possible

### How to Add Styles (when requested)
- **ONLY** use scoped `<style>` tags within `.astro` components
- **NEVER** create separate CSS files (`.css`, `.scss`, etc.)
- **NEVER** use inline styles (style attribute)
- **NEVER** use CSS frameworks (Tailwind, Bootstrap, etc.)
- **NEVER** use CSS-in-JS libraries
- Scoped styles are automatically handled by Astro

### Example Pattern (when adding styles)
```astro
<article>
  <h3><a href="/blog/post">Title</a></h3>
</article>

<style>
  article:has(a:focus) {
    outline: 2px solid blue;
  }

  a:focus {
    outline: 0;
  }
</style>
```

## JavaScript Guidelines

### Rules
- **Minimize or avoid client-side JavaScript entirely**
- Prefer static generation over client-side interactivity
- **NEVER** add complex state management libraries
- If JavaScript is absolutely necessary, keep it minimal and vanilla
- Leverage Astro's server-side rendering capabilities

## HTML & Accessibility

### Semantic HTML
- **Always** use proper HTML5 semantic elements
- Prefer `<article>`, `<section>`, `<nav>`, `<header>`, `<footer>`, `<main>`, `<aside>` over generic `<div>`
- Use `<time>` for dates with proper `datetime` attribute
- Use `<em>` and `<strong>` over `<i>` and `<b>`

### Accessibility Requirements
- **Always** include `aria-label` on links and interactive elements
- Ensure keyboard navigation works properly
- Use proper heading hierarchy (h1, h2, h3)
- Include `:focus` styles for keyboard users (when adding styles)
- Test that all interactive elements are keyboard accessible

### Example
```astro
<a
  href={`/blog/${post.slug}`}
  aria-label={`Read blog post: ${post.data.title}`}
>
  {post.data.title}
</a>
```

## SEO Requirements

### Structured Data
- Include JSON-LD structured data in layouts
- Use Schema.org types: `BlogPosting`, `WebPage`, `Person`
- Include author information, dates, keywords

### Meta Tags
- Set proper `title` (format: `{Page Title} | {Site Title}`)
- Include `description` meta tags
- Add Open Graph tags for social sharing
- Include canonical URLs

### Example Pattern (from BaseLayout.astro)
```javascript
const structuredData = {
  "@context": "https://schema.org",
  "@type": type === "article" ? "BlogPosting" : "WebPage",
  headline: title || defaultTitle,
  description: pageDescription,
  url: currentUrl,
  author: {
    "@type": "Person",
    name: "Dani Bengl",
    url: siteUrl,
  },
};
```

## Image Handling

### Image Compression Guidelines
- **Format**: Always use WebP for blog images and assets
- **Quality**: Default to 85% quality (adjustable via `-q` flag)
- **Tool**: Use `./scripts/img-to-webp.sh` or `npm run img-to-webp`
- **Location**: Blog images go in `src/assets/blog/`
- **Accepted inputs**: PNG, JPG, JPEG, GIF

### Image Processing
- **Preferred tool**: `cwebp` (install via `brew install webp`)
- **Fallback**: `sips` (macOS built-in, limited quality control)
- **Astro**: Uses `sharp` service for image optimization

### When to Convert
1. Before adding new images to the repository
2. When image file sizes are >100KB
3. For all blog post assets
4. Convert existing images if making related changes

### Usage Example
```bash
# Convert with default settings (85% quality)
./scripts/img-to-webp.sh image.png

# Convert with custom quality
./scripts/img-to-webp.sh -q 90 image.jpg

# Convert to specific location
./scripts/img-to-webp.sh screenshot.png src/assets/blog/post-name.webp
```

## Build Configuration

### Compression Settings (astro.config.mjs)
- **CSS**: Enabled
- **HTML**: Enabled (collapse whitespace, remove comments, preserve attribute quotes)
- **JavaScript**: Enabled
- **SVG**: Enabled
- **Images**: Disabled (handled separately via WebP conversion)

### Build Options
- **Output**: Static site (`output: 'static'`)
- **CSS**: No code splitting (`cssCodeSplit: false`)
- **Stylesheets**: Auto-inline (`inlineStylesheets: 'auto'`)
- **Chunks**: No manual chunks (keep it simple)

### Markdown/MDX
- **Syntax Highlighting**: Disabled in config (custom solution in use)
- **Plugins**: Custom configuration (`extendPlugins: false`)

## Development Workflow

### Available Commands
- `npm run dev` - Start development server at localhost:4321
- `npm run build` - Type check and build (must pass before deployment)
- `npm run preview` - Preview production build
- `npm run fastcheck` - Quick type checking with auto-fix
- `npm run fastcheck:check` - Quick type checking without fixes
- `npm run img-to-webp` - Convert images to WebP format

### Before Committing
1. Run `npm run fastcheck:check` to verify types
2. Run `npm run build` to ensure production build succeeds
3. Test in browser at `localhost:4321` if UI changes were made
4. Verify images are optimized (WebP format, reasonable file sizes)

### Git Workflow
- **Main branch**: `main` (use for PRs)
- Always run `npm run build` before committing significant changes
- Use conventional commit messages
- Keep commits focused and atomic

## Code Quality

### TypeScript
- TypeScript is enabled - ensure proper typing
- Run `astro check` before building
- Use `./bin/fastcheck` for quick validation during development

### Formatting
- Prettier is configured (`.prettierrc.mjs`)
- Let Prettier handle formatting automatically
- Don't manually format code

### Documentation
- **Minimal comments** - only for complex logic
- Prefer self-documenting code with clear naming
- Don't add JSDoc unless the function is genuinely complex
- Code should speak for itself

## Dependencies

### Policy
- **Keep dependencies minimal** - avoid adding new packages unless absolutely necessary
- Check `package.json` before suggesting new packages
- Prefer built-in solutions over external libraries
- Use npm for package management (not yarn or pnpm)

### Current Stack
- Astro core + official integrations (@astrojs/*)
- TypeScript
- Prettier
- markdown-it, rehype/remark plugins
- sanitize-html
- astro-compress

## Design & UI Patterns

### Style
- **Minimalist design** - clean, simple layouts with whitespace
- **No animations or heavy effects** - keep it lightweight and fast
- **Mobile-first responsive** - works on all screen sizes
- Follow patterns in existing components

### Visual Hierarchy
- Use semantic headings for structure
- Let typography and spacing create hierarchy
- Avoid unnecessary decorative elements
- Focus on content readability

## Performance Optimization

### Guidelines
- Prefer static generation over client-side rendering
- Keep bundle sizes minimal (no manual chunks configured)
- Use WebP images to reduce page weight
- Leverage Astro's built-in optimizations
- Images processed through sharp service
- No unnecessary JavaScript in the browser

## Error Handling

- **Minimal error handling** - let it fail fast
- Only validate at system boundaries (user input, external APIs)
- Trust internal code and framework guarantees
- Don't add error handling for scenarios that can't happen
- Focus on preventing errors through good design

## Testing

- No automated test suite (static site)
- Manual testing workflow:
  1. Verify the build passes (`npm run build`)
  2. Test in browser (`npm run dev`)
  3. Check type safety (`npm run fastcheck:check`)
- Focus on ensuring builds succeed without errors

## File Creation Guidelines

- **PREFER** editing existing files over creating new ones
- **NEVER** create documentation files unless explicitly requested
- **NEVER** create separate CSS files
- **NEVER** create new configuration files without discussion
- Keep the codebase minimal and focused

## Common Patterns to Follow

### Component Structure
```astro
---
// Imports and props at the top
import { formatDate } from "../utils/dateHelpers";
const { post } = Astro.props;
---

<!-- Semantic HTML with accessibility -->
<article>
  <h3>
    <a
      href={`/blog/${post.slug}`}
      aria-label={`Read blog post: ${post.data.title}`}
    >
      {post.data.title}
    </a>
  </h3>

  <div class="meta">
    <em>
      Published on <time datetime={post.data.publishedAt.toISOString()}>
        {formatDate(post.data.publishedAt)}
      </time>
    </em>
  </div>

  <p>{post.data.description}</p>
</article>

<!-- Only add styles if explicitly requested -->
<style>
  /* Scoped styles go here */
</style>
```

### Layout Structure
- Include proper meta tags and structured data
- Set up SEO-friendly titles and descriptions
- Include accessibility features
- Keep layouts clean and focused

## What NOT to Do

### Never:
- Add CSS frameworks (Tailwind, Bootstrap, etc.)
- Create separate CSS files
- Use inline styles (style attribute)
- Add client-side JavaScript libraries
- Add complex state management
- Use CSS-in-JS solutions
- Add animations or heavy visual effects
- Create unnecessary abstractions
- Add dependencies without strong justification
- Use divs when semantic elements exist
- Skip accessibility attributes
- Forget structured data for blog posts
- Create documentation files unprompted
- Add CSS styling unless explicitly requested

## Summary

This is a **minimal, fast, accessible, SEO-optimized static portfolio site**. When in doubt:
1. Check existing code for patterns
2. Keep it simple and semantic
3. Prioritize performance and accessibility
4. Avoid adding complexity
5. Let the code speak for itself
6. Only add styling when requested
