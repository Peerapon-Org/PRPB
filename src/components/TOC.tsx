import { useRef, type JSX } from "react";

type Headings = {
  depth: number;
  slug: string;
  text: string;
}[];

export function TOC({ headings }: { headings: Headings }) {
  const navBar = useRef<HTMLDivElement | null>(null);
  const navBtn = useRef<HTMLDivElement | null>(null);
  const floorDepth = headings[0].depth;
  const onClickHandler = () => {
    navBar.current?.classList.toggle("!w-0");
    navBtn.current?.classList.toggle("hidden");
    navBtn.current?.firstElementChild?.classList.toggle("rotate-180");
  };
  const generateTOC = (
    headings: Headings,
    currentDepth: number
  ): JSX.Element => {
    return (
      <>
        <ul className="list-none">
          {headings.map(({ depth, slug, text }, idx) => {
            if (depth !== currentDepth) return;
            return (
              <li key={slug + "list"} className="pt-2">
                <a
                  key={slug + "anchor"}
                  href={"#" + slug}
                  className="text-wrap block bg-background hover:bg-muted px-2 py-1"
                  onClick={onClickHandler}
                >
                  {text}
                </a>
                {headings[idx + 1]?.depth > currentDepth &&
                  generateTOC(headings.slice(idx + 1), headings[idx + 1].depth)}
              </li>
            );
          })}
        </ul>
      </>
    );
  };

  return (
    <nav className="fixed top-0 right-0 z-[999] h-full flex items-center text-sm">
      <div
        ref={navBtn}
        onClick={onClickHandler}
        className="w-7 py-4 rounded-l-xl hover:cursor-pointer select-none border-y border-l border-r border-r-background bg-background relative left-[2px] hidden xs:block"
      >
        <svg
          className="w-full h-full rotate-180"
          viewBox="0 0 1024 1024"
          version="1.1"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M768 903.232l-50.432 56.768L256 512l461.568-448 50.432 56.768L364.928 512z"
            fill="currentColor"
          />
        </svg>
      </div>
      <div
        ref={navBar}
        className="overflow-y-auto h-full pt-[3.3rem] bg-background flex flex-col items-center w-screen xs:w-[340px] border-l"
        // style={{ width: "clamp(100vw, 340px)" }}
      >
        <div className="py-6 text-lg font-semibold">Table of content</div>
        <div className="pr-8 py-6">
          {generateTOC(
            headings.map((heading) => {
              if (heading.depth < floorDepth)
                return { ...heading, depth: floorDepth };
              return heading;
            }),
            floorDepth
          )}
        </div>
      </div>
    </nav>
  );
}
