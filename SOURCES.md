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
- [ruby-advisory-db](https://github.com/rubysec/ruby-advisory-db)

While the advisory tracking for NVD and ruby-advisory-db is semi-automated, 
we check the oss-security mailing list manually. 

For the manual source tracking, we use the following strategy:
- Look for vulnerability announcement that do not have a CVE with an announcement day not older than 4 weeks
- Generate an identifier (as explained in our [contribution guidelines](CONTRIBUTING.md))
- Create an MR (according to our [contribution guidelines](CONTRIBUTING.md))

It's preferred to create merge requests right away but the team member
in charge of checking the source may not be immediately available to do that,
and creating issues is a way to delay the task or to pass it on to another team member.

Once ready the merge requests are passed on to a reviewer
who will either discuss/challenge the findings
or publish the advisory if it is correct and complies with the [contribution guidelines](CONTRIBUTING.md).

