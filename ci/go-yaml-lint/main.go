package main

import (
	"fmt"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"os"
	"path/filepath"
)

// we need a separate linting step for go due to
// https://gitlab.com/gitlab-org/gitlab/-/issues/323505
func main() {

	if len(os.Args) != 2 {
		fmt.Printf("usage: %s <dir>", os.Args[0])
		os.Exit(1)
	}

	dir := os.Args[1]

	err := filepath.Walk(dir,
		func(path string, file os.FileInfo, err error) error {
			if err != nil {
				return err
			}

			if file.IsDir() {
				return nil
			}

			typ := filepath.Ext(path)

			if typ == ".yaml" || typ == ".yml" {
				input, err := ioutil.ReadFile(path)
				if err != nil {
					return fmt.Errorf("%s: %s", path, err)
				}

				m := Advisory{}
				err = yaml.Unmarshal([]byte(input), &m)
				if err != nil {
					return fmt.Errorf("%s: %v", path, err)
				}
			}
			return nil
		})

	if err != nil {
		fmt.Printf("%s", err.Error())
		os.Exit(1)
	}
	os.Exit(0)
}
