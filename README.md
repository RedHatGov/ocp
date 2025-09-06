# 🚀 OpenShift Disconnected Quick Start Guide

**Your Complete Guide to oc-mirror v2 Two-Host Architecture**

Welcome to the OpenShift disconnected installation guide! This guide will take you from zero to successfully running OpenShift in disconnected environments using a two-host architecture with oc-mirror v2.

---

## 📋 Requirements and Assumptions

### **🔑 Key Assumptions**

- ✅ One `imageset-config.yaml` for all oc-mirror --v2 operations:
  - 🚀 First run initial mirroring
  - 🔄 Subsequent runs and updates  
  - ➕ Adding new operators
  - 🆙 New versions of OpenShift
  - ➖ Removing operators
  - 🖼️ Adding and removing additional images
- ✅ Always use the latest oc-mirror v2 (regardless of the OpenShift Version)
- ✅ Never run as ROOT user
- ✅ Bastion host must be persistent (maintain `.cache` and `.history` directory)
- ✅ Secure transfer method between hosts (SCP/rsync,blueray)
- ✅ Use fully qualified hostnames

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
git clone git@github.com:RedHatGov/ocp.git & cd ocp

# Collect OpenShift tools (includes oc-mirror v2)
./collect_ocp

# Create container config directory
mkdir -p ~/.config/containers

# Create and Paste your pull secret content into this auth.json file
vi ~/.config/containers/auth.json
```

### **Step 2: m2d Flow - Mirror to Disk**

**📦 Create Portable Archives on Bastion**

```bash
# oc-mirror --v2 will create the content as defined in your imageset-config.yaml
# Edit imageset-config.yaml for your requirements
cd oc-mirror

# Run mirror-to-disk operation
./mirror-to-disk.sh

# Verify archive creation
ls -la content/

# Create a backup copy of your imageset-config.yaml with the YYYY-MM-DD in content/ 
cp imageset-config.yaml content/imageset-config-$(date +%F).yaml
```

### **Step 3: Transfer to Registry Host**

**🚚 Secure Archive Transfer**

```bash
# Transfer all content in the ocp directory to registry host
# Excluding the ocp/oc-mirror/content/working-dir
cd ~

rsync -av --progress \ 
  -e "ssh -i ~/.ssh/kevin" \
  --exclude 'oc-mirror/content/working-dir' \
  ./ocp/ \
  ec2-user@registry.sandbox762.opentlc.com:~/ocp/
```

### **Step 4: Registry Host Setup**

**🔧 Install Required Tools and configure**

```bash
# Set the hostname (replace XXX with your sandbox number)
sudo hostnamectl hostname registry.sandboxXXX.opentlc.com

# Install base requirements
sudo dnf install -y podman git

# Install ocp binaries into your path
cd ocp/downloads/ & ./install.sh

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
# On registry host - load mirrored content
oc-mirror --v2 --from file://./mirror-archive docker://registry-host:8443

# Verify content loaded
oc-mirror list --config imageset-config.yaml docker://registry-host:8443
```

---

