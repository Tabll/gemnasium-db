## Terms

This vulnerability database is available freely under the [GitLab Security Alert Database Terms](./LICENSE.md), please review them before contributing.

_This notice should stay as the first item in the CONTRIBUTING.md file._

## Submit a vulnerability

**Search the project** before submitting a new vulnerability.
The vulnerability may already in repo. If not, there may be a Merge Request or an issue for it,
and you may show your support with an award emoji and/or join the discussion.

If there's no match in the project, we encourage you to **submit a Merge Request**
to add a new vulnerability to the database. See how to [contribute a YAML file](#contribute-a-yaml-file).


### Single advisory contributions

The title for a single advisory Merge Request should be like:

> Add CVE-2019-11324 to urllib3

Where "CVE-2019-11324" is the identifier of the advisory and "urllib3" is the package name.

The description of the Merge Request must contain a link to a security advisory,
to the affected source code or to the fix.

Alternatively you may create an issue with the same information (title and description)
but your request is more likely to be addressed quickly if you submit a Merge Request instead,
even if the submitted YAML file doesn't contain all the details.

It's possible that the vulnerability already exists in the repo
but with a **different identifier or package name**.
You may then want to open a Merge Request to challenge the contents and/or the path
of the YAML file describing the vulnerability.

### Batch import

Advisories can be contributed in batches. To simplify the reviewing process
we suggest that a batch size does not exceed 50 advisories and that all of them 
are related to the same package type. We acknowledge, however, 
that this may not always be possible. 

The title for a batch import should start with `Batch import` followed by a short
description about the advisories it contains.

### YAML field constraints

Please checks these before submitting a YAML file to the repo:

All the YAML fields should be double-quoted and all files should start with three dashes `---`.
The text width for all fields should be <=150 characters. 
The indentation level should be 2 characters. These rules are enforced through
yamllint.

* `identifiers` (array of strings) is an array that includes public identifiers
  for the advisory.  If a vulnerability (and the corresponding advisory) cannot
  be linked to a CVE, you can use our internal id `GMS-<year>-<nr>` where
  `<year>` is the year in which the vulnerability was disclosed and `<nr>` is a
  sequence number. In order to generate a new, unique valid id, you can use our
  helper script `identifier/identifer.rb` which can be invoked with
  `identifier/identifer.rb -n . <year>` where `<year>` is the year in which the
  vulnerability has been disclosed, e.g. `2017`.
* `identifier` (string, **DEPRECATED**) should be the CVE id when it exists. If
  a vulnerability (and the corresponding advisory) cannot be linked to a CVE,
  you can use our internal id `GMS-<year>-<nr>` where `<year>` is the year in
  which the vulnerability was disclosed and `<nr>` is a sequence number. In
  order to generate a new, unique valid id, you can use our helper script
  `identifier/identifer.rb` which can be invoked with `identifier/identifer.rb
  -n . <year>` where `<year>` is the year in which the vulnerability has been
  disclosed, e.g. `2017`.
* `package_slug` refers to a public package.
* `title` must not contain the package name. Please use an appropriate CWE
  title if available.
* `pubdate` (string): The date on which the advisory was published, in ISO-8601
  format.
* `date` (string): The last date on which the advisory was modified, in
  ISO-8601 format.
* `not_impacted` must not list the fixed versions.
* `solution` (string, optional): How to remediate the vulnerability.
* `urls` must contain URLs specific to the vulnerability, not URLs generic to
  the package itself.

`description` should not provide an overview of the package itself, only the
description of the vulnerability as it pertains to the package

File paths, source-code snippets, configuration parameters, as well as 
in and output parameters/values that 
appear in the `description` field 
should be enclosed by backticks (markdown formatting) so that
they are visually distinguishable from the rest of the description.

`affected_versions` and `not_impacted` should satisfy the following rules:
- use `Version x` in case x is a distinct version
- use `All versions` in case of a version range
- use `up to` to express inclusive upper bounds
- use `before` to express non-inclusive upper bounds
- use `starting from` to express inclusive lower bounds
- use `after` to express non-inclusive lower bounds
- use `,` to separate the explataion for versions

Since the `description` supports [Markdown](https://daringfireball.net/projects/markdown) syntax,
[backtick quotes](https://daringfireball.net/projects/markdown/syntax#precode)
should be used for variables, constants, functions, class names and file paths.

### Affected package

Contributors should carefully review the package name and make sure this is where the vulnerability has been found.
It happens that a vulnerability is reported in the context of a meta-package
like the Ruby gem [rails](https://rubygems.org/gems/rails) when in fact it comes from one of its dependencies like
[actionpack](https://rubygems.org/gems/actionpack) or [actionview](https://rubygems.org/gems/actionview).
This is a common issue when submitting vulnerabilities for Java Maven packages.
If unsure about the affected Maven package,
you can use [mvnrepository.com](https://mvnrepository.com/) to investigate packages and their dependencies.

### CVSS Vector

If CVSS information information is not available, you can rely on the
[CVSS calculator](https://www.first.org/cvss/calculator/3.1) to compute it.

### Affected & fixed versions

Contributors should carefully review `fixed_versions` and `affected_range`
and make sure they are consistent with the information that's publicly available:
- advisories published on [NVD](https://nvd.nist.gov), [CVE](https://cve.mitre.org/) or others
- affected and fixed commits in the package's source repository

So whenever possible, contributors should make sure affected and fixed commits in the repo
correspond to affected and fixed versions of the package:
- if package versions correspond to git tags, check the tags of the commits fixing the vulnerability
- if the repo features a changelog, look for commits or branches containing the fix,
  and see what version is added to the changelog

If there's no easy way to make the connection between the package versions and the source code,
it may be necessary to download the package at specific versions, open it,
and see whether it contains the fix or the vulnerable code.

**Look for backports** of the fix. Popular projects usually support multiple branches, and security fixes are backported.

**Beware of unsupported branches.**
These unsupported branches may not be explicitly mentioned in the security advisory even though they are affected.
If you can't establish whether some old versions are affected, then you should consider they are;
it's better to report a false positive than ignoring the risk.

### Reviewing and Mergeing advisories

After reviewing an advisory and validating it, it is ready to be merged. 

For validating an advisory, you can use our validation script which can be
found under [schema/validate.rb](schema/validate.rb). The validation script
ensures that your contribution adheres to [our YAML schema
specification](schema/schema.json).

You can execute the script by providing the YAML file to be validated as
command-line argument with:

`schema/validate.rb your-yaml-file.yml`

If the validation script does not report any error, your contribution is valid
according to our YAML schema specification an can be merged.
