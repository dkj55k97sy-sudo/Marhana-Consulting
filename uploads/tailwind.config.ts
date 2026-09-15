import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        cream: "#faf9f5",
        teal: {
          dark: "#113C39",
        },
        sand: "#F7F3EA",
      },
      fontFamily: {
        serif: ["Playfair Display", "Georgia", "serif"],
        sans: ["Inter", "system-ui", "sans-serif"],
      },
      lineHeight: {
        relaxed: "1.6",
      },
      boxShadow: {
        premium: "0 20px 40px rgba(17, 60, 57, 0.08)",
      },
      transitionDuration: {
        default: "300ms",
      },
    },
  },
  plugins: [],
};

export default config;
