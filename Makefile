# CoreOS options.
NAME       := coreos-home-server
STREAM     ?= stable
ARCH       ?= x86_64
VERSION    ?= $(call coreos-version,$(ARCH))
HOST       := $(if $(filter deploy,$(MAKECMDGOALS)),$(if $(HOST),$(HOST),$(error Please specify a valid HOST to deploy)),$(HOST))
TYPE       := $(if $(filter deploy,$(MAKECMDGOALS)),$(if $(filter virtual,$(HOST)),virtual,$(if $(TYPE),$(TYPE),$(error Please specify a valid deployment TYPE))),$(TYPE))
STREAM_URI := https://builds.coreos.fedoraproject.org/streams/$(STREAM).json
IMAGE_URI  := https://builds.coreos.fedoraproject.org/prod/streams/

# Default Makefile options.
VERBOSE :=
ROOTDIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
TMPDIR  := $(shell ls -d /var/tmp/$(NAME).???? 2>/dev/null || mktemp -d /var/tmp/$(NAME).XXXX && chmod 0755 /var/tmp/$(NAME).????)/

# Target-specific variables.
ADDRESS        ?= $(shell ip -o route get 1 | awk '{for (i=1; i<=NF; i++) {if ($$i == "src") {print $$(i+1); exit}}}')
CONTAINERFILES ?= $(wildcard service/*/Containerfile)
VIRTUAL_PORTS  ?= 8022:22 8025:25 8080:80 8143:143 8443:443 8465:465 8587:587 8993:993 5222:5222 5223:5223 5269:5269 5347:5347 7920:7920

# Build-time dependencies.
BUTANE ?= $(call find-cmd,butane)
PODMAN ?= $(call find-cmd,podman)
CURL   ?= $(call find-cmd,curl) $(if $(VERBOSE),,--progress-bar) --fail
GPG    ?= $(call find-cmd,gpg) $(if $(VERBOSE),,-q)
QEMU   ?= $(call find-cmd,qemu-system-$(ARCH)) -enable-kvm
NC     ?= $(call find-cmd,nc) -vv -r -l
XZ     ?= $(call find-cmd,xz) $(if $(VERBOSE),--verbose)
JQ     ?= $(call find-cmd,jq) --raw-output

# Common-use functions.
#
# Find and return full path to command by name, or throw error if none can be found in PATH.
# Example use: $(call find-cmd,ls)
find-cmd = $(or $(firstword $(wildcard $(addsuffix /$(1),$(subst :, ,$(PATH))))),$(error "Command '$(1)' not found in PATH"))

# Get latest release for given architecture.
# Example use: $(call coreos-version,x86_64)
coreos-version = $(shell $(CURL) --silent $(STREAM_URI) | $(JQ) '.architectures.$(1).artifacts.metal.release')

## Builds and deploys Fedora CoreOS for HOST of TYPE.
deploy: deploy-$(TYPE)

## Remove deployment configuration files required for build.
clean:
	@printf "Removing deployment configuration files...\n"
	$Q rm -Rf $(TMPDIR)deploy

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
	@awk -F ':|##' '/^##/ {c=$$2; getline; printf "$(BLUE)%6s$(RESET)%s\n", $$1, c}' $(MAKEFILE_LIST)
	@printf "\n"

# Builds and deploys Fedora CoreOS for HOST on ADDRESS.
deploy-metal: $(TMPDIR)deploy/host/$(HOST)/spec.ign
	@printf "Serving Ignition config '$<' over HTTP...\n"
	@printf 'HTTP/1.0 200 OK\r\nContent-Length: %d\r\n\r\n%s\n' "$$(wc -c < $<)" "$$(cat $<)" | $(NC) -s $(ADDRESS) || exit 0

# Prepares and deploys CoreOS release for local, virtual environment.
deploy-virtual: $(TMPDIR)images/fedora-coreos-$(VERSION)-qemu.$(ARCH).qcow2 $(TMPDIR)deploy/host/$(HOST)/spec.ign
	@printf "Preparing virtual environment (press C-a h for help)...\n"
	$Q $(QEMU) -m 4096 -cpu host -nographic -snapshot \
	           -fw_cfg name=opt/com.coreos/config,file=$(TMPDIR)deploy/host/$(HOST)/spec.ign \
	           -drive if=virtio,file=$(TMPDIR)images/fedora-coreos-$(VERSION)-qemu.$(ARCH).qcow2 \
	           -nic user,model=virtio,$(subst $(SPACE),$(COMMA),$(foreach p,$(VIRTUAL_PORTS),hostfwd=tcp::$(subst :,-:,$(p))))

# Build container file locally using 'podman build'.
$(CONTAINERFILES):
	@printf "Building container for '$(notdir $(@D))'...\n"
	$Q cd "$(abspath $(@D))" && $(PODMAN) build .

# Copy host configuration in plain-text. Mainly used for development hosts.
$(TMPDIR)deploy/$(HOST).env: $(ROOTDIR)host/$(HOST)/$(HOST).env
	$Q install -d $(@D)
	$Q cp -f $< $@

# Copy encrypted host configuration. Used in production hosts.
$(TMPDIR)deploy/$(HOST).env.gpg: $(ROOTDIR)host/$(HOST)/$(HOST).env.gpg
	@printf "Waiting to decrypt configuration for '$(HOST)'...\n"
	$Q install -d $(@D)
	$Q $(GPG) -o $@ --decrypt $<

# Copy directory tree if any of the files within are newer than the target directory.
$(TMPDIR)deploy/%/: $(shell find $(ROOTDIR)$* -type f -newer $(TMPDIR)deploy/$* 2>/dev/null)
	$Q install -d $(dir $(@D))
	$Q cp -Ru $(if $(VERBOSE),-v) $(ROOTDIR)$* $(dir $(@D))
	$Q touch $(@D)

# Copy specific file if source file is newer.
$(TMPDIR)deploy/%: $(ROOTDIR)%
	$Q install $(if $(VERBOSE),-v) -D $< $@

# Compile Ignition file from Butane configuration file.
$(TMPDIR)deploy/%.ign: $(ROOTDIR)%.bu
	$Q install -d $(@D)
	$Q $(BUTANE) --pretty --strict --files-dir $(TMPDIR)deploy -o $@ $<

# Download and, optionally, extract Fedora CoreOS installation image.
$(TMPDIR)images/fedora-coreos-$(VERSION)-%:
	@printf "Downloading image file '$(@F)'...\n"
	$Q install -d $(TMPDIR)images
	$Q $(CURL) -o $@.xz.sig $(IMAGE_URI)$(STREAM)/builds/$(VERSION)/$(ARCH)/$(@F).xz.sig
	$Q $(CURL) -o $@.xz $(IMAGE_URI)$(STREAM)/builds/$(VERSION)/$(ARCH)/$(@F).xz
	$Q $(GPG) --verify $@.xz.sig
	$Q $(XZ) --decompress $@.xz

# Generate Makefile dependencies from `local:` definitions in BUTANE files.
$(TMPDIR)make.depend: $(shell find $(ROOTDIR) -name '*.bu' -type f 2>/dev/null)
	@printf "# Automatic prerequisites for Fedora CoreOS configuration." > $@
	@printf "$(foreach i,$^,\n$(patsubst $(ROOTDIR)%.bu,$(TMPDIR)deploy/%.ign, \
	         $(i)): $(addprefix $(TMPDIR)deploy/, $(shell awk -F '[ ]+local:[ ]*' '/^[ ]+(-[ ]+)?local:/ {print $$2}' $(i))))" >> $@

.PHONY: deploy deploy-metal deploy-virtual clean purge help $(CONTAINERFILES)

# Conditional command echo control.
Q := $(if $(VERBOSE),,@)

# Shell colors, used in messages.
BOLD      = \033[1m
UNDERLINE = \033[4m
BLUE      = \033[36m
RESET     = \033[0m

# Variables for reserved characters.
SPACE = $(eval) $(eval)
COMMA = ,

# Dependency includes.
include $(TMPDIR)make.depend
