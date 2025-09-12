# 🌐 BIND DNS Server Setup for OpenShift

**Complete DNS Configuration Guide for Disconnected OpenShift Environments**

This guide provides step-by-step instructions for setting up a BIND DNS server with dual domains, supporting wildcard routing for OpenShift clusters in disconnected environments.

---

## 📋 Requirements and Assumptions

### **🔑 Key Features**

- ✅ **Dual domain support** - `lab.local` and `prod.local` environments
- ✅ **Wildcard DNS entries** - `*.apps.<domain>` for OpenShift routes
- ✅ **Registry support** - `quay.<domain>` for container registry
- ✅ **API endpoint resolution** - `api.<domain>` for cluster API access
- ✅ **Authoritative DNS** - Master zones for complete control
- ✅ **Firewall integration** - Proper service configuration

### **✅ What You'll Accomplish**

- 🏗️ **Complete DNS infrastructure** for OpenShift clusters
- 🔧 **Authoritative name server** with dual domain support
- 🌐 **Wildcard route resolution** for applications
- 📦 **Registry DNS entries** for container image hosting
- 🛡️ **Secure configuration** with proper permissions

### **🛡️ System Requirements**

- **RHEL-based system** (RHEL 8/9, Rocky, Alma, etc.)
- **Root or sudo access** for system configuration
- **Network connectivity** to client systems
- **Static IP address** recommended for DNS server
- **Firewall configuration** access

---

### **📦 Step 1: Install BIND DNS Server**

#### **🔧 Install Required Packages**

```bash
# Install BIND and DNS utilities
sudo dnf install -y bind bind-utils
```

### **⚙️ Step 2: Configure BIND Options**

#### **📝 Edit Main Configuration**

```bash
# Edit the main BIND configuration
sudo vi /etc/named.conf
```

**Configuration Content:**

```dns
options {
    directory "/var/named";
    listen-on port 53 { any; };
    allow-query     { any; };
    recursion no;
};

zone "lab.local" IN {
    type master;
    file "lab.local.db";
};

zone "prod.local" IN {
    type master;
    file "prod.local.db";
};
```

> 📝 **Note:** `recursion no` is set for security - this server only answers for zones it knows about.

### **📁 Step 3: Create DNS Zone Files**

#### **🏗️ Create Lab Environment Zone**

```bash
# Create lab.local zone file
sudo vi /var/named/lab.local.db
```

**Lab Zone Configuration:**

```dns
$TTL 1D
@       IN SOA  ns1.lab.local. admin.lab.local. (
                2025070901  ; Serial (YYYYMMDDNN format)
                1D          ; Refresh
                1H          ; Retry
                1W          ; Expire
                3H )        ; Minimum

        IN NS   ns1.lab.local.

; DNS Server
ns1     IN A    192.168.100.1

; OpenShift Cluster Endpoints
api     IN A    192.168.100.10
*.apps  IN A    192.168.100.11

; Container Registry
quay    IN A    192.168.100.12
```

#### **🏭 Create Production Environment Zone**

```bash
# Create prod.local zone file
sudo vi /var/named/prod.local.db
```

**Production Zone Configuration:**

```dns
$TTL 1D
@       IN SOA  ns1.prod.local. admin.prod.local. (
                2025070901  ; Serial (YYYYMMDDNN format)
                1D          ; Refresh
                1H          ; Retry
                1W          ; Expire
                3H )        ; Minimum

        IN NS   ns1.prod.local.

; DNS Server
ns1     IN A    192.168.200.1

; OpenShift Cluster Endpoints
api     IN A    192.168.200.10
*.apps  IN A    192.168.200.11

; Container Registry
quay    IN A    192.168.200.12
```

> 💡 **Tip:** Adjust IP addresses according to your network configuration.

### **🔐 Step 4: Set File Permissions**

#### **🛡️ Configure Security Permissions**

```bash
# Set proper ownership and permissions for zone files
sudo chown root:named /var/named/lab.local.db
sudo chown root:named /var/named/prod.local.db
sudo chmod 640 /var/named/lab.local.db
sudo chmod 640 /var/named/prod.local.db
```

### **🚀 Step 5: Enable and Start BIND Service**

#### **▶️ Start DNS Service**

```bash
# Enable and start BIND service
sudo systemctl enable --now named

# Check service status
sudo systemctl status named
```

**Expected Output:**
```
● named.service - Berkeley Internet Name Domain (DNS)
   Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; vendor preset: disabled)
   Active: active (running)
```

### **🔥 Step 6: Configure Firewall**

#### **🛡️ Allow DNS Traffic**

```bash
# Allow DNS service through firewall
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --reload

# Verify firewall rules
sudo firewall-cmd --list-services
```

### **🔧 Step 7: Configure DNS Clients**

#### **📝 Point Clients to BIND Server**

**On RHEL hosts and OpenShift nodes:**

```bash
# Edit DNS configuration
sudo vi /etc/resolv.conf
```

**Add nameserver entries:**

```dns
# For lab environment clients
nameserver 192.168.100.1

# For production environment clients  
nameserver 192.168.200.1

# Optional: Add fallback DNS
nameserver 8.8.8.8
```

> ⚠️ **Important:** Consider using NetworkManager or systemd-resolved for persistent DNS configuration in production environments.

### **✅ Step 8: Test DNS Configuration**

#### **🔍 Verify DNS Resolution**

**Test Lab Environment:**

```bash
# Test API endpoint resolution
dig @192.168.100.1 api.lab.local

# Test wildcard application routes
dig @192.168.100.1 test.apps.lab.local
dig @192.168.100.1 console-openshift-console.apps.lab.local

# Test registry resolution
dig @192.168.100.1 quay.lab.local
```

**Test Production Environment:**

```bash
# Test API endpoint resolution
dig @192.168.200.1 api.prod.local

# Test wildcard application routes
dig @192.168.200.1 myapp.apps.prod.local

# Test registry resolution
dig @192.168.200.1 quay.prod.local
```

**Expected Output Example:**
```
;; ANSWER SECTION:
api.lab.local.          86400   IN      A       192.168.100.10
```

#### **🧪 Additional Testing Commands**

```bash
# Test from client machines
nslookup api.lab.local
nslookup test.apps.prod.local

# Test reverse DNS (optional)
dig -x 192.168.100.10

# Verify DNS server is listening
ss -tulpn | grep :53
```

---

## 🔧 Advanced Configuration

### **📊 Monitoring and Logging**

```bash
# Check BIND logs
sudo journalctl -u named -f

# View DNS query logs (if logging enabled)
sudo tail -f /var/log/messages | grep named
```

### **🔄 Zone File Updates**

**When making changes to zone files:**

```bash
# Update serial number in SOA record (increment by 1)
# Example: 2025070901 → 2025070902

# Reload specific zone
sudo rndc reload lab.local

# Or reload all zones
sudo systemctl reload named
```

### **🛡️ Security Considerations**

```bash
# Restrict queries to specific networks (optional)
# In /etc/named.conf options section:
# allow-query { 192.168.100.0/24; 192.168.200.0/24; };

# Enable query logging (optional)
# logging {
#     channel default_debug {
#         file "data/named.run";
#         severity dynamic;
#     };
# };
```

---

## 🔧 Troubleshooting

### **❌ Common Issues**

#### **1. Service Won't Start**

```bash
# Check configuration syntax
sudo named-checkconf

# Check zone files
sudo named-checkzone lab.local /var/named/lab.local.db
sudo named-checkzone prod.local /var/named/prod.local.db
```

#### **2. DNS Resolution Fails**

```bash
# Verify BIND is listening
sudo ss -tulpn | grep :53

# Check firewall
sudo firewall-cmd --list-services | grep dns

# Test direct query
dig @localhost api.lab.local
```

#### **3. Permission Errors**

```bash
# Fix SELinux contexts (if enabled)
sudo restorecon -R /var/named/

# Verify file ownership
ls -la /var/named/*.db
```

---

## ✅ Integration with OpenShift

### **🎯 Perfect for Disconnected Clusters**

This DNS setup is ideal for:

- ✅ **OpenShift disconnected installations**
- ✅ **Wildcard route resolution** (`*.apps.lab.local`)
- ✅ **API server access** (`api.lab.local`)
- ✅ **Container registry resolution** (`quay.lab.local`)
- ✅ **Multi-environment support** (lab and prod domains)

### **🔗 Next Steps After DNS Setup**

1. **Configure OpenShift install-config.yaml** with your domain
2. **Set up container registry** at `quay.<domain>`
3. **Configure load balancer** for API and ingress endpoints
4. **Test application deployment** with wildcard routes

---

> 📝 **Next Steps:** After DNS setup, configure your OpenShift installation to use these domains and verify all services can resolve properly.

**📖 References:**
- [BIND Documentation](https://bind9.readthedocs.io/)
- [OpenShift DNS Requirements](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html#installation-dns-user-infra_installing-bare-metal)
- [Red Hat BIND Configuration Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/managing_networking_infrastructure_services/assembly_setting-up-and-configuring-a-bind-dns-server_managing-networking-infrastructure-services)
