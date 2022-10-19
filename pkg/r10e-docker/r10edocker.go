package r10edocker

import (
	"embed"
	"encoding/json"
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"github.com/pkg/errors"
)

type Config struct {
	ProjectName  string          `json:"project_name"`
	BuildCmd     string          `json:"build_cmd"`
	Maintainers  []string        `json:"maintainers"`
	Artifacts    []Artifact      `json:"artifacts"`
	ExternalData []ExternalDatum `json:"extern_data"`
}

type Artifact struct {
	Source      string `json:"src"`
	Destination string `json:"dest"`
}

type ExternalDatum = Artifact

var (
	//go:embed files
	templateFs embed.FS

	DestDir       string
	r10eDockerDir = "r10e-docker"
)

// ReadConfigFile reads from a JSON file in configFilePath, and returns project
// configuration config.
func ReadConfigFile(configFilePath string) (config Config, error error) {
	absPath, err := filepath.Abs(configFilePath)
	config = Config{}
	if err != nil {
		return config, errors.Wrap(err, "could not convert config file path to absolute path")
	}
	b, err := os.ReadFile(absPath)
	if err != nil {
		return config, errors.Wrap(err, "could not read config file")
	}
	err = json.Unmarshal(b, &config)
	if err != nil {
		return config, errors.Wrap(err, "could not unmarshal JSON config")
	}

	// sanity checks
	if config.ProjectName == "" {
		return config, errors.New("project_name must not be empty or null")
	}

	if len(config.ProjectName) != len(strings.TrimSpace(config.ProjectName)) ||
		len(strings.Fields(config.ProjectName)) > 1 {
		return config, errors.New("project_name must not contain whitespace")
	}

	if strings.TrimSpace(config.BuildCmd) == "" {
		return config, errors.New("build_cmd must not be empty or null")
	}

	if len(config.Artifacts) == 0 {
		return config, errors.New("artifacts must not be empty or null")
	}

	for _, a := range config.Artifacts {
		if strings.TrimSpace(a.Source) == "" ||
			strings.TrimSpace(a.Destination) == "" {
			return config, fmt.Errorf(
				"neither src nor dest of artifact shall be empty or null; got %#v", a)
		}
	}

	for _, d := range config.ExternalData {
		if strings.TrimSpace(d.Source) == "" ||
			strings.TrimSpace(d.Destination) == "" {
			return config, fmt.Errorf(
				"neither src nor dest of extern_datum shall be empty or null; got %#v", d)
		}
	}

	return config, nil
}

// GenR10eDocker creates in subdirectory `r10e-docker` the customized build
// scripts for reproducible Docker images, using project configuration config.
func GenR10eDocker(config *Config) error {
	if info, err := os.Stat(r10eDockerDir); err != nil || !info.IsDir() {
		die(os.MkdirAll(r10eDockerDir, 0755))
	}

	err := fs.WalkDir(templateFs, "files", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		//log.Printf("Visited: %s\n", path)
		if !d.IsDir() {
			template, err := template.ParseFS(templateFs, path)
			if err != nil {
				return errors.Wrapf(err, "could not parse %s\n", path)
			}
			fpath := filepath.Join(r10eDockerDir, strings.TrimPrefix(path, "files/"))
			dPath := filepath.Dir(fpath)
			if info, err := os.Stat(dPath); err != nil || !info.IsDir() {
				die(os.MkdirAll(dPath, 0755))
			}

			f, err := os.Create(fpath)
			if err != nil {
				return errors.Wrapf(err, "could not create %s\n", f)
			}
			return template.Execute(f, config)
		}
		return nil
	})

	if err != nil {
		return errors.Wrap(err, "r10e-docker creation failed")
	}

	log.Printf("R10e build scripts created in '%s'", r10eDockerDir)
	return nil
}

func die(err error) {
	if err != nil {
		log.Fatal(err)
	}
}
