PREFIX ?= /usr/local

readme := README.md

# Directory containing external files that should not be edited
srcdir := src
# Directory containing editable scripts and converted files from $(srcdir)
bindir := bin
# Install everything in $(bindir) except LICENSE* files
bin = $(filter-out $(wildcard $(bindir)/LICENSE*),$(wildcard $(bindir)/*))

# Where to find and install completions
completions = completions
completionsdir = share/bash-completion/$(completions)

peru = .peru/lastimports

all: $(bindir)/fsystemctl $(readme)

install: all
	install -d $(PREFIX)/$(bindir)
	install $(bin) $(PREFIX)/$(bindir)
	install -d $(PREFIX)/$(completionsdir)
	install $(completions)/* $(PREFIX)/$(completionsdir)

# Convert fuzzy-sys to an executable script and
# change the name used in the help output
$(bindir)/fsystemctl: $(srcdir)/fuzzy-sys $(peru)
	mkdir -p $(dir $@)
	> $@
	chmod +x $@
	echo "#!/bin/bash" >> $@
	echo "#" >> $@
	sed 's/^/# /' $(srcdir)/UNLICENSE.fuzzy-sys >> $@
	echo "#" >> $@
	echo "# Modified from:" >> $@
	echo "#   https://github.com/NullSense/fuzzy-sys/blob/master/fuzzy-sys.plugin.zsh" >> $@ 
	echo "#" >> $@
	cat $< >> $@
	echo '$(notdir $<) "$$*"' >> $@
	sed -i 's/$(notdir $<)/$(notdir $@)/' $@

clean:
	$(RM) $(readme)

distclean: clean
	$(RM) $(bindir)/fsystemctl

$(peru): peru.yaml
	peru sync
	# peru sync does not set mtime
	touch $@

# Generate README.md from 'abstract' tags
#
readme_hdr := readme.header
readme_ext := readme.external

# Base URL for README links
SRCPATH := https://github.com/jbrubake/fzf-scripts/blob/master

# Look for 'abstract' in all tracked files
scripts := $(shell git ls-files $(bindir))

$(readme): peru.yaml $(readme_hdr) $(readme_ext) $(scripts)
	> $@

	# Read abstracts from internal files
	cat $(readme_hdr) >> $@
	./mkreadme.awk -v base_url=$(SRCPATH) $(filter-out $< $(readme_hdr) $(readme_ext),$^) >> $@
	echo >> $@

	# Read abstracts from $< (external files)
	cat $(readme_ext) >> $@
	./mkreadme.awk < $< | sort >> $@
	echo >> $@

