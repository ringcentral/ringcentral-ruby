# Release notes

## 2.0.0

- **Breaking compatibility change:** require Ruby >= 3.3. Local development uses
  Ruby 4.0; full live-suite CI covers Ruby 3.3, 3.4 and 4.0.
- Update runtime dependency minimums to addressable 2.9.2, concurrent-ruby 1.3.8,
  faraday 2.15.1, faraday-multipart 1.2.0 and faye-websocket 0.12.0 within their
  declared compatible series.
- Fix the default production server when constructing a client without a server;
  explicit server selection and the existing public SDK interfaces are preserved.
- Add a greeting integration example using the existing multipart interface and
  retained "hello world" WAV fixture; no new SDK runtime API is introduced.
- Load shared test setup and dotenv consistently, start coverage before the SDK,
  preserve local environment overrides, and complete the sample configuration.
- Wait for active WebSocket subscriptions and observe real notification windows;
  clean up subscriptions and message state even when assertions fail.
- Run the complete live suite in the normal and release Ruby matrices, serialize
  shared-account jobs, report missing credentials, and upload coverage per Ruby.
  Publish once only after the entire release matrix passes.
- Build PR documentation without deployment; deploy YARD documentation only on
  pushes to master. Add weekly GitHub Actions updates without automatic merging.
- Document tag-based release as the primary route, with manual publication as a
  mutually exclusive alternative for a given version.

- Include the MIT license text in the gem.
- Remove unused MkDocs configuration and the completed message-inspection
  diagnostic; retain YARD documentation, test configuration, and example fixtures.
