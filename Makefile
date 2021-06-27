# CoreOS options.
STREAM    := stable
VERSION   := 34.20210529.3.0
ARCH      := x86_64
IMAGE_URI := https://builds.coreos.fedoraproject.org/prod/streams/
HOST      := $(if $(filter deploy-virtual,$(MAKECMDGOALS)),virtual,$(HOST))

# Default Makefile options.
VERBOSE :=
ROOTDIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
TMPDIR  := $(shell ls -d /var/tmp/fcos-build.???? 2>/dev/null || mktemp -d /var/tmp/fcos-build.XXXX && chmod 0755 /var/tmp/fcos-build.????)/

# Build-time dependencies.
BUTANE      ?= $(call find-cmd,butane)
CURL        ?= $(call find-cmd,curl) $(if $(VERBOSE),,--progress-bar)
GPG         ?= $(call find-cmd,gpg) $(if $(VERBOSE),,-q)
VIRSH       ?= $(call find-cmd,virsh) --connect=qemu:///system $(if $(VERBOSE),,-q)
VIRTINSTALL ?= $(call find-cmd,virt-install) --connect=qemu:///system
NC          ?= $(call find-cmd,nc) -vv -r -l

## Builds and deploys Fedora CoreOS for HOST.
deploy: deploy-$(HOST)

# Prepares and deploys CoreOS for remote environment, serving resulting file in HTTP server.
deploy-%: LISTENADDR = $(shell ip -o route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$$/\1/p')
deploy-%: $(TMPDIR)host/%/spec.ign
	@printf "Serving Ignition config '$<' over HTTP...\n"
	@printf 'HTTP/1.0 200 OK\r\nContent-Length: %d\r\n\r\n%s\n' "`wc -c < $<`" "`cat $<`" | $(NC) -s $(LISTENADDR) || exit 0

## Prepares and deploys CoreOS release for local, virtual environment.
deploy-virtual: $(TMPDIR)images/fedora-coreos-$(VERSION)-qemu.$(ARCH).qcow2.xz $(TMPDIR)host/$(HOST)/spec.ign
	@printf "Preparing virtual environment...\n"
	$Q $(VIRTINSTALL) --import --name="fcos-$(STREAM)-$(VERSION)-$(ARCH)" --os-variant=fedora34 \
	                  --graphics=none --vcpus=2 --memory=2048 \
	                  --disk="size=10,backing_store=$(TMPDIR)images/fedora-coreos-$(VERSION)-qemu.$(ARCH).qcow2" \
	                  --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=$(TMPDIR)host/$(HOST)/spec.ign"

## Stop and remove virtual environment for CoreOS.
destroy-virtual:
	$Q $(VIRSH) destroy fcos-$(STREAM)-$(VERSION)-$(ARCH) || true
	$Q $(VIRSH) undefine --remove-all-storage fcos-$(STREAM)-$(VERSION)-$(ARCH) || true

## Remove configuration files required for build.
clean:
	@printf "Removing configuration files...\n"
	$Q rm -Rf $(TMPDIR)config $(TMPDIR)host $(TMPDIR)make.depend

## Remove all temporary files required for build.
purge:
	@printf "Cleaning all temporary files...\n"
	$Q rm -Rf $(TMPDIR)

## Show usage information for this Makefile.
help:
	@printf "$(BOLD)$(UNDERLINE)CoreOS Home-Server Setup$(RESET)\n\n"
	@printf "This Makefile contains tasks for processing auxiliary actions, such as\n"
	@printf "building binaries, packages, or running tests against the test suite.\n\n"
	@printf "$(UNDERLINE)Available Tasks$(RESET)\n\n"
	@awk -F ':|##' '/^##/ {c=$$2; getline; printf "$(BLUE)%16s$(RESET)%s\n", $$1, c}' $(MAKEFILE_LIST)
	@printf "\n"

# Copy host configuration in plain-text. Mainly used for development hosts.
$(TMPDIR)config/$(HOST).env: $(ROOTDIR)host/$(HOST)/$(HOST).env
	$Q install -d $(@D)
	$Q cp -f $< $@

# Copy encrypted host configuration. Used in production hosts.
$(TMPDIR)config/$(HOST).env.gpg: $(ROOTDIR)host/$(HOST)/$(HOST).env.gpg
	@printf "Decrypting host configuration...\n"
	$Q install -d $(@D)
	$Q $(GPG) -o $@ --decrypt $<

# Copy directory tree if any of the files within are newer than the target directory.
$(TMPDIR)config/%/: $(shell find $(ROOTDIR)config/$* -type f -newer $(TMPDIR)config/$* 2>/dev/null)
	$Q install -d $(dir $(@D))
	$Q cp -Ru $(if $(VERBOSE),-v) $(ROOTDIR)config/$* $(dir $(@D))
	$Q touch $(@D)

# Copy specific file if source file is newer.
$(TMPDIR)config/%: $(ROOTDIR)config/%
	$Q install $(if $(VERBOSE),-v) -D $< $@

# Compile Ignition file from Butane configuration file.
$(TMPDIR)%.ign: $(ROOTDIR)%.bu
	$Q install -d $(@D)
	$Q $(BUTANE) --pretty --strict --files-dir $(TMPDIR)config -o $@ $<

# Download and, optionally, extract Fedora CoreOS installation image.
$(TMPDIR)images/fedora-coreos-$(VERSION)-%:
	@printf "Downloading image file '$(@F)'...\n"
	$Q install -d $(TMPDIR)images
	$Q $(CURL) -o $@ $(IMAGE_URI)$(STREAM)/builds/$(VERSION)/$(ARCH)/$(@F)
	$Q $(CURL) -o $@.sig $(IMAGE_URI)$(STREAM)/builds/$(VERSION)/$(ARCH)/$(@F).sig
	$Q $(GPG) --verify $@.sig
	$Q test $(suffix $(@F)) = .xz && xz --decompress $@ || true
	$Q touch $@

# Generate Makefile dependencies from `local:` definitions in BUTANE files.
$(TMPDIR)make.depend: $(shell find $(ROOTDIR) -name '*.bu' -type f 2>/dev/null)
	@printf "# Automatic prerequisites for Fedora CoreOS configuration." > $@
	@printf "$(foreach i,$^,\n$(patsubst $(ROOTDIR)%.bu,$(TMPDIR)%.ign, \
	         $(i)): $(addprefix $(TMPDIR)config/, $(shell awk -F '[ ]+local:[ ]*' '/[ ]+local:/ {print $$2}' $(i))))" >> $@

# Show help if empty or invalid target has been given.
.DEFAULT:
	@printf "Invalid target '$@'...\n"
	$Q $(MAKE) -s -f $(firstword $(MAKEFILE_LIST)) help

.PHONY: deploy deploy-virtual destroy-virtual clean purge help

# Conditional command echo control.
Q := $(if $(VERBOSE),,@)

# Find and return full path to command by name, or throw error if none can be found in PATH.
# Example use: $(call find-cmd,ls)
find-cmd = $(or $(firstword $(wildcard $(addsuffix /$(1),$(subst :, ,$(PATH))))),$(error "Command '$(1)' not found in PATH"))

# Shell colors, used in messages.
BOLD      := \033[1m
UNDERLINE := \033[4m
BLUE      := \033[36m
RESET     := \033[0m

# Dependency includes.
include $(TMPDIR)make.depend
