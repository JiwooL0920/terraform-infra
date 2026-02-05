.PHONY: help init plan apply destroy validate fmt lint clean install-tools cluster-info cluster-create cluster-destroy output

# Auto-detect OpenTofu or Terraform
TF_BIN := $(shell command -v tofu 2>/dev/null)
ifndef TF_BIN
	TF_BIN := $(shell command -v terraform 2>/dev/null)
endif

# Default target
help:
	@echo "OpenTofu/Terraform KIND Cluster Management"
	@echo ""
	@echo "Using: $(TF_BIN)"
	@echo ""
	@echo "Setup:"
	@echo "  install-tools    - Check and install required tools (OpenTofu, KIND, kubectl)"
	@echo "  init             - Initialize OpenTofu/Terraform (downloads providers)"
	@echo "  validate         - Validate configuration"
	@echo "  fmt              - Format .tf files"
	@echo ""
	@echo "Cluster Operations:"
	@echo "  plan             - Preview Terraform changes"
	@echo "  apply            - Create/update KIND cluster"
	@echo "  destroy          - Destroy KIND cluster and cleanup"
	@echo "  output           - Show Terraform outputs"
	@echo "  cluster-info     - Show cluster information (kubectl + kind)"
	@echo ""
	@echo "Aliases:"
	@echo "  cluster-create   - Alias for 'make apply'"
	@echo "  cluster-destroy  - Alias for 'make destroy'"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean            - Clean Terraform cache and temporary files"
	@echo "  lint             - Run tflint (if installed)"
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make install-tools   # Verify prerequisites"
	@echo "  2. make init           # Initialize Terraform"
	@echo "  3. make plan           # Preview changes"
	@echo "  4. make apply          # Create cluster"
	@echo "  5. make cluster-info   # Verify cluster"

# Check if required tools are installed
check-tools:
	@echo "Checking required tools..."
	@if [ -z "$(TF_BIN)" ]; then \
		echo "❌ Neither OpenTofu nor Terraform installed"; \
		echo "   Install OpenTofu: brew install opentofu"; \
		echo "   Or Terraform: brew install terraform"; \
		exit 1; \
	fi
	@command -v kind >/dev/null 2>&1 || (echo "❌ kind not installed (brew install kind)" && exit 1)
	@command -v kubectl >/dev/null 2>&1 || (echo "❌ kubectl not installed (brew install kubectl)" && exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "❌ docker not installed (brew install colima or use Docker Desktop)" && exit 1)
	@echo "✓ All required tools are installed"
	@echo "✓ Using: $(TF_BIN)"

# Install or verify tools
install-tools:
	@echo "Checking and installing required tools..."
	@if ! command -v tofu >/dev/null 2>&1 && ! command -v terraform >/dev/null 2>&1; then \
		echo "Installing OpenTofu (recommended)..."; \
		brew install opentofu; \
	fi
	@which kind >/dev/null || (echo "Installing kind..." && brew install kind)
	@which kubectl >/dev/null || (echo "Installing kubectl..." && brew install kubectl)
	@which docker >/dev/null || echo "⚠️  Docker not found. Install: brew install colima"
	@echo ""
	@echo "Tool versions:"
	@if command -v tofu >/dev/null 2>&1; then \
		tofu version | head -n 1; \
	elif command -v terraform >/dev/null 2>&1; then \
		terraform version | head -n 1; \
	fi
	@kind version
	@kubectl version --client --short 2>/dev/null || kubectl version --client
	@echo ""
	@echo "✓ Tool check complete!"

# Check if Docker/Colima is running
check-docker:
	@docker ps >/dev/null 2>&1 || (echo "❌ Docker is not running. Start with: colima start" && exit 1)

# Setup: Copy example tfvars if terraform.tfvars doesn't exist
setup-tfvars:
	@if [ ! -f main/terraform.tfvars ]; then \
		echo "Creating terraform.tfvars from example..."; \
		cp main/terraform.tfvars.example main/terraform.tfvars; \
		echo "✓ Created main/terraform.tfvars"; \
		echo "  Edit this file to customize your configuration"; \
	fi

# Initialize OpenTofu/Terraform
init: check-tools setup-tfvars
	@echo "Initializing with $(TF_BIN)..."
	@cd main && $(TF_BIN) init
	@echo "✓ Initialized successfully"

# Validate configuration
validate: check-tools
	@echo "Validating configuration..."
	@cd main && $(TF_BIN) validate
	@echo "✓ Configuration is valid"

# Format .tf files
fmt:
	@echo "Formatting .tf files..."
	@$(TF_BIN) fmt -recursive .
	@echo "✓ Files formatted"

# Plan changes
plan: check-tools check-docker
	@echo "Planning changes..."
	@cd main && $(TF_BIN) plan

# Apply changes (create/update cluster)
apply: check-tools check-docker
	@echo "Applying configuration..."
	@cd main && $(TF_BIN) apply
	@echo ""
	@echo "✓ Cluster operation complete!"
	@echo ""
	@$(MAKE) cluster-info

# Destroy cluster
destroy: check-tools
	@echo "⚠️  This will destroy the KIND cluster and all resources."
	@cd main && $(TF_BIN) destroy

# Show outputs
output: check-tools
	@cd main && $(TF_BIN) output

# Show cluster information
cluster-info:
	@echo "==================== Cluster Information ===================="
	@echo ""
	@echo "KIND Clusters:"
	@kind get clusters 2>/dev/null || echo "  No KIND clusters found"
	@echo ""
	@echo "Kubernetes Nodes:"
	@kubectl get nodes 2>/dev/null || echo "  Unable to connect to cluster"
	@echo ""
	@echo "Current kubectl context:"
	@kubectl config current-context 2>/dev/null || echo "  No context set"
	@echo ""
	@echo "Outputs:"
	@cd main && $(TF_BIN) output 2>/dev/null || echo "  Run 'make init' and 'make apply' first"
	@echo ""
	@echo "============================================================="

# Alias for apply
cluster-create: apply

# Alias for destroy
cluster-destroy: destroy

# Clean cache and temporary files
clean:
	@echo "Cleaning cache and temporary files..."
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find . -type f -name "terraform.tfstate.backup" -delete 2>/dev/null || true
	@find . -type f -name ".tofu.lock.hcl" -delete 2>/dev/null || true
	@echo "✓ Cleaned cache files"
	@echo ""
	@echo "Note: .tfstate and .tfvars files are preserved"

# Run tflint (if installed)
lint:
	@if command -v tflint >/dev/null 2>&1; then \
		echo "Running tflint..."; \
		cd main && tflint; \
		cd ../modules/homelab/tf-kind-base && tflint; \
		echo "✓ Linting complete"; \
	else \
		echo "⚠️  tflint not installed (brew install tflint)"; \
		echo "  Skipping lint check"; \
	fi

# Development workflow: format, validate, plan
dev: fmt validate plan

# Full workflow: init, validate, plan, apply
all: init validate plan apply

# Quick restart: destroy and recreate cluster
restart: destroy apply

# Show kubeconfig path
kubeconfig:
	@cd main && $(TF_BIN) output -raw kubeconfig_path 2>/dev/null || echo "~/.kube/config"

# Switch kubectl context to this cluster
use-context:
	@CONTEXT=$$(cd main && $(TF_BIN) output -raw kubectl_context 2>/dev/null); \
	if [ -n "$$CONTEXT" ]; then \
		kubectl config use-context $$CONTEXT; \
		echo "✓ Switched to context: $$CONTEXT"; \
	else \
		echo "❌ Cluster not found. Run 'make apply' first"; \
	fi
