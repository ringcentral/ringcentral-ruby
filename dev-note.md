## Update all dependencies

Dependabot opens weekly update PRs for GitHub Actions only. Updates are reviewed
and merged manually; automatic merging and Ruby gem updates are not configured.
Dependency-update PRs use the same full-suite tests as other PRs. Required live
test credentials may be unavailable to Dependabot or fork PRs; a run without
them cannot validate the full suite. Never expose credentials to untrusted PR
code or use a privileged PR trigger to bypass this restriction.

```
bundle update
```

## Documentation

The documentation workflow generates YARD documentation for PRs targeting
`master` and pushes to `master`. PR builds have read-only repository access and
no deployment environment or deployment credentials. A separate deployment job
publishes the built documentation to GitHub Pages only after a successful build
on a push to `master`; only that job uses the `prod` environment and repository
write permission.

## Test

```
bundle exec rspec
```

### Run a specific test case

```
bundle exec rspec spec/path/to/test.rb
```

## Deploy

Update version number in `ringcentral-sdk.gemspec`.

```
gem build ringcentral-sdk.gemspec
gem push ringcentral-sdk-<version>.gem
```
