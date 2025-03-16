import { useRef, type JSX } from "react";

type Headings = {
  depth: number;
  slug: string;
  text: string;
}[];

export function TOC({ headings }: { headings: Headings }) {
  const navBar = useRef<HTMLDivElement | null>(null);
  const floorDepth = headings[0].depth;
  const onClickHandler = () => {
    navBar.current?.classList.toggle("w-0");
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
              <li key={slug + "list"} className="pt-3">
                <a
                  key={slug + "anchor"}
                  href={"#" + slug}
                  className="text-wrap"
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
        onClick={onClickHandler}
        className="hover:cursor-pointer select-none"
      >
        {"<"}
      </div>
      <div
        ref={navBar}
        className="overflow-y-auto h-full pt-[3.3rem] bg-background flex flex-col items-center w-0 md:w-[340px]"
        // style={{ width: "clamp(100vw, 340px)" }}
      >
        <div className="py-6">Table of content</div>
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
