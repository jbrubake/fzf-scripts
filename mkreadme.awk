#!/bin/awk -f

function print_entry(name, base_url, filename, description, license)
{
    # Extract the description
    sub("^.*abstract[^:]*:[[:space:]]*", "", description)

    printf("- [%s](%s%s) - %s%s\n",
        name, base_url,
        filename ? "/" filename : "",
        description,
        license ? " (" license ")" : "")
}

BEGINFILE {
    # Use the filename without extension for the name of
    # entries pulled from source files. FILENAME is unchanged
    # so that links still point to the source
    basename = gensub("\\.c$", "", 1, FILENAME);

    # Don't use a previous url
    url = ""
}

# If url: and/or license: are used, the order must be:
# url: <URL>
# license: <license>
# abstract: <abstract>
# abstract: <abstract>
# ...
#
# The most recent url and license in the file will be included with
# each abstract. The license is cleared when a new url is found
/url:/     { url     = gensub(/.*url:[[:space:]]*/, "", 1);     license = ""; next }
/license:/ { license = gensub(/.*license:[[:space:]]*/, "", 1);               next }

# Normal abstracts (abstract: ...)
# By-name abstracts (abstract-<name>: ...)
#
/abstract-?[^:]*:/ {
    # Extract the name from abstract-<name>: ...
    # name == $0 for abstract: ...
    name = gensub(/^.*abstract-([^:]+):.*$/, "\\1", 1)

    # Get the name of the program
    #
    # abstract: ...
    if (name == $0) {
        if (FILENAME == "-") {
            # stdin doesn't have a filename so extract the "word" prior
            # to the abstract (i.e., ....<name> # abstract:...) and use
            # that as the name and filename for the link
            name = gensub(/^.*[[:space:]]([^[:space:]]+)[[:space:]]+[^[:space:]]+[[:space:]]*abstract:.*$/, "\\1", 1, $0)
        } else {
            name = basename
        }
    # Skip abstract-<name>: ... that is for a different file
    } else if (name != basename && FILENAME != "-") {
        next
    } # else use abstract-<name>: ... for this file or stdin

    # Set url target
    #
    if (FILENAME == "-") {
        # Use the exact URL from the url: tag
        target = ""

        # Strip source file extensions from name
        name = gensub("\\.c$", "", 1, name);
    } else {
        target = FILENAME
    }

    # Strip path from name
    name = gensub("^.*/", "", 1, name);

    print_entry(name, url ? url : base_url, target, $0, license)

    # Skip ahead if we got what we needed
    if (name == basename) {
        nextfile
    } else {
        next
    }
}

