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
- ✅ Secure transfer method between hosts (SCP/rsync)

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

**🔧 Install Required Tools**

```bash
# Install base requirements
sudo dnf install -y podman git

# Clone this repository
git clone git@github.com:RedHatGov/ocp.git & cd ocp

# Collect OpenShift tools (includes oc-mirror v2)
./collect_ocp
```

### **Step 2: m2d Flow - Mirror to Disk**

**📦 Create Portable Archives on Bastion**

```bash
# Create imageset configuration
# Edit imageset-config.yaml for your requirements

# Run mirror-to-disk operation
oc-mirror --v2 --config imageset-config.yaml file://./mirror-archive

# Verify archive creation
ls -la mirror-archive/
```

### **Step 3: Transfer to Registry Host**

**🚚 Secure Archive Transfer**

```bash
# Transfer archive to registry host
scp -r mirror-archive/ ec2-user@registry-host:/tmp/

# Or use rsync for large transfers
rsync -avz --progress mirror-archive/ ec2-user@registry-host:/tmp/mirror-archive/
```

### **Step 4: Registry Host Setup**

**🏪 Deploy Mirror Registry**

```bash
# On registry host - install mirror-registry
./mirror-registry install --quayHostname registry-host

# Verify registry is running
curl -k https://$(hostname):8443/health/instance
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

