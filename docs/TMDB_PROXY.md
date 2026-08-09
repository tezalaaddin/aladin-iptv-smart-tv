# TMDB proxy configuration

Production builds should use `--dart-define=TMDB_PROXY_URL=https://your-domain.example/tmdb/search`.
The proxy receives `type`, `query`, and `language`, adds the private TMDB credential server-side,
and returns the unmodified TMDB search JSON. Never store the private API key in the repository.

Direct `TMDB_API_KEY` remains supported only for local development. When neither value is supplied,
metadata enrichment disables itself safely without affecting playback.
