package form

import (
	"fmt"
	"net/http"
	"strconv"
)

func ParseValues(r *http.Request) *Profile {
	if err := r.ParseForm(); err != nil {
		fmt.Printf("ERROR: Could not parse request body.\n%s", err)
	}
	p := &Profile{}
	p.Config.AllowWorkloadsOnMaster, _ = strconv.ParseBool(r.FormValue("allowWorkloadsOnMaster"))
	p.Config.BaseDomain = r.FormValue("baseDomain")
	p.Config.BaseIPType = r.FormValue("baseIpType")
	p.Config.BasePassword = r.FormValue("basePassword")
	p.Config.BaseUser = r.FormValue("baseUser")
	p.Config.CertificationMode, _ = strconv.ParseBool(r.FormValue("certificationMode"))
	p.Config.DefaultKeyboardLanguage = r.FormValue("defaultKeyboardLanguage")
	p.Config.DisableLinuxDesktop, _ = strconv.ParseBool(r.FormValue("disableLinuxDesktop"))
	p.Config.DisableSessionTimeout, _ = strconv.ParseBool(r.FormValue("disableSessionTimeout"))
	p.Config.DNSResolution = r.FormValue("dnsResolution")
	p.Config.Docker.DockerhubEmail = r.FormValue("dockerhub_email")
	p.Config.Docker.DockerhubPassword = r.FormValue("dockerhub_password")
	p.Config.Docker.DockerhubUsername = r.FormValue("dockerhub_username")
	p.Config.GlusterFsDiskSize, _ = strconv.ParseInt(r.FormValue("GlusterFSDiskSize"), 10, 64)
	p.Config.LocalVolumes.FiftyGB, _ = strconv.ParseInt(r.FormValue("fifty_gb"), 10, 64)
	p.Config.LocalVolumes.FiveGB, _ = strconv.ParseInt(r.FormValue("five_gb"), 10, 64)
	p.Config.LocalVolumes.OneGB, _ = strconv.ParseInt(r.FormValue("one_gb"), 10, 64)
	p.Config.LocalVolumes.TenGB, _ = strconv.ParseInt(r.FormValue("ten_gb"), 10, 64)
	p.Config.LocalVolumes.ThirtyGB, _ = strconv.ParseInt(r.FormValue("thirty_gb"), 10, 64)
	p.Config.ProxySettings.HTTPProxy = r.FormValue("http_proxy")
	p.Config.ProxySettings.HTTPSProxy = r.FormValue("https_proxy")
	p.Config.ProxySettings.NoProxy = r.FormValue("no_proxy")
	p.Config.SelectedTemplates = r.FormValue("selectedTemplates")
	p.Config.SslProvider = r.FormValue("sslProvider")
	p.Config.StandaloneMode, _ = strconv.ParseBool(r.FormValue("standaloneMode"))
	p.Config.StartupMode = r.FormValue("startupMode")
	p.Config.StaticNetworkSetup.BaseFixedIPAddresses.KxMain1 = r.FormValue("kx-main1")
	p.Config.StaticNetworkSetup.BaseFixedIPAddresses.KxMain2 = r.FormValue("kx-main2")
	p.Config.StaticNetworkSetup.BaseFixedIPAddresses.KxMain3 = r.FormValue("kx-main3")
	p.Config.StaticNetworkSetup.BaseFixedIPAddresses.KxWorker1 = r.FormValue("kx-worker1")
	p.Config.StaticNetworkSetup.BaseFixedIPAddresses.KxWorker2 = r.FormValue("kx-worker2")
	p.Config.StaticNetworkSetup.BaseFixedIPAddresses.KxWorker3 = r.FormValue("kx-worker3")
	p.Config.StaticNetworkSetup.BaseFixedIPAddresses.KxWorker4 = r.FormValue("kx-worker4")
	p.Config.UpdateSourceOnStart, _ = strconv.ParseBool(r.FormValue("updateSourceOnStart"))
	p.Config.VirtualizationType = r.FormValue("virtualizationType")
	p.Config.VMProperties.MainAdminNodeCPUCores, _ = strconv.ParseInt(r.FormValue("mainAdminNodeCPUCores"), 10, 64)
	p.Config.VMProperties.MainAdminNodeMemory, _ = strconv.ParseInt(r.FormValue("mainAdminNodeMemory"), 10, 64)
	p.Config.VMProperties.MainNodeCount, _ = strconv.ParseInt(r.FormValue("mainNodeCount"), 10, 64)
	p.Config.VMProperties.MainReplicaNodeCPUCores, _ = strconv.ParseInt(r.FormValue("mainReplicaNodeCPUCores"), 10, 64)
	p.Config.VMProperties.MainReplicaNodeMemory, _ = strconv.ParseInt(r.FormValue("mainReplicaNodeMemory"), 10, 64)
	p.Config.VMProperties.ThreeDAcceleration = (r.FormValue("the3DAcceleration"))
	p.Config.VMProperties.WorkerNodeCPUCores, _ = strconv.ParseInt(r.FormValue("workerNodeCPUCores"), 10, 64)
	p.Config.VMProperties.WorkerNodeMemory, _ = strconv.ParseInt(r.FormValue("workerNodeMemory"), 10, 64)
	p.NotificationEndpoints.EmailAddress = r.FormValue("emailAddress")
	p.NotificationEndpoints.MsTeamsWebhook = r.FormValue("msTeamsWebhook")
	p.NotificationEndpoints.SlackWebhook = r.FormValue("slackWebhook")
	return p
}

type Profile struct {
	Config                Config                `json:"config"`
	NotificationEndpoints NotificationEndpoints `json:"notification_endpoints"`
}
type Config struct {
	AllowWorkloadsOnMaster  bool               `json:"allowWorkloadsOnMaster"`
	BaseDomain              string             `json:"baseDomain"`
	BaseIPType              string             `json:"baseIpType"`
	BasePassword            string             `json:"basePassword"`
	BaseUser                string             `json:"baseUser"`
	CertificationMode       bool               `json:"certificationMode"`
	DefaultKeyboardLanguage string             `json:"defaultKeyboardLanguage"`
	DisableLinuxDesktop     bool               `json:"disableLinuxDesktop"`
	DisableSessionTimeout   bool               `json:"disableSessionTimeout"`
	DNSResolution           string             `json:"dnsResolution"`
	Docker                  Docker             `json:"docker"`
	EnvironmentPrefix       string             `json:"environmentPrefix"`
	GlusterFsDiskSize       int64              `json:"glusterFsDiskSize"`
	KubeOrchestrator        string             `json:"kubeOrchestrator"`
	LocalVolumes            LocalVolumes       `json:"local_volumes"`
	LogLevel                string             `json:"logLevel"`
	MetalLbIPRange          MetalLBIPRange     `json:"metalLbIpRange"`
	ProxySettings           ProxySettings      `json:"proxy_settings"`
	SelectedTemplates       string             `json:"selectedTemplates"`
	SslProvider             string             `json:"sslProvider"`
	StandaloneMode          bool               `json:"standaloneMode"`
	StartupMode             string             `json:"startupMode"`
	StaticNetworkSetup      StaticNetworkSetup `json:"staticNetworkSetup"`
	UpdateSourceOnStart     bool               `json:"updateSourceOnStart"`
	VirtualizationType      string             `json:"virtualizationType"`
	VMProperties            VMProperties       `json:"vm_properties"`
}
type Docker struct {
	DockerhubEmail    string `json:"dockerhub_email"`
	DockerhubPassword string `json:"dockerhub_password"`
	DockerhubUsername string `json:"dockerhub_username"`
}
type LocalVolumes struct {
	FiftyGB  int64 `json:"fifty_gb"`
	FiveGB   int64 `json:"five_gb"`
	OneGB    int64 `json:"one_gb"`
	TenGB    int64 `json:"ten_gb"`
	ThirtyGB int64 `json:"thirty_gb"`
}

type MetalLBIPRange struct {
	IPRangeEnd   string `json:"ipRangeEnd"`
	IPRangeStart string `json:"ipRangeStart"`
}
type ProxySettings struct {
	HTTPProxy  string `json:"http_proxy"`
	HTTPSProxy string `json:"https_proxy"`
	NoProxy    string `json:"no_proxy"`
}

type StaticNetworkSetup struct {
	BaseFixedIPAddresses BaseFixedIPAddresses `json:"baseFixedIpAddresses"`
	Dns1                 string               `json:"dns1"`
	Dns2                 string               `json:"dns2"`
	Gateway              string               `json:"gateway"`
}

type BaseFixedIPAddresses struct {
	KxMain1   string `json:"kx-main1"`
	KxMain2   string `json:"kx-main2"`
	KxMain3   string `json:"kx-main3"`
	KxWorker1 string `json:"kx-worker1"`
	KxWorker2 string `json:"kx-worker2"`
	KxWorker3 string `json:"kx-worker3"`
	KxWorker4 string `json:"kx-worker4"`
}

type VMProperties struct {
	ThreeDAcceleration      string `json:"3d_acceleration"`
	MainAdminNodeCPUCores   int64  `json:"main_admin_node_cpu_cores"`
	MainAdminNodeMemory     int64  `json:"main_admin_node_memory"`
	MainNodeCount           int64  `json:"main_node_count"`
	MainReplicaNodeCPUCores int64  `json:"main_replica_node_cpu_cores"`
	MainReplicaNodeMemory   int64  `json:"main_replica_node_memory"`
	WorkerNodeCount         int64  `json:"worker_node_count"`
	WorkerNodeCPUCores      int64  `json:"worker_node_cpu_cores"`
	WorkerNodeMemory        int64  `json:"worker_node_memory"`
}
type NotificationEndpoints struct {
	EmailAddress   string `json:"email_address"`
	MsTeamsWebhook string `json:"ms_teams_webhook"`
	SlackWebhook   string `json:"slack_webhook"`
}
