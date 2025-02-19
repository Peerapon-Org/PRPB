"use client";

import "@/styles/mobileHeader.css";
import { cn } from "@/lib/utils";
import { Button, buttonVariants } from "@/components/ui/button";
import { ThemeToggleBtn } from "@/components/ui/themeToggleBtn";
import prpbIcon from "@/assets/prpb.svg";
import githubIcon from "@/assets/github.svg";
import darkGithubIcon from "@/assets/github-dark.svg";
import linkedinIcon from "@/assets/linkedin.svg";
import darkLinkedinIcon from "@/assets/linkedin-dark.svg";
import { useEffect, useRef } from "react";

export function MobileHeader() {
  // const menus = [
  //   { menu: "Home", link: "/" },
  //   { menu: "Blogs", link: "/blogs" },
  //   { menu: "About", link: "/about" },
  // ];
  // // spacebar: 32, pageup: 33, pagedown: 34, end: 35, home: 36
  // // left: 37, up: 38, right: 39, down: 40,
  // const keys = [32, 33, 34, 35, 36, 37, 38, 39, 40];
  // const wheelEvent =
  //   "onwheel" in document.createElement("div") ? "wheel" : "mousewheel";
  // const menuOverlay = useRef<HTMLDivElement | null>(null);
  // const menuContainer = useRef<HTMLDivElement | null>(null);
  // const themeToggleBtn = useRef<HTMLDivElement | null>(null);
  // const githubIconNode = useRef<HTMLImageElement | null>(null);
  // const linkedinIconNode = useRef<HTMLImageElement | null>(null);

  useEffect(() => {
    const isDark = document.documentElement.classList.contains("dark");
    // if (isDark) {
    //   (githubIconNode.current as HTMLImageElement).src = darkGithubIcon.src;
    //   (linkedinIconNode.current as HTMLImageElement).src = darkLinkedinIcon.src;
    // } else {
    //   (githubIconNode.current as HTMLImageElement).src = githubIcon.src;
    //   (linkedinIconNode.current as HTMLImageElement).src = linkedinIcon.src;
    // }

    // themeToggleBtn.current?.addEventListener("click", () => {
    //   if (document.documentElement.classList.contains("dark")) {
    //     (githubIconNode.current as HTMLImageElement).src = githubIcon.src;
    //     (linkedinIconNode.current as HTMLImageElement).src = linkedinIcon.src;
    //   } else {
    //     (githubIconNode.current as HTMLImageElement).src = darkGithubIcon.src;
    //     (linkedinIconNode.current as HTMLImageElement).src =
    //       darkLinkedinIcon.src;
    //   }
    // });

    // menuContainer.current?.addEventListener("click", (e) => {
    //   if (!menuContainer.current?.classList.contains("active")) {
    //     e.preventDefault();
    //     themeToggleBtn.current?.classList.add("active");
    //     menuOverlay.current?.classList.add("active");
    //     menuContainer.current?.classList.add("active");
    //     disableScroll();
    //   }
    // });

    //   menuOverlay.current?.addEventListener("click", (e) => {
    //     if (menuContainer.current?.classList.contains("active")) {
    //       themeToggleBtn.current?.classList.remove("active");
    //       menuOverlay.current?.classList.remove("active");
    //       menuContainer.current.classList.remove("active");
    //       enableScroll();
    //     }
    //   });
  }, []);

  function preventDefault(e: Event) {
    e.preventDefault();
  }

  // function preventDefaultForScrollKeys(e: KeyboardEvent) {
  //   if (keys.includes(e.keyCode)) {
  //     e.preventDefault();
  //     return false;
  //   }
  // }

  // function disableScroll() {
  //   menuOverlay.current?.addEventListener(
  //     "DOMMouseScroll",
  //     preventDefault,
  //     false
  //   ); // older FF
  //   menuOverlay.current?.addEventListener(wheelEvent, preventDefault, false); // modern desktop
  //   menuOverlay.current?.addEventListener("touchmove", preventDefault, false); // mobile
  //   window.addEventListener("keydown", preventDefaultForScrollKeys, false);
  // }

  // function enableScroll() {
  //   menuOverlay.current?.removeEventListener(
  //     "DOMMouseScroll",
  //     preventDefault,
  //     false
  //   ); // older FF
  //   menuOverlay.current?.removeEventListener(wheelEvent, preventDefault, false); // modern desktop
  //   menuOverlay.current?.removeEventListener(
  //     "touchmove",
  //     preventDefault,
  //     false
  //   ); // mobile
  //   window.removeEventListener("keydown", preventDefaultForScrollKeys, false);
  // }

  return (
    <ThemeToggleBtn />
    //       <div className="absolute h-full w-full">
    //   <div
    //     ref={menuOverlay}
    //     className="menu-overlay bg-overlay/90 dark:bg-overlay/90"
    //   ></div>
    //   <div className="menu-group">
    //     <div ref={themeToggleBtn} className="theme-toggle-btn-wrapper">
    //       <ThemeToggleBtn />
    //     </div>
    //     <div
    //       ref={menuContainer}
    //       className="menu-container circle backdrop-filter backdrop-blur-[6px]"
    //     >
    //       {menus.map(({ menu, link }) => (
    //         <a
    //           key={menu}
    //           className={cn([
    //             buttonVariants({
    //               variant: "secondary",
    //               size: "custom",
    //               fontSize: "custom",
    //             }),
    //             "menu-item",
    //           ])}
    //           href={link}
    //         >
    //           {menu}
    //         </a>
    //       ))}
    //       <Button
    //         variant={"secondary"}
    //         size={"custom"}
    //         fontSize={"custom"}
    //         className="menu-item about-me"
    //       >
    //         <a href="/" rel="noopener noreferrer nofollow">
    //           <img
    //             src={prpbIcon.src}
    //             className="h-0 prpb-icon"
    //             alt="PRPB Logo"
    //           />
    //         </a>
    //         <div className="flex items-center">
    //           <a
    //             href="https://github.com/Peerapon-Org/PRPB"
    //             rel="noopener noreferrer nofollow"
    //             target="_blank"
    //           >
    //             <img
    //               ref={githubIconNode}
    //               className="h-0 pr-[.8rem] github-icon"
    //               alt="GitHub Logo"
    //             />
    //           </a>
    //           <a
    //             href="https://www.linkedin.com/in/peerapon-b-197172345"
    //             rel="noopener noreferrer nofollow"
    //             target="_blank"
    //           >
    //             <img
    //               ref={linkedinIconNode}
    //               className="h-0 linkedin-icon"
    //               alt="Linkedin Logo"
    //             />
    //           </a>
    //         </div>
    //       </Button>
    //     </div>
    //   </div>
    // </div>
  );
}
