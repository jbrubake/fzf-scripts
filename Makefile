PREFIX ?= /usr/local

# Editable templates and shells
srcdir = src
# Editable scripts
bindir = bin
# Generated intermediate files
gendir = gen
# Generated, installable files
outdir = out

completions = completions
completionsdir = share/bash-completion/$(completions)

parsers = $(shell sed -n '/parser_definition/s/.*_\(.*\)().*/\1/p' src/ix-parsers)

all: $(outdir)/fsystemctl $(outdir)/ix

install: all
	install -d $(PREFIX)/$(bindir)
	$(foreach d,$(bindir) $(outdir),install $d/* $(PREFIX)/$(bindir);)
	install -d $(PREFIX)/$(completionsdir)
	install $(completions)/* $(PREFIX)/$(completionsdir)

# Convert fuzzy-sys to an executable script and
# change the name used in the help output
$(outdir)/fsystemctl: $(srcdir)/fuzzy-sys
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
$(gendir)/ix-parsers: $(srcdir)/ix-parsers
	mkdir -p $(dir $@)
	> $@
	$(foreach p,$(parsers), < $< gengetoptions parser parser_definition_$p parse_$p ix >> $@;)

# Put ix parsers into final script
# NOTE: pre-req order matters
$(outdir)/ix: $(srcdir)/ix $(gendir)/ix-parsers
	sed '/@include/r $(filter-out $<,$^)' $< > $@
	chmod +x $@

distclean:
	rm -f $(gendir)/ix-parsers
	rmdir $(gendir) 2>/dev/null || true
	rm -f $(outdir)/*
	rmdir $(outdir) 2>/dev/null || true

