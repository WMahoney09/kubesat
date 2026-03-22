# KubeSAT Adapters

Adapters provide the Dispatcher with a way to poll external sources for changes. They are **optional** — without an adapter, the Dispatcher creates an Actor Job every orbit unconditionally.

## Interface

An adapter is a shell script that implements a single function:

### `adapter_fetch_items`

Must echo a JSON array of objects to stdout:

```json
[
  {"id": "123", "hash": "2024-01-15T10:30:00Z"},
  {"id": "456", "hash": "abc123def456"}
]
```

- `id` — unique identifier for the item (string)
- `hash` — change indicator (string). Can be anything: a content hash, a timestamp, an ETag. The Dispatcher compares this value against its orbit log to detect changes.

The function reads its own configuration from environment variables.

## How adapters are used

1. The Dispatcher sources the adapter: `source adapters/<name>.sh`
2. Each orbit, the Dispatcher calls `adapter_fetch_items`
3. The Dispatcher compares the returned `hash` values against its orbit log
4. If any items are new or changed, the Dispatcher creates an Actor Job with the changed item IDs
5. The Actor (Claude) fetches item content itself using available tools — adapters are a Dispatcher-only concern

## Writing an adapter

1. Create `adapters/<name>.sh`
2. Implement `adapter_fetch_items` as a shell function
3. Document required environment variables at the top of the file
4. The function must echo valid JSON to stdout

## Built-in adapters

- `github-issues` — polls GitHub Issues via `gh api`
