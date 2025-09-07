# 🚀 OpenShift Cluster Upgrade Guide for Disconnected Environments

**Your Complete Guide to Upgrading OpenShift Clusters in Disconnected Environments**

This comprehensive guide walks you through upgrading a disconnected OpenShift cluster from **4.19.2 → 4.19.3** using content mirrored with our standardized `oc-mirror v2` workflow.

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
- ✅ Always create a backup of your imageset-config.yaml
- ✅ Always use the latest oc-mirror v2 (regardless of the OpenShift Version)
- ✅ Never run as ROOT user
- ✅ Bastion host must be persistent (maintain `.cache` and `.history` directory)

### **📋 Step 1: Pre-Upgrade Planning (Registry Node)**

**📖 Essential Reading:**
- [OCP Cluster Upgrade Graph](https://access.redhat.com/labs/ocpupgradegraph/update_path/) - Plan your upgrade path
- [OpenShift Updating Clusters](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/updating_clusters/index#updating-cluster-cli)
- [Disconnected Environment Updates](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/disconnected_environments/index#updating-disconnected-cluster)

#### **🔍 Verify Current Cluster State**

```bash
# Check current cluster version
oc get clusterversion
```

**Example Output:**
```
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.19.2    True        False         3d      Cluster version is 4.19.2
```

#### **🔄 Identify Current Release Channel**

```bash
# Check cluster update channel
oc get clusterversion version -o jsonpath='{.spec.channel}{"\n"}'

# Expected output: stable-4.19
```

### **🔄 Step 2: m2d Flow - Mirror to Disk - Latest Content**

**🔧 Update Installed Tools**

```bash
# Collect Latest OpenShift tools (includes oc-mirror v2)
./collect_ocp
```

#### **📁 Navigate to Mirror Directory**

```bash
cd ~/ocp/oc-mirror
```

#### **📋 Review Mirror Configuration**

```bash
# Check what content will be mirrored
cat imageset-config.yaml

# Check previous mirrored content
ls content/imageset-config*
```

**Modify the maxVersion to your upgrade version:**
```bash
vi imageset-config.yaml
```

```yaml
      maxVersion: 4.19.3
```

**📦 Create Portable Archives on Bastion**

```bash
# Run mirror-to-disk operation
./mirror-to-disk.sh

# Verify archive creation (Note: orginal tar files are replaced)
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

rsync -av --progress -e "ssh -i ~/.ssh/aws.pem" \
  --exclude 'oc-mirror/content/working-dir' \
  ./ocp/ \
  ec2-user@registry.sandbox3296.opentlc.com:~/ocp/
```
> 📝 **Critical:** You do not need to transfer the .cache to your disconnected host

> 📝 **Critical:** DO NOT overwrite your working-dir on your disconnected host

### **Step 5: d2m Flow - Disk to Mirror**


**🔧 Update Required Tools**

```bash
# Install ocp binaries into your path
cd ocp/downloads/ && ./install.sh
```

**📋 Load Archives into Registry**

```bash
# Inspect your imageset-config.yaml and the backup copy in /content.
# They should be identical. This is the content that you will load into the registry
# This will also create your custom catalog based on the operators in the imageset-config.yaml
cd ~/ocp/oc-mirror
cat imageset-config.yaml

# Run disk-to-mirror operation
./disk-to-mirror.sh

# If you get an error on 
[ERROR]  : [Executor] collection error: [GetReleaseReferenceImages] error list [APIRequestError: version 4.19.2 in channel stable-4.19: GraphDataInvalid: could not parse graph data content/working-dir/hold-release/cincinnati-graph-data/amd64-stable-4.19.json: invalid character '}' after top-level value]

# Clear out the graph history
rm -rf /home/ec2-user/ocp/oc-mirror/content/working-dir/hold-release/cincinnati-graph-data
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






















### **🔧 Step 3: Cluster Preparation**

#### **🔍 Verify Available Release Images**

**🔍 Check Mirror Registry:**
- Navigate to: `https://$(hostname):8443`
- Search for: `openshift/release-images`
- Verify **4.19.7** release image is available

**Alternative CLI Method:**
```bash
# List available release images
oc image info --filter-by-os linux/amd64 \
  $(hostname):8443/openshift/release-images:4.19.3-x86_64
```

#### **🛋 Validate Upgrade Path**

**Using Upgrade Graph:**
1. Visit: [OCP Upgrade Graph Tool](https://access.redhat.com/labs/ocpupgradegraph/update_path/)
2. Enter: **Source Version**: `4.19.2`, **Target Version**: `4.19.3`
3. Verify: Direct upgrade path is supported



**Verify Resources:**
```bash
# Check image digest mirror sets
oc get imageDigestMirrorSet

# Check image tag mirror sets  
oc get imageTagMirrorSet

# Verify catalog sources
oc get catalogsource -n openshift-marketplace
```

### **🚀 Step 4: Execute Upgrade**

#### **⏸️ Pause Machine Health Checks**

> ⚠️ **Important:** Pause MachineHealthCheck during upgrade to prevent node replacement. Refer to the [upgrade documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/updating_clusters/index#updating-cluster-cli) for detailed guidance.

```bash
# List machine health checks
oc get machinehealthcheck -n openshift-machine-api

# Pause all machine health checks
oc patch machinehealthcheck -n openshift-machine-api \
  --type merge --patch '{"spec":{"maxUnhealthy":"100%"}}'
```

#### **🎯 Get Target Release Image Digest**

```bash
# Get the exact image digest for 4.19.3
TARGET_IMAGE="$(hostname):8443/openshift/release-images:4.19.3-x86_64"

# Get image digest
IMAGE_DIGEST=$(oc image info "$TARGET_IMAGE" -o json | jq -r '.digest')
FULL_IMAGE="$TARGET_IMAGE@$IMAGE_DIGEST"

echo "Target image: $FULL_IMAGE"
```

#### **💥 Execute Cluster Upgrade**

```bash
# Start the cluster upgrade
echo "🚀 Starting cluster upgrade to 4.19.3..."

oc adm upgrade \
  --allow-explicit-upgrade \
  --force=true \
  --to-image="$FULL_IMAGE"

oc get clusterversion
```

#### **🔍 Monitor Upgrade Progress**

```bash
# Monitor cluster version status
watch -n 30 "oc get clusterversion"

# Monitor cluster operators
watch -n 30 "oc get co"

# Check upgrade progress details
oc describe clusterversion
watch -n 5 "oc describe clusterversion | grep '^ *Message:'"
```

**Monitor for:**
- `PROGRESSING: True` during upgrade
- `AVAILABLE: True` when complete
- All cluster operators should be `AVAILABLE: True`

### **✅ Step 5: Post-Upgrade Verification**

#### **🔍 Verify Cluster Version**

```bash
# Confirm new cluster version
oc get clusterversion

# Expected output shows 4.19.3
```

#### **⚙️ Apply Updated Mirror Configuration. This will replace your operator hub catalogs

```bash
# Apply updated IDMS/ITMS resources
cd ~/ocp/oc-mirror

# Apply all cluster resources
oc apply -f content/working-dir/cluster-resources/
```

#### **▶️ Resume Machine Health Checks**

> 📝 **Note:** Resume normal machine health check behavior after successful upgrade.

```bash
# Resume normal machine health check behavior
oc patch machinehealthcheck -n openshift-machine-api \
  --type merge --patch '{"spec":{"maxUnhealthy":"40%"}}'
```

#### **⚙️ Verify Cluster Operators**

```bash
# Check all cluster operators are healthy
oc get co

# All operators should show:
# AVAILABLE: True, PROGRESSING: False, DEGRADED: False
```

#### **📊 Check Operator Catalog Status**

```bash
# Verify operator catalogs are healthy
oc get catalogsource -n openshift-marketplace

# Check for any operator updates needed
```

**Web Console Verification:**
1. Navigate to: **Operators** → **Installed Operators**
2. Verify: All operators show successful upgrade status
3. Update: Any operators requiring manual updates


---

### **🎉 Upgrade Complete!**

**Your OpenShift cluster has been successfully upgraded!**

> 📝 **Next Steps:** Consider updating your documentation with the new cluster version and testing critical applications to ensure they function correctly with the upgraded platform.



