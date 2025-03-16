// @ts-check
import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";
import react from "@astrojs/react";
import remarkMermaid from "remark-mermaidjs";

export default defineConfig({
  integrations: [tailwind({ applyBaseStyles: false }), react()],
  markdown: {
    remarkPlugins: [remarkMermaid],
  },
});
