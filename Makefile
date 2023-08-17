PREFIX ?= /usr/local

# Editable templates and shells
srcdir = src
# Editable scripts
bindir = bin
# Generated intermediate files
genext = gen

completions = completions
completionsdir = share/bash-completion/$(completions)

parsers = $(shell sed -n '/parser_definition/s/.*_\(.*\)().*/\1/p' src/ix-parsers)

all: $(bindir)/fsystemctl $(bindir)/ix

install: all
	install -d $(PREFIX)/$(bindir)
	install bin/* /usr/local/bin
	install -d $(PREFIX)/$(completionsdir)
	install $(completions)/* $(PREFIX)/$(completionsdir)

# Convert fuzzy-sys to an executable script and
# change the name used in the help output
$(bindir)/fsystemctl: $(srcdir)/fuzzy-sys
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
	echo '$(notdir $^) "$$*"' >> $@
	sed -i 's/$(notdir $<)/$(notdir $@)/' $@

# Generate ix parsers
$(srcdir)/ix-parsers.$(genext): $(srcdir)/ix-parsers
	mkdir -p $(dir $@)
	> $@
	$(foreach p,$(parsers), < $< gengetoptions parser parser_definition_$p parse_$p ix >> $@;)

# Put ix parsers into final script
# NOTE: pre-req order matters
$(bindir)/ix: $(srcdir)/ix $(srcdir)/ix-parsers.$(genext)
	sed '/@include/r $(filter-out $<,$^)' $< > $@
	chmod +x $@

clean:
	rm -f $(bindir)/fsystemctl
	rm -f $(bindir)/ix

distclean: clean
	rm -f $(srcdir)/ix-parsers.$(genext)

