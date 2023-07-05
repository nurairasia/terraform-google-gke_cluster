# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "name_suffix" {
  description = "An arbitrary suffix that will be added to the resource name(s) for distinguishing purposes."
  type        = string
  validation {
    condition     = length(var.name_suffix) <= 14
    error_message = "A max of 14 character(s) are allowed."
  }
}

variable "vpc_network" {
  description = "A reference (self link) to the VPC network to host the cluster in."
  type        = string
}

variable "vpc_subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in."
  type        = string
}

variable "pods_ip_range_name" {
  description = "Name of subnet's secondary IP range for hosting k8s pods."
  type        = string
}

variable "services_ip_range_name" {
  description = "Name of subnet's secondary IP range for hosting k8s services."
  type        = string
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "An arbitrary name to identify the k8s cluster."
  type        = string
  default     = "k8s"
}

variable "ingress_ip_names" {
  description = "Arbitrary names for list of static Ingress IPs to be created for the GKE cluster. Use empty list to avoid creating static Ingress IPs."
  type        = list(string)
  default     = []
}

variable "istio_ip_names" {
  description = "Arbitrary names for list of static Istio IPs to be created for the GKE cluster. Use empty list to avoid creating static Istio IPs."
  type        = list(string)
  default     = []
}

variable "nginx_ip_names" {
  description = "Arbitrary names for list of static NGINX IPs to be created for the GKE cluster. Use empty list to avoid creating static NGINX IPs."
  type        = list(string)
  default     = []
}

variable "firewall_name" {
  description = "An arbitrary name to identify the firewall that will be generated for the GKE cluster if \"var.istio_ip_names\" or \"var.firewall_ingress_ports\" contains any values."
  type        = string
  default     = "allow-ingress"
}

variable "firewall_ingress_ports" {
  description = "Additional ports (on cluster nodes) that should be allowed via firewall rules to receive incoming traffic."
  type        = list(string)
  default     = []
}

variable "sa_name" {
  description = "An arbitrary name to identify the ServiceAccount that will be generated & attached to the k8s cluster nodes."
  type        = string
  default     = "gke-sa"
}

variable "min_master_version" {
  description = "The \"minimum\" version number that should be used by the GKE cluster master (a.k.a control-plane). Note that, this is not the same as the \"current\" version number of the cluster master which maybe higher than the \"min_master_version\" specified here. To get the current version number of the cluster master, see the output of the module attribute \"current_master_version\". See https://cloud.google.com/kubernetes-engine/docs/release-notes-stable."
  type        = string
  default     = "1.18.17-gke.1900"
}

variable "cluster_description" {
  description = "The description of the GKE cluster."
  type        = string
  default     = "Generated by Terraform"
}

variable "cluster_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster. Both the key and the value must only contain lowercase letters ([a-z]), numeric characters ([0-9]), underscores (_) and dashes (-). International characters are allowed."
  type        = map(string)
  default     = {}
}

variable "location_type" {
  description = "Options are \"ZONAL\" (default) or \"REGIONAL\". In \"ZONAL\" clusters, the control-plane exists in a single zone. In \"REGIONAL\" clusters, the control-plane is replicated across multiple zones. Regional clusters contain additional quotas. See \"var.locations\". See https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters#availability."
  type        = string
  default     = "ZONAL"
}

variable "locations" {
  description = "Accepts a list of one or more zone-letters from among \"a\", \"b\", \"c\" or \"d\". Defaults to a single \"a\" zone if nothing is specified here. If \"var.location_type\" is \"ZONAL\", then multiple values can be passed here to make it a \"multi-zonal\" cluster - in which case the control-plane will run in the first specified zone while nodes are replicated in all specified zones.. If \"var.location_type\" is \"REGIONAL\" then the control-plane and the nodes are all replicated in all specified zones. See https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters"
  type        = list(string)
  default     = ["a"]
}

variable "master_authorized_networks" {
  description = "External networks that can access the cluster master(s) through HTTPS."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes feature on all nodes in the cluster. Toggling this value will drain, delete, and recreate all nodes in all node pools of this cluster. This may take a lot of time, depending on cluster size, usage and maintenance windows."
  type        = bool
  default     = true
}

variable "enable_public_endpoint" {
  description = "Allows access through the public endpoint of cluster master. Keep it 'true' if you have 'master_authorized_networks_config.cidr_blocks' in the k8s cluster."
  type        = bool
  default     = true
}

variable "namespaces" {
  description = "A list of namespaces to be created in kubernetes. A map of secrets can be included e.g. {\"mysql\": {\"username\": \"johndoe\", \"password\": \"password123\"}}"
  type = list(object({
    name    = string
    labels  = map(string)
    secrets = map(map(string))
  }))
  default = []
}

variable "enable_addon_http_load_balancing" {
  description = "Whether to enable HTTP (L7) load balancing controller addon."
  type        = bool
  default     = true
}

variable "enable_addon_horizontal_pod_autoscaling" {
  description = "Whether to enable Horizontal Pod Autoscaling addon which autoscales based on usage of pods."
  type        = bool
  default     = true
}

variable "enable_vertical_pod_autoscaling" {
  type        = bool
  description = "Whether to enable Vertical Pod Autoscaling which autoscales based on usage of pods."
  default     = false
}

variable "enable_addon_dns_cache_config" {
  description = "Whether to enable NodeLocal DNSCache addon. NodeLocal DNSCache improves DNS lookup latency, makes DNS lookup times more consistent, and reduces the number of DNS queries to kube-dns by running a DNS cache on each node in a cluster. It is disabled by default. See: https://cloud.google.com/kubernetes-engine/docs/how-to/nodelocal-dns-cache"
  type        = bool
  default     = true
}

variable "default_max_pods_per_node" {
  description = "The default maximum number of pods per node in this cluster. Every object in the node_pools variable  already has a max_pods_per_node attribute in it. However, this default_max_pods_per_node value is used by the default pool of the cluster when the cluster is being created for the first time - which BTW is deleted by terraform right after creation (see this module's source code for the attribute called 'remove_default_node_pool' which is set to true). So this value is used only for cluster creation and kept small by design. Override this value if you already have a cluster which was created previously with google's default max_pods_per_node value above 8. See https://cloud.google.com/kubernetes-engine/docs/how-to/flexible-pod-cidr#cidr_ranges_for_clusters"
  type        = number
  default     = 8
}

variable "max_surge" {
  description = "Max number of node(s) that can be over-provisioned while the GKE cluster is undergoing a version upgrade. Raising the number would allow more number of node(s) to be upgraded simultaneously."
  type        = number
  default     = 1
}

variable "max_unavailable" {
  description = "Max number of node(s) that can be allowed to be unavailable while the GKE cluster is undergoing a version upgrade. Raising the number would allow more number of node(s) to be upgraded simultaneously."
  type        = number
  default     = 0
}

variable "maintenance_window" {
  description = <<-EOT
  The time windows when GKE can be allowed to perform maintenance ops like version upgrade, 
  repair, scheduled maintenance etc. GKE requires the total sum of allowed hours to be at least 48 hours per 
  32 days - with no single duration being shorter than 4 hours.
  
  The `_time_utc` values are allowed in 24-hour `HH:MM` format only and must be in UTC timezone.
  The `days_of_week` value is a CSV string containing 2-letter notations of days in a week in capital letters.
  Check the default values for reference. Note that, the timezone conversions from UTC do not impact the day values.
  
  KNOWN ISSUE: 
  If the `start_time_utc` is as late in the day as pushing `end_time_utc` over to the NEXT day in UTC, 
  then `end_time_utc` will become smaller than `start_time_utc` - this is disallowed by Terraform. 
  Therefore, both `start_time_utc` and `end_time_utc` must be within the same single day in UTC.
  EOT
  type = object({
    start_time_utc = string
    end_time_utc   = string
    days_of_week   = string
  })
  default = {
    start_time_utc = "19:00"          # implies 3AM in MYT
    end_time_utc   = "23:00"          # implies 7AM in MYT
    days_of_week   = "MO,TU,WE,TH,FR" # implies MO,TU,WE,TH,FR in MYT - remains unchanged by timezone conversion
  }
}

variable "node_pools" {
  description = <<-EOT
  node_pool_name: An arbitrary name to identify the GKE node pool and its VMs & VM instance groups.
  
  node_count_min_per_zone: The minimum number of nodes (per zone) this nodepool will allocate if
  auto-down-scaling occurs.
  
  node_count_max_per_zone: The maximum number of nodes (per zone) this nodepool will allocate if
  auto-up-scaling occurs.
  
  node_labels: Kubernetes labels (key-value pairs) to be applied to each node. The kubernetes.io/
  and k8s.io/ prefixes are reserved by Kubernetes Core components and cannot be specified.
  See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#labels.

  node_taints: Kubernetes taint to be applied to each node of the nodepool. Supported values for
  `effect` are `NO_SCHEDULE`, `PREFER_NO_SCHEDULE` or `NO_EXECUTE`.
  See https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
  
  max_pods_per_node: The maximum number of pods per node in this node pool. This value has direct
  correlation with the IP range sizes availble in "var.pods_ip_range_name".
  See https://cloud.google.com/kubernetes-engine/docs/how-to/flexible-pod-cidr#cidr_ranges_for_clusters.
  
  machine_type: The size of VM for each node.
  See https://cloud.google.com/compute/docs/machine-types.
  
  disk_type: Type of the disk for each node. Acceptable values are "pd-standard", "pd-balanced" or
  "pd-ssd". "pd-standard" is default. "pd-ssd" is costly.
  
  disk_size_gb: Size of the disk on each node in Giga Bytes.
  
  preemptible: Preemptible nodes last a maximum of 24 hours and helps reduce cost while providing no
  availability guarantee. It can be used for non-production clusters to help save cost. Not recommended
  for production clusters to help maintain availability. Only one of 'preemptible' or 'spot' can be enabled at a time.

  spot: Spot VMs are the latest version of preemptible VMs. They do not have a maximum runtime limitation.
  It is like spot instances in AWS EC2. Recommended for non-production clusters to help save cost. Only one of
  'preemptible' or 'spot' can be enabled at a time.

  max_surge: Max number of node(s) that can be over-provisioned while the GKE cluster is undergoing
  a version upgrade. Raising the number would allow more number of node(s) to be upgraded
  simultaneously.
  
  max_unavailable: Max number of node(s) that can be allowed to be unavailable while the GKE
  cluster is undergoing a version upgrade. Raising the number would allow more number of node(s) to
  be upgraded simultaneously.
  
  enable_node_integrity: Whether to enable/disable the Secure Boot & Integrity Monitoring features
  of the nodes. These features are used alongside GKE Shielded Nodes feature. By default
  (when set to null), Integrity Monitoring is set to 'true' and Secure Boot is set to 'false'.
  See https://cloud.google.com/kubernetes-engine/docs/how-to/shielded-gke-nodes#node_integrity

  network_tags: List of network tags to be applied to all nodes in a nodepool. Network tags are used
  by VPC firewall rules to determine sources and targets.

  node_metadatas: Map of Compute Engine instance metadata (key-values) to be applied to all nodes in a nodepool. Instance metadata can be used to configure the behavior of the nodes / VM instances.
  EOT
  type = list(object({
    node_pool_name          = string
    node_count_min_per_zone = number
    node_count_max_per_zone = number
    node_labels             = map(string)
    node_taints             = list(object({ key = string, value = string, effect = string }))
    max_pods_per_node       = number
    network_tags            = list(string)
    machine_type            = string
    disk_type               = string
    disk_size_gb            = number
    preemptible             = bool
    spot                    = bool
    max_surge               = number
    max_unavailable         = number
    enable_node_integrity   = bool
    node_metadatas          = map(string)
    gpu_type                = map(string)
  }))
  default = [{
    node_pool_name          = "gkenp-a"
    node_count_min_per_zone = 1
    node_count_max_per_zone = 2
    node_labels             = {}
    node_taints             = []
    max_pods_per_node       = 16
    network_tags            = []
    machine_type            = "e2-micro"
    disk_type               = "pd-standard"
    disk_size_gb            = 50
    preemptible             = false
    spot                    = false
    max_surge               = 1
    max_unavailable         = 0
    enable_node_integrity   = null
    node_metadatas          = {}
    gpu_type                = null
  }]
}

variable "cluster_logging_service" {
  description = "The logging service that the cluster should write logs to. Available options include \"logging.googleapis.com\" (Legacy Stackdriver), \"logging.googleapis.com/kubernetes\" (Stackdriver Kubernetes Engine Logging), and \"none\"."
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "cluster_monitoring_service" {
  description = "The monitoring service to be used by the GKE cluster."
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "cluster_timeout" {
  description = "how long a cluster operation is allowed to take before being considered a failure."
  type        = string
  default     = "60m"
}

variable "node_pool_timeout" {
  description = "how long a node pool operation is allowed to take before being considered a failure."
  type        = string
  default     = "30m"
}

variable "namespace_timeout" {
  description = "how long a k8s namespace operation is allowed to take before being considered a failure."
  type        = string
  default     = "5m"
}

variable "sa_roles" {
  description = "The IAM roles that should be granted to the ServiceAccount which is attached to the GKE node VMs. This will enable the node VMs to access other GCP resources as permitted (or disallowed) by the IAM roles."
  type        = list(string)
  default     = []
}

variable "ip_address_timeout" {
  description = "how long a Compute Address operation is allowed to take before being considered a failure."
  type        = string
  default     = "5m"
}

variable "nginx_controller" {
  description = "Whether to have a NGINX Ingress Controller installed in this cluster; with a dedicated IP. Refer to the IP name in var.nginx_ip_names to be used here."
  type = object({
    enabled = bool
    ip_name = string
  })
  default = {
    enabled = false
    ip_name = null
  }
}

variable "master_private_ip_cidr" {
  description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet"
  type        = string
  default     = "172.16.0.0/28"
}
