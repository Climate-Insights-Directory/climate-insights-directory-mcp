---
name: climate-energy-research
description: "Best-practice method for any AI agent researching the Climate Insights Directory MCP server: finding documents with high recall (including snowballing and adjacent topics) and citing them with correct provenance."
---

# Researching the Climate Insights Directory

The Climate Insights Directory (climateinsightsdirectory.org) is an open index of reports, policy briefs,
submissions and analyses published by civil-society organisations worldwide. Each record holds publisher
metadata (title, organisation, date, type, language, link to the original) plus fields the directory
generates with AI: a summary, numbered key insights, climate tags and places discussed.

This skill is for agents serving people who need answers they can stand behind, such as a financial desk
researcher scanning a market or jurisdiction, a journalist checking a claim or finding who has written on
something, or an academic assembling a literature set. It covers two things: **finding the right
documents** and **citing them correctly**. It needs only the two MCP tools, with no shell or file system.

## Tools

- `search`: takes `query` (required; may be `""`), `page` (from 1), `page_size` (1–20, default 10),
  `response_format` (`concise` | `detailed`), `sort` (`relevance` default | `published` newest first |
  `published_asc` oldest first), and the filters `climate_tags`, `geography`, `geography_discussed`,
  `organization`, `document_type`, `analysis_type`, `frame_perspective`, `language`, `published_from`,
  `published_to` (YYYY-MM-DD) and `added` (ingestion date or `YYYY-MM-DD..YYYY-MM-DD`).
- `fetch(id)`: one record as markdown, including **Author(s)**, **primary geography**, the AI summary and
  findings, and **ready-made citations** (APA, Chicago, Wikipedia `{{cite report}}`, BibTeX).

Without the MCP tools, the same API is public at
`https://climateinsightsdirectory.org/api/v1/search?q=...&page=...` (same parameters), and each record has
a page at `https://climateinsightsdirectory.org/document/<id>`.

## Method

### 1. Turn the question into entry points

Before searching, write down what the question hangs on. Most questions combine two or three of these:

| Entry point | Use |
|---|---|
| A concept or theme | `climate_tags` filter (or `hasconcept:"..."` in the query) |
| An exact phrase, programme, instrument or acronym | quoted full text: `"\"Just Energy Transition Partnership\""` |
| A named entity (company, utility, bank, place) | full text, or `insummary:Eskom` |
| A country as the document's focus | `geography` filter |
| A publisher | `organization` (slug or short identifier) or `ispublisher:` |
| A period | `published_from` / `published_to`; `sort` |
| A genre (submission, guide, research paper) | `document_type` or `doctype:` |
| A known document | `cidid:<record-id>`, or `fetch(id)` |

### 2. Probe counts before pulling results

Run each candidate search with `page_size=1, response_format="concise"` and read two things:

- `total.value`, the size of the pool.
- `query_echo.warnings`. **Any warning means the result is wrong.** A value that isn't in the vocabulary
  is not simply dropped: it changes the count unpredictably. Fix the value and run it again before
  trusting any number.

Compare the counts of the different ways to ask (tag vs exact phrase vs loose words). In one test,
`just transition` came back with 2,116 as a tag, 1,996 as loose words and 1,289 as a quoted phrase.
The gaps show you what each route misses.

### 3. Widen recall deliberately

No single search finds everything. Combine:

- **Tag plus full text.** Tags are AI-assigned and miss things; full text misses documents that use other
  wording. Run both and merge by record `id`.
- **Synonyms and acronyms**, e.g. `JETP` / `"Just Energy Transition Partnership"`, `CBAM` / `"carbon border"`,
  former and local names of places, programmes and companies.
- **Other languages.** Summaries are in English even for non-English documents, so an English query
  finds them (`"just transition"` + `language=["fr"]` gave 48). A query in the document's own language
  finds more (`transition juste` + `fr` gave 79). For a country focus, run both.
- **Both sort orders.** `relevance` finds the best matches for a full-text query; `published` and
  `published_asc` show the newest and oldest. A tag-only pull (`query=""`) should use an explicit date
  sort.

### 4. Snowball from seed documents and follow adjacent topics

Keyword searches only find documents that use your words. Snowballing finds the rest by using what
the good hits tell you. Start from 3–5 **seed documents**: the most relevant records from steps 2–3,
ideally from different publishers and years. Read them in `detailed` format, or with `fetch`.

**Snowball from each seed along these lines:**

| From the seed's ... | Next search |
|---|---|
| `climate_tags` | each tag that is specific to the question (skip generic ones like `climate finance` unless that is the question) as a `climate_tags` filter, ANDed with your core filter |
| key insights and summary | named programmes, instruments, laws, companies, projects, places, as quoted full text or `insummary:` |
| publisher | the same `organization` + topic words: publishers usually write series and follow-ups |
| real authors and coalition partners | each partner organisation's own records (`organization` or `ispublisher:`) |
| `analysis_type` / `document_type` | the same type on the same topic (e.g. other `stakeholder analysis` records, other submissions on the same bill) |
| date | **backward**: `published_to` = seed date to find earlier work it builds on; **forward**: `published_from` = seed date to find responses, updates and outcomes |
| primary geography (from `fetch`) | the same topic in neighbouring or comparable countries |

For references *inside* a document (its bibliography), open `source_url`. A cited report may itself be in
the directory: search its title with `intitle:` or a quoted phrase.

**Work out the adjacent topics as you go.** While screening, sort each hit into one of three groups:

- **on-topic**: it answers the question;
- **adjacent**: it is about a neighbouring theme that bears on the question (e.g. for coal-plant early
  retirement: blended finance, stranded assets, power-purchase agreements, mine rehabilitation, worker
  reskilling);
- **off-topic**: the match was incidental.

When **three or more** adjacent hits share a theme, that theme is a real neighbour. Run a supplementary
search for it (as a tag if one exists in the hits' `climate_tags`, otherwise as full text), still ANDed
with the question's core filter (country, period, publisher), and screen those results the same way.
A quick way to find the neighbours: across a page of `detailed` results, list which `climate_tags`
turn up alongside your core tag most often.

**When to stop.** Do up to three rounds of snowballing and adjacent searches. Stop sooner once a round
brings back mostly records you have already seen; that saturation is your evidence of coverage. If you
are still finding many new on-topic records after three rounds, the question is broader than it looked:
report what you have and suggest narrowing it, or ask before carrying on.

**Keep a log.** For every snowball and adjacent search, note the seed or theme it came from, the
query and filters, the total, and how many new on-topic records it added. Report adjacent themes as
adjacent ("a related body of work on stranded assets ...") rather than mixing them into the core
findings.

### 5. Narrow with filters

- Repeating a value in one filter gives **OR**; combining different filters gives **AND**. The query text
  is ANDed with all filters.
- **Vocabulary format:** tags are case-insensitive words with spaces (`"carbon pricing"`). Single-word
  countries work as names (`"Kenya"`, `"Indonesia"`); multi-word countries need the slug
  (`"south-africa"`; `"South Africa"` warns).
- `organization` takes either the slug (`south-african-institute-of-international-affairs`) or the
  short identifier (`saiia`). Record IDs start with that identifier (`saiia-001296`).
- `intitle:` is narrow (`intitle:JETP` gave 11). Use it to find flagship reports, not to measure
  coverage.
- **Known quirk (Oct 2026):** `geography_discussed` returned 0 for every value tested, with or without a
  warning. For places a document *discusses* (as opposed to focuses on), use full text or `insummary:`
  instead, and treat any 0 from this filter as "not working", not "no documents".
- A 0 can also mean you have stacked too many ANDs. Remove filters one at a time to see which one empties
  the pool.

### 6. Page through systematically and group related versions

- Use `page_size=20` and follow `next` until it disappears, or until you have enough for the task.
- Use `detailed` only when you need insights and tags (pages get large); `concise` is enough for screening
  titles and summaries.
- Merge results from all searches (core, wideners, snowball, adjacent) by `id`, so a record found by
  several searches is counted once.
- **Group related versions of the same work.** Publishers often release one piece of research in several
  forms, each indexed as its own record: translations (same publisher, similar title, different
  `language`), an executive summary alongside the full report, or a brief alongside a longer paper.
  Cite the version that best fits the reader (usually the fullest, or the one in the reader's language),
  mention the others where useful, and count them as one piece of work when saying how much has been
  written.

### 7. Fetch every record you will cite

Search results omit authors and primary geography. Call `fetch(id)` for each document you rely on, to get:

- **Author(s)** and the real authoring body (see Provenance below),
- the exact publication date,
- the original `Source URL`,
- the ready-made citation formats.

## Citation and provenance

### Who said it

- **Credit the original publisher, not the directory.** Pattern: *Publisher, "Title" (date), via Climate
  Insights Directory*, linking the directory record URL and, where possible, the original `source_url`.
- **The indexing publisher is not always the author.** Coalition letters filed through a legal NGO,
  commissioned studies, and joint reports are indexed under one organisation. Example: a CER record on
  South Africa's JETP is a letter from the Life After Coal Campaign and the Fair Finance Coalition. Read
  the summary and the `fetch` Author(s) line, and credit everyone named ("X and Y, published by Z").
- **Count organisations, not documents,** when saying how many sources hold a view. One prolific
  publisher with ten reports is one voice. Snowballing through one publisher's series tends to inflate
  this, so check it again before you write.

### What exactly was said

- Summaries and key insights are **AI-generated and not reviewed by the publisher** (every response
  carries an `ai_marking` notice). Don't present them as the publisher's own words. Either:
  - attribute them to the directory ("the directory's summary of CPI's 2022 guide says ..."), or
  - open the `source_url` and quote or cite the publisher's text directly, ideally with a page number.
- Check any **figure** (percentages, dollar amounts, dates) against the original before a reader may
  rely on it.
- Copy text exactly; never retype or "tidy" a quote. Skip insights with garbled characters (stray control
  characters, such as the `\u001c` that appears in some titles) or quote the original instead.
- A precise pointer to an insight is its `unit`: `<record-id>#insight-N` (in `fetch` output, the Nth
  Key Findings bullet).

### When it was said

- Give `date_published` **as provided**: it may be `YYYY-MM-DD`, `YYYY-MM`, `YYYY` or null. Don't pad
  partial dates; write "undated" for null.
- Put the year next to every contrasting claim ("RMI (2021) ... Ember (2026) ...") so readers can tell a
  live disagreement from one overtaken by events.
- For "who raised this first", sort `published_asc` and say **"the earliest in the directory"**, not the
  earliest anywhere. `added` is when the directory ingested the record, which is not the publication date.

### Ready-made formats

`fetch` returns APA, Chicago, Wikipedia (`{{cite report ... |via=Climate Insights Directory}}`) and
BibTeX citations. Use them as a starting point, check that the author matches who actually wrote the
document, and update `access-date` / `urldate` to today.

## Examples of the method in use

- *"Which NGOs have criticised AIIB policy-based lending?"* Search full text `AIIB` with
  `"policy-based"`, then the `climate finance` tag + `AIIB`. Snowball from the strongest hit's named
  countries and instruments, and from its publisher's other AIIB work. Merge, fetch, and list by
  organisation with dates, crediting coalition authors.
- *"Is the claim that 93% of coal capacity is shielded from market pressure sourced?"* Use full text
  `"93%" coal` and `insummary:"coal capacity"`. Fetch, find the CPI 2022 guide, snowball backward
  (`published_to` 2022-11) for earlier sources of the figure, then cite it from the original document
  rather than from the AI insight.
- *"Literature on just transition in South Africa, 2020 onwards"* Combine the tag `just transition` +
  `geography=["south-africa"]` + `published_from=2020-01-01` with full-text passes for `JETP` and
  `Mpumalanga`. Snowball from seeds into the neighbouring themes that recur (e.g. coal-plant
  repurposing, municipal electricity debt, water). Stop when new rounds return mostly known records,
  then report the counts and searches used.

## Scope note (keep it short)

The directory covers civil-society research, not peer-reviewed literature, government filings or company
disclosures, and its coverage varies by publisher and region. One line in the answer saying so is enough.
For laws and NDCs, point to Climate Policy Radar; for emissions data, to sources such as Climate TRACE.

## Before you answer

- [ ] No search you relied on had a `warnings` entry.
- [ ] You tried at least one recall widener (synonym, full text vs tag, language).
- [ ] You snowballed from seed documents and checked for adjacent themes (3+ shared hits), up to three
  rounds or until saturation, and logged each search.
- [ ] Adjacent material is labelled as adjacent, not mixed into the core findings.
- [ ] Related versions of the same work (translations, summaries, briefs) are grouped and counted once.
- [ ] Every cited record was fetched; authors and dates come from the record.
- [ ] Each citation names the original publisher (and real co-authors), the date as given, and "via
  Climate Insights Directory", with the record link.
- [ ] AI summary or insight text is labelled as the directory's wording, or replaced by the original.
- [ ] Figures a reader may act on were checked against the source document.
- [ ] Coverage is stated: searches run, totals, saturation, and "earliest / most in the directory"
  phrasing where relevant.
