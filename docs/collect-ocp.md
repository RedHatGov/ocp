# 🛠️ collect_ocp - OpenShift Tool Collection Guide

**Your Complete Guide to Collecting and Installing OpenShift Tools**

A streamlined script that downloads, extracts, and installs all required OpenShift tools for both connected and disconnected environments in one simple command.

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

> 🎯 **Tip:** Use version-specific downloads for production deployments to ensure consistency and repeatability.


