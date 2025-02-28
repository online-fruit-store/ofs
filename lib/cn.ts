import clsx, { ClassValue } from "clsx";
import { extendTailwindMerge } from "tailwind-merge";

const twMerge = extendTailwindMerge({
  extend: {
    theme: {
      color: [
        "primary",
        "secondary",
        "accent",
        "background",
        "text",
        "neutralHard",
        "neutral",
        "neutralSoft",
        "info",
        "error",
        "success",
      ],
    },
  },
});

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
