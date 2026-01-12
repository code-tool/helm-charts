package golden

import (
	"path/filepath"
	"testing"
	"tests/golden"

	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
)

var defaultSetValues = map[string]string{
	"commitSha":             "ed5e844826ce4be1711b05c6a9940a85c8326868",
	"rollme":                "false",
	"itIsTest":              "true",
	"global.redis.password": "test",
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
			"templates/configmap.yaml",
			//"templates/extra-list.yaml",
			"templates/headless-svc.yaml",
			"templates/health-configmap.yaml",
			"templates/master/application.yaml",
			//"templates/master/psp.yaml",
			//"templates/master/pvc.yaml",
			"templates/master/serviceaccount.yaml",
			"templates/master/service.yaml",
			//"templates/metrics-svc.yaml",
			"templates/networkpolicy.yaml",
			//"templates/pdb.yaml",
			//"templates/prometheusrule.yaml",
			//"templates/replicas/hpa.yaml",
			"templates/replicas/serviceaccount.yaml",
			"templates/replicas/service.yaml",
			"templates/replicas/statefulset.yaml",
			//"templates/rolebinding.yaml",
			//"templates/role.yaml",
			"templates/scripts-configmap.yaml",
			//"templates/secret-svcbind.yaml",
			"templates/secret.yaml",
			//"templates/sentinel/hpa.yaml",
			//"templates/sentinel/node-services.yaml",
			//"templates/sentinel/ports-configmap.yaml",
			//"templates/sentinel/service.yaml",
			//"templates/sentinel/statefulset.yaml",
			//"templates/serviceaccount.yaml",
			//"templates/servicemonitor.yaml",
			//"templates/tls-secret.yaml",
		},
		SetValues: defaultSetValues,
		ValuesFiles: []string{
			"../../values/default.values.yaml",
		},
	})
}

func TestGolden01(t *testing.T) {
	t.Parallel()

	chartPath, err := filepath.Abs("../../..")
	require.NoError(t, err)

	suite.Run(t, &golden.TemplateGoldenTest{
		ChartPath:      chartPath,
		Release:        "golden-file-test",
		Namespace:      "test-namespace",
		GoldenFileName: "01",
		Templates: []string{
			"templates/networkpolicy.yaml",
			"templates/sentinel/pdb.yaml",
			"templates/serviceaccount.yaml",
			"templates/configmap.yaml",
			"templates/health-configmap.yaml",
			"templates/scripts-configmap.yaml",
			"templates/headless-svc.yaml",
			"templates/metrics-svc.yaml",
			"templates/sentinel/service.yaml",
			"templates/sentinel/statefulset.yaml",
			"templates/servicemonitor.yaml",
		},
		SetValues: defaultSetValues,
		ValuesFiles: []string{
			"../../values/01.values.yaml",
		},
	})
}

func TestGolden02(t *testing.T) {
	t.Parallel()

	chartPath, err := filepath.Abs("../../..")
	require.NoError(t, err)

	suite.Run(t, &golden.TemplateGoldenTest{
		ChartPath:      chartPath,
		Release:        "golden-file-test",
		Namespace:      "test-namespace",
		GoldenFileName: "02",
		Templates: []string{
			"templates/networkpolicy.yaml",
			"templates/replicas/pdb.yaml",
			"templates/replicas/serviceaccount.yaml",
			"templates/configmap.yaml",
			"templates/health-configmap.yaml",
			"templates/scripts-configmap.yaml",
			"templates/headless-svc.yaml",
			"templates/metrics-svc.yaml",
			"templates/replicas/service.yaml",
			"templates/replicas/hpa.yaml",
			"templates/replicas/statefulset.yaml",
			"templates/servicemonitor.yaml",
		},
		SetValues: defaultSetValues,
		ValuesFiles: []string{
			"../../values/02.values.yaml",
		},
	})
}

func TestGolden03(t *testing.T) {
	t.Parallel()

	chartPath, err := filepath.Abs("../../..")
	require.NoError(t, err)

	suite.Run(t, &golden.TemplateGoldenTest{
		ChartPath:      chartPath,
		Release:        "golden-file-test",
		Namespace:      "test-namespace",
		GoldenFileName: "03",
		Templates: []string{
			"templates/configmap.yaml",
			"templates/headless-svc.yaml",
			"templates/health-configmap.yaml",
			"templates/serviceaccount.yaml",
			"templates/metrics-svc.yaml",
			"templates/networkpolicy.yaml",
			"templates/prometheusrule.yaml",
			"templates/sentinel/pdb.yaml",
			"templates/scripts-configmap.yaml",
			"templates/sentinel/service.yaml",
			"templates/sentinel/statefulset.yaml",
		},
		SetValues: defaultSetValues,
		ValuesFiles: []string{
			"../../values/03.values.yaml",
		},
	})
}

func TestGoldenExtraDeploy(t *testing.T) {
	t.Parallel()

	chartPath, err := filepath.Abs("../../..")
	require.NoError(t, err)

	suite.Run(t, &golden.TemplateGoldenTest{
		ChartPath:      chartPath,
		Release:        "golden-file-test",
		Namespace:      "test-namespace",
		GoldenFileName: "extradeploy",
		Templates: []string{
			"templates/extra-list.yaml",
		},
		SetValues: defaultSetValues,
		ValuesFiles: []string{
			"../../values/extradeploy.values.yaml",
		},
	})
}

// non-bitnami version of 01.golden.yaml
func TestGolden04(t *testing.T) {
	t.Parallel()

	chartPath, err := filepath.Abs("../../..")
	require.NoError(t, err)

	suite.Run(t, &golden.TemplateGoldenTest{
		ChartPath:      chartPath,
		Release:        "golden-file-test",
		Namespace:      "test-namespace",
		GoldenFileName: "04",
		Templates: []string{
			"templates/networkpolicy.yaml",
			"templates/sentinel/pdb.yaml",
			"templates/serviceaccount.yaml",
			"templates/configmap.yaml",
			"templates/health-configmap.yaml",
			"templates/scripts-configmap.yaml",
			"templates/headless-svc.yaml",
			"templates/metrics-svc.yaml",
			"templates/sentinel/service.yaml",
			"templates/sentinel/statefulset.yaml",
			"templates/servicemonitor.yaml",
		},
		SetValues: defaultSetValues,
		ValuesFiles: []string{
			"../../values/04.values.yaml",
		},
	})
}

// non-bitnami version of 02.golden.yaml
func TestGolden05(t *testing.T) {
	t.Parallel()

	chartPath, err := filepath.Abs("../../..")
	require.NoError(t, err)

	suite.Run(t, &golden.TemplateGoldenTest{
		ChartPath:      chartPath,
		Release:        "golden-file-test",
		Namespace:      "test-namespace",
		GoldenFileName: "05",
		Templates: []string{
			"templates/networkpolicy.yaml",
			"templates/replicas/pdb.yaml",
			"templates/replicas/serviceaccount.yaml",
			"templates/configmap.yaml",
			"templates/health-configmap.yaml",
			"templates/scripts-configmap.yaml",
			"templates/headless-svc.yaml",
			"templates/metrics-svc.yaml",
			"templates/replicas/service.yaml",
			"templates/replicas/hpa.yaml",
			"templates/replicas/statefulset.yaml",
			"templates/servicemonitor.yaml",
		},
		SetValues: defaultSetValues,
		ValuesFiles: []string{
			"../../values/05.values.yaml",
		},
	})
}
