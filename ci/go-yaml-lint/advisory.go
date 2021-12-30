package main

import (
	"strings"
)

// see https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium/-/blob/master/advisory/advisory.go

// Advisory is a security advisory published for a package.
type Advisory struct {
	// Identifier is CVE id (preferred) or any public identifier.
	Identifier string `yaml:"identifier,omitempty" json:"identifier,omitempty"`

	// Title is a short description of the security flaw.
	Title string `yaml:"title" json:"title"`

	// Description is a long description of the security flaw and the possible risks.
	Description string `yaml:"description" json:"description"`

	// DisclosureDate is the date on which the advisory was made public, in ISO-8601 format.
	DisclosureDate string `yaml:"date,omitempty" json:"date,omitempty"`

	// AffectedRange is the range of affected versions. Machine-readable syntax used by the package manager.
	AffectedRange string `yaml:"affected_range" json:"affected_range"`

	// CVSSV2 is the Common Vulnerability Scoring System v2 compressed textual
	// representation of the characteristics of a vulnerability.
	CVSSV2 string `yaml:"cvss_v2,omitempty" json:"cvss_v2,omitempty"`

	// CVSSV3 is the Common Vulnerability Scoring System v3.x compressed textual
	// representation of the characteristics of a vulnerability.
	CVSSV3 string `yaml:"cvss_v3,omitempty" json:"cvss_v3,omitempty"`

	// FixedVersions are the versions fixing the vulnerability. The order is not relevant.
	FixedVersions []string `yaml:"fixed_versions,omitempty" json:"fixed_versions,omitempty"`

	// ImpactedVersions is the range of affected versions. Human-readable version for display.
	ImpactedVersions string `yaml:"affected_versions,omitempty" json:"affected_versions,omitempty"`

	// NotImpacted describes the environments not affected by the vulnerability.
	NotImpacted string `yaml:"not_impacted,omitempty" json:"not_impacted,omitempty"`

	// Solution tells how to remediate the vulnerability.
	Solution string `yaml:"solution,omitempty" json:"solution,omitempty"`

	// Credit gives the names of the people who reported the vulnerability or helped fixing it.
	Credit string `yaml:"credit,omitempty" json:"credit,omitempty"`

	// Links are the URLs of: detailed advisory, documented exploit, vulnerable source code, etc.
	Links []string `yaml:"urls" json:"urls"`

	// Package is the affected package.
	Package Package `yaml:"package_slug" json:"package_slug"`

	// UUID is the identifier in Gemnasium DB. It's no longer used.
	UUID string `yaml:"uuid,omitempty" json:"uuid,omitempty"`

	// URL is the web URL of the advisory. This field is calculated when loading the advisory.
	// It is encoded to JSON for internal communication b/w the scanner and the convert package.
	URL string `yaml:"-" json:"url,omitempty"`

	// Version meta-information
	Versions []Version `yaml:"versions,omitempty" json:"versions,omitempty"`
}

// Version contains meta-information for a single version
type Version struct {
	Number string `yaml:"number" json:"number"`
	Commit Commit `yaml:"commit" json:"commit"`
}

// Commit contains meta-information w.r.t. a single git commit
type Commit struct {
	Tags      []string `yaml:"tags" json:"tags"`
	Sha       string   `yaml:"sha" json:"sha"`
	Timestamp string   `yaml:"timestamp" json:"timestamp"`
}

// https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium/-/blob/master/advisory/package.go
type Package struct {
	Type string `json:"type"`
	Name string `json:"name"`
}

// Slug returns the package slug/path.
func (p Package) Slug() string {
	return p.Type + "/" + p.Name
}

// UnmarshalYAML decodes a package slug.
func (p *Package) UnmarshalYAML(unmarshal func(interface{}) error) error {
	var slug string
	if err := unmarshal(&slug); err != nil {
		return err
	}

	parts := strings.SplitN(slug, "/", 2)
	if len(parts) > 1 {
		p.Name = parts[1]
	}
	p.Type = parts[0]

	return nil
}
