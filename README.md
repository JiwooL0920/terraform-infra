# terraform-infra

Infrastructure as Code for provisioning Kubernetes clusters with OpenTofu/Terraform. Supports KIND (Kubernetes in Docker) clusters for local development and testing.

## Overview

This repository provisions a **multi-node KIND cluster** designed for FluxCD GitOps deployments. The cluster is configured to work seamlessly with the [fleet-infra](https://github.com/JiwooL0920/fleet-infra) repository, providing a complete local Kubernetes environment with:

- **3-node cluster** (1 control-plane + 2 workers)
- **Port mappings** for Traefik ingress (80/443)
- **Production-like setup** for testing GitOps workflows
- **FluxCD-ready** configuration

## Prerequisites

### System Requirements

Your machine needs sufficient resources to run a 3-node Kubernetes cluster:

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 6 cores | 8+ cores |
| RAM | 12GB | 16GB |
| Disk | 60GB | 80GB |

### Required Tools

#### 1. Container Runtime

Choose one:

**Option A: Colima (Recommended for macOS)**
```bash
brew install colima

# Start with recommended resources
colima start --cpu 8 --memory 16 --disk 80

# Verify it's running
colima list
```

**Option B: Docker Desktop**
- Download from [docker.com](https://www.docker.com/products/docker-desktop)
- Configure resources in Docker Desktop settings

#### 2. Kubernetes Tools

```bash
# Install kubectl (Kubernetes CLI)
brew install kubectl

# Install KIND (Kubernetes in Docker)
brew install kind
```

#### 3. Infrastructure as Code Tool

```bash
# Install OpenTofu or Terraform
brew install opentofu
# or: brew install terraform
```

#### 4. Optional Tools

```bash
# FluxCD CLI (for GitOps deployment)
brew install flux
```

### Quick Install (All-in-One)

```bash
# Install everything at once
brew install colima kubectl kind opentofu flux

# Start Colima
colima start --cpu 8 --memory 16 --disk 80
```

## Quick Start Guide

### Step 1: Verify Prerequisites

```bash
# Check that Docker/Colima is running
docker ps

# If using Colima and it's not running:
colima start --cpu 8 --memory 16 --disk 80

# Verify all required tools are installed
make install-tools
```

**Expected output:**
```
✓ All required tools are installed
✓ Using: /opt/homebrew/bin/tofu

Tool versions:
OpenTofu v1.8.x
kind v0.x.x
```

### Step 2: Initialize Infrastructure

```bash
# This will:
# - Create terraform.tfvars from the example
# - Download the KIND provider
# - Set up the working directory
make init
```

**What happens:**
- Creates `main/terraform.tfvars` with default values
- Downloads OpenTofu/Terraform providers
- Initializes backend for state management

### Step 3: Preview What Will Be Created

```bash
# See the execution plan
make plan
```

**What you'll see:**
- 1 KIND cluster resource
- Cluster name: `dev-services-amer`
- 3 nodes (1 control-plane + 2 workers)
- Port mappings for ingress

### Step 4: Create the Cluster

```bash
# Apply the configuration
make apply

# Review the plan and type 'yes' when prompted
```

**This takes ~2-3 minutes.** OpenTofu will:
1. Create the KIND cluster
2. Configure networking and port mappings
3. Wait for all nodes to be ready

### Step 5: Verify Cluster

```bash
# Comprehensive cluster information
make cluster-info
```

**Expected output:**
```
==================== Cluster Information ====================

KIND Clusters:
  dev-services-amer

Kubernetes Nodes:
NAME                             STATUS   ROLES           AGE   VERSION
dev-services-amer-control-plane  Ready    control-plane   2m    v1.31.0
dev-services-amer-worker         Ready    <none>          2m    v1.31.0
dev-services-amer-worker2        Ready    <none>          2m    v1.31.0

Current kubectl context:
  kind-dev-services-amer

Outputs:
  cluster_name = "dev-services-amer"
  cluster_endpoint = "https://127.0.0.1:xxxxx"
  kubectl_context = "kind-dev-services-amer"
```

### Step 6: Test Cluster Access

```bash
# Run kubectl commands
kubectl get nodes
kubectl get namespaces
kubectl cluster-info

# All commands should work without errors
```

✅ **Your KIND cluster is now ready!**

---

## Next Steps

Sync your cluster with FluxCD using the [fleet-infra](https://github.com/JiwooL0920/fleet-infra) repository.

---

## Alternative: Manual Commands (Without Makefile)

If you prefer not to use the Makefile:

```bash
cd main

# Copy and edit configuration
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Customize if needed

# Initialize
tofu init
# or: terraform init

# Preview
tofu plan

# Apply
tofu apply

# Verify
kind get clusters
kubectl get nodes
```

## What Gets Created

The configuration provisions a complete Kubernetes cluster:

### Cluster Specifications

| Component | Value | Purpose |
|-----------|-------|---------|
| **Cluster Name** | `dev-services-amer` | Matches FluxCD configuration |
| **Kubernetes Version** | v1.31.0 | Configurable via `kind_release_version` |
| **Control Plane Nodes** | 1 | Manages cluster state |
| **Worker Nodes** | 2 | Run application workloads |

### Network Configuration

| Port Mapping | Purpose |
|--------------|---------|
| `80 → 30080` | HTTP traffic for Traefik ingress |
| `443 → 30443` | HTTPS traffic for Traefik ingress |

### Features

- ✅ **Node Labels** - For workload scheduling and placement
- ✅ **FluxCD Ready** - Pre-configured for GitOps deployment
- ✅ **Traefik Compatible** - Ingress controller port mappings
- ✅ **Multi-node** - Production-like environment
- ✅ **Local Development** - No cloud costs


## Repository Structure

```
terraform-infra/
├── Makefile                        # Automation commands
├── README.md                       # This file
│
├── main/                           # Root module (entry point)
│   ├── backend.tf                  # State backend (local)
│   ├── main.tf                     # Module invocation
│   ├── variables.tf                # Input variable definitions
│   ├── outputs.tf                  # Output values
│   ├── versions.tf                 # Provider version constraints
│   ├── terraform.tfvars.example    # Example configuration
│   └── terraform.tfvars            # Your configuration (gitignored)
│
└── modules/                        # Reusable modules
    └── homelab/
        └── tf-kind-base/           # KIND cluster module
            ├── main.tf             # Cluster resource
            ├── variables.tf        # Module inputs
            ├── outputs.tf          # Module outputs
            └── versions.tf         # Provider requirements
```

### Key Files

| File | Purpose |
|------|---------|
| `Makefile` | Convenient automation commands |
| `main/terraform.tfvars` | Your cluster configuration (edit this) |
| `main/main.tf` | Calls the KIND module |
| `modules/.../main.tf` | Defines the actual cluster resource |
| `.gitignore` | Protects sensitive files from git |


## Makefile Reference

### Core Commands

| Command | Description | When to Use |
|---------|-------------|-------------|
| `make help` | Show all available commands | Anytime you need a reference |
| `make install-tools` | Install/check required tools | First-time setup |
| `make init` | Initialize OpenTofu/Terraform | Before first apply, or after config changes |
| `make plan` | Preview infrastructure changes | Before applying changes |
| `make apply` | Create or update cluster | To provision the cluster |
| `make destroy` | Delete cluster completely | When you're done or need to start fresh |
| `make cluster-info` | Show cluster status | To verify cluster state |
| `make output` | Show infrastructure outputs | To get cluster connection info |

### Convenience Aliases

| Command | Equivalent | Description |
|---------|-----------|-------------|
| `make cluster-create` | `make apply` | More intuitive name |
| `make cluster-destroy` | `make destroy` | More intuitive name |
| `make restart` | `make destroy && make apply` | Quick cluster rebuild |
| `make use-context` | `kubectl config use-context ...` | Switch kubectl to this cluster |

### Development Commands

| Command | Description |
|---------|-------------|
| `make fmt` | Format all .tf files |
| `make validate` | Validate configuration syntax |
| `make lint` | Run tflint (if installed) |
| `make clean` | Remove cache files (preserves state) |
| `make dev` | Run fmt + validate + plan |

## Common Tasks

### View Cluster Information

```bash
make cluster-info
```

Shows comprehensive info: nodes, context, outputs, and cluster status.

### Update Kubernetes Version

1. Edit `main/terraform.tfvars`:
   ```hcl
   kind_release_version = "v1.32.0"  # Change version
   ```

2. Apply the change:
   ```bash
   make apply
   ```

**Note:** Changing the Kubernetes version requires recreating the cluster.

### Customize Cluster Configuration

Edit `main/terraform.tfvars` to change:

| Variable | Default | Description |
|----------|---------|-------------|
| `kind_cluster_name` | `"dev-services-amer"` | Cluster name |
| `kind_release_version` | `"v1.31.0"` | Kubernetes version |
| `env` | `"dev"` | Environment label |
| `cluster_type` | `"services"` | Cluster type/purpose |
| `target_region` | `"us-west-1"` | Region (for tagging) |

After editing:
```bash
make plan    # Preview changes
make apply   # Apply changes
```

### Rebuild Cluster from Scratch

```bash
# Quick way
make restart

# Or step-by-step
make destroy
make apply
```

### Delete Everything

```bash
make destroy

# Confirm with 'yes' when prompted
```

This removes:
- KIND cluster
- All containers
- Infrastructure state (in `.tfstate` file)

**Note:** Your configuration files (`terraform.tfvars`, `.tf` files) are preserved.

### Switch kubectl Context

If you have multiple clusters:

```bash
# Switch to this cluster
make use-context

# Verify
kubectl config current-context
# Output: kind-dev-services-amer
```

## Best Practices Implemented

This repository follows infrastructure-as-code best practices:

- ✅ **Module-based architecture** - Reusable, composable components
- ✅ **Version pinning** - Locked provider versions for reproducibility
- ✅ **Local state** - Simple state management for single-user development
- ✅ **Type-safe variables** - Input validation and type checking
- ✅ **Comprehensive outputs** - Easy integration with other tools
- ✅ **Example configuration** - Clear starting point
- ✅ **Documentation** - Step-by-step instructions
- ✅ **Automation** - Makefile for common operations
- ✅ **Flexible tooling** - Works with OpenTofu or Terraform  

## Troubleshooting

### ❌ Docker/Colima Not Running

**Error:** `Cannot connect to the Docker daemon`

**Solution:**
```bash
# Check status
docker ps

# If using Colima
colima status
colima start --cpu 8 --memory 16 --disk 80

# If using Docker Desktop
# Start Docker Desktop application
```

---

### ❌ Port 80 or 443 Already in Use

**Error:** `port is already allocated`

**Solution:**
```bash
# Find what's using the ports
sudo lsof -i :80
sudo lsof -i :443

# Option 1: Stop the conflicting service
# Option 2: Modify port mappings in modules/homelab/tf-kind-base/main.tf
```

---

### ❌ Cluster Creation Fails

**Error:** Various cluster creation errors

**Solution:**
```bash
# Clean up failed attempt
kind delete cluster --name dev-services-amer

# Restart container runtime
colima restart  # or restart Docker Desktop

# Verify Docker is working
docker ps

# Try again
make apply
```

---

### ❌ kubectl Can't Connect to Cluster

**Error:** `The connection to the server ... was refused`

**Solution:**
```bash
# Check cluster exists
kind get clusters

# Check current context
kubectl config current-context

# Switch to the correct context
make use-context
# or manually:
kubectl config use-context kind-dev-services-amer

# Verify connection
kubectl cluster-info
kubectl get nodes
```

---

### ❌ "No such file or directory" for tofu/terraform

**Error:** Command not found

**Solution:**
```bash
# Install OpenTofu
brew install opentofu

# Or install Terraform
brew install terraform

# Verify installation
which tofu
tofu version
```

---

### ❌ Wrong Kubernetes Version

**Problem:** Cluster has wrong version

**Solution:**
```bash
# Edit configuration
vim main/terraform.tfvars

# Change this line:
kind_release_version = "v1.31.0"  # Set desired version

# Recreate cluster
make restart
```

---

### ❌ After Colima Restart, Services Don't Work

**Problem:** Control plane IP changed

**Solution:**
```bash
# In fleet-infra repo (after FluxCD is deployed)
cd /path/to/fleet-infra
make fix-control-plane
```

---

### 🆘 Complete Reset

If everything is broken and you want to start fresh:

```bash
# 1. Delete the cluster
make destroy

# 2. Clean all cache files
make clean

# 3. Delete state (nuclear option)
rm main/terraform.tfstate*

# 4. Restart container runtime
colima restart

# 5. Start over
make init
make apply
```

## Advanced Topics

### Using Remote State (For Teams)

The default configuration uses local state (`terraform.tfstate`), which is fine for personal use. For team collaboration:

1. Edit `main/backend.tf`:
   ```hcl
   terraform {
     backend "s3" {
       bucket = "your-state-bucket"
       key    = "kind-cluster/terraform.tfstate"
       region = "us-west-1"
     }
   }
   ```

2. Re-initialize:
   ```bash
   make init
   ```

### Managing Multiple Environments

**Option 1: Separate Directories**
```bash
main/
  dev/         # Development config
  staging/     # Staging config
  prod/        # Production config
```

**Option 2: OpenTofu/Terraform Workspaces**
```bash
cd main

# Create workspaces
tofu workspace new staging
tofu workspace new prod

# Switch between environments
tofu workspace select dev
make apply

tofu workspace select staging
make apply
```



## Learning Resources

### Official Documentation
- [OpenTofu Documentation](https://opentofu.org/docs/)
- [Terraform Documentation](https://www.terraform.io/docs) (mostly compatible)
- [KIND Documentation](https://kind.sigs.k8s.io/)
- [KIND Provider for Terraform/OpenTofu](https://registry.terraform.io/providers/tehcyx/kind/latest/docs)
- [FluxCD Documentation](https://fluxcd.io/)

### Related Projects
- [fleet-infra Repository](https://github.com/JiwooL0920/fleet-infra) - GitOps configuration for this cluster

### Getting Help

1. **Check troubleshooting section** above
2. **Enable debug logs:**
   ```bash
   cd main
   TF_LOG=DEBUG tofu apply
   ```
3. **Verify basics:**
   ```bash
   docker ps                    # Container runtime working?
   kind get clusters           # Cluster exists?
   kubectl get nodes           # Can connect to cluster?
   make cluster-info           # Comprehensive status
   ```

---

## License

This project is open source. Use it however you like for learning and personal projects.
