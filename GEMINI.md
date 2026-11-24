# Climate Insights Directory Extension

When the user asks what NGOs, think tanks or other civil-society organisations say about climate, energy or
environmental policy, use the `climate-insights-directory` MCP server. Its tools are `search` and `fetch`
(in Gemini CLI: `mcp_climate-insights-directory_search` and `mcp_climate-insights-directory_fetch`). The
`climate-energy-research` skill in this extension holds the full method; the rules below apply even when
it is not loaded.

## Finding documents

- <!-- rule:tag-pull --> Query text narrows a tag pull. Any non-empty `query` switches to full text and
  silently shrinks the pool (the tag `loss and damage`: 1,133 records with `query=""`, 389 with extra
  words). To pull everything a filter matches, send `query=""` with the filters and a date `sort`. Report
  `filters_total` beside `total` where they differ.
- <!-- rule:region-gap --> A region does not include its countries. `geography=Africa` misses records
  tagged with Nigeria or Zambia. Send the region and its member countries as separate `geography` values,
  and say which countries you included.
- <!-- rule:homonyms --> Acronyms can name another body or event (`CoP-30` returns a 2022 Inter-American
  Institute meeting, `COP30` the 2025 conference). Check `facets.publisher` and the first page for
  off-topic hits, add a year, host city or tag, and drop the wrong ones.
- <!-- rule:concentration --> One publisher can fill a pool. After each pull, divide the first
  `facets.publisher` `count` by `total.value`. At 20% or more, state the share, read the next publishers,
  and do not present the pool as the view of civil society.
- <!-- rule:warnings --> Any entry in `query_echo.warnings` means the result is wrong. Fix the value and
  search again before you trust a number.

## Citing

- <!-- rule:fetch-before-cite --> Call `fetch(id)` for every record you cite. Search results omit authors
  and primary geography.
- <!-- rule:cite-publisher --> Credit the original publisher, not the directory: publisher, "title"
  (date), via Climate Insights Directory, linking the record URL. Name real co-authors where the record
  does.
- <!-- rule:coalition-once --> Count a coalition once. A joint letter is one voice, however many
  organisations sign it. Count organisations, not documents, when saying how many sources hold a view.
- <!-- rule:ai-text --> Summaries and key insights are AI-generated and not reviewed by the publisher.
  Attribute them to the directory or quote the original, and check any figure at `source_url`.
- <!-- rule:dates --> Give `date_published` as provided (`YYYY-MM-DD`, `YYYY-MM`, `YYYY` or null); do not
  pad partial dates. "Earliest" means earliest in the directory.
