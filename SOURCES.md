# Tracking external sources

One of the main challenges of maintaining a vulnerability database
is to learn about security advisories recently published.
To that goal, the GitLab team checks external sources on a regular basis.
If an external source lists an advisory that is not already in gemnasium-db,
they research and check the advisory, add metadata to it, and publish it to this repo
following the [contribution guidelines](CONTRIBUTING.md).

## Tracking process and schedule

- [NVD JSON feeds](https://nvd.nist.gov/vuln/data-feeds) (daily)
- [FriendsOfPHP security advisories](https://github.com/FriendsOfPHP/security-advisories)
- [Victims CVE DB](https://github.com/victims/victims-cve-db)
- [oss-security mailing list](http://www.openwall.com/lists/oss-security/)

While the source tracking of NVD, FriendsOfPHP and Victims CVE DB is semi-automated, 
we check the oss-security mailing list manually. 

For the manual source tracking, we use the following strategy:
- Look for vulnerability announcement that do not have a CVE with an announcement day not older than 4 weeks
- Generate an identifier (as explaine in our [contribution guidelines](CONTRIBUTING.md))
- Create an MR (according to our [contribution guidelines](CONTRIBUTING.md))

It's preferred to create merge requests right away but the team member
in charge of checking the source may not be immediately available to do that,
and creating issues is a way to delay the task or to pass it on to another team member.

Once ready the merge requests are passed on to a reviewer
who will either discuss/challenge the findings
or publish the advisory if it is correct and complies with the [contribution guidelines](CONTRIBUTING.md).

## Sources

### Generic Sources

These are generic sources covering all sorts of Open Source projects, including libraries.
They provide vendor and project names but no package information,
so one has to figure out the package type and name in order to submit an advisory to the Gemansium DB.

| Source | Feed |
| -------|------|
| [oss-security mailing list](http://www.openwall.com/lists/oss-security/) | - |
| [NVD](https://nvd.nist.gov/) | RSS([all](https://nvd.nist.gov/feeds/xml/cve/misc/nvd-rss.xml), [analyzed](https://nvd.nist.gov/feeds/xml/cve/misc/nvd-rss-analyzed.xml)), JSON |
| [CVE Details](http://www.cvedetails.com/) | [RSS](https://www.cvedetails.com/vulnerability-feed.php)  |

Vendor and product IDs used by [NVD](https://nvd.nist.gov/) are defined in the
[Official Common Platform Enumeration (CPE) Dictionary](https://nvd.nist.gov/products/cpe).

The RSS feed of [CVE Details](http://www.cvedetails.com/) can be filtered by project or vendor id:

- [vendor: Python](http://www.cvedetails.com/vulnerability-feed.php?vendor_id=10210&product_id=0&version_id=0&orderby=3&cvssscoremin=0)
- [product: Django](http://www.cvedetails.com/vulnerability-feed.php?vendor_id=10210&product_id=0&version_id=0&orderby=3&cvssscoremin=0)

### Package-specific sources

These are sources covering one or multiple package types.
The package type and name can be directly retrieved from their security advisories.

| Source | Package type | Packages registries | Feed |
| -------|--------------|---------------------|------|
| [rubysec](https://github.com/rubysec/ruby-advisory-db) | Ruby | [rubygems.org](https://rubygems.org) | GitHub commits |
| [PHP Security Advisories DB](https://github.com/FriendsOfPHP/security-advisories) | PHP Composer | [packagist.org](https://packagist.org), others | GitHub commits |
| [Victims CVE database](https://github.com/victims/victims-cve-db) | Maven, Pypi | [pypi.org](https://pypi.org), [Maven Central](https://repo1.maven.org/maven2/), others? | GitHub commits |

### Vendor-specific sources

These popular Open Source projects have a web page and/or RSS feed with all their security advisories.

| Project | Feed |
|---------|------|
| [SilverStripe](https://www.silverstripe.org) | [Security releases](https://www.silverstripe.org/download/security-releases/rss) |
| [Django](https://www.djangoproject.com/) | [All posts](https://www.djangoproject.com/weblog/) |
