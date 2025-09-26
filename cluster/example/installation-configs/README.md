# 📁 OpenShift Installation Configurations

## 🙏 **Attribution & Source**

**The installation configuration examples in this directory are sourced from:**
- **Author:** Bill Strauss
- **Original Repository:** [bstrauss84/openshift-install-configs](https://github.com/bstrauss84/openshift-install-configs)
- **License:** Content provided as-is (see original repository for specific licensing)

**Full credit goes to Bill Strauss for creating and maintaining these comprehensive OpenShift installation configuration examples.**

## 📖 **Overview**

This directory contains documentation-accurate, heavily commented OpenShift installation configurations for:

### 🏗️ **Installation Methods:**
- **IPI (Installer Provisioned Infrastructure)** - Installer creates & controls infrastructure
- **UPI (User Provisioned Infrastructure)** - You provide infrastructure (LB, DNS, compute)  
- **Agent** - ISO/PXE-based flow with static/DHCP networking via NMState

### ☁️ **Platform Support:**
- **AWS** - Amazon Web Services cloud deployments
- **Bare Metal** - Physical server installations
- **vSphere** - VMware virtualization platform

### 🌐 **Network Configurations:**
- **Connected** - Standard internet-connected deployments
- **Proxied** - Deployments through corporate proxy servers
- **Disconnected** - Air-gapped/offline installations
- **FIPS** - Federal Information Processing Standards compliance
- **Multi-subnet** - Complex networking scenarios
- **Bonded interfaces** - Network redundancy configurations

## 🚀 **Usage**

Each scenario directory contains:
- `install-config.yaml` (and `agent-config.yaml` for Agent installations)
- `README.md` - Detailed usage instructions and field explanations
- `scenario.yaml` - Metadata for automation/tooling

### 💡 **Common Configuration Notes:**
- **SSH Public Key:** Provide your public key (not private!) - generate with `ssh-keygen -t ed25519`
- **Pull Secret:** Must be single-line JSON - use `jq -c . < pull-secret.json`
- **Base Domain:** Examples use `example.com` - replace with your actual domain
- **FIPS Installations:** Require FIPS-enabled RHEL 9 host and FIPS-enabled installer

## 🔗 **Additional Resources**

For the complete repository with utility configurations, networking examples, and oc-mirror ImageSet configurations, visit:
**https://github.com/bstrauss84/openshift-install-configs**

## 🔄 **Keeping Content Updated**

This directory contains a **vendor copy** of installation configurations from Bill Strauss's repository. To update with the latest configurations:

### **Manual Update Process:**
1. **Check for updates:** Visit [bstrauss84/openshift-install-configs](https://github.com/bstrauss84/openshift-install-configs)
2. **Review changes:** Compare with current content in this directory
3. **Selective updates:** Copy relevant new configurations or updates
4. **Test configurations:** Validate any new configurations in test environments
5. **Commit updates:** Document which configurations were updated and why

### **Update History:**
- **Initial import:** All installation-configs from bstrauss84/openshift-install-configs (commit: `2d332de`)
- **Future updates:** Document major updates here

> 💡 **Tip:** We use a vendor/copy approach rather than git submodules or subtrees to maintain full control over configuration stability and to integrate seamlessly with our repository structure.

## ⚠️ **Important Notes**

- Always refer to official OpenShift documentation for the latest requirements
- Test configurations in non-production environments first
- Modify example values (domains, networks, certificates) for your environment
- FIPS installations require specific host and installer versions

---

*These configurations are provided as educational examples. Always validate against current OpenShift documentation for production deployments.*
