import rss from "@astrojs/rss";
import { getCollection } from "astro:content";
import sanitizeHtml from "sanitize-html";
import MarkdownIt from "markdown-it";
const parser = new MarkdownIt();

export async function GET(context) {
  const blog = await getCollection("blog");

  const items = await Promise.all(
    blog.map(async (post) => {
      return {
        title: post.data.title,
        pubDate: post.data.pubDate,
        description: post.data.description,
        link: `/blog/${post.slug}/`,
        content: sanitizeHtml(parser.render(post.body), {
          allowedTags: sanitizeHtml.defaults.allowedTags.concat(["img"]),
        }),
        categories: post.data.tags || [],
        author: "cb341",
        guid: post.slug,
        ...(post.data.heroImage && {
          enclosure: {
            url: post.data.heroImage,
            type: "image/jpeg",
            length: 0,
          },
        }),
        customData: `
          <tags>${(post.data.tags || []).map((tag) => `<tag>${tag}</tag>`).join("")}</tags>
          <license>MIT</license>
        `,
      };
    }),
  );

  return rss({
    title: "cb341 Blog",
    description: "Personal blog and portfolio",
    site: context.site,
    language: "en",
    copyright: `Copyright (c) ${new Date().getFullYear()} cb341. Licensed under MIT.`,
    lastBuildDate: new Date(),
    ttl: 60,
    customData: `<generator>Astro v4</generator>`,
    items,
  });
}
