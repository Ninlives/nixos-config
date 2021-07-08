if did_filetype()
	finish
endif
if getline(1) =~ '^#!.*/bin/\S*'
	execute "setfiletype " . matchlist(getline(1), '^#!.*/bin/\(\S*\)')[1]
endif
