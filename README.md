# GitLab Advisory Database

This repository contains the security advisories used by the 
[GitLab dependency scanners](https://docs.gitlab.com/ee/user/application_security/dependency_scanning/index.html).
It can be used for both searching advisories and submitting new ones.
The GitLab team constantly improves this vulnerability database
by checking external sources on a regular basis, and contributing their findings to this repo.
Learn more on the [external sources](SOURCES.md) and how the GitLab team tracks them.

The advisory data contained in this repository is used as the basis for our 
[Advisory Landing Page](https://advisories.gitlab.com).

Statistical data about the advisories contained in this repository is available
on our [GitLab Advisory Stats Page](https://gitlab-org.gitlab.io/security-products/gemnasium-db/). 

## Licensing

This vulnerability database is available freely under the 
[GitLab Security Alert Database Terms](./LICENSE.md), 
please review them before any usage.

## Contributing

If you know about a vulnerability that isn't listed in this repo,
you can contribute to the GitLab Advisory Database database by opening an issue,
or even submit the vulnerability as a YAML file in a merge request.
Please review the [contribution guidelines](CONTRIBUTING.md).

## Credits 

We would like to thank the following authors very much for their valuable
contributions.

| Author    | MRs            |
| --------- | -------------- |
| @brondsem | !1500, !1501   |
| @mrtux    | !1611, !1613   |
| @rusher1  | !2246          | 
| @vavkamil | !4650          |
| @robw-nom | !4808          |

## Directory structure

Each YAML file of the repo corresponds to a single security advisory.
The file path is made of the slug of the affected package (type and name),
and the identifier of the advisory, following the pattern:

```
package_slug/advisory_identifier.yml
```

For instance, security advisory [CVE-2019-11324](https://nvd.nist.gov/vuln/detail/CVE-2019-11324)
related to Python package [urllib3](https://pypi.org/project/urllib3/) is:

```
pypi/urllib3/CVE-2019-11324.yaml
```

## Package slug and package name

The package [slug](https://en.wikipedia.org/wiki/Clean_URL#Slug) is made of the
package type and the fully qualified package name separated by a slash `/`. The
package name refers to the exact name of the package as it would appear in the
dependency configuration/lockfile.

The supported package types are:

```
gem
go
maven
npm
packagist
pypi
nuget
conan
```

These correspond to:

- gems from [rubygems.org](http://rubygems.org)
- go from source code hosting services such as `gitlab.com` or `github.com`
- Java Maven packages from [Maven Central](https://repo1.maven.org/maven2/)
- npm packages from [npmjs.com](https://www.npmjs.com/)
- PHP Composer packages from [packagist.org](https://packagist.org/)
- Python packages from [pypi.org](https://pypi.org/)
- Nuget packages from [nuget.org](https://www.nuget.org/)
- Conan packages from [conan.io](https://conan.io/center/)

For npm packages, the package name may include a [npm scope](https://docs.npmjs.com/misc/scope).
For instance, the package slug of [@babel/cli](https://www.npmjs.com/package/@babel/cli) is:

```
npm/@babel/cli
```

For Maven packages, the package name is made of the `groupId` and the `artifactId` separted by a slash `/`.
For instance, the package slug of [jackson-databind](https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/) is:

```
maven/com.fasterxml.jackson.core/jackson-databind
```

For Nuget packages, the package name may be separated by `.` characters, for example:

```
nuget/Node.js
```

## YAML schema

* `identifier` should be the CVE id when it exists. If a vulnerability (and the
corresponding advisory) cannot be linked to a CVE, you can use our internal id
`GMS-<year>-<nr>` where `<year>` is the year in which the vulnerability was
disclosed and `<nr>` is a sequence number. In order to generate a new, unique
valid id, you can use our helper script `identifier/identifer.rb` which can be
invoked with `identifier/identifer.rb -n . <year>` where `<year>` is the year
in which the vulnerability has been disclosed, e.g. `2017`.
* `package_slug` (string): Package type and package name separated by a slash.
* `title` (string): A short description of the security flaw.
* `description` (string): A long description of the security flaw and the possible risks.
   The [CommonMark](https://spec.commonmark.org/0.28/) flavor of Markdown can be used.
* `pubdate` (string): The date on which the advisory was made public, in ISO-8601 format; `pubdate` refers to the publication date provided by the data-source from which the advisory originates (e.g., NVD).
* `date` (string): The last date on which the advisory was modified, in ISO-8601 format; `date` refers to the modification date provided by the data-source from which the advisory originates (e.g., NVD).
* `affected_range` (string): The range of affected versions. Machine-readable syntax used by the package manager.
* `affected_versions` (string): The range of affected versions. Human-readable version for display.
* `fixed_versions` (array of strings): The versions fixing the vulnerability. The order is not relevant.
* `not_impacted` (string, optional): Environments not affected by the vulnerability.
* `solution` (string, optional): How to remediate the vulnerability.
* `credit` (string, optional): The names of the people who reported the vulnerability or helped fixing it.
* `urls` (array of strings): URLs of: detailed advisory, documented exploit, vulnerable source code, etc.
   The order is not relevant.
* `cvss_v2` (string, optional): The CVSS attack vector (version 2.x) for a
given vulnerability (see https://www.first.org/cvss/v2/ for more details).
* `cvss_v3` (string, optional): The CVSS attack vector (version 3.x) for a
given vulnerability (see https://www.first.org/cvss/v3-1/ for more details).
* `versions` (array, optional): Version meta information. This array contains
meta-information about the versions that are mentioned in the `affected_range`
and `fixed_version` fields. A meta-information object includes the following
properties:
  - `number`: The version number.
  - `commit`: Meta information related to a Git commit with the following properties:
    - `tags`: The git commit tags that are assiciated with this particular version.
    - `sha`: The git commit SHA.
    - `timestamp`: The git commit timestamp. This is also the property by which all the meta-information objects, which are contained in the `versions` array, are sorted in ascending order.

The syntax to be used in `affected_range` depends on the package type:
- `gem`: [gem requirement](https://guides.rubygems.org/specification-reference/#add_runtime_dependency)
- `maven`: [Maven Dependency Version Requirement Specification](https://maven.apache.org/pom.html#Dependency_Version_Requirement_Specification)
- `npm`: [node-semver](https://github.com/npm/node-semver#ranges)
- `php`: [PHP Composer version constraints](https://getcomposer.org/doc/articles/versions.md#writing-version-constraints)
- `pypi`: [PEP440](https://www.python.org/dev/peps/pep-0440/#version-specifiers)
- `go`: [go semver](https://godoc.org/golang.org/x/tools/internal/semver)
- `nuget`: [NuGet semver](https://docs.microsoft.com/en-us/nuget/concepts/package-versioning)
- `conan`: [node-semver flavour](https://github.com/npm/node-semver#ranges)


The YAML schema also supports temporary fields. All temporary field names start with
an underscore `_` character. Note that temporary fields may disappear in the
future.

Our YAML file schema for advisories is specified in [schema/schema.json](schema/schema.json).

Here's a sample document:

```
---
identifier: "CVE-2020-11001"
package_slug: "pypi/wagtail"
title: "Cross-site Scripting"
description: "A cross-site scripting (XSS) vulnerability exists on the
  page revision comparison view within the Wagtail admin interface. A user with a
  limited-permission editor account for the Wagtail admin could potentially craft
  a page revision history that, when viewed by a user with higher privileges, could
  perform actions with that user's credentials. The vulnerability is not exploitable
  by an ordinary site visitor without access to the Wagtail admin."
date: "2020-04-15"
pubdate: "2020-04-14"
affected_range: ">=1.9,<=2.7.1||==2.8"
fixed_versions:
- "2.7.2"
- "2.8.1"
affected_versions: "All versions starting from 1.9 up to 2.7.1, version 2.8"
not_impacted: "All versions before 1.9, all versions after 2.7.1 before 2.8, all versions
  after 2.8"
solution: "Upgrade to versions 2.7.2, 2.8.1 or above."
urls:
- "https://nvd.nist.gov/vuln/detail/CVE-2020-11001"
cvss_v2: "AV:N/AC:M/Au:S/C:N/I:P/A:N"
cvss_v3: "CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:N/A:N"
uuid: "4f4e9149-afd0-47d6-850f-4c8c70a49143"

```

### Versioning and Changelog

We apply the following [semantic versioning](https://semver.org/spec/v2.0.0.html) scheme to the GitLab Advisory DB:

1. **patch version increment**: for updated/patched/added advisories.
2. **minor version increment**: backwards-compatible YAML schema changes (e.g., adding/removing optional fields).
3. **major version increment**: non-backwards-compatible YAML schema changes (e.g., adding/removing required fields)

All notable changes concerning minor and major updates are tracked in [the changelog](CHANGELOG.md) which 
is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

