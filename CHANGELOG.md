# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

## [Unreleased]

### Added

### Changed

- [kc] kettle-jem/prepare: updated 11 project files:
  - dependencies (11)

- [kc] kettle-jem/template: updated 8 project files:
  - code and tests (1)
  - configuration (1)
  - dependencies (2)
  - documentation (1)
  - other (3)

### Deprecated

### Removed

### Fixed

### Security

## [0.9.8] - 2026-08-09

- TAG: [v0.9.8][0.9.8t]
- COVERAGE: 95.41% -- 208/218 lines in 6 files
- BRANCH COVERAGE: 84.62% -- 66/78 branches in 6 files
- 42.55% documented

### Changed

- kettle-jem-template-20260801-001 - Generated README gem dashboard links now
  use ClickGems instead of BestGems.

### Fixed

- kettle-jem-template-20260801-002 - Generated RSpec helpers now normalize
  managed configuration block bindings structurally, preventing mixed block
  parameter names from producing invalid configuration after a merge.
- kettle-jem-template-20260801-003 - Generated project metadata and
  documentation now normalize configured underscore hostnames to valid
  hyphenated hostnames.
- kettle-jem-template-20260801-004 - Generated organization README logos now
  use GitHub's stable organization avatar endpoint instead of assuming a
  matching Galtzo-hosted asset exists.

- kettle-jem-template-20260802-001 - Devcontainer JSON files now merge as JSONC,
  preserving comments and trailing commas during template updates.

## [0.9.7] - 2026-07-31

- TAG: [v0.9.7][0.9.7t]
- COVERAGE: 92.66% -- 202/218 lines in 6 files
- BRANCH COVERAGE: 79.49% -- 62/78 branches in 6 files
- 42.55% documented

### Added

- Documentation linting now has its generated `yard-lint` dependency and severity config available in the local bundle.

- kettle-jem-template-20260726-001 - Projects now include YARD lint
  configuration and documentation dependencies so documentation issues fail
  before generated docs are refreshed.

- kettle-jem-template-20260727-001 - Spec harness documentation now lists the
  RSpec helpers provided by `kettle-test`.

### Changed

- kettle-jem-template-20260716-002 - Generated gemspec manifests now ship fewer
  repository-only files by default to reduce downstream distro packaging churn.
- kettle-jem-template-20260720-002 - Generated development Gemfiles now use the
  released `tree_sitter_language_pack` gem 1.13.3 or newer by default.
- kettle-jem-template-20260720-003 - Generated StructuredMerge Git diff driver
  config now uses the installed `smorg-rb` Ruby driver name.
- kettle-jem-template-20260720-005 - Generated README Support & Community rows
  now include a RubyForum help badge.
- kettle-jem-template-20260725-001 - Generated JRuby and TruffleRuby workflow
  files now run when pull request head branches start with `feature/release`,
  so release CI monitoring does not report intentionally skipped engine
  workflows as failures.

- kettle-jem-template-20260725-002 - Generated gemspec templates now include
  `anonymous_loader` as a development dependency, and version specs use it to
  execute generated `version.rb` files for coverage without redefining package
  constants. Managed version specs are removed when `version_gem` is disabled
  or incompatible with the project's runtime Ruby floor.

- kettle-jem-template-20260728-001 - Generated Ruby workflows now use clearer
  setup-ruby-flash planning and can prepare appraisal-only jobs without
  installing the main Gemfile bundle.

### Fixed

- Added coverage for YARD plugin loader and rake task integration paths so the
  suite meets release coverage thresholds.

- kettle-jem-template-20260726-002 - Generated version files now document their
  version namespace and constants, reducing warning-only YARD lint output.

- kettle-jem-template-20260726-003 - Coverage upload steps now treat Coveralls,
  QLTY, and Codecov as optional, so provider outages do not fail CI when local
  coverage thresholds still pass.
- kettle-jem-template-20260728-002 - Generated RuboCop configs now ignore the
  same `gemfiles/vendor/bundle` tree as `.gitignore`, so vendored dependency
  installs are not reported as project lint debt.
- kettle-jem-template-20260728-003 - Generated dep-heads workflows now run
  TruffleRuby jobs with current RubyGems and Bundler, avoiding setup failures
  before the test suite starts.

- kettle-jem-template-20260728-004 - Generated dep-heads workflows now use the
  setup-ruby Bundler install path for direct appraisal Gemfiles, avoiding rv
  lockfile parser failures on Git and path dependencies.

- kettle-jem-template-20260728-005 - VersionGem bootstrap now creates the
  missing canonical version spec when a project only has shim namespace version
  specs.

- kettle-jem-template-20260730-001 - Gemspec package file enumeration now runs
  relative to the gemspec directory, so packaged template assets are included
  even when the gemspec is loaded from another working directory.

## [0.9.6] - 2026-07-02

- TAG: [v0.9.6][0.9.6t]
- COVERAGE: 90.83% -- 198/218 lines in 6 files
- BRANCH COVERAGE: 71.79% -- 56/78 branches in 6 files
- 38.30% documented

### Fixed

- Package configured license files in gem release file lists.

## [0.9.5] - 2026-06-22

- TAG: [v0.9.5][0.9.5t]
- COVERAGE: 90.83% -- 198/218 lines in 6 files
- BRANCH COVERAGE: 71.79% -- 56/78 branches in 6 files
- 38.30% documented

### Added

- Added support for JRuby 10.1 and TruffleRuby 34.0.

### Changed

- Retemplated project metadata and CI/development automation with `kettle-jem` v7.0.0.

### Fixed

- Corrected RubyGems homepage metadata to point at the gem documentation site.

- Avoided a circular require warning when YARD's plugin loader requires
  `yard-fence` while `yard/fence` is already loading.

## [0.9.4] - 2026-06-14

- TAG: [v0.9.4][0.9.4t]
- COVERAGE: 95.65% -- 198/207 lines in 5 files
- BRANCH COVERAGE: 83.33% -- 55/66 branches in 5 files
- 38.30% documented

### Changed

- Retemplated project metadata, workflow pins, and dependency floors with the
  latest `kettle-jem` template, including resilient templating bootstrap updates.

### Fixed

- Restored `docs/CNAME` so the generated documentation site keeps its custom domain.

## [0.9.3] - 2026-06-09

- TAG: [v0.9.3][0.9.3t]
- COVERAGE: 95.65% -- 198/207 lines in 5 files
- BRANCH COVERAGE: 83.33% -- 55/66 branches in 5 files
- 38.30% documented

### Fixed

- Narrowed `YARD_FENCE_CLEAN_DOCS=true` cleanup to generated YARD HTML/CSS/JS artifacts so checked-in site metadata such as `docs/CNAME` is preserved.

## [0.9.2] - 2026-06-03

- TAG: [v0.9.2][0.9.2t]
- COVERAGE: 95.57% -- 194/203 lines in 5 files
- BRANCH COVERAGE: 82.81% -- 53/64 branches in 5 files
- 39.13% documented

### Fixed

- Prevented YARD from treating pipe-delimited token examples such as `{KJ|GEM_NAME}` and rendered example-table fragments as unresolved documentation links.

## [0.9.1] - 2026-05-24

- TAG: [v0.9.1][0.9.1t]
- COVERAGE: 97.71% -- 171/175 lines in 5 files
- BRANCH COVERAGE: 90.74% -- 49/54 branches in 5 files
- 47.37% documented

### Changed

- Expanded the `rdoc` runtime dependency to allow `rdoc` 7.x while retaining
  support for `rdoc` 6.11.x.

### Fixed

- Fixed CI workflow setup for appraisal-based style and coverage jobs, locked-deps, and TruffleRuby 23.1.

## [0.9.0] - 2026-05-23

- TAG: [v0.9.0][0.9.0t]
- COVERAGE: 97.71% -- 171/175 lines in 5 files
- BRANCH COVERAGE: 90.74% -- 49/54 branches in 5 files
- 47.37% documented

### Added

- `Yard::Fence.install_rake_tasks!` for explicit integration with a chosen documentation rake task
- Rake task integration now wires `yard:fence:prepare` before the selected YARD task and runs HTML post-processing after that task completes

### Changed

- Documentation processing is now Rake-driven. Projects should call `Yard::Fence.install_rake_tasks!` after defining their `:yard` task so prepare and post-processing hooks run only for documentation builds.
- Project maintenance files, workflows, modular Gemfiles, and local development wiring were refreshed with the current kettle-jem template.

### Removed

- Removed global `at_exit` post-processing. Raw `yard` / `bin/yard` no longer runs `yard-fence` post-processing unless the caller invokes the Rake-integrated documentation task.

### Fixed

- Loading YARD during unrelated rake tasks no longer clears or rewrites `docs/`.

## [0.8.2] - 2025-12-30

- TAG: [v0.8.2][0.8.2t]
- COVERAGE: 100.00% -- 130/130 lines in 4 files
- BRANCH COVERAGE: 100.00% -- 40/40 branches in 4 files
- 50.00% documented

### Added

- `Yard::Fence::RakeTask` - New rake task class that provides `yard:fence:prepare` and `yard:fence:clean` tasks
  - Automatically enhances the `:yard` task when defined
  - Auto-registers when Rake is available at gem load time
- `Yard::Fence.prepare_for_yard` - New method to prepare for YARD documentation generation
  - Combines `clean_docs_directory` and `prepare_tmp_files` into a single call
  - Intended to be called from rake tasks, not at load time

### Deprecated

- `Yard::Fence.at_load_hook` - Now does nothing; use `prepare_for_yard` via rake task instead

### Removed

- **BREAKING**: Removed load-time execution of `clean_docs_directory` and `prepare_tmp_files`
  - Previously, these ran when yard-fence was loaded, causing `docs/` to be cleared during unrelated rake tasks like `build` and `release`
  - Now all preparation happens via the `yard:fence:prepare` rake task, which runs as a prerequisite to the `:yard` task

### Fixed

- Fixed `docs/` directory being cleared during `rake build` and `rake release` commands
  - The root cause was `at_load_hook` running at gem load time instead of only when generating documentation
  - Now docs cleanup and tmp file preparation only occur when the `yard` task actually runs

## [0.8.1] - 2025-12-29

- TAG: [v0.8.1][0.8.1t]
- COVERAGE: 100.00% -- 129/129 lines in 4 files
- BRANCH COVERAGE: 100.00% -- 40/40 branches in 4 files
- 40.00% documented

### Added

- `YARD_FENCE_CLEAN_DOCS` environment variable to optionally clear the `docs/` directory before regeneration
  - Set to `true` to enable; prevents stale HTML files from persisting when markdown source files are deleted

### Changed

- `prepare_tmp_files` now clears the `tmp/yard-fence/` staging directory before regenerating files
  - This prevents stale preprocessed files from persisting when source markdown files are deleted
  - Previously, files added manually or by other processes to `tmp/yard-fence/` would remain and get included in documentation

## [0.8.0] - 2025-11-08

- TAG: [v0.8.0][0.8.0t]
- COVERAGE: 100.00% -- 121/121 lines in 4 files
- BRANCH COVERAGE: 100.00% -- 36/36 branches in 4 files
- 37.93% documented

### Added

- Allow disabling of yard-fence via YARD_FENCE_DISABLE=true (default false)

### Fixed

- Usage instructions in README.md
  - Include `--markup-provider kramdown`

## [0.7.0] - 2025-11-08

- TAG: [v0.7.0][0.7.0t]
- COVERAGE: 99.19% -- 123/124 lines in 4 files
- BRANCH COVERAGE: 90.00% -- 36/40 branches in 4 files
- 37.93% documented

### Changed

- Actually use custom KramdownGFM

## [0.6.0] - 2025-11-07

- TAG: [v0.6.0][0.6.0t]
- COVERAGE: 100.00% -- 119/119 lines in 4 files
- BRANCH COVERAGE: 100.00% -- 34/34 branches in 4 files
- 37.93% documented

### Added

- Catch unrendered code blocks and attempt to convert to HTML

## [0.5.0] - 2025-11-07

- TAG: [v0.5.0][0.5.0t]
- COVERAGE: 100.00% -- 98/98 lines in 4 files
- BRANCH COVERAGE: 100.00% -- 22/22 branches in 4 files
- 34.62% documented

### Added

- Support multi-line braces
- 100% lines / 100% branches test coverage

## [0.4.0] - 2025-11-07

- TAG: [v0.4.0][0.4.0t]
- COVERAGE: 96.43% -- 81/84 lines in 4 files
- BRANCH COVERAGE: 93.75% -- 15/16 branches in 4 files
- 29.17% documented

### Added

- Docs: Document importance of `require: false` in `Gemfile` for this gem

### Changed

- Docs: Improved markdown syntax in README.md for Kramdown => HTML

### Fixed

- Use namespaced directory in `tmp/` (`tmp/yard-fence`)
  - avoids polluting, and pollution from, other garbage in `tmp/`

## [0.3.0] - 2025-11-07

- TAG: [v0.3.0][0.3.0t]
- COVERAGE: 96.43% -- 81/84 lines in 4 files
- BRANCH COVERAGE: 93.75% -- 15/16 branches in 4 files
- 29.17% documented

### Added

- yard/fence/hoist.rb: Hoisting the customized GFM kramdown parser

## [0.2.0] - 2025-11-07

- TAG: [v0.2.0][0.2.0t]
- COVERAGE: 96.43% -- 81/84 lines in 4 files
- BRANCH COVERAGE: 93.75% -- 15/16 branches in 4 files
- 29.17% documented

### Added

- Up to 96% lines / 93% branches test coverage

### Fixed

- handling of optional dependencies
    - kramdown
    - kramdown-parser-gfm

## [0.1.0] - 2025-11-06

- Initial release

[Unreleased]: https://github.com/galtzo-floss/yard-fence/compare/v0.9.8...HEAD
[0.9.8]: https://github.com/galtzo-floss/yard-fence/compare/v0.9.7...v0.9.8
[0.9.8t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.9.8
[0.9.7]: https://github.com/galtzo-floss/yard-fence/compare/v0.9.6...v0.9.7
[0.9.7t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.9.7
[0.9.6]: https://github.com/galtzo-floss/yard-fence/compare/v0.9.5...v0.9.6
[0.9.6t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.9.6
[0.9.5]: https://github.com/galtzo-floss/yard-fence/compare/v0.9.4...v0.9.5
[0.9.5t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.9.5
[0.9.4]: https://github.com/galtzo-floss/yard-fence/compare/v0.9.3...v0.9.4
[0.9.4t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.9.4
[0.9.3]: https://github.com/galtzo-floss/yard-fence/compare/v0.9.2...v0.9.3
[0.9.3t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.9.3
[0.9.2]: https://github.com/galtzo-floss/yard-fence/compare/v0.9.1...v0.9.2
[0.9.2t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.9.2
[0.9.1]: https://github.com/galtzo-floss/yard-fence/compare/v0.9.0...v0.9.1
[0.9.1t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.9.1
[0.9.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.8.2...v0.9.0
[0.9.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.9.0
[0.8.2]: https://github.com/galtzo-floss/yard-fence/compare/v0.8.1...v0.8.2
[0.8.2t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.8.2
[0.8.1]: https://github.com/galtzo-floss/yard-fence/compare/v0.8.0...v0.8.1
[0.8.1t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.8.1
[0.8.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.7.0...v0.8.0
[0.8.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.8.0
[0.7.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.6.0...v0.7.0
[0.7.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.7.0
[0.6.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.5.0...v0.6.0
[0.6.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.6.0
[0.5.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.4.0...v0.5.0
[0.5.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.5.0
[0.4.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.3.0...v0.4.0
[0.4.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.4.0
[0.3.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.2.0...v0.3.0
[0.3.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.3.0
[0.2.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.1.0...v0.2.0
[0.2.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.2.0
