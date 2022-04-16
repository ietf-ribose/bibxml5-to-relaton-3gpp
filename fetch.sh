mkdir /tmp/bibxml-to-relaton-3gpp
rsync -avuz xml2rfc.tools.ietf.org::xml2rfc.bibxml/bibxml5 /tmp/bibxml-to-relaton-3gpp
rm /tmp/bibxml-to-relaton-3gpp/bibxml5/reference.3GPP.3.xml
rm /tmp/bibxml-to-relaton-3gpp/bibxml5/reference.3GPP..xml
if [ ! -f /tmp/bibxml-to-relaton-3gpp/main.zip ]; then wget https://github.com/ietf-ribose/relaton-data-3gpp/archive/refs/heads/main.zip -O /tmp/bibxml-to-relaton-3gpp/main.zip; fi
if [ ! -d /tmp/bibxml-to-relaton-3gpp/relaton-data-3gpp-main ]; then (cd /tmp/bibxml-to-relaton-3gpp && unzip main.zip); fi
