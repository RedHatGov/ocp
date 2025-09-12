# 🚀 OpenShift Disconnected Quick Start Guide

**Your Complete Guide to oc-mirror v2 Two-Host Architecture**

Welcome to the OpenShift disconnected installation guide! This guide will take you from zero to successfully running OpenShift in disconnected environments using a two-host architecture with oc-mirror v2.

---
### **📝  CRITICAL ASSUMPTIONS:

This guide assumes that the customer will use a single imageset-config.yaml file for ALL oc-mirror tasks/runs. This includes doing the initial base openshift image set pull as well as subsequent image pulls for a single (or multiple) operators or openshift upgrades.  

Retention of the .cache directory is CRITICAL to these subsequent pulls. Keeping the .cache and using the same imageset-config.yaml will ensure that content is not pulled again and again from the internet. 

Retention of the working-dir is CRITICAL to all operations. It contains all state infomation of all oc-mirror --v2 operations. This state information will REDUCE the size of .tar files and allow for the ability to re-tar content based on historical dates of collection.  

- For example, initial Openshift pull is 20GB, additional image pull of 10 Operators would be ~5GB and will NOT contain the initial openshift pull. Keeping the working-dir directory will ensure this "history" of previous image pulls will be consecutive on subsequent runs and you will not have to transfer the same images multiple times.

  
## 📋 Requirements and Assumptions

### **🔑 Key Assumptions**

- ✅ One `imageset-config.yaml` for all oc-mirror --v2 operations:
  - 🚀 First run initial mirroring
  - 🔄 Subsequent runs and updates  
  - ➕ Adding new operators
  - 🆙 New versions of OpenShift
  - ➖ Removing operators
  - 🖼️ Adding and removing additional images
- ✅ Always create a backup of your imageset-config.yaml
- ✅ Always use the latest oc-mirror v2 (regardless of the OpenShift Version)
- ✅ Never run as ROOT user
- ✅ Bastion host must be persistent (maintain `.cache` and `.history` directory)
- ✅ Secure transfer method between hosts (SCP/rsync,Blu-ray)
- ✅ Use fully qualified hostnames
- ✅ oc-mirror shells are supplied to ensure commands are documented and tracked in the user environment

### **✅ Host Requirements**

| Specification | Bastion Host | Registry Host |
|---------------|--------------|---------------|
| **OS** | RHEL 9 or 8 | RHEL 9 or 8 |
| **CPU** | 8 cores | 8 cores |
| **Memory** | 16 GB | 16 GB |
| **Storage** | 2 TB | 2 TB |
| **Internet** | ✅ Required | ❌ Disconnected |

### **🌊 For AWS Lab Setup**

📖 **Complete AWS Infrastructure Guide:** [docs/aws.md](docs/aws.md)

---

## 🚀 Quick Start

### **Step 1: Bastion Host Setup**

**🔧 Install Required Tools and configure pull secret (authentication)**

**🔧 Navigate to:** [OpenShift Downloads](https://console.redhat.com/openshift/downloads) Copy your pull secret


```bash
# Set the hostname (replace XXX with your sandbox number)
sudo hostnamectl hostname bastion.sandboxXXX.opentlc.com

# Install base requirements
sudo dnf install -y podman git

# Clone this repository
git clone git@github.com:RedHatGov/ocp.git && cd ocp

# Collect OpenShift tools (includes oc-mirror v2)
./collect_ocp

# Create container config directory
mkdir -p ~/.config/containers

# Create and Paste your pull secret content into this auth.json file
vi ~/.config/containers/auth.json
```

> 📝 **Critical:** For this guide, the collect_ocp pulls 4.19.2 version of openshift-install. Modify it based on the version of OpenShift that you want to deploy

### **Step 2: m2d Flow - Mirror to Disk**

**📦 Create Portable Archives on Bastion**

```bash
# oc-mirror --v2 will create the content as defined in your imageset-config.yaml
# Edit imageset-config.yaml for your requirements
cd oc-mirror

# View your imageset-config.yaml to see what content will be mirrored
cat imageset-config.yaml

# Run mirror-to-disk operation
./mirror-to-disk.sh

# Verify archive creation
ls -la content/

# Create a backup copy of your imageset-config.yaml with the YYYY-MM-DD in content/ 
cp imageset-config.yaml content/imageset-config-$(date +%F).yaml
```
> 📝 **Note:** Additional example imageset-config.yaml files exist in the example directory in oc-mirror. Explore them if you would like to add additional operators to your deployment.


### **Step 3: Transfer to Registry Host**

**🚚 Secure Archive Transfer**

```bash
# Transfer all content in the ocp directory to registry host
# Excluding the ocp/oc-mirror/content/working-dir
cd ~

rsync -av --progress -e "ssh -i ~/.ssh/aws.pem" \
  --exclude 'oc-mirror/content/working-dir' \
  ./ocp/ \
  ec2-user@registry.sandbox3296.opentlc.com:~/ocp/
```
> 📝 **Critical:** You do not need to transfer the .cache to your disconnected host

> 📝 **Critical:** DO NOT overwrite your working-dir on your disconnected host

### **Step 4: Registry Host Setup**

**🔧 Install Required Tools and configure**

```bash
# Set the hostname (replace XXX with your sandbox number)
sudo hostnamectl hostname registry.sandboxXXX.opentlc.com

# Install base requirements
sudo dnf install -y podman git

# Install ocp binaries into your path
cd ocp/downloads/ && ./install.sh

# Create container config directory
mkdir -p ~/.config/containers
```
**Configure the firewall to allow inbound access to the registry**

```bash
# Allow HTTP traffic (port 80)
sudo firewall-cmd --permanent --add-port=80/tcp

# Allow HTTPS traffic (port 443)  
sudo firewall-cmd --permanent --add-port=443/tcp

# Allow mirror registry traffic (port 8443)
sudo firewall-cmd --permanent --add-port=8443/tcp

# Reload firewall to apply changes
sudo firewall-cmd --reload

# Verify firewall rules
sudo firewall-cmd --list-ports
```
**🏪  Deploy Mirror Registry**

```bash
# Change to mirror registry directory
cd mirror-registry

# Install mirror registry
./mirror-registry install 
```
> 📝 **Critical:** When the installation completes, **save the generated registry credentials** (username and password) from the last line of the log output to a secure location. You'll need these for authentication.

**Trust Registry SSL Certificate**

```bash
# Copy certificate to system trust store
sudo cp ~/quay-install/quay-rootCA/rootCA.pem /etc/pki/ca-trust/source/anchors/

# Update certificate trust
sudo update-ca-trust
```

**Set Up Registry Authentication**
```bash
# Login to your mirror registry (use credentials from installation)
podman login https://$(hostname):8443 \
  --username init \
  --password [YOUR_REGISTRY_PASSWORD] \
  --authfile ~/.config/containers/auth.json
```

### **Step 5: d2m Flow - Disk to Mirror**

**📋 Load Archives into Registry**

```bash
# Inspect your imageset-config.yaml and the backup copy in /content.
# They should be identical. This is the content that you will load into the registry
# This will also create your custom catalog based on the operators in the imageset-config.yaml
cd ../../oc-mirror
cat imageset-config.yaml

# Run disk-to-mirror operation
./disk-to-mirror.sh
```
**📋 Verify the disk-to-mirror process was successful**

```bash
# Inspect the oc-mirror log file
cat content/working-dir/logs/oc-mirror.log

# Inspect the cluster-resources
ls content/working-dir/cluster-resources

# Inspect registry content (if using Quay web interface)
firefox https://$(hostname):8443
```

> 📝 **Critical:** Note the success of this action on your bastion node. The clean hygiene will ensure future success with this process.

### **Step 6: Deploy OpenShift**

**📋 Validate your openshift-install client**

```bash
# Inspect the openshift-release image
oc adm release info $HOSTNAME:8443/openshift/release-images:4.19.2-x86_64 | grep release

# Inspect the release for the openshift-install client
openshift-install version
```

**📋 OpenShift Installation Configuration**

```bash
# Generate SSH key for cluster node access, take the defaults
ssh-keygen -t ed25519 -C "openshift@$(hostname)"

# Extract registry-specific authentication for install config
# Format needed: {"auths": {"<MIRROR-REGISTRY>:8443": {"auth": "BASE64_CREDENTIALS"}}}
jq -c --arg reg "$(hostname):8443" '
  .auths[$reg].auth as $token
  | {"auths": { ($reg): {"auth": $token} }}
' ~/.config/containers/auth.json

# Create install configuration
mkdir ~/ocp/cluster/ocp 
cd ~/ocp/cluster/ocp
openshift-install create install-config 
```
**Provide Platform Information:**

| Parameter | Example Value | Notes |
|-----------|---------------|-------|
| **SSH Public Key** | `~/.ssh/id_ed25519.pub` | Generated above |
| **Platform** | AWS, Azure, GCP, vSphere, etc. | Your cloud/infrastructure provider |
| **Platform Credentials** | Various | Specific to your cloud provider |
| **Region/Location** | us-east-2, eastus, etc. | Provider-specific region |
| **Base Domain** | sandbox762.opentlc.com | Your DNS domain for the cluster |
| **Cluster Name** | ocp | Descriptive cluster name |
| **Pull Secret** | Registry auth JSON | From your merged auth.json file |

> 📋 **Platform-Specific Setup:** For detailed cloud-specific configuration, refer to the [OpenShift Installation Documentation](https://docs.openshift.com/container-platform/latest/installing/) for your specific platform.

**Add Image Mirror Sources:**

Edit the installation configuration to include mirror information
```bash
# Edit the configuration
vi install-config.yaml
```

**Add the imageDigestSources section:**
```yaml
imageDigestSources:
  - mirrors:
    - $(hostname):8443/openshift/release
    source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
  - mirrors:
    - $(hostname):8443/openshift/release-images
    source: quay.io/openshift-release-dev/ocp-release
```

**Add Additional Trust Bundle:**

Include the registry certificate in the installation configuration
```bash
# Get the registry certificate
cat ~/quay-install/quay-rootCA/rootCA.pem

# Add the certificate to install-config.yaml
{ echo "additionalTrustBundle: |"; sed 's/^/  /' ~/quay-install/quay-rootCA/rootCA.pem; } >> install-config.yaml
```

**Example disconnected install-config additions**
```bash
# Inspect the example
cat ../install-disconnected.example

# Inspect the install-config
cat install-config.yaml
```

**Install OpenShift**
```bash
# Create a backup of your config
cp install-config.yaml install-config.yaml.backup

# Deploy the cluster with debug logging
openshift-install create cluster --log-level debug
```
**Set up local access to your new cluster: This can be done at any time during the install**
```bash
# Set KUBECONFIG environment variable
export KUBECONFIG=~/ocp/cluster/ocp/auth/kubeconfig

# Create kube config directory
mkdir -p ~/.kube

# Copy cluster config
cp auth/kubeconfig ~/.kube/config

# Verify cluster access
oc whoami
oc whoami --show-console
oc get nodes
oc get co
```
>**Access the web console** using the URL and credentials provided.

**Apply IDMS and ITMS resources generated during mirroring:**
```bash
# Navigate to mirror configuration directory
cd ~/ocp/oc-mirror

# Apply all cluster resources
oc apply -f content/working-dir/cluster-resources/
```

**Applied Resources:**
- **IDMS** (ImageDigestMirrorSet): Maps digest-based image references to mirror registry
- **ITMS** (ImageTagMirrorSet): Maps tag-based image references to mirror registry  
- **CatalogSource**: Defines operator catalog sources from mirror registry

**Create Certificate ConfigMap:**
```bash
# Create ConfigMap with registry certificate
oc create configmap registry-config \
  --from-file=$(hostname):8443=${HOME}/quay-install/quay-rootCA/rootCA.pem \
  -n openshift-config
```

**Apply Certificate to Cluster:**
```bash
# Patch cluster image configuration to trust the registry
oc patch image.config.openshift.io/cluster \
  --patch '{"spec":{"additionalTrustedCA":{"name":"registry-config"}}}' \
  --type=merge
```

**Disable Default Operator Sources**
```bash
# Disable all default operator sources
oc patch OperatorHub cluster --type json \
  -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

> ⚠️ **Important:** This prevents the cluster from attempting to pull operators from external registries.

### 📖 **Step 7: [OpenShift Cluster Upgrade](docs/cluster-upgrade.md)**

**📋 Validate your openshift-install client**

```bash
# Inspect the openshift-release image
oc adm release info $HOSTNAME:8443/openshift/release-images:4.19.2-x86_64 | grep release

# Inspect the release for the openshift-install client
openshift-install version
```
TODO: inspect the history, draft the history and --since date. 

---

