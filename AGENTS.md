# Agent Notes

## Variants Workflow

When the user asks for variants, proposals, comparisons, or alternatives for a page/component/design:

- Create a directory named `[topic]-variants/`.
- Put each standalone variant in `[topic]-variants/*.html`.
- Include an `[topic]-variants/index.html` comparison page.
- The comparison index should show all variants side by side.
- Each variant preview in the comparison index should be scaled to the site's normal reading width: `67ch`.
- Prefer iframes for the comparison index so each variant keeps its own layout, header, footer, and page-level CSS isolated.
- The comparison index itself should be only the comparison shell unless the user asks otherwise; do not add the site header/footer around the index if the embedded variants already include them.

Example:

```text
avatar-variants/
  index.html
  01-stacked.html
  02-float-right.html
  03-heading-lockup.html
  04-banner-crop.html
```

The index grid should use fixed-width columns like:

```css
.comparison {
  display: grid;
  grid-template-columns: repeat(4, 67ch);
  gap: 12px;
  width: calc((67ch * 4) + 36px);
}
```
