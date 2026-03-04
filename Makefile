PREFIX ?= /usr/local

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

all: $(bindir)/fsystemctl

install: all
	install -d $(PREFIX)/$(bindir)
	install $(bin) /usr/local/bin
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

distclean: clean
	$(RM) $(bindir)/fsystemctl

$(peru): peru.yaml
	peru sync

