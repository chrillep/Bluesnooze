.DEFAULT_GOAL := help

CONFIGURATION ?= Release
DEPLOYMENT_TARGET ?= 12.0
INSTALL_DIR ?= /Applications
DERIVED_DATA := $(CURDIR)/.build/DerivedData
APP := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)/Bluesnooze.app

ifneq (,$(findstring xterm,$(TERM)))
BLUE := $(shell tput -Txterm setaf 6)
RESET := $(shell tput -Txterm sgr0)
endif

XCODEBUILD = xcodebuild -project src/Bluesnooze.xcodeproj \
	-scheme Bluesnooze -configuration "$(CONFIGURATION)" \
	-destination 'generic/platform=macOS' \
	-derivedDataPath "$(DERIVED_DATA)" \
	-disableAutomaticPackageResolution \
	MACOSX_DEPLOYMENT_TARGET="$(DEPLOYMENT_TARGET)" CODE_SIGN_IDENTITY=-

.PHONY: help build install run lint clean

help: ## Show available commands
	@printf '\nUsage: make <target>\n\n'
	@awk 'BEGIN {FS = ":.*## "} /^[a-z-]+:.*## / {printf "  $(BLUE)%-12s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the locally ad-hoc-signed macOS app (Release by default)
	$(XCODEBUILD) build

install: build ## Build and copy the app to /Applications (quit Bluesnooze first)
	@mkdir -p "$(INSTALL_DIR)"
	ditto "$(APP)" "$(INSTALL_DIR)/Bluesnooze.app"
	codesign --verify --deep --strict "$(INSTALL_DIR)/Bluesnooze.app"

run: install ## Build, install, and launch the installed menu-bar app
	open "$(INSTALL_DIR)/Bluesnooze.app"

lint: ## Run strict SwiftLint with the committed baseline
	swiftlint lint --config .swiftlint.yml --strict

clean: ## Clean Xcode build products without removing the installed app
	$(XCODEBUILD) clean
