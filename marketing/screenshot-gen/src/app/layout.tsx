import type { Metadata } from "next";
import { Newsreader, Inter, Noto_Serif_JP, Noto_Sans_JP } from "next/font/google";
import "./globals.css";

const serif = Newsreader({
  variable: "--font-serif",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

const sans = Inter({
  variable: "--font-sans",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

const serifJa = Noto_Serif_JP({
  variable: "--font-serif-ja",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

const sansJa = Noto_Sans_JP({
  variable: "--font-sans-ja",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

export const metadata: Metadata = {
  title: "Weft — Screenshot Generator",
  description: "Internal tool for App Store screenshots",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html
      lang="en"
      className={`${serif.variable} ${sans.variable} ${serifJa.variable} ${sansJa.variable}`}
    >
      <body>{children}</body>
    </html>
  );
}
