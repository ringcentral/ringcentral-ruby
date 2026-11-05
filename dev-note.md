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

See [README testing guidance](README.md#how-to-test) for credentials, local
`.env` overrides, selected examples and the complete live-suite command:

```sh
bundle exec rspec
```

The full suite is the local and CI default, including fax, MMS, pager, greeting
changes and WebSocket operations. Use the agreed test account and destinations.
Validate Ruby 3.3, 3.4 and 4.0. Serialize local suites and workflow runs sharing
an account; a workflow's sequential matrix does not serialize separate runs.
Missing credentials are a failure, not a reason to skip tests. Fork and
Dependabot limitations and supported secret setup are described in the README.

## Prepare a release

1. Finalize the source, version, release notes and consumer documentation. For
   2.0.0, set `gem.version` to `2.0.0` and `required_ruby_version` to `>= 3.3`;
   keep `.ruby-version` on the local development Ruby 4.0 series.
2. Validate the complete suite on Ruby 3.3, 3.4 and 4.0 and inspect the normal and
   release workflow matrix/gate configuration. Record exact commits and results.
   Remote integration and workflow execution require explicit authorization.
3. Build from the final committed source into a retained directory:

```sh
release_dir=$(mktemp -d)
release_gem="$release_dir/ringcentral-sdk-2.0.0.gem"
git rev-parse HEAD
gem build ringcentral-sdk.gemspec --output "$release_gem"
gem specification "$release_gem" --yaml
tar -xOf "$release_gem" data.tar.gz | tar -tzf -
shasum -a 256 "$release_gem"
```

Check identity, Ruby requirement, runtime dependencies and package integrity.
Confirm the requirement accepts 3.3, 3.4 and 4.0 and rejects Ruby below 3.3
without installing an EOL runtime. Include the license, SDK entry points, README
and CHANGELOG. Existing spec sources (including shared setup) are packaged as
examples, but fixtures, environment files, credentials, temporary diagnostics
and agent configuration must be absent. Run integration examples from a checkout
with its fixtures; the installed gem is not a runnable test checkout.

4. Install that same gem in fresh consumer gem homes on Ruby 3.3 and 4.0,
   outside the development bundle and checkout load path. Use each runtime's own
   executables; these checks make no API calls:

```sh
ruby -v
consumer_gems=$(mktemp -d)
GEM_HOME="$consumer_gems" GEM_PATH="$consumer_gems" gem install "$release_gem" --no-document
GEM_HOME="$consumer_gems" GEM_PATH="$consumer_gems" ruby -e 'require "ringcentral"; require "subscription"; puts Gem.loaded_specs.fetch("ringcentral-sdk").full_name'
```

Record actual Ruby and dependency versions, manifest, source commit, checksum,
consumer results and full-suite evidence. These consumer checks complement the
live matrix. Present the artifact and release notes for maintainer review. Mark
previous artifacts and evidence as superseded while retaining them for history.

## Publish after explicit authorization

Release tags, RubyGems publication, GitHub Releases and secret/settings changes
require separate authorization. A release tag runs live tests and can publish
automatically. Source integration and validation may be authorized separately;
preparing an artifact alone does not authorize either action.

Immediately before release, recheck RubyGems for `ringcentral-sdk` 2.0.0. If it
already exists, stop and report the blocker; do not overwrite it or choose a new
version without agreement. Use existing authentication and protected environment
rules, keeping credentials out of source, logs and issues.

### Primary route: release tag

After validation, explicit authorization and integration of the intended final
commit, verify the remote source commit and gemspec version. Tag that exact
commit with `v2.0.0`, then push that tag:

```sh
git tag v2.0.0 <reviewed-final-commit>
git push origin v2.0.0
```

The tag-triggered Release workflow runs the full live suite sequentially on
Ruby 3.3, 3.4 and 4.0. Its single publication job waits for every matrix entry to
pass, derives version `2.0.0` from the tag, and builds/publishes once. CI builds
from the reviewed tagged source; separately built archives may have different
bytes from the locally inspected gem. Verify the workflow's exact tag/commit and
published metadata after release. A failed matrix must block publication.

### Alternative: publish the reviewed artifact manually

Only when explicitly choosing manual publication instead of the tag route,
use the exact reviewed artifact and checksum after full-suite validation:

```sh
gem push "$release_gem" --host https://rubygems.org
```

Do not use both routes for one version: after a manual publication, do not push
a release tag that would publish it again. Verify the public registry version,
Ruby requirement and dependency constraints after either route:

```sh
curl -fsSL https://rubygems.org/api/v2/rubygems/ringcentral-sdk/versions/2.0.0.json
```

If release or verification fails, inspect the actual workflow and registry state
before retrying. Publication remains a separate step from preparation.
