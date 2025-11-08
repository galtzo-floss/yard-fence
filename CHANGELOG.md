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

- Support multi-line braces

### Changed

### Deprecated

### Removed

### Fixed

### Security

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

[Unreleased]: https://github.com/galtzo-floss/yard-fence/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.3.0...v0.4.0
[0.4.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.4.0
[0.3.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.2.0...v0.3.0
[0.3.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.3.0
[0.2.0]: https://github.com/galtzo-floss/yard-fence/compare/v0.1.0...v0.2.0
[0.2.0t]: https://github.com/galtzo-floss/yard-fence/releases/tag/v0.2.0
