import { defineMiddleware } from "astro:middleware";

export interface Locals {
  theme: "dark" | "light";
}

export const onRequest = defineMiddleware(async ({ locals, request }, next) => {
  const { url } = request;
  const { pathname } = new URL(url);
  // const timestamp = new Date().toISOString();

  // (locals as { timestamp: string }).timestamp = timestamp;

  // const cookies = request.headers.get("cookie");
  // const parsedCookies = cookies
  //   ? Object.fromEntries(cookies.split("; ").map((c) => c.split("=")))
  //   : {};
  // console.log("parsedCookies", parsedCookies);
  (locals as Locals).theme = "dark";

  const response = await next();

  return response;
});
