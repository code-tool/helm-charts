package golden

import (
	"path/filepath"
	"testing"
	"tests/golden"

	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
)

var defaultSetValues = map[string]string{
	"commitSha": "ed5e844826ce4be1711b05c6a9940a85c8326868",
	"rollme":    "false",
	"itIsTest":  "true",
}

func TestGoldenDefault(t *testing.T) {
	t.Parallel()

	chartPath, err := filepath.Abs("../../..")
	require.NoError(t, err)

	suite.Run(t, &golden.TemplateGoldenTest{
		ChartPath:      chartPath,
		Release:        "golden-file-test",
		Namespace:      "test-namespace",
		GoldenFileName: "default",
		Templates: []string{
			"templates/clusterrolebinding.yaml",
			"templates/clusterrole.yaml",
			//"templates/configmap.yaml",
			"templates/deployment.yaml",
			//"templates/extra-list.yaml",
			"templates/networkpolicy.yaml",
			"templates/pdb.yaml",
			//"templates/podmonitor.yaml",
			//"templates/psp-clusterrolebinding.yaml",
			//"templates/psp-clusterrole.yaml",
			//"templates/psp.yaml",
			//"templates/rolebindings.yaml",
			//"templates/role.yaml",
			//"templates/secret.yaml",
			"templates/serviceaccount.yaml",
			//"templates/servicemonitor.yaml",
			"templates/service.yaml",
			//"templates/tls-secret.yaml",
		},
		SetValues: defaultSetValues,
		ValuesFiles: []string{
			"../../values/default.values.yaml",
		},
	})
}
