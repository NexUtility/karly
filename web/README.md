# karly-web

Promo & legal site for the **Karly** mobile app
(Cross-border marketplace seller profit calculator). Served at
[karly.nexutility.dev](https://karly.nexutility.dev) as a Cloudflare
Worker (Static Assets).

Same stack as the org umbrella site `NexUtility/nexutility-web`:
**Astro 6 + Tailwind v4 + Geist**.

## Routes

| Route      | Purpose |
| ---------- | ------- |
| `/`        | Hero, features, supported marketplaces, legal CTA |
| `/privacy` | Privacy Policy (the URL submitted to Google Play / App Store) |
| `/terms`   | Terms of Service |
| `/support` | Support contacts + FAQ |
| `/404`     | Custom not-found page |

## Development

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # static output to ./dist
npm run preview  # serve the built site locally
```

## Deploy

```bash
npm run deploy   # builds + wrangler deploy to the karly-web Worker
```

The custom domain `karly.nexutility.dev` is attached to the `karly-web`
Worker. Pushes to `main` trigger a Cloudflare auto-build if the repo is
connected via the Workers & Pages dashboard.

`public/_headers` and `public/_redirects` are picked up automatically.

## Legal placeholders

`/privacy` and `/terms` are template-grade. Before submitting the app to
the App Store / Play Store, replace the bracketed values
(`[Legal entity name]`, `[Registered address]`, `[Your jurisdiction]`,
`[Your venue]`) and have the documents reviewed by counsel.
