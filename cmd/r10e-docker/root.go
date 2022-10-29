package r10edocker

import (
	"log"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
	r10edocker "github.com/syncom/r10edocker/pkg/r10e-docker"
)

var configFile string

var rootCmd = &cobra.Command{
	Use:   "r10edocker",
	Short: "r10edocer - make minimum, reproducible Docker container for Go application",
	Long: `r10edocker creates a framework for making reproducible Docker container images

Configure r10edocker in JSON.

If your Go application is reproducible, the Docker container that includes the application is reproducible.

The resulting Docker container is minimum, in that it contains only the application(s), but does not include an OS shell, a package manager, etc.`,
	Run: func(cmd *cobra.Command, args []string) {
		cfg, err := r10edocker.ReadConfigFile(configFile)
		if err != nil {
			log.Fatalf("could not load project config file: '%s'\n", err)
		}
		if err := r10edocker.GenR10eDocker(&cfg); err != nil {
			log.Fatalf("could not generate r10e-docker build scripts: '%s'\n", err)
		}
	},
}

func Execute(version string) {
	rootCmd.Version = version
	if err := rootCmd.Execute(); err != nil {
		log.Fatalf("CLI error:, '%s'", err)
	}
}

func init() {
	var path, err = os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	r10edocker.DestDir = filepath.Join(path, "r10e-docker")
	rootCmd.Flags().StringVarP(&configFile, "config_path", "c", "", "path of JSON config (required)")
	rootCmd.MarkFlagRequired("config_path")
}
