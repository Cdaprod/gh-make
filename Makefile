# Define directories
REPOS_DIR := /path/to/your/repos
HOOKS_DIR := $(CURDIR)/hooks
SCRIPTS_DIR := $(CURDIR)/scripts

# Define hooks to be installed
HOOKS := pre-commit commit-msg post-commit pre-push post-merge

# Define the list of repositories to install hooks into
REPOSITORIES := $(shell find $(REPOS_DIR) -type d -name ".git" | xargs -n 1 dirname)

.PHONY: install-hooks install-scripts index-repos setup all clean

# Default target
all: install-hooks install-scripts setup index-repos

# Install hooks into all repositories
install-hooks:
	@echo "Installing hooks into repositories..."
	@for repo in $(REPOSITORIES); do \
		echo "Installing hooks in $$repo..."; \
		for hook in $(HOOKS); do \
			cp $(HOOKS_DIR)/$$hook $$repo/.git/hooks/; \
			chmod +x $$repo/.git/hooks/$$hook; \
		done; \
	done
	@echo "Hooks installation complete."

# Install shared scripts into all repositories
install-scripts:
	@echo "Installing scripts into repositories..."
	@for repo in $(REPOSITORIES); do \
		echo "Copying scripts to $$repo..."; \
		mkdir -p $$repo/scripts; \
		cp -R $(SCRIPTS_DIR)/* $$repo/scripts/; \
	done
	@echo "Scripts installation complete."

# Index Git repositories and add them to GitHub Project
index-repos:
	@echo "Indexing Git repositories and adding to GitHub Project..."
	@$(SCRIPTS_DIR)/git-repo-project-25-index-host-projects.sh
	@echo "Indexing complete."

# Run setup script to install hooks
setup:
	@echo "Running setup to install hooks..."
	@$(SCRIPTS_DIR)/setup.sh
	@echo "Setup complete."

# Clean up the script and docker templates from repositories
clean:
	@echo "Cleaning up repositories..."
	@for repo in $(REPOSITORIES); do \
		echo "Cleaning up $$repo..."; \
		rm -rf $$repo/scripts; \
	done
	@echo "Cleanup complete."