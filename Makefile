PREFIX ?= /usr/local
srcdir = src
bindir = bin
completions = completions
completionsdir = share/bash-completion/$(completions)

all: $(bindir)/fsystemctl

install: all
	install -d $(PREFIX)/$(bindir)
	install $(bindir)/* $(PREFIX)/$(bindir)
	install -d $(PREFIX)/$(completionsdir)
	install $(completions)/* $(PREFIX)/$(completionsdir)


# Convert fuzzy-sys to an executable script and
# change the name used in the help output
$(bindir)/fsystemctl: $(srcdir)/fuzzy-sys
	> $@
	chmod +x $@
	echo "#!/bin/bash" >> $@
	echo "#" >> $@
	sed 's/^/# /' $(srcdir)/UNLICENSE >> $@
	echo "#" >> $@
	echo "# Modified from:" >> $@
	echo "#   https://github.com/NullSense/fuzzy-sys/blob/master/fuzzy-sys.plugin.zsh" >> $@ 
	echo "#" >> $@
	cat $^ >> $@
	echo '$(notdir $^) "$$*"' >> $@
	sed -i 's/$(notdir $^)/$(notdir $@)/' $@
