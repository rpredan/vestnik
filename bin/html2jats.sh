#!/bin/sh
# This command file runs html2jats.xsl to convert
# original Slovenenian xhtml and translated English xhtml
# (from a specific journal article xhtml format exported from InDesign)
# to JATS format for PubMedCentral.

# SAXON_HOME must be set to the folder containing saxon9he.jar.
# SAXON_HOME=~/SaxonHE9-8-0-14J
# export SAXON_HOME
#
# RESOLVER_HOME must be set to the folder containing resolver.jar.
# RESOLVER_HOME=~/xml-commons-resolver-1.2
# export RESOLVER_HOME

# html2jats.sh must be in the same folder as html2jats.xsl
HTML2JATS_HOME=$(realpath --relative-to=. $(dirname $0))

# parameters: path-to/NNNN [pass]
# where NNNN is both a folder name and part of file names.
# where [pass] is optional, may be "sl", "en", "combine", or "all" (default)
#
# For example, suppose NNNN is '2660', then the folder may contain
#   path-to/2660/2660.html
#   path-to/2660/2660-en.html
#   path-to/2660/2660_edifiX_JATSXML.xml
# Output may be written to
#   path-to/2660/2660-sl.xml
#   path-to/2660/2660-en.xml
#   path-to/2660/2660-all.xml

DIR=$(realpath --relative-to=. $1)
FILE=$(basename $DIR)

if [[ ( -z "$2" || "$2" = "all" || "$2" = "sl") && -f "$DIR/$FILE.html" ]];
then
    java -cp "$SAXON_HOME/saxon9he.jar;${RESOLVER_HOME}/resolver.jar" \
	 net.sf.saxon.Transform \
	 "-catalog:${HTML2JATS_HOME}/jats-dtd-catalog.xml" \
	 "-xsl:$HTML2JATS_HOME/html2jats.xsl" \
	 "-s:$DIR/$FILE.html" \
	 "-o:$DIR/$FILE-sl.xml" \
	 "+reflistDoc=$DIR/${FILE}_edifiX_JATSXML.xml"
fi

if [[ ( -z "$2" || "$2" = "all" || "$2" = "en") && -f "$DIR/$FILE-en.html" ]];
then
    java -cp "$SAXON_HOME/saxon9he.jar;${RESOLVER_HOME}/resolver.jar" \
	 net.sf.saxon.Transform \
	 "-catalog:${HTML2JATS_HOME}/jats-dtd-catalog.xml" \
	 "-xsl:$HTML2JATS_HOME/html2jats.xsl" \
	 "-s:$DIR/$FILE-en.html" \
	 "-o:$DIR/$FILE-en.xml" \
	 "+reflistDoc=$DIR/${FILE}_edifiX_JATSXML.xml"
fi

if [[ ( -z "$2" || "$2" = "all" || "$2" = "combine" )
      && -f "$DIR/$FILE-sl.xml" && -f "$DIR/$FILE-en.xml" ]];
then   
    java -cp "$SAXON_HOME/saxon9he.jar;${RESOLVER_HOME}/resolver.jar" \
	 net.sf.saxon.Transform \
	 "-catalog:${HTML2JATS_HOME}/jats-dtd-catalog.xml" \
	 "-xsl:$HTML2JATS_HOME/combinejats.xsl" \
	 "-s:$DIR/$FILE-sl.xml" \
	 "-o:$DIR/$FILE-all.xml" \
	 "+translatedDoc=$DIR/$FILE-en.xml"
fi
