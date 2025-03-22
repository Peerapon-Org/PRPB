"use client";

import { useEffect, useRef } from "react";
import { cn } from "@/lib/utils";

type ThemeToggleBtnProps = {
  size?: "sm" | "md";
};

export function ThemeToggleBtn({ size = "md" }: ThemeToggleBtnProps) {
  const styles = {
    circle: {
      sm: "w-[2.2rem] h-[2.2rem] rounded-[2rem] border-2 border-[hsl(var(--menu-border))] backdrop-filter backdrop-blur-[6px]",
      md: "w-[3rem] h-[3rem] rounded-[2rem] border-2 border-[hsl(var(--menu-border))] backdrop-filter backdrop-blur-[6px]",
    },
    themeToggleBtn: "cursor-pointer overflow-hidden",
    themeToggleIcon:
      "w-full h-full flex basis-full shrink-0 items-center justify-center transition-all duration-500 ease-menu",
    icon: {
      sm: "w-[1.25rem] h-[1.25rem] select-none",
      md: "w-[1.7rem] h-[1.7rem] select-none",
    },
  };

  const themeToggleBtn = useRef<HTMLDivElement | null>(null);
  const sunIconElement = useRef<HTMLImageElement | null>(null);
  const moonIconElement = useRef<HTMLImageElement | null>(null);

  function switchIcon(isDark: boolean) {
    if (isDark) {
      sunIconElement.current?.style.setProperty(
        "transform",
        "rotate(-90deg) translateX(-100%)"
      );
      moonIconElement.current?.style.setProperty(
        "transform",
        "rotate(-270deg) translateX(-100%) rotate(-90deg)"
      );
    } else {
      sunIconElement.current?.style.setProperty("transform", "rotate(0deg)");
      moonIconElement.current?.style.setProperty("transform", "rotate(0deg)");
    }
  }

  function themeToggleHandler() {
    document.documentElement.classList.toggle("dark");
    const isDark = document.documentElement.classList.contains("dark");
    switchIcon(isDark);
  }

  useEffect(() => {
    const isDark = document.documentElement.classList.contains("dark");
    switchIcon(isDark);

    const observer = new MutationObserver(() => {
      const isDark = document.documentElement.classList.contains("dark");
      switchIcon(isDark);
    });
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class"],
    });
  }, []);

  return (
    <div
      ref={themeToggleBtn}
      className={cn(styles.circle[size], styles.themeToggleBtn)}
      onClick={themeToggleHandler}
    >
      <div ref={sunIconElement} className={styles.themeToggleIcon}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          className={styles.icon[size]}
        >
          <circle cx="12" cy="12" r="5"></circle>
          <line x1="12" y1="1" x2="12" y2="3"></line>
          <line x1="12" y1="21" x2="12" y2="23"></line>
          <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
          <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
          <line x1="1" y1="12" x2="3" y2="12"></line>
          <line x1="21" y1="12" x2="23" y2="12"></line>
          <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
          <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
        </svg>
      </div>
      <div ref={moonIconElement} className={styles.themeToggleIcon}>
        {/* <img src={moonIcon.src} className={styles.icon[size]} alt="Sun Logo" /> */}
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="white"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          className={styles.icon[size]}
        >
          <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
        </svg>
      </div>
    </div>
  );
}
