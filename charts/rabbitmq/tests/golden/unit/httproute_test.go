package golden

import (
	"path/filepath"
	"testing"
	"tests/golden"

	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
)

func TestGoldenHTTPRoute(t *testing.T) {
	t.Parallel()

	chartPath, err := filepath.Abs("../../..")
	require.NoError(t, err)

	suite.Run(t, &golden.TemplateGoldenTest{
		ChartPath:      chartPath,
		Release:        "golden-file-test",
		Namespace:      "test-namespace",
		GoldenFileName: "httproute",
		Templates: []string{
			"templates/httproute.yaml",
		},
		SetValues: defaultSetValues,
		ValuesFiles: []string{
			"../../values/httproute.values.yaml",
		},
	})
}
