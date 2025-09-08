# 🗑️ OpenShift Image Deletion Guide for Disconnected Environments

**Your Complete Guide to Safely Removing Old OpenShift Images from Mirror Registries**

This comprehensive guide walks you through safely removing old OpenShift images (**4.19.2 → 4.19.6**) from your mirror registry after upgrading your cluster to **4.19.7+**, using our standardized `oc-mirror v2` deletion workflow.

---

## 📋 Requirements and Assumptions

### **🔑 Key Assumptions**

- ✅ Cluster should be **upgraded past** the versions you plan to delete
- ✅ Two-phase process: Generate plan → Review → Execute
- ✅ No accidental deletions: Must explicitly review and approve
- ✅ Preserves current versions: Only removes specified old versions


### **✅ What You'll Accomplish**

- 🔍 **Pre-deletion validation** of current registry and cluster state
- 📋 **Generate deletion plan** using our standardized script (safe preview)
- 👀 **Review generated plan** to verify what will be deleted
- 🗑️ **Execute controlled deletion** of old OpenShift versions
- ✅ **Post-deletion verification** of registry and cluster health


---

### **📋 Step 1: Pre-Deletion Planning**

#### **🔍 Verify Current Cluster Version**

First, confirm your cluster is running a version **newer** than what you plan to delete:

```bash
# Check current cluster version
oc get clusterversion

# Expected output: 4.19.7 (or later)
```

**Example Output:**
```
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.19.7    True        False         24h     Cluster version is 4.19.7
```

#### **📊 Inventory Registry Content**

Verify the versions you plan to delete actually exist in your registry:

```bash
# Check versions you plan to delete (adjust versions as needed)
oc adm release info $(hostname):8443/openshift/release-images:4.19.2-x86_64 2>/dev/null && echo "✅ 4.19.2 present" || echo "❌ 4.19.2 not found"
oc adm release info $(hostname):8443/openshift/release-images:4.19.3-x86_64 2>/dev/null && echo "✅ 4.19.3 present" || echo "❌ 4.19.3 not found"
```

> 💡 **Tip:** Only verify the versions you plan to delete. You can also use your web browser to review the inventory.

#### **📋 Review Deletion Configuration**

Verify your deletion configuration targets the correct versions:

```bash
# Review the deletion configuration
cat oc-mirror/imageset-delete.yaml
```

**Expected configuration:**
```yaml
apiVersion: mirror.openshift.io/v2alpha1
kind: DeleteImageSetConfiguration
delete:
  platform:
    channels:
    - name: stable-4.19
      minVersion: 4.19.2
      maxVersion: 4.19.2  # Only delete versions older than current 4.19.7
    graph: true
```

### **🔄 Step 2: Generate Deletion Plan**

#### **📁 Navigate to Working Directory**

```bash
# Navigate to the oc-mirror working directory
cd ~/ocp/oc-mirror
```

#### **🛠️ Execute Deletion Plan Generation**

Run our standardized deletion plan generation script:

```bash
# Generate deletion plan (SAFE - no actual deletions occur)
./delete-generate.sh
```

### **👀 Step 3: Review Deletion Plan**

#### **📋 Examine Generated Deletion Plan**

> ⚠️ **CRITICAL SAFETY STEP:** Review the generated deletion plan before executing!

```bash
# Review the deletion plan
cat content/working-dir/delete/delete-images.yaml
```

#### **🔍 Understand the Deletion Plan Format**

The generated plan will contain:
- **Manifests to delete:** Specific image manifests with SHA256 digests
- **Registry locations:** Exact paths in your registry  
- **Release versions:** Confirm it targets 4.19.2-4.19.6 only

#### **✅ Verify Target Versions**

Look for entries like:
```yaml
# Expected entries in deletion plan
- image: $(hostname):8443/openshift/release-images@sha256:...
# Should target versions 4.19.2, 4.19.3, 4.19.4, 4.19.5, 4.19.6
```

#### **🛡️ Confirm Preservation of Current Version**

**Verify that 4.19.7 (your current cluster version) is NOT listed for deletion:**

```bash
# This should return NO results (4.19.7 should be preserved)
grep -i "4.19.3\|4.19.8\|4.19.9\|4.19.10" content/working-dir/delete/delete-images.yaml || echo "✅ Current versions are preserved"
```

#### **📊 Estimate Deletion Impact**

Count the number of images to be deleted:

```bash
# Count images in deletion plan
grep -c "image:" content/working-dir/delete/delete-images.yaml
echo "images will be deleted from the registry"
```

### **💥 Step 4: Execute Deletion**

#### **📋 Final Pre-Execution Checklist**

Before executing the deletion:

- ✅ **Reviewed deletion plan** thoroughly
- ✅ **Confirmed target versions** are correct
- ✅ **Verified current version preservation**
- ✅ **Have registry credentials** and permissions
- ✅ **Cluster is healthy** and upgraded

#### **🚀 Execute Deletion with Script**

Use our standardized deletion execution script:

```bash
# Execute deletion (requires confirmation)
./delete-execute.sh
```

**Manual execution command:**
```bash
# Execute deletion using generated plan
oc mirror delete \
  --delete-yaml-file content/working-dir/delete/delete-images.yaml \
  docker://$(hostname):8443 \
  --v2 \
  --cache-dir .cache
```

### **✅ Step 5: Post-Deletion Verification**

#### **🔍 Verify Deleted Versions Are Gone**

Test that the deleted versions are no longer accessible:

```bash
# These should now fail (versions deleted)
echo "🔍 Checking deleted versions:"
for version in 4.19.2 4.19.3 4.19.4 4.19.5 4.19.6; do
  if oc adm release info $(hostname):8443/openshift/release-images:${version}-x86_64 2>&1 | grep -q "deleted or has expired"; then
    echo "✅ ${version} successfully deleted"
  else
    echo "❌ ${version} still present"
  fi
done
```

#### **✅ Verify Current Version Is Preserved**

Test that your current cluster version is still available:

```bash
# This should still work (current version preserved)
oc adm release info $(hostname):8443/openshift/release-images:4.19.3-x86_64
```

#### **🔧 Verify Cluster Health**

Ensure your running cluster is unaffected:

```bash
# Check cluster operators
oc get co
# All operators should show AVAILABLE=True, PROGRESSING=False, DEGRADED=False
```





### **🚨 Recovery Procedures**

#### **If Deletion Goes Wrong**

1. **Stop immediately** if errors occur
2. **Check cluster health:** `oc get co`
3. **Verify current version availability:** `oc adm release info`
4. **Re-mirror if needed:** Use your mirroring scripts to restore content

#### **Emergency Recovery**

If critical versions were accidentally deleted:
```bash
# Re-mirror required content immediately
cd ~/ocp/oc-mirror
./mirror-to-disk.sh    # Mirror to disk
./disk-to-mirror.sh    # Upload to registry
```

---

## 🚀 Quick Start Example

**Ready to clean up old images? Here's the complete workflow:**

```bash
# 1. Navigate to working directory
cd ~/ocp/oc-mirror

# 2. Generate deletion plan (SAFE - no actual deletions)
./delete-generate.sh

# 3. Review generated plan (CRITICAL SAFETY STEP)
cat content/working-dir/delete/delete-images.yaml

# 4. Execute deletion (only after thorough review)
oc mirror delete \
  --delete-yaml-file content/working-dir/delete/delete-images.yaml \
  docker://$(hostname):8443 \
  --v2 \
  --cache-dir .cache

# 5. Verify deletion success
echo "🔍 Verifying deleted versions:"
for version in 4.19.2 4.19.3 4.19.6; do
  oc adm release info $(hostname):8443/openshift/release-images:${version}-x86_64 2>/dev/null || echo "✅ ${version} deleted"
done
```
