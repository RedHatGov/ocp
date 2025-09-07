# 🛠️ collect_ocp - OpenShift Tool Collection Guide

**Your Complete Guide to Collecting OpenShift Tools for Disconnected Environments**

A simplified tool collection script for OpenShift disconnected installations that downloads, organizes, and prepares all required OpenShift tools for air-gapped deployments.

---

## 📋 Requirements and Assumptions

### **🔑 Key Features**

- ✅ Downloads all required OpenShift tools automatically
- ✅ Installs tools to system PATH (`/usr/local/bin/`)
- ✅ Creates versioned filenames (e.g., `openshift-install-linux-4.19.2.tar.gz`)
- ✅ Organizes everything in `downloads/` directory
- ✅ Creates `downloads/install.sh` for disconnected systems
- ✅ Simple version management with single variable
- ✅ 88% code reduction compared to legacy scripts

### **✅ What You'll Accomplish**

- 🔧 **Automated tool collection** for OpenShift installations
- 📦 **Organized download structure** ready for transfer
- 🚀 **Self-contained installer** for air-gapped systems
- 🎯 **Version-specific downloads** or latest stable
- 📁 **Clean directory structure** for easy management

### **🛡️ System Requirements**

- **Linux system** with bash, curl, tar
- **Internet access** for downloading (connected phase)
- **sudo access** for installing to `/usr/local/bin/`
- **Storage:** ~1GB for downloads

---

### **📋 Step 1: Configure Version Selection**

#### **🎯 Choose Your OpenShift Version**

Edit the version in the script to match your requirements:

```bash
# Edit the collect_ocp script
vi collect_ocp
```

**Version Options:**

**For Latest Stable Release:**
```bash
# Edit line 14 in collect_ocp
OPENSHIFT_VERSION="stable"  # For latest stable release
```

**For Specific Version:**
```bash  
# Edit line 14 in collect_ocp
OPENSHIFT_VERSION="4.19.2"  # For specific version
```

#### **🔍 Version Examples**

**Latest Stable:**
```bash
OPENSHIFT_VERSION="stable"
./collect_ocp
# Creates: openshift-install-linux-stable.tar.gz
# Installs: Current stable version (e.g., 4.19.7)
```

**Specific Version:**
```bash
OPENSHIFT_VERSION="4.19.2"
./collect_ocp
# Creates: openshift-install-linux-4.19.2.tar.gz  
# Installs: Exact version 4.19.2
```

### **🚀 Step 2: Execute Tool Collection**

#### **▶️ Run the Collection Script**

```bash
# Execute the collection script
./collect_ocp
```

**What it does:**
- ✅ Downloads all required OpenShift tools
- ✅ Extracts and organizes binaries
- ✅ Creates version-stamped archives
- ✅ Generates self-contained installer
- ✅ Prepares for disconnected transfer

#### **📁 Generated Directory Structure**

After execution, you'll have:

```
downloads/
├── install.sh*                              # Self-contained installer
├── mirror-registry/                         # Mirror registry components
├── openshift-install-linux-[VERSION].tar.gz # Version-stamped installer
├── oc-mirror.tar.gz                         # Content mirroring tool
├── openshift-client-linux.tar.gz           # OpenShift CLI
├── butane-amd64                            # Config generator
└── [extracted binaries]*                   # Ready to install
```

### **🔄 Step 3: Disconnected Workflow**

#### **📤 Connected System (Internet Access)**

```bash
# On system with internet access
./collect_ocp
```

#### **🚚 Transfer to Air-Gapped System**

**Option A: SCP Transfer**
```bash
# Copy entire downloads directory
scp -r downloads/ user@airgapped-host:/path/
```

**Option B: USB/Removable Media**
```bash
# Copy to removable media
rsync -av downloads/ /media/usb-drive/
```

**Option C: Archive Transfer**
```bash
# Create compressed archive
tar -czf openshift-tools.tar.gz downloads/
```

#### **📥 Air-Gapped System Installation**

```bash
# On air-gapped system
cd downloads
./install.sh
```

> 📝 **That's it!** All tools are now installed and ready to use.

### **✅ Step 4: Verification**

#### **🔍 Verify Tool Installation**

After installation, verify all tools work correctly:

```bash
# Check OpenShift client
oc version

# Check OpenShift installer
openshift-install version

# Check oc-mirror tool
oc-mirror --help

# Check Butane config tool  
butane --help
```

**Expected Output Example:**
```
Client Version: 4.19.2
Kubernetes Version: v1.32.0

openshift-install 4.19.2
built from commit abc123def456789
release image quay.io/openshift-release-dev/ocp-release:4.19.2-x86_64
```

#### **📊 Installation Summary**

```bash
# Check installed tools location
ls -la /usr/local/bin/ | grep -E "(oc|openshift-install|butane)"

# Verify downloads directory
ls -la downloads/
```

---

## 🆚 Script Comparison

### **New vs. Legacy collect_ocp**

| Feature | Old `collect_ocp` | New `collect_ocp` |
|---------|-------------------|-------------------|
| **Lines of code** | 567 lines | 65 lines (88% reduction) |
| **Version support** | Complex logic | Simple `OPENSHIFT_VERSION="4.19.2"` |
| **File naming** | Generic | Version-stamped |
| **Organization** | Scattered | All in `downloads/` |
| **Disconnected support** | Manual | Automatic `install.sh` |
| **Maintenance** | Complex | Simple |

### **🎯 Advantages of New Script**

- ✅ **Simplified maintenance** with minimal code
- ✅ **Clear version control** with single variable
- ✅ **Better organization** with structured output
- ✅ **Enhanced disconnected support** with auto-installer
- ✅ **Version tracking** with stamped filenames
- ✅ **Reduced complexity** for better reliability

---

## 🔧 Advanced Usage

### **🎛️ Custom Configuration**

**For specific use cases, you can modify the script:**

```bash
# Edit collect_ocp for custom requirements
vi collect_ocp

# Example modifications:
# - Change download directory
# - Add additional tools  
# - Modify installation path
# - Configure proxy settings
```

### **🔄 Updating Existing Installation**

**To update to a newer version:**

```bash
# Update version in script
OPENSHIFT_VERSION="4.19.3"

# Re-run collection
./collect_ocp

# Transfer and install on disconnected systems
cd downloads && ./install.sh
```

### **📦 Batch Processing**

**For managing multiple versions:**

```bash
# Collect multiple versions
for version in "4.19.2" "4.19.3" "4.19.7"; do
  sed -i "s/OPENSHIFT_VERSION=.*/OPENSHIFT_VERSION=\"$version\"/" collect_ocp
  ./collect_ocp
  mv downloads downloads-$version
done
```

---

## 🔧 Troubleshooting

### **❌ Common Issues**

#### **1. Download Failures**

**Error:** Network or download issues

**Solution:**
```bash
# Check network connectivity
curl -I https://mirror.openshift.com/

# Verify DNS resolution
nslookup mirror.openshift.com

# Check proxy settings if applicable
echo $HTTP_PROXY $HTTPS_PROXY
```

#### **2. Permission Errors**

**Error:** Cannot install to `/usr/local/bin/`

**Solution:**
```bash
# Ensure sudo access
sudo -v

# Check directory permissions
ls -la /usr/local/bin/

# Alternative: Install to user directory
mkdir -p ~/bin
export PATH="$HOME/bin:$PATH"
```

#### **3. Storage Issues**

**Error:** Insufficient disk space

**Solution:**
```bash
# Check available space
df -h .

# Clean up old downloads if needed
rm -rf downloads/

# Use alternative directory with more space
mkdir /tmp/ocp-downloads
cd /tmp/ocp-downloads
```

#### **4. Version Not Found**

**Error:** Specified version doesn't exist

**Solution:**
```bash
# Check available versions
curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/ | grep -o '4\.[0-9]*\.[0-9]*' | sort -V

# Use "stable" for latest
OPENSHIFT_VERSION="stable"
```

---

## 🚀 Quick Start Example

**Ready to collect OpenShift tools? Here's the complete workflow:**

```bash
# 1. Configure version (edit script)
vi collect_ocp
# Set: OPENSHIFT_VERSION="4.19.2"

# 2. Execute collection
./collect_ocp

# 3. Verify downloads  
ls -la downloads/

# 4. Transfer to air-gapped system (choose method)
scp -r downloads/ user@disconnected-host:/path/
# OR
tar -czf ocp-tools.tar.gz downloads/

# 5. Install on disconnected system
cd downloads/
./install.sh

# 6. Verify installation
oc version
openshift-install version
```

### **🎯 Why Use This Tool?**

- ✅ **Simplified process** compared to manual downloads
- ✅ **Version consistency** across environments
- ✅ **Automated organization** reduces errors  
- ✅ **Disconnected-ready** output format
- ✅ **Self-contained installer** for air-gapped systems

```bash
echo "✅ OpenShift tools collected and ready for deployment!"
```

---

> 📝 **Best Practice:** Always test the collected tools in a non-production environment before deploying to production systems.

> 🎯 **Tip:** Use version-specific downloads for production deployments to ensure consistency and repeatability.

**📖 References:**
- [OpenShift Downloads](https://console.redhat.com/openshift/downloads)
- [OpenShift Installation Documentation](https://docs.openshift.com/container-platform/latest/installing/)
- [oc-mirror Documentation](https://docs.openshift.com/container-platform/latest/installing/disconnected_install/installing-mirroring-creating-registry.html)
