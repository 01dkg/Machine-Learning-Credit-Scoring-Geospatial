#!/usr/bin/perl -w
#
# list2idx - use the \n-separated list of words `concepts.list' to scan a
#            document from stdin, in order to generate a new document
#            list2idx-out.tex with \index entries.
#
# Copyright (C) 19 january 1999 B.W. van Schooten
#
# Obvious limitations:
# * It's not very fast, it scans 200 concepts in 150K of text in 1 minute
#   on a pentium pro 180.
# * Sometimes, the \index entried are generated where they cause trouble
#   in the latex code. This seems to happen especially with tables.
# * the \index's inserted are at worst one line below the match; this means
#   that there is a small chance that the page number listed in the index
#   is one more than the actual page. 

open(LISTIN,"<concepts.list");
#open(DOCOUT,">list2idx-out.tex");

# list of regexps
@explst= ();
# list of \index{..} strings
@idxlst= ();

# read concepts.list into @explst and @idxlst
while (<LISTIN>) {
	# chop all whitespace at beginning and end
	s/\s+$//;
	s/^\s+//;
	# convert spaces to regular expression `\s*'
	push @idxlst, ("\\index{$_}");
	while (s/\s+/\\s\+/) {};
	push @explst, ("\\b$_\\b");
}


@linebuf=("","","","");
@explstoccur=();

# read stdin line by line, keep buffer of last few lines.
while (<STDIN>) {
	# pan the multiline buffer, print the entry that falls off to output.
	print shift(@linebuf);
	push @linebuf,($_);

	# Search for patterns in buffer. Pattern found => 1 in explstoccur[i],
	# not found => 0 in explstoccur[i].
	# Before the new value is written, the old value is checked. If there
	# was a change 1->0, the idxlst[i] is written to output.
	$_="@linebuf";
	for ($i=0; $i<$#explst; $i++) {
		if (not defined($explstoccur[$i])) { $explstoccur[$i]=0; }
		if (/$explst[$i]/i) {
			$explstoccur[$i]=1;
		} else {
			if ($explstoccur[$i]==1) {
				print $idxlst[$i]."\n";
			}
			$explstoccur[$i]=0;
		}
	}
}



