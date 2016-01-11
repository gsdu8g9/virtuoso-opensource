<?xml version="1.0"?>
<!--
 -
 -  $Id$
 -
 -  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
 -  project.
 -
 -  Copyright (C) 1998-2016 OpenLink Software
 -
 -  This project is free software; you can redistribute it and/or modify it
 -  under the terms of the GNU General Public License as published by the
 -  Free Software Foundation; only version 2 of the License, dated June 1991.
 -
 -  This program is distributed in the hope that it will be useful, but
 -  WITHOUT ANY WARRANTY; without even the implied warranty of
 -  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 -  General Public License for more details.
 -
 -  You should have received a copy of the GNU General Public License along
 -  with this program; if not, write to the Free Software Foundation, Inc.,
 -  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 -
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:wfw="http://wellformedweb.org/CommentAPI/"
  xmlns:slash="http://purl.org/rss/1.0/modules/slash/"
  xmlns:content="http://purl.org/rss/1.0/modules/content/"
  xmlns:r="http://backend.userland.com/rss2"
  xmlns:ocs = "http://InternetAlchemy.org/ocs/directory#"
  version="1.0">

<xsl:output indent="yes" cdata-section-elements="content:encoded" />


<!-- general element conversions -->

<xsl:template match="/">
  <xsl:comment>OCS based XML document generated By OpenLink Virtuoso</xsl:comment>
  <rdf:RDF>
    <xsl:apply-templates/>
  </rdf:RDF>
</xsl:template>

<xsl:template match="opml">
    <rdf:description about="">
	<dc:title><xsl:apply-templates select="head/title"/></dc:title>
	<cd:creator/>
	<xsl:apply-templates select="body/outline"/>
    </rdf:description>
</xsl:template>

<xsl:template match="body/outline">
    <rdf:description about="{@xmlUrl}">
	<dc:title><xsl:value-of select="@title"/></dc:title>
	<rdf:description about="{@xmlUrl}">
	    <dc:language>en</dc:language>
	    <ocs:format>http://my.netscape.com/rdf/simple/0.9/</ocs:format>
	    <ocs:updatePeriod>monthly</ocs:updatePeriod>
	    <ocs:updateFrequency>1</ocs:updateFrequency>
	</rdf:description>
    </rdf:description>
</xsl:template>

</xsl:stylesheet>
