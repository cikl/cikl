package CIF::Smrt::Parsers;

# time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/00_alexa_whitelist.cfg -f top100 -v2
use CIF::Smrt::Parsers::ParseDelim;

# time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/malwaredomainlist.cfg -f malwaredomainlist -v2
use CIF::Smrt::Parsers::ParseCsv;

# time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/phishtank.cfg -f urls -v2 
use CIF::Smrt::Parsers::ParseJson;

# time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/zeustracker.cfg -f binaries -g 90
use CIF::Smrt::Parsers::ParseRss;

# time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/misc.cfg -f sshbl.org
use CIF::Smrt::Parsers::ParseTxt;

# time perl  cif-smrt/bin/cif_smrt -C cif.conf  -r cif-smrt/rules/etc/cleanmx.cfg -f malware 
use CIF::Smrt::Parsers::ParseXml;

1;
