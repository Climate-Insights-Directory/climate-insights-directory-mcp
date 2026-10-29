# Climate Insights Directory for AI assistants

Free, no API key. Discover what civil-society reports, policy briefs and analyses say about climate
and energy, improve your desk research for policy, finance, scholarship, and journalism.

[Climate Insights Directory](https://climateinsightsdirectory.org) is a free, open index of climate
and energy research published by global civil society organizations, such as NGOs, think tanks and
research centers. This repository connects it to AI assistants through its MCP server, so an
assistant can search the index and cite what it finds. No account or API key is needed.

## Install

### Claude Code

Add this repository as a plugin marketplace, then install the plugin:

```
/plugin marketplace add Climate-Insights-Directory/climate-insights-directory-mcp
/plugin install climate-insights-directory@climate-insights-directory
```

Then ask, for example: "What do civil-society reports say about coal phase-out in Southeast Asia?"

### Gemini CLI

```
gemini extensions install https://github.com/Climate-Insights-Directory/climate-insights-directory-mcp
```

Then ask, for example: "Which think tanks have analysed the EU Carbon Border Adjustment Mechanism?"

### Other assistants

If your assistant lists Climate Insights Directory in its connector directory, install it from
there. Every client can also add the server by hand; the steps for Claude, ChatGPT, Antigravity,
Hermes and others are on [climateinsightsdirectory.org/api-docs](https://climateinsightsdirectory.org/api-docs#mcp).

## What the assistant gets

Two read-only tools:

- `search`: full-text search over the index, with filters for publisher, geography, topic tags,
  document type, language and publication date.
- `fetch`: one record by its id, with its title, text, URL and metadata.

Every record carries metadata, an AI-written summary and a link to the original publisher. Full
documents stay on the publishers' websites. The directory does not include datasets and does not
return time series.

Our preferred citation names the original publisher, followed by "via Climate Insights Directory".

## Feedback

Found something wrong, or have an idea? [Open an issue](https://github.com/Climate-Insights-Directory/climate-insights-directory-mcp/issues)
in this repository. Issues are welcome for anything about the website or the API, not only this
plugin: a wrong record, a missing organization, a search that should find something and doesn't.
You can also write to [info@climateinsightsdirectory.org](mailto:info@climateinsightsdirectory.org).

## What is in this repository

- `plugins/climate-insights-directory/`: the Claude Code plugin, with the server connection and a
  skill that tells Claude when to use it.
- `gemini-extension.json` and `GEMINI.md`: the Gemini CLI extension.

More plugins and tools from the Climate Insights Directory team may join this repository over time.

## License

[MIT](LICENSE)
