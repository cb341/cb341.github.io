import { defineConfig, sharpImageService } from "astro/config";
import mdx from "@astrojs/mdx";
import sitemap from '@astrojs/sitemap';
import compress from "astro-compress";

export default defineConfig({
  layout: "layouts/BaseLayout.astro",
  output: 'static',
  markdown: {
    syntaxHighlight: false,
  },
  integrations: [
    mdx({
      extendPlugins: false,
    }),
    sitemap(),
    compress({
      CSS: true,
      HTML: {
        removeAttributeQuotes: false,
        collapseWhitespace: true,
        removeComments: true,
      },
      Image: false,
      JavaScript: true,
      SVG: true,
    })
  ],
  site: "https://cb341.dev",
  image: {
    service: sharpImageService(),
    domains: [],
  },
  build: {
    inlineStylesheets: 'always',
    assets: '_astro',
  },
  vite: {
    build: {
      cssCodeSplit: false,
      rollupOptions: {
        output: {
          manualChunks: undefined,
        },
      },
    },
  },
});
