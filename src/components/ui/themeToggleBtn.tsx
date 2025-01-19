"use client";

import sunIcon from "@/assets/sun.svg";
import moonIcon from "@/assets/moon.svg";
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
        <img src={sunIcon.src} className={styles.icon[size]} alt="Sun Logo" />
      </div>
      <div ref={moonIconElement} className={styles.themeToggleIcon}>
        <img src={moonIcon.src} className={styles.icon[size]} alt="Sun Logo" />
      </div>
    </div>
  );
}
