<!-- Follow the contributing guide https://gitlab.com/gitlab-org/security-products/gemnasium-db/blob/master/CONTRIBUTING.md#submit-a-vulnerability -->
<!-- Title must feature both the advisory identifier and the package name, like this: Add CVE-2019-XYZ to Package-xyz -->
<!-- Please provide a link to a security advisory, to the affected code (mentioning the security flaw) or the fixed code.  -->

To be checked:

* [ ] `identifier` should be the CVE id when it exists.
* [ ] `title` is a short description. It does not contain the package name.
* [ ] `description` must not contain an overview of the package, fixed versions, affected versions, solution or links.
      It leverages the Markdown syntax.
* [ ] `date` is the date on which the advisory was made public.
* [ ] `not_impacted` lists old versions that are not impacted, if any, the fixed versions.
* [ ] `solution` tells how to remediate the vulnerability.
* [ ] `urls` must contain URLs specific to the vulnerability, not URLs generic to the package itself.

/label ~"group::composition analysis" ~"devops::secure" ~"vulnerability database" ~feature
