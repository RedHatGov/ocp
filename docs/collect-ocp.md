# 🛠️ collect_ocp - OpenShift Tool Collection Guide

**Your Complete Guide to Collecting and Installing OpenShift Tools**

A streamlined 66-line script that downloads, extracts, and installs all required OpenShift tools for both connected and disconnected environments in one simple command.

---

## 📋 Requirements and Assumptions

### **🔑 Key Features**

- ✅ **Simple 66-line script** - dramatically simplified from legacy versions
- ✅ **All-in-one operation** - downloads, extracts, and installs automatically
- ✅ **Version-aware naming** - creates `openshift-install-linux-4.19.2.tar.gz`
- ✅ **Immediate installation** - installs tools to `/usr/local/bin/` on connected system
- ✅ **Disconnected-ready** - creates portable `downloads/` directory
- ✅ **Self-contained installer** - `install.sh` for air-gapped systems
- ✅ **Mirror registry included** - complete package for registry setup

### **✅ What You'll Accomplish**

- 🔧 **One-command tool collection** with automatic installation
- 📦 **Complete downloads package** ready for air-gapped transfer
- 🚀 **Immediate tool availability** on connected systems
- 🎯 **Version-specific OpenShift installer** with latest stable tools
- 📁 **Organized structure** in `downloads/` directory

### **🛡️ System Requirements**

- **Linux system** with bash, curl, tar
- **Internet access** for downloading (connected phase)
- **sudo access** for installing to `/usr/local/bin/`
- **Storage:** ~1GB for downloads

---

### **📋 Step 1: Configure Version (Optional)**

#### **🎯 Choose Your OpenShift Version**

The script is pre-configured with OpenShift 4.19.2. To use a different version, edit the script:

```bash
# Edit the collect_ocp script
vi collect_ocp
```

**Current Configuration:**
```bash
# Line 14 in collect_ocp
OPENSHIFT_VERSION="4.19.2"  # Currently set version
```

**Version Options:**

**For Latest Stable Release:**
```bash
# Change line 14 to:
OPENSHIFT_VERSION="stable"  # For latest stable release
```

**For Different Specific Version:**
```bash  
# Change line 14 to:
OPENSHIFT_VERSION="4.19.3"  # For different specific version
```

> 📝 **Note:** The script downloads `oc`, `oc-mirror`, and `butane` from the latest stable release, only `openshift-install` uses the specified version.

### **🚀 Step 2: Execute Tool Collection and Installation**

#### **▶️ Run the Collection Script**

```bash
# Execute the collection and installation script
./collect_ocp
```

**What it does automatically:**
- ✅ **Downloads** all required OpenShift tools from official mirrors
- ✅ **Extracts** all archives and organizes binaries
- ✅ **Installs** tools immediately to `/usr/local/bin/` (requires sudo)
- ✅ **Creates** portable `downloads/` directory for air-gapped systems
- ✅ **Generates** `install.sh` script for disconnected installations

**Expected Output:**
```
=== Downloading OpenShift Tools (version: 4.19.2) ===
Downloading oc-mirror...
Downloading openshift-client...
Downloading butane...
Downloading mirror-registry...
Downloading openshift-install (version: 4.19.2)...
=== Extracting Archives ===
=== Installing to PATH (Connected System) ===
Installing oc-mirror...
Installing oc...
Installing openshift-install...
Installing butane...
Setting permissions...

=== Installation Complete ===
Installed tools:
  • oc-mirror
  • oc
  • openshift-install
  • butane

💡 For disconnected systems:
   1. Copy the entire 'downloads/' directory to your air-gapped environment
   2. cd downloads && ./install.sh
```

#### **📁 Generated Directory Structure**

After execution, you'll have:

```
downloads/
├── install.sh*                              # Self-contained installer for air-gapped
├── mirror-registry/                         # Complete mirror registry package
│   ├── mirror-registry*                     # Registry installer binary
│   ├── execution-environment.tar           # Container runtime
│   ├── image-archive.tar                    # Registry images
│   └── sqlite3.tar                          # Database components
├── openshift-install-linux-4.19.2.tar.gz   # Version-stamped installer archive
├── oc-mirror.tar.gz                         # Content mirroring tool archive
├── openshift-client-linux.tar.gz           # OpenShift CLI archive
├── mirror-registry-amd64.tar.gz             # Mirror registry archive
├── butane*                                  # Config generator (extracted)
├── oc*                                      # OpenShift CLI (extracted)
├── oc-mirror*                               # Content mirroring tool (extracted)
└── openshift-install*                       # Installer (extracted)
```

> ✅ **Connected System:** Tools are already installed to `/usr/local/bin/` and ready to use!

> 📦 **Air-Gapped Ready:** The entire `downloads/` directory can be transferred to disconnected systems.

### **🔄 Step 3: Air-Gapped System Workflow**

#### **📤 Connected System (Already Complete)**

✅ **Tools are already installed** on the connected system after running `./collect_ocp`

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
# Create compressed archive for easier transfer
tar -czf openshift-tools.tar.gz downloads/
# Transfer the archive, then extract on air-gapped system:
# tar -xzf openshift-tools.tar.gz
```

#### **📥 Air-Gapped System Installation**

```bash
# On air-gapped system, navigate to downloads directory
cd downloads/

# Run the self-contained installer
./install.sh
```

**The install.sh script will:**
- ✅ Install `oc-mirror` to `/usr/local/bin/`
- ✅ Install `oc` to `/usr/local/bin/`  
- ✅ Install `openshift-install` to `/usr/local/bin/`
- ✅ Install `butane` to `/usr/local/bin/`
- ✅ Set proper permissions on all binaries
- ✅ Provide verification commands

> 📝 **That's it!** All tools are now installed and ready to use on the air-gapped system.

### **✅ Step 3: Verification**

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

## 🆚 Script Design Philosophy

### **Streamlined vs. Legacy Approach**

| Feature | Legacy Scripts | Current `collect_ocp` |
|---------|----------------|----------------------|
| **Lines of code** | 567+ lines | 66 lines (88% reduction) |
| **Complexity** | Multiple scripts/phases | Single script execution |
| **Version management** | Complex logic | Simple variable: `OPENSHIFT_VERSION="4.19.2"` |
| **Installation** | Manual steps | Automatic on connected system |
| **File organization** | Scattered | Clean `downloads/` structure |
| **Disconnected support** | Manual process | Ready-to-go `install.sh` |
| **Maintenance** | Complex debugging | Simple troubleshooting |

### **🎯 Design Advantages**

- ✅ **One-command simplicity** - `./collect_ocp` does everything
- ✅ **Immediate availability** - tools installed on connected system
- ✅ **Air-gap ready** - complete `downloads/` package created
- ✅ **Version consistency** - OpenShift installer matches specified version
- ✅ **Latest tools** - `oc`, `oc-mirror`, `butane` always from stable
- ✅ **Self-documenting** - clear output and built-in guidance

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

### **🔄 Updating to Newer Versions**

**To update to a newer version:**

```bash
# Edit the version in the script
vi collect_ocp
# Change line 14: OPENSHIFT_VERSION="4.19.3"

# Re-run collection (will overwrite downloads/)
./collect_ocp

# Transfer and install on disconnected systems
cd downloads/ && ./install.sh
```

### **📦 Managing Multiple Versions**

**For keeping multiple versions:**

```bash
# Backup current downloads before collecting new version
mv downloads downloads-4.19.2

# Update script and collect new version
vi collect_ocp  # Change to OPENSHIFT_VERSION="4.19.3"
./collect_ocp   # Creates new downloads/ directory

# Now you have both:
# downloads-4.19.2/  (previous version)
# downloads/          (current version)
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

**Error:** Specified version doesn't exist (e.g., `curl: (22) The requested URL returned error: 404`)

**Solution:**
```bash
# Check available versions
curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/ | grep -o '4\.[0-9]*\.[0-9]*' | sort -V

# Edit the script to use "stable" for latest or valid version
vi collect_ocp
# Change line 14 to: OPENSHIFT_VERSION="stable"
```

### **🔍 Diagnostic Commands**

Useful commands for troubleshooting the collect_ocp script:

```bash
# Check script configuration
head -20 collect_ocp | grep OPENSHIFT_VERSION

# Verify downloads directory structure after execution
ls -la downloads/

# Check if tools are installed on connected system
which oc openshift-install oc-mirror butane

# Test tool versions
oc version 2>/dev/null || echo "oc not found in PATH"
openshift-install version 2>/dev/null || echo "openshift-install not found in PATH"

# Check download archives exist
ls -la downloads/*.tar.gz

# Verify install.sh exists and is executable
ls -la downloads/install.sh

# Test mirror-registry components
ls -la downloads/mirror-registry/
```

### **🚨 Recovery Procedures**

If collection fails or downloads are corrupted:

```bash
# Clean up and start fresh
rm -rf downloads/

# Re-run collection
./collect_ocp

# If install.sh fails on disconnected system, check sudo access
sudo -v
sudo ls -la /usr/local/bin/

# Alternative: Install to user directory instead
mkdir -p ~/bin
export PATH="$HOME/bin:$PATH"
cd downloads/
cp oc oc-mirror openshift-install butane ~/bin/
```

---

## 🚀 Quick Start Example

**Ready to collect and install OpenShift tools? Here's the complete workflow:**

```bash
# 1. (Optional) Configure version if different from 4.19.2
# vi collect_ocp  # Edit OPENSHIFT_VERSION="4.19.2" if needed

# 2. Execute collection and installation (one command!)
./collect_ocp

# 3. Verify tools are installed on connected system
oc version
openshift-install version
oc-mirror --help

# 4. For air-gapped systems, transfer downloads directory
scp -r downloads/ user@disconnected-host:/path/
# OR create archive:
# tar -czf ocp-tools.tar.gz downloads/

# 5. Install on disconnected system
cd downloads/
./install.sh

# 6. Verify installation on air-gapped system
oc version
openshift-install version
```

### **🎯 Why Use This Streamlined Script?**

- ✅ **One command does it all** - download, extract, install
- ✅ **Immediate productivity** - tools ready on connected system
- ✅ **Air-gap optimized** - complete portable package
- ✅ **Version control** - OpenShift installer matches your needs
- ✅ **Latest tools** - always get current oc, oc-mirror, butane
- ✅ **Minimal complexity** - 66 lines of clear, maintainable code

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
