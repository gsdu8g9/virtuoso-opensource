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
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:wfw="http://wellformedweb.org/CommentAPI/"
  xmlns:slash="http://purl.org/rss/1.0/modules/slash/"
  xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns="http://www.w3.org/2005/Atom"
  xmlns:vi="http://www.openlinksw.com/weblog/"
  xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/"
  xmlns:itunes="http://www.itunes.com/DTDs/Podcast-1.0.dtd"
  xmlns:media="http://search.yahoo.com/mrss"
  version="1.0">

<xsl:output indent="yes" />

<xsl:template match="/">
    <xsl:comment>RSS with Yahoo Media extensions based XML document generated By OpenLink Virtuoso</xsl:comment>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="rss|rss/channel|rss/channel/title|rss/channel/link|rss/channel/description|item[enclosure[@url!='']]|item/title|item/link">
    <xsl:copy>
	<xsl:copy-of select="@*" />
	<xsl:apply-templates />
    </xsl:copy>
</xsl:template>

<xsl:template match="item/enclosure">
    <media:content url="{@url}" fileSize="{@length}" type="{@type}" expression="full">
	<media:text type="plain">
	    <xsl:apply-templates select="parent::item/description" mode="removeTags" />
	</media:text>
	<media:rating>nonadult</media:rating>
	<media:keywords>
	    <xsl:value-of select="parent::item/itunes:keywords" />
	</media:keywords>
    </media:content>
</xsl:template>

<xsl:template match="*" />

<xsl:template match="text()">
  <xsl:value-of select="normalize-space(.)" />
</xsl:template>

<xsl:template match="*" mode="removeTags">
    <xsl:call-template name="removeTags" />
</xsl:template>

<xsl:template name="removeTags">
  <xsl:param name="html" select="." />
  <xsl:choose>
    <xsl:when test="contains($html,'&lt;')">
      <xsl:call-template name="removeEntities">
        <xsl:with-param name="html" select="substring-before($html,'&lt;')" />
      </xsl:call-template>
      <xsl:call-template name="removeTags">
        <xsl:with-param name="html" select="substring-after($html, '&gt;')" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="removeEntities">
        <xsl:with-param name="html" select="$html" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="removeEntities">
  <xsl:param name="html" select="." />
  <xsl:choose>
    <xsl:when test="contains($html,'&amp;')">
      <xsl:value-of select="substring-before($html,'&amp;')" />
      <xsl:variable name="c" select="substring-before(substring-after($html,'&amp;'),';')" />
      <xsl:choose>
        <xsl:when test="$c='nbsp'">&#160;</xsl:when>
        <xsl:when test="$c='lt'">&lt;</xsl:when>
        <xsl:when test="$c='gt'">&gt;</xsl:when>
        <xsl:when test="$c='amp'">&amp;</xsl:when>
        <xsl:when test="$c='quot'">&quot;</xsl:when>
        <xsl:when test="$c='apos'">&apos;</xsl:when>
        <xsl:otherwise>?</xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="removeTags">
        <xsl:with-param name="html" select="substring-after($html, ';')" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$html" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
