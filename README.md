<p align="center">
  <img src="assets/banner.svg" alt="GEO-SEO Skill (Claude + Codex + Qwen)" width="900"/>
</p>

<p align="center">
  <strong>GEO-first, SEO-supported.</strong> Optimize websites for AI-powered search engines<br/>
  (ChatGPT, Claude, Perplexity, Gemini, Google AI Overviews) while maintaining traditional SEO foundations.
</p>

<p align="center">
  AI search is eating traditional search. This tool optimizes for where traffic is going, not where it was.
</p>

---

## Why GEO Matters (2026)

| Metric | Value |
|--------|-------|
| GEO services market | $850M+ (projected $7.3B by 2031) |
| AI-referred traffic growth | +527% year-over-year |
| AI traffic conversion rate vs organic | 4.4x higher |
| Gartner: search traffic drop by 2028 | -50% |
| Brand mentions vs backlinks for AI | 3x stronger correlation |
| Marketers investing in GEO | Only 23% |

---

## New in This Version

- Native install targets for **Claude Code**, **Codex CLI**, and **Qwen Code**
- `GEO_INSTALL_TARGET` support for single-target or multi-target installs
- Tested CLI-specific invocation flows instead of assuming one slash-command format everywhere
- Shared GEO scripts, sub-skills, agents, and schema assets installed into each CLI's home

---

## CLI Support

| CLI | Install Location | How to Invoke | Status |
|-----|------------------|---------------|--------|
| Claude Code | `~/.claude` | `/geo audit https://site.com` | Tested |
| Codex CLI | `~/.codex` | `Use $geo and run a GEO audit for https://site.com` | Tested |
| Qwen Code | `~/.qwen` | `/skills geo` → `geo` → `Run a GEO audit for https://site.com` | Tested |

---

## Quick Start

### One-Command Install (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/zubair-trabzada/geo-seo-claude/main/install.sh | bash
```

### Manual Install

```bash
git clone https://github.com/zubair-trabzada/geo-seo-claude.git
cd geo-seo-claude
./install.sh
```

Optional target selection:

```bash
GEO_INSTALL_TARGET=qwen ./install.sh   # claude | codex | qwen | all | claude,qwen (default: all)
```

### Requirements

- Python 3.8+
- Claude Code CLI, Codex CLI, and/or Qwen Code
- Git
- Optional: Playwright (for screenshots)

---

## Commands

In Claude Code, use these slash commands:

| Command | What It Does |
|---------|-------------|
| `/geo audit <url>` | Full GEO + SEO audit with parallel subagents |
| `/geo quick <url>` | 60-second GEO visibility snapshot |
| `/geo citability <url>` | Score content for AI citation readiness |
| `/geo crawlers <url>` | Check AI crawler access (robots.txt) |
| `/geo llmstxt <url>` | Analyze or generate llms.txt |
| `/geo brands <url>` | Scan brand mentions across AI-cited platforms |
| `/geo platforms <url>` | Platform-specific optimization |
| `/geo schema <url>` | Structured data analysis & generation |
| `/geo technical <url>` | Technical SEO audit |
| `/geo content <url>` | Content quality & E-E-A-T assessment |
| `/geo report <url>` | Generate client-ready GEO report |
| `/geo report-pdf` | Generate professional PDF report with charts & visualizations |

In Codex CLI, use prompt-style commands with `$geo`, for example:

- `Use $geo and run a GEO audit for https://site.com`
- `Use $geo and run a quick GEO visibility snapshot for https://site.com`
- `Use $geo and generate a client-ready GEO report for https://site.com`

Important for Codex:

- Restart the `codex` session after installing new skills so they are reloaded.
- Do not use Claude-style slash commands like `/geo audit ...` in Codex.
- In Codex, invoke the skill in a normal prompt with `$geo`.

In Qwen Code, explicitly load and select the skill first, then ask for the task:

- `/skills geo`
- `geo`
- `Run a GEO audit for https://site.com`
- `Generate a client-ready GEO report for https://site.com`

Important for Qwen:

- On first run, Qwen may stop on an authentication screen. Complete the OAuth flow once.
- `/skills geo` opens the GEO skill list. Select `geo` to load the main orchestrator skill.
- After `geo` is active, ask for the specific task or website you want analyzed.

---

## Architecture

```
geo-seo-claude/
├── geo/                          # Main skill orchestrator
│   └── SKILL.md                  # Primary skill file with commands & routing
├── skills/                       # 11 specialized sub-skills
│   ├── geo-audit/                # Full audit orchestration & scoring
│   ├── geo-citability/           # AI citation readiness scoring
│   ├── geo-crawlers/             # AI crawler access analysis
│   ├── geo-llmstxt/              # llms.txt standard analysis & generation
│   ├── geo-brand-mentions/       # Brand presence on AI-cited platforms
│   ├── geo-platform-optimizer/   # Platform-specific AI search optimization
│   ├── geo-schema/               # Structured data for AI discoverability
│   ├── geo-technical/            # Technical SEO foundations
│   ├── geo-content/              # Content quality & E-E-A-T
│   ├── geo-report/               # Client-ready markdown report generation
│   └── geo-report-pdf/           # Professional PDF report with charts
├── agents/                       # 5 parallel subagents
│   ├── geo-ai-visibility.md      # GEO audit, citability, crawlers, brands
│   ├── geo-platform-analysis.md  # Platform-specific optimization
│   ├── geo-technical.md          # Technical SEO analysis
│   ├── geo-content.md            # Content & E-E-A-T analysis
│   └── geo-schema.md             # Schema markup analysis
├── scripts/                      # Python utilities
│   ├── fetch_page.py             # Page fetching & parsing
│   ├── citability_scorer.py      # AI citability scoring engine
│   ├── brand_scanner.py          # Brand mention detection
│   ├── llmstxt_generator.py      # llms.txt validation & generation
│   └── generate_pdf_report.py    # PDF report generator (ReportLab)
├── schema/                       # JSON-LD templates
│   ├── organization.json         # Organization schema (with sameAs)
│   ├── local-business.json       # LocalBusiness schema
│   ├── article-author.json       # Article + Person schema (E-E-A-T)
│   ├── software-saas.json        # SoftwareApplication schema
│   ├── product-ecommerce.json    # Product schema with offers
│   └── website-searchaction.json # WebSite + SearchAction schema
├── install.sh                    # One-command installer
├── uninstall.sh                  # Uninstaller
├── requirements.txt              # Python dependencies
└── README.md                     # This file
```

---

## How It Works

### Full Audit Flow

When you run the GEO audit flow for `https://site.com`:

1. **Discovery** — Fetches homepage, detects business type, crawls sitemap
2. **Parallel Analysis** — Launches 5 subagents simultaneously:
   - AI Visibility (citability, crawlers, llms.txt, brand mentions)
   - Platform Analysis (ChatGPT, Perplexity, Google AIO readiness)
   - Technical SEO (Core Web Vitals, SSR, security, mobile)
   - Content Quality (E-E-A-T, readability, freshness)
   - Schema Markup (detection, validation, generation)
3. **Synthesis** — Aggregates scores, generates composite GEO Score (0-100)
4. **Report** — Outputs prioritized action plan with quick wins

### Scoring Methodology

| Category | Weight |
|----------|--------|
| AI Citability & Visibility | 25% |
| Brand Authority Signals | 20% |
| Content Quality & E-E-A-T | 20% |
| Technical Foundations | 15% |
| Structured Data | 10% |
| Platform Optimization | 10% |

---

## Key Features

### Citability Scoring
Analyzes content blocks for AI citation readiness. Optimal AI-cited passages are 134-167 words, self-contained, fact-rich, and directly answer questions.

### AI Crawler Analysis
Checks robots.txt for 14+ AI crawlers (GPTBot, ClaudeBot, PerplexityBot, etc.) and provides specific allow/block recommendations.

### Brand Mention Scanning
Brand mentions correlate 3x more strongly with AI visibility than backlinks. Scans YouTube, Reddit, Wikipedia, LinkedIn, and 7+ other platforms.

### Platform-Specific Optimization
Only 11% of domains are cited by both ChatGPT and Google AI Overviews for the same query. Provides tailored recommendations per platform.

### llms.txt Generation
Generates the emerging llms.txt standard file that helps AI crawlers understand your site structure.

### Client-Ready Reports
Generates professional GEO reports in markdown or PDF format. PDF reports include score gauges, bar charts, platform readiness visualizations, color-coded tables, and prioritized action plans — ready to deliver to clients.

---

## Tested Flows

### Claude Code

```text
/geo audit https://site.com
```

### Codex CLI

```text
Use $geo and run a GEO audit for https://site.com
```

### Qwen Code

```text
/skills geo
geo
Run a GEO audit for https://site.com
```

---

## Use Cases

- **GEO Agencies** — Run client audits and generate deliverables
- **Marketing Teams** — Monitor and improve AI search visibility
- **Content Creators** — Optimize content for AI citations
- **Local Businesses** — Get found by AI assistants
- **SaaS Companies** — Improve entity recognition across AI platforms
- **E-commerce** — Optimize product pages for AI shopping recommendations

---

## Uninstall

```bash
./uninstall.sh
```

Optional target selection:

```bash
GEO_INSTALL_TARGET=qwen ./uninstall.sh   # claude | codex | qwen | all | claude,qwen (default: all)
```

Or manually:
```bash
rm -rf \
  ~/.claude/skills/geo ~/.claude/skills/geo-* ~/.claude/agents/geo-*.md \
  ~/.codex/skills/geo ~/.codex/skills/geo-* ~/.codex/agents/geo-*.md \
  ~/.qwen/skills/geo ~/.qwen/skills/geo-* ~/.qwen/agents/geo-*.md
```

---

## Troubleshooting

- **Codex does not recognize `geo`**: Restart `codex` after install and use `$geo` in a normal prompt, not `/geo ...`.
- **Qwen asks for authentication**: Complete the Qwen OAuth flow on first launch, then rerun `/skills geo`, choose `geo`, and continue.
- **You only want one CLI target**: Use `GEO_INSTALL_TARGET=claude`, `codex`, `qwen`, or a comma-separated list like `claude,qwen`.
- **You want all supported CLIs**: Run `./install.sh` with no target override. Default is `all`.

---

## Want to Turn This Into a Business?

The tool is free. Learning how to monetize it is where the community comes in.

**[Join the AI Workshop Community →](https://skool.com/aiworkshop)**

Inside you'll get:
- **Video walkthroughs** — Step-by-step setup, running audits, reading results
- **Client acquisition playbook** — How to find prospects, pitch GEO services, and close deals
- **Live office hours** — Bring your audit results, get direct help
- **GEO agency pricing & templates** — Proposal docs, cold outreach scripts, onboarding workflows

GEO agencies charge $2K–$12K/month. This tool does the audit. The community teaches you how to sell it.

---

## License

MIT License

---

## Contributing

Contributions welcome!

---

Built for the AI search era.
