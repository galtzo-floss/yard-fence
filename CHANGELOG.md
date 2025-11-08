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

- Allow disabling of yard-fence via YARD_FENCE_DISABLED=true (default false)

### Changed

### Deprecated

### Removed

### Fixed

- Usage instructions in README.md
  - Include `--markup-provider kramdown`

### Security

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

[Unreleased]: https://github.com/galtzo-floss/yard-fence/compare/v0.7.0...HEAD
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
