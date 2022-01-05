# GitLab Advisory Database

This repository contains the security advisories used by the 
[GitLab dependency scanners](https://docs.gitlab.com/ee/user/application_security/dependency_scanning/index.html).
It can be used for both searching advisories and submitting new ones.
The GitLab team constantly improves this vulnerability database
by checking external sources on a regular basis, and contributing their findings to this repo.
Learn more on the [external sources](SOURCES.md) and how the GitLab team tracks them.

More information about the advisories contained in this repository is available
on our [Advisory Landing Page](https://advisories.gitlab.com).

## Licensing

This vulnerability database is available freely under the 
[GitLab Security Alert Database Terms](./LICENSE.md), 
please review them before any usage.

## Contributing

If you know about a vulnerability that isn't listed in this repo,
you can contribute to the GitLab Advisory Database database by opening an issue,
or even submit the vulnerability as a YAML file in a merge request.
Please review the [contribution guidelines](CONTRIBUTING.md).

In case you do not want to create the advisory yourself, you can also create an
issue and mention the missing advisory. In this case, we would be grateful if
you could add a publicly available resource/links to mailing lists and/or issue
description for verification purposes. We would be very grateful, if you could
create an issue using the `New Advisory` template. 

## Credits 

We would like to thank the following authors very much for their valuable
contributions.

| Author         | MRs/Issues            |
| -------------- | --------------------- |
| @blischalkcof  | #168                  |
| @thklein       | #167                  |
| @AB-xdev       | #166                  |
| @brondsem      | !1500, !1501          |
| @mrtux         | !1611, !1613, !11467  |
| @rusher1       | !2246                 | 
| @vavkamil      | !4650                 |
| @robw-nom      | !4808                 |
| @masahiro331   | !6889                 |
| @mattchrist    | #173                  |
| @curvedriver   | #174                  |
| @AFDesk        | #175                  |
| @patrickmorton | #179                  |
| @westonsteimel | !11629                |

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

* `identifiers` (array of strings) is an array that includes public identifiers
  for the advisory.  If a vulnerability (and the corresponding advisory) cannot
  be linked to a CVE, you can use our internal id `GMS-<year>-<nr>` where
  `<year>` is the year in which the vulnerability was disclosed and `<nr>` is a
  sequence number. In order to generate a new, unique valid id, you can use our
  helper script `identifier/identifer.rb` which can be invoked with
  `identifier/identifer.rb -n . <year>` where `<year>` is the year in which the
  vulnerability has been disclosed, e.g. `2017`.
* `identifier` (string, **DEPERECATED**) should be the CVE id when it exists. If a
  vulnerability (and the corresponding advisory) cannot be linked to a CVE, you
  can use our internal id `GMS-<year>-<nr>` where `<year>` is the year in which
  the vulnerability was disclosed and `<nr>` is a sequence number. In order to
  generate a new, unique valid id, you can use our helper script
  `identifier/identifer.rb` which can be invoked with `identifier/identifer.rb
  -n . <year>` where `<year>` is the year in which the vulnerability has been
  disclosed, e.g. `2017`.
* `package_slug` (string): Package type and package name separated by a slash.
* `title` (string): A short description of the security flaw.
* `description` (string): A long description of the security flaw and the
  possible risks.  The [CommonMark](https://spec.commonmark.org/0.28/) flavor
  of Markdown can be used.
* `pubdate` (string): The date on which the advisory was made public, in
  ISO-8601 format; `pubdate` refers to the publication date provided by the
  data-source from which the advisory originates (e.g., NVD).
* `date` (string): The last date on which the advisory was modified, in
  ISO-8601 format; `date` refers to the modification date provided by the
  data-source from which the advisory originates (e.g., NVD).
* `affected_range` (string): The range of affected versions. Machine-readable
  syntax used by the package manager.
* `affected_versions` (string): The range of affected versions. Human-readable
  version for display.
* `fixed_versions` (array of strings): The versions fixing the vulnerability.
  The order is not relevant.
* `not_impacted` (string, optional): Environments not affected by the
  vulnerability.
* `solution` (string, optional): How to remediate the vulnerability.
* `credit` (string, optional): The names of the people who reported the
  vulnerability or helped fixing it.
* `urls` (array of strings): URLs of: detailed advisory, documented exploit,
  vulnerable source code, etc.  The order is not relevant.
* `links` (array of objects, optional): Meta-information regarding the advisory
  pointing to resources that are helpful to better understand the context.  The
  key has to be alphanumeric. Every object has two properties: a required
  `name` (string) and an optional `type` (`poc`, `blog`).
* `cwe_ids` (array of strings): List of CWEs that are related to the advisory.
* `cvss_v2` (string, optional): The CVSS attack vector (version 2.x) for a
  given vulnerability (see https://www.first.org/cvss/v2/ for more details).
* `cvss_v3` (string, optional): The CVSS attack vector (version 3.x) for a
  given vulnerability (see https://www.first.org/cvss/v3-1/ for more details).
* `versions` (array, optional): Version meta information. This array contains
  meta-information about the versions that are mentioned in the
  `affected_range` and `fixed_version` fields. A meta-information object
  includes the following properties:
  - `number`: The version number.
  - `commit`: Meta information related to a Git commit with the following
    properties:
    - `tags`: The git commit tags that are assiciated with this particular
      version.
    - `sha`: The git commit SHA.
    - `timestamp`: The git commit timestamp. This is also the property by which
      all the meta-information objects, which are contained in the `versions`
      array, are sorted in ascending order.

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

``` yaml
---
identifier: "CVE-2021-28965"
identifiers: 
- "CVE-2021-28965"
package_slug: "gem/rexml"
title: "Improper Restriction of XML External Entity Reference"
description: "The REXML gem does not properly address XML round-trip issues. An incorrect
  document can be produced after parsing and serializing."
date: "2021-06-02"
pubdate: "2021-04-21"
affected_range: "<3.2.5"
fixed_versions:
- "3.2.5"
affected_versions: "All versions before 3.2.5"
not_impacted: "All versions starting from 3.2.5"
solution: "Upgrade to version 3.2.5 or above."
urls:
- "https://nvd.nist.gov/vuln/detail/CVE-2021-28965"
- "https://www.ruby-lang.org/en/news/2021/04/05/xml-round-trip-vulnerability-in-rexml-cve-2021-28965/"
links:
  - url: "https://hackerone.com/reports/1104077"
    type: "poc"
  - url: "https://nvd.nist.gov/vuln/detail/CVE-2021-28965"
  - url: "https://www.ruby-lang.org/en/news/2021/04/05/xml-round-trip-vulnerability-in-rexml-cve-2021-28965/"
cwe_ids:
- "CWE-611"
cvss_v2: "AV:N/AC:L/Au:N/C:N/I:P/A:N"
cvss_v3: "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:N"
uuid: "d3422009-4cd3-49e6-bc8a-b0581fed6612"
```

### Advisory Headers

For some advisories you may find the comments below listed in the advisory headers:

* `# community-sync`: synchronizes the advisories automatically with [our community database](https://gitlab.com/gitlab-org/advisories-community) independent of its creation date of the advisory.

### Versioning and Changelog

We apply the following [semantic versioning](https://semver.org/spec/v2.0.0.html) scheme to the GitLab Advisory DB:

1. **patch version increment**: for updated/patched/added advisories.
2. **minor version increment**: backwards-compatible YAML schema changes (e.g., adding/removing optional fields).
3. **major version increment**: non-backwards-compatible YAML schema changes (e.g., adding/removing required fields)

All notable changes concerning minor and major updates are tracked in [the changelog](CHANGELOG.md) which 
is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

### 3rd party integrations

Our [GitLab Security Alert Database Terms](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/blob/master/LICENSE.md#5-general-prohibitions-and-gitlabs-enforcement-rights)
prohibit the use of data contained in the GitLab Advisory Database (or more
specifically the [gemnasium-db](https://gitlab.com/gitlab-org/security-products/gemnasium-db))
by 3rd party tools. 3rd party integrators can use the
MIT-licensed, time-delayed gemnasium-db clone https://gitlab.com/gitlab-org/advisories-community instead.
