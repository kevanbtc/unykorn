Here’s a single, copy-paste **Copilot prompt** you can drop into Copilot Chat (or as a repo “/PROMPT.md”) to make it enhance/fix code **and** generate a clean, glossy/frosty 3D Web3 site. Customize the 🔧 placeholders first.

---

## PROMPT FOR COPILOT

**Role:** You are a senior full-stack engineer + product designer. Your job is to **repair any broken code**, **tighten the build pipeline**, and **generate a production-ready Web3 website** with a **clean, glossy, frosty (glassmorphism) aesthetic** and subtle **3D polish**. Output complete, runnable code and minimal docs.

### Product goals

* Build a fast, accessible, responsive **Web3 onboarding site** with:

  * **Landing page** (hero, value props, CTA)
  * **Join / Check-in page** (simple 1-tap flow; older-user friendly)
  * **Connector page** (share links, intro flow)
  * **Merchant page** (create pay links / offers)
  * **Dashboard** (wallet status, activity, payouts)
* Integrate **wallet connect** (email/phone + Web3: RainbowKit/Wagmi or Privy/Magic as fallback).
* Include **QR generation** and deep links (for posters/NFC/SMS).
* Ship with **Netlify** config that avoids 404s and adds SPA redirects.
* Design language: **glassmorphism / frosted glass**, **soft 3D shadows**, **high-contrast, legible**, **tasteful motion**.

### Tech stack (target)

* **Next.js** + **TypeScript**
* **Tailwind CSS** (+ tailwind-animate, class-variance-authority, framer-motion)
* **shadcn/ui** for base components
* **Wagmi + RainbowKit** (connectors: Coinbase, WalletConnect, Rainbow; plus email/passkey fallback)
* **Zod** (validation), **React Hook Form**
* **Vercel OG** (social images) (optional)
* **Netlify** deployment (site already on Netlify)
* **ESLint + Prettier + Husky + lint-staged** (fix on commit)

> If repo already exists, **migrate/repair** to the above stack with minimal disruption.

### Aesthetic & UX requirements

* **Frosted glass** cards (blur, translucency), **subtle depth**, **soft specular highlights**, **light/dark mode**.
* **Large type, giant buttons**, single-action screens for older users.
* **Motion:** micro-interactions with Framer Motion (fade/slide; 150–250ms).
* **3D polish:** gentle parallax on hero, optional CSS perspective hover on cards (no heavy WebGL).
* **Accessibility:** WCAG AA, keyboard nav, aria labels; color contrast ≥ 4.5:1.
* **Performance:** Lighthouse ≥ 90 on Mobile (Performance/SEO/Accessibility).

### Features to implement

1. **Wallet / Auth**

   * RainbowKit/Wagmi with common EVM chains.
   * **Fallback**: email/phone login (e.g., Privy or Magic) for non-crypto users.
2. **QR + Links**

   * Generate QR codes for: `/join?b=<beaconId>`, `/pay?amt=…&m=…&poi=…`
   * Short-link helper with slug storage.
3. **Pages**

   * `/` Landing: hero + CTA “Join now”
   * `/join` Simple 1-tap flow (big button) → toast success
   * `/connector` Share intro link; list prior intros
   * `/merchant` Create pay links (form validation)
   * `/dashboard` Wallet state, recent activity, “copy link” tools
4. **Theming**

   * Tailwind theme tokens for frosty/glassy look (backdrop-blur, gradients, elevation)
   * Dark mode via `class` strategy
5. **State & Data**

   * Local demo store (zustand) stubbed now; easy swap to API later
6. **Deployment**

   * **netlify.toml** with correct `publish` and Next plugin (SSR) **or** static export + `_redirects` for SPA:

     * If SSR: `@netlify/plugin-nextjs`, publish `.next`
     * If SPA export: publish `out` + `_redirects` containing `/* /index.html 200`
7. **Tooling & QA**

   * ESLint/Prettier strict, TypeScript strict, CI script
   * Add example e2e with Playwright for smoke (load pages, click primary CTAs)

### Content & copy (seed)

* Headline: “Turn time & intros into value.”
* Sub: “Scan. Share. Get paid when real commerce happens.”
* CTAs: “Join now”, “Share an intro”, “Create a pay link”
* Footer: legal placeholders (Terms, Privacy, Disclosures).

### Acceptance criteria (must pass)

* ✅ `npm run build` succeeds with no type errors.
* ✅ Pages load on Netlify (no 404 at `/`).
* ✅ Mobile Lighthouse ≥ 90 (Perf/SEO/A11y/Best Practices).
* ✅ Wallet connect works (EVM testnet ok); fallback auth visible.
* ✅ QR generation works; scanned links resolve.
* ✅ Responsive: 360px to 1440px; keyboard accessible.
* ✅ Glass/frost look is obvious but tasteful; motion subtle.
* ✅ README with quick start + deploy steps.

### Repair & hardening tasks (apply automatically)

* Scan repo for **broken imports, missing env vars, bad publish dir**, or failing routes.
* Fix Netlify 404 by choosing correct mode:

  * **Next SSR**: add `@netlify/plugin-nextjs`, publish `.next`, remove SPA `_redirects`
  * **Static export**: `next export` to `out`, add `_redirects` with `/* /index.html 200`
* Add sensible defaults to `.env.example` and guard all env accessors.
* Configure Husky + lint-staged to run `typecheck`, `lint`, `format`.

### Deliverables

* Full code changes (pages/components/styles/hooks).
* `netlify.toml`, `_redirects` (if SPA), `README.md` (setup, build, deploy, env).
* A **design tokens** doc section listing color palette, radii, shadows, blur levels.
* A short **“Why it’s fast & accessible”** note.
* A **troubleshooting** section for Netlify 404s.

### Style cheatsheet (apply in Tailwind)

* Cards: `backdrop-blur-xl bg-white/8 dark:bg-white/5 border border-white/10 shadow-[0_10px_30px_rgba(0,0,0,0.25)]`
* Gradients: subtle diagonal background; add glass highlights via pseudo-elements
* Motion: `whileHover={{ scale: 1.02 }}` `transition={{ type: "spring", stiffness: 200, damping: 18 }}`

### Non-goals

* No heavy WebGL/Three.js; keep assets light.
* No blockchain writes yet (read-only wallet ok); wire APIs later.

**Now:**

1. Inspect current repo.
2. List repairs you’ll make.
3. Implement the site per above.
4. Print a short summary of what changed + how to run + how to deploy on Netlify.

**Constraints:** Keep it elegant and minimal. Prefer composable components over page-specific one-offs. Ensure everything is production-grade.

---

If you want, I can also give you a **Netlify “mode switcher”** mini-prompt to tell Copilot which deployment mode to use (Next SSR vs. static export).
