# 🚀 AWS Infrastructure Setup Guide

**Your Complete Guide to Two-Host AWS Environment for oc-mirror v2**

Welcome to the AWS infrastructure setup for OpenShift disconnected installations! This guide will provision your two-host environment (bastion + registry) on AWS using Red Hat Demo Platform.

---

## 🚀 Quick Start

### **Step 1: Create AWS Demo Environment**

Navigate to the Red Hat Demo Platform and provision your AWS environment:

**🔗 Demo Platform URL:**
```
https://catalog.demo.redhat.com/catalog?item=babylon-catalog-prod/sandboxes-gpte.sandbox-open.prod&utm_source=webapp&utm_medium=share-link
```

> ⚠️ **Important:** Keep the demo environment page open for AWS credential access throughout the setup process

### **Step 2: AWS Console Access**

1. **Copy the AWS Web Console URL** from the demo environment page
2. **Open this URL in a new browser window**
3. **Log into AWS using the Web Console Credentials** from the demo environment page
4. **Navigate to required AWS services** using Search at the top, with each service in a new tab:
   - **EC2:** Instance management and configuration
   - **Route53:** DNS configuration for the bastion host

### **Step 3: Network Infrastructure Setup**

#### Create Default VPC (if needed)
1. Navigate to: [VPC Console - Create Default VPC](https://us-east-2.console.aws.amazon.com/vpc/home?region=us-east-2#CreateDefaultVpc:)
2. Click **"Create Default VPC"**
3. Wait for creation to complete

### **Step 4: Bastion Host Configuration**

**🌐 Launch EC2 Instance**

#### Instance Configuration
1. In the EC2 Console, click **"Launch instance"**
2. Use the wizard to configure the following settings:

| Setting | Value | Notes |
|---------|-------|-------|
| **Name** | `bastion` | Descriptive name for identification |
| **OS** | Red Hat Enterprise Linux 9 | Latest stable RHEL version |
| **Instance Type** | `t2.xlarge` | Minimum for mirroring operations |
| **Key Pair** | Create new or select existing | Download and save securely |
| **Network** | Default VPC and subnet | Use previously created Default VPC |
| **Storage** | 1x 2048 GiB (gp3) | Required for mirroring operations |

3. Click **"Launch instance"**

**🛡️ Security Group Configuration** (only needed to access your registry externally)

Configure inbound rule to allow access to mirror registry:

1. **Select your bastion instance** from the EC2 console
2. Navigate to the **"Security"** tab
3. **Click on the currently applied Security Group** link (usually `launch-wizard-1`)
4. Click **"Edit inbound rules"**
5. Click **"Add rule"** and use the following settings:
   - **Type:** Custom TCP
   - **Port Range:** 8443
   - **Source:** 0.0.0.0/0 (for lab/testing only - restrict in production)
6. Click **"Save Rules"**

**🔗 Connect to Bastion Host**

#### SSH Connection
```bash
# Replace with your actual key file and IP address
ssh -i ~/.ssh/your-key.pem ec2-user@[BASTION-PUBLIC-IP]
```

### **Step 5: Registry Host Configuration**

**🔒 Launch Registry EC2 Instance**

Create a second EC2 instance identical to the bastion host for registry operations:

#### Instance Configuration
1. In the EC2 Console, click **"Launch instance"**
2. Use the wizard to configure the following settings:

| Setting | Value | Notes |
|---------|-------|-------|
| **Name** | `registry` | Descriptive name for registry operations |
| **OS** | Red Hat Enterprise Linux 9 | Same as bastion host |
| **Instance Type** | `t2.xlarge` | Same specifications as bastion |
| **Key Pair** | Use same key pair as bastion | For consistent access |
| **Network** | Default VPC and subnet | Same network as bastion host |
| **Storage** | 1x 2048 GiB (gp3) | Same storage as bastion for registry data |

3. Click **"Launch instance"**



**🔗 Connect to Registry Host**

#### SSH Connection
```bash
# Replace with your actual key file and IP address
ssh -i ~/.ssh/your-key.pem ec2-user@[REGISTRY-PUBLIC-IP]
```

### **Step 6: DNS Configuration**

**🌐 Set up DNS records for both bastion and registry hosts**

**Create Bastion DNS Record**

1. **Copy the public IP address** from your bastion EC2 instance details
2. **Navigate to the Route53 console**
3. **Click Hosted zones from the sidebar menu**
4. **Select your hosted zone** (e.g. `sandboxXXX.opentlc.com`)
5. **Click "Create record" and use the following settings**:
   - **Record Name:** `bastion`
   - **Record Type:** A
   - **Value:** [Your bastion EC2 instance's public IP]
6. **Click "Create records"**

**Create Registry DNS Record**

1. **Copy the public IP address** from your registry EC2 instance details
2. **In the same hosted zone**, click **"Create record"** again
3. **Use the following settings**:
   - **Record Name:** `registry`
   - **Record Type:** A
   - **Value:** [Your registry EC2 instance's public IP]
4. **Click "Create records"**

**✅ Verify DNS Configuration**

```bash
# Test DNS resolution for both hosts
nslookup bastion.sandboxXXX.opentlc.com
nslookup registry.sandboxXXX.opentlc.com

# Alternative: Use dig command
dig +short bastion.sandboxXXX.opentlc.com
dig +short registry.sandboxXXX.opentlc.com
```

---
