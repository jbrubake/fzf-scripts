PREFIX ?= /usr/local

# Editable templates and shells
srcdir = src
# Editable scripts
bindir = bin
# Generated intermediate files
genext = gen

completions = completions
completionsdir = share/bash-completion/$(completions)

peru = .peru/lastimports

all: $(bindir)/fsystemctl

install: all
	install -d $(PREFIX)/$(bindir)
	install bin/* /usr/local/bin
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
	sed 's/^/# /' $(srcdir)/UNLICENSE >> $@
	echo "#" >> $@
	echo "# Modified from:" >> $@
	echo "#   https://github.com/NullSense/fuzzy-sys/blob/master/fuzzy-sys.plugin.zsh" >> $@ 
	echo "#" >> $@
	cat $< >> $@
	echo '$(notdir $<) "$$*"' >> $@
	sed -i 's/$(notdir $<)/$(notdir $@)/' $@

clean:
	rm -f $(bindir)/fsystemctl

distclean: clean

$(peru): peru.yaml
	peru sync

