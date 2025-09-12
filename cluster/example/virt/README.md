# 🖥️ OpenShift Virtualization Setup Guide

**Complete Configuration for OpenShift Virtualization with Windows VM Templates**

This comprehensive guide walks you through installing and configuring OpenShift Virtualization (CNV) in disconnected environments, including the creation of Windows Server 2025 VM templates and bootable volumes.

---

## 📋 Requirements and Assumptions

### **🔑 Key Assumptions**

- ✅ **OpenShift Virtualization operators** already mirrored in disconnected environment
- ✅ **RHEL 8, 9, and 10 base images** available for ImageStreams
- ✅ **Windows Server installation media** (ISO files) accessible
- ✅ **Sufficient cluster resources** for virtualization workloads
- ✅ **Storage provisioner** configured for persistent volumes
- ✅ **Administrative access** to OpenShift cluster

### **✅ What You'll Accomplish**

- 🚀 **Complete OpenShift Virtualization** deployment
- 🖼️ **RHEL ImageStream integration** with mirrored images
- 💿 **Windows Server 2025 template** creation and configuration
- 📦 **Bootable volume management** for VM deployment
- ⚙️ **VM template optimization** with sysprep integration
- 🔄 **Template update workflows** for maintenance

### **🛡️ System Requirements**

- **OpenShift 4.12+** with virtualization support
- **Bare metal or nested virtualization** capable infrastructure
- **Container storage** for VM disks and images
- **Network connectivity** for VM access
- **Windows Server licensing** for template creation

---

### **🔧 Step 1: Configure Image Mirror Sets**

#### **📋 Set Up RHEL Image Mirroring**

**Create ImageTagMirrorSet for RHEL base images:**

```yaml
# Apply RHEL ImageTagMirrorSet
apiVersion: config.openshift.io/v1
kind: ImageTagMirrorSet
metadata:
  name: itms-rhel-images
spec:
  imageTagMirrors:
  - mirrors:
    - $(hostname):8443/rhel8
    source: registry.redhat.io/rhel8
  - mirrors:
    - $(hostname):8443/rhel9
    source: registry.redhat.io/rhel9
  - mirrors:
    - $(hostname):8443/rhel10
    source: registry.redhat.io/rhel10
```

**Create ImageDigestMirrorSet for digest-based references:**

```yaml
---
apiVersion: config.openshift.io/v1
kind: ImageDigestMirrorSet
metadata:
  name: idms-rhel-images
spec:
  imageDigestMirrors:
  - mirrors:
    - $(hostname):8443/rhel8
    source: registry.redhat.io/rhel8
  - mirrors:
    - $(hostname):8443/rhel9
    source: registry.redhat.io/rhel9
  - mirrors:
    - $(hostname):8443/rhel10
    source: registry.redhat.io/rhel10
```

**Apply the configurations:**

```bash
# Apply the image mirror configurations
oc apply -f image-mirror-sets.yaml

# Verify the mirror sets are created
oc get imagetagmirrorset
oc get imagedigestmirrorset
```

### **🚀 Step 2: Install OpenShift Virtualization**

#### **📦 Deploy Virtualization Operator**

```bash
# Install the OpenShift Virtualization operator
# Navigate to: Operators → OperatorHub → Search "OpenShift Virtualization"
# Install with default settings

# Verify operator installation
oc get csv -n openshift-cnv
```

#### **⚙️ Configure HyperConverged Operator**

```bash
# Create HyperConverged resource (without CommonImageTemplates for disconnected)
oc apply -f - <<EOF
apiVersion: hco.kubevirt.io/v1beta1
kind: HyperConverged
metadata:
  name: kubevirt-hyperconverged
  namespace: openshift-cnv
spec:
  commonTemplatesNamespace: openshift
  featureGates:
    withHostPassthroughCPU: true
  # Disable CommonImageTemplates for disconnected environments
  commonImageTemplates: false
EOF
```

> 📝 **Note:** Setting `commonImageTemplates: false` prevents automatic template creation in disconnected environments.

### **💿 Step 3: Prepare Windows Installation Media**

#### **📥 Obtain Windows Server 2025 ISO**

**Download from Microsoft Evaluation Center:**
- [Windows Server 2025 Evaluation](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2025)

#### **📤 Upload ISO to OpenShift**

**Method 1: Web Console Upload**

1. **Navigate to Storage:**
   - Go to **Storage → PersistentVolumeClaims**
   - Select Project: `openshift-virtualization-os-images`

2. **Create PVC with Data Upload:**
   - Click **Create PersistentVolumeClaim**
   - Select **With Data upload form**
   - Choose **Upload** and select your ISO file
   - **PVC Name:** `win2k25.iso`
   - Click **Upload**

**Method 2: Using virtctl (Alternative)**

```bash
# Upload ISO using virtctl
virtctl image-upload pvc win2k25.iso \
  --size=6Gi \
  --image-path=/path/to/windows-server-2025.iso \
  --namespace openshift-virtualization-os-images
```

### **🖥️ Step 4: Create Windows VM Template**

#### **🏗️ Deploy Base Windows VM**

```bash
# Navigate to: Virtualization → Catalog → Template Catalog
# Select "Microsoft Windows Server 2025 VM"
```

**Configuration Parameters:**

| Setting | Value | Purpose |
|---------|--------|---------|
| **Project** | `openshift-virtualization-os-images` | Template storage location |
| **CPU** | 4 cores | Adequate for installation |
| **Memory** | 8 GB | Recommended minimum |
| **Boot Source** | CD-ROM | Windows ISO installation |
| **CD Source** | PVC (clone) | Use uploaded ISO |
| **PVC Project** | `openshift-virtualization-os-images` | ISO location |
| **PVC Name** | `win2k25.iso` | Windows installation media |
| **Disk Source** | Blank | New VM disk |
| **VM Name** | `win2k25-template` | Template identifier |

#### **📋 Complete Windows Installation**

```bash
# Monitor VM startup
oc get vm win2k25-template -n openshift-virtualization-os-images

# Access VM console
# Navigate to: Virtualization → VirtualMachines → win2k25-template → Console
```

**Installation Steps:**

1. **Boot from CD:** VM will boot from the Windows ISO
2. **Complete Windows Setup:** Follow standard Windows Server installation
3. **Install VirtIO Drivers:**
   - Navigate to **D:\** drive in VM
   - Run **virtio-win-guest-tools.exe**
   - **Restart** the VM after installation

### **⚙️ Step 5: Generalize Windows Template**

#### **🔄 Run Sysprep for Template Creation**

**Access VM and run sysprep:**

```cmd
# Open Command Prompt as Administrator
cmd

# Navigate to sysprep directory
cd c:\windows\system32\sysprep\

# Run sysprep with OOBE settings
sysprep.exe
```

**Sysprep Configuration:**
- ✅ **Enter System Out-of-Box Experience (OOBE)**
- ✅ **Check "Generalize"**
- ✅ **Shutdown** (not restart)

> ⚠️ **Important:** Always select "Shutdown" option to preserve the generalized state.

#### **🧹 Clean Up VM Configuration**

**Remove installation media and drivers disk:**

```bash
# Navigate to VM configuration
# Virtualization → VirtualMachines → win2k25-template → Configuration → Storage

# Remove unnecessary disks:
# 1. Uncheck "Mount Windows drivers disk"  
# 2. Click ellipse (⋯) → installation-cdrom → Detach
```

### **📦 Step 6: Create Bootable Volume**

#### **💾 Save Template Disk as Bootable Volume**

**Method 1: From VM Storage Configuration**

```bash
# Navigate to: Virtualization → VirtualMachines → win2k25-template
# Go to: Configuration → Storage → rootdisk → ellipse (⋯)
# Click: "Save as bootable volume"

# Configure bootable volume:
# - Volume Name: win2k25-template
# - VM Class Profile: windows.2k25.virtio
# - VM Class Instance: u1.large
```

**Method 2: Using Catalog Add Volume**

```bash
# Navigate to: Virtualization → Catalog → "Add volume"
# Select: "Use existing Volume"
# Project: openshift-virtualization-os-images
# Volume: Select the template rootdisk volume
```

### **🚀 Step 7: Deploy VM from Template**

#### **📋 Create New VM Instance**

```bash
# Navigate to: Virtualization → Catalog
# Create new project or select existing project
```

**VM Deployment Configuration:**

| Setting | Value | Purpose |
|---------|--------|---------|
| **Project** | `win-vm-1` (or create new) | VM deployment location |
| **Template** | `win2k25-template-rootdisk` | Bootable volume template |
| **Instance Type** | U series (2 CPU, 8GB RAM) | Resource allocation |
| **VM Name** | `windows-2k25-1` | Instance identifier |

```bash
# Monitor VM deployment
oc get vm windows-2k25-1 -n win-vm-1

# Access new VM console once running
# The VM will boot to Windows OOBE setup screen
```

---

## 🔄 Template Management and Updates

### **🛠️ Updating Existing Templates**

**Challenge:** Templates cannot be directly replaced after creation.

**Recommended Workflow:**

1. **Create Updated Base VM:**
   ```bash
   # Power on the original template VM
   oc patch vm win2k25-template -n openshift-virtualization-os-images \
     --type merge --patch '{"spec":{"running":true}}'
   ```

2. **Apply Updates:**
   - Install Windows updates
   - Configure additional software
   - Apply security patches

3. **Prepare for Re-generalization:**
   ```cmd
   # Required registry cleanup for multiple sysprep runs
   reg delete "HKLM\System\Setup\Status\SysprepStatus" /f
   ```

4. **Create New Template Version:**
   - Follow sysprep process again
   - Create new bootable volume with version identifier
   - Test deployment before removing old template

### **📊 Template Versioning Strategy**

**Recommended naming convention:**
- `win2k25-v1` - Initial template
- `win2k25-v2` - First update (patches, software)
- `win2k25-latest` - Alias for current version

---

## ✅ Verification and Testing

### **🔍 Verify OpenShift Virtualization Installation**

```bash
# Check HyperConverged operator status
oc get hco -n openshift-cnv

# Verify all CNV pods are running
oc get pods -n openshift-cnv

# Check available VM templates
oc get templates -n openshift

# List available bootable volumes
oc get datavolume -n openshift-virtualization-os-images
```

### **🧪 Test VM Deployment**

```bash
# Deploy test VM from template
# Follow Step 7 deployment process

# Verify VM boots successfully
oc get vm -A

# Check VM console accessibility
# Navigate to: Virtualization → VirtualMachines → [VM] → Console
```

---

## 🔧 Troubleshooting

### **❌ Common Issues**

#### **1. Template VM Won't Boot**

```bash
# Check VM events
oc describe vm win2k25-template -n openshift-virtualization-os-images

# Verify storage connectivity
oc get pvc -n openshift-virtualization-os-images

# Check node virtualization support
oc get nodes -o jsonpath='{.items[*].status.allocatable.devices\.kubevirt\.io/kvm}'
```

#### **2. Sysprep Failures**

```cmd
# Check sysprep logs in Windows
C:\Windows\System32\Sysprep\Panther\setuperr.log

# Reset sysprep status if needed
reg delete "HKLM\System\Setup\Status\SysprepStatus" /f
```

#### **3. VirtIO Driver Issues**

```bash
# Ensure drivers are available in VM
# Download latest VirtIO drivers ISO
# Mount as additional CD-ROM in VM configuration
```

---

## 🎯 Best Practices

### **📋 Template Creation Guidelines**

- ✅ **Always run sysprep** for Windows templates
- ✅ **Install VirtIO drivers** before generalization  
- ✅ **Remove installation media** before template creation
- ✅ **Test templates** thoroughly before production use
- ✅ **Version your templates** for tracking changes
- ✅ **Document customizations** made to base images

### **🛡️ Security Considerations**

- ✅ **Apply security updates** to template before generalization
- ✅ **Use least-privilege** accounts for VM access
- ✅ **Enable Windows firewall** in templates
- ✅ **Disable unnecessary services** in base template
- ✅ **Configure proper network policies** for VM traffic

---

## 📈 Integration with OpenShift

### **🔗 Integration Points**

- **Storage Classes:** Use appropriate storage for VM performance
- **Network Policies:** Secure VM-to-VM and VM-to-pod communication  
- **Resource Quotas:** Control VM resource consumption
- **RBAC:** Manage user access to virtualization resources
- **Monitoring:** Integrate with OpenShift monitoring stack

### **🚀 Next Steps**

1. **Scale VM Deployments** using tested templates
2. **Implement Backup Strategy** for critical VMs
3. **Configure Network Policies** for security
4. **Set up Monitoring** for VM resource usage
5. **Integrate with GitOps** for VM lifecycle management

---

> 📝 **Next Steps:** After template creation, consider implementing automated VM provisioning workflows and integrating with OpenShift's resource management capabilities.

**📖 References:**
- [OpenShift Virtualization Documentation](https://docs.openshift.com/container-platform/latest/virt/about-virt.html)
- [Windows VM Templates Best Practices](https://docs.openshift.com/container-platform/latest/virt/virtual_machines/creating_vms_rh/virt-creating-vms-from-templates.html)
- [VirtIO Drivers Documentation](https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/)