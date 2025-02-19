"use client";

// import ThemeToggleIcon from "@/components/ThemeToggleIcon.astro";
// import { Input } from "@/components/ui/input";
import prpbIcon from "@/assets/prpb.svg";
import { ThemeToggleBtn } from "@/components/ui/themeToggleBtn";
// import { buttonVariants } from "@/components/ui/button";
// import { cn } from "@/lib/utils";
import { redirectHandler } from "@/lib/redirectHandler";

export function PCHeader() {
  const menus = [
    { menu: "Home", link: "/" },
    { menu: "Blogs", link: "/blogs" },
    { menu: "About", link: "/about" },
  ];

  return (
    <div className="absolute h-full  w-full">
      <div className="sticky z-full top-0 px-44 h-[3.3rem] flex items-center justify-between backdrop-filter backdrop-blur-[20px] border-b">
        <a
          href="/"
          rel="noopener noreferrer nofollow"
          className="flex items-center justify-center h-full shrink-0"
        >
          <img
            src={prpbIcon.src}
            className="w-[3.5rem] select-none"
            alt="PRPB Logo"
          />
        </a>
        <div className="flex h-full">
          {menus.map(({ menu, link }) => (
            <a
              key={menu}
              href={link}
              onClick={redirectHandler}
              className="text-sm bg-transparent h-full px-[1.8rem] flex items-center justify-center hover:bg-secondary transition-all duration-500 ease-menu select-none"
            >
              {menu}
            </a>
          ))}
        </div>
        <div className="shrink-0">
          <ThemeToggleBtn size="sm" />
        </div>
        {/* <div className=""></div> */}
        {/* <Input type="search" /> */}
      </div>
    </div>
  );
}
