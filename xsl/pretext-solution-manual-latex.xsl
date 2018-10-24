<?xml version='1.0'?> <!-- As XML file -->

<!--********************************************************************
Copyright 2018 Robert A. Beezer

This file is part of PreTeXt.

MathBook XML is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 or version 3 of the
License (at your option).

MathBook XML is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MathBook XML.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************-->

<!-- http://pimpmyxslt.com/articles/entity-tricks-part2/ -->
<!DOCTYPE xsl:stylesheet [
    <!ENTITY % entities SYSTEM "entities.ent">
    %entities;
]>

<!-- Identify as a stylesheet -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:exsl="http://exslt.org/common"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="exsl date str"
>

<xsl:import href="./mathbook-latex.xsl" />

<!-- Intend output for rendering by pdflatex -->
<xsl:output method="text" />

<!-- These variables are interpreted in mathbook-common.xsl and  -->
<!-- so may be used/set in a custom XSL stylesheet for a         -->
<!-- project's solution manual.                                  -->
<!--                                                             -->
<!-- exercise.inline.hint                                        -->
<!-- exercise.inline.answer                                      -->
<!-- exercise.inline.solution                                    -->
<!-- exercise.divisional.hint                                    -->
<!-- exercise.divisional.answer                                  -->
<!-- exercise.divisional.solution                                -->
<!-- project.hint                                                -->
<!-- project.answer                                              -->
<!-- project.solution                                            -->
<!--                                                             -->
<!-- The second set of variables are internal, and are derived   -->
<!-- from the above via careful routines in mathbook-common.xsl. -->
<!--                                                             -->
<!-- b-has-inline-hint                                           -->
<!-- b-has-inline-answer                                         -->
<!-- b-has-inline-solution                                       -->
<!-- b-has-divisional-hint                                       -->
<!-- b-has-divisional-answer                                     -->
<!-- b-has-divisional-solution                                   -->
<!-- b-has-project-hint                                          -->
<!-- b-has-project-answer                                        -->
<!-- b-has-project-solution                                      -->

<!-- We have a switch for just this situation, to force -->
<!-- (overrule) the auto-detetion of the necessity for  -->
<!-- LaTeX styles for the solutions to exercises.       -->
<!-- See  mathbook-latex.xsl  for more explanation.     -->
<xsl:variable name="b-needs-solution-styles" select="true()"/>

<!-- For a "book" we replace the first chapter by a call to the        -->
<!-- solutions generator.  So we burrow into parts to get at chapters. -->

<xsl:template match="part|chapter|backmatter/solutions" />

<xsl:template match="part[1]">
    <xsl:apply-templates select="chapter[1]" />
</xsl:template>

<xsl:template match="chapter[1]">
    <xsl:apply-templates select="$document-root" mode="solutions-generator">
        <xsl:with-param name="b-inline-statement"     select="false()" />
        <xsl:with-param name="b-inline-hint"          select="$b-has-inline-hint"  />
        <xsl:with-param name="b-inline-answer"        select="$b-has-inline-answer"  />
        <xsl:with-param name="b-inline-solution"      select="$b-has-inline-solution"  />
        <xsl:with-param name="b-divisional-statement" select="false()" />
        <xsl:with-param name="b-divisional-hint"      select="$b-has-divisional-hint"  />
        <xsl:with-param name="b-divisional-answer"    select="$b-has-divisional-answer"  />
        <xsl:with-param name="b-divisional-solution"  select="$b-has-divisional-solution"  />
        <xsl:with-param name="b-project-statement"    select="false()" />
        <xsl:with-param name="b-project-hint"         select="$b-has-project-hint"  />
        <xsl:with-param name="b-project-answer"       select="$b-has-project-answer"  />
        <xsl:with-param name="b-project-solution"     select="$b-has-project-solution"  />
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="part|chapter|section|subsection|subsubsection|exercises" mode="division-in-solutions">
    <xsl:param name="scope" />
    <xsl:param name="content" />

    <!-- LaTeX heading with hard-coded number -->
    <xsl:text>\</xsl:text>
    <xsl:apply-templates select="." mode="division-name" />
    <xsl:text>*{</xsl:text>
    <!-- control the numbering, i.e. hard-coded -->
    <xsl:variable name="the-number">
        <xsl:apply-templates select="." mode="number" />
    </xsl:variable>
    <!-- no trailing space if no number -->
    <xsl:if test="not($the-number = '')">
        <xsl:value-of select="$the-number" />
        <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="." mode="title-full" />
    <xsl:text>}&#xa;</xsl:text>
    <!-- An entry for the ToC, since we hard-code numbers -->
    <!-- These mainmatter divisions should always have a number -->
    <xsl:text>\addcontentsline{toc}{</xsl:text>
    <xsl:apply-templates select="." mode="division-name" />
    <xsl:text>}{</xsl:text>
    <xsl:value-of select="$the-number" />
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="." mode="title-simple" />
    <xsl:text>}&#xa;</xsl:text>

    <xsl:copy-of select="$content" />
</xsl:template>

<!-- Hard-Coded Numbers -->
<!-- As a subset of full content, we can't          -->
<!-- point to much of the content with hyperlinks   -->
<!-- But we do have the full context as we process, -->
<!-- so we can get numbers for cross-references     -->
<!-- and *hard-code* them into the LaTeX              -->

<!-- We don't dither about possibly using a \ref{} and  -->
<!-- just produce numbers.  These might lack the "part" -->
<xsl:template match="*" mode="xref-number">
  <xsl:apply-templates select="." mode="number" />
</xsl:template>

<!-- The actual link is not a \hyperlink nor a    -->
<!-- hyperref, but instead is just plain 'ol text -->
<xsl:template match="*" mode="xref-link">
    <xsl:param name="content" select="'MISSING LINK CONTENT'"/>
    <xsl:value-of select="$content" />
</xsl:template>

</xsl:stylesheet>
