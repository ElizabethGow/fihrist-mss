<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:jc="http://james.blushingbunny.net/ns.html" exclude-result-prefixes="tei jc xsi"
    version="2.0" xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance">



    <!-- Set up the collection of files to be converted -->
    <!-- files and recurse parameters defaulting to '*.xml' and 'no' respectively -->
    <xsl:param name="files" select="'*.xml'"/>
    <!-- <xsl:param name="recurse" select="yes" /> -->

    <!-- path hard-coded to location on my desktop cuz that was convenient -->
    <xsl:variable name="path">
        <xsl:value-of
            select="concat('../collections/?select=', $files,';on-error=warning;recurse=yes')"/>
    </xsl:variable>

    <!-- the main collection of all the documents we are dealing with -->
    <xsl:variable name="doc" select="collection($path)"/>

    <!-- Named template which we call that starts off the whole thing-->
    <xsl:template name="main">
        <!-- For each item in the collection -->
        <xsl:for-each select="$doc">
            <xsl:sort select="tokenize(base-uri(), '/')[last()-1]"/>
            <xsl:sort select="tokenize(base-uri(), '/')[last()]"/>
            <xsl:variable name="baseURI">
                <xsl:value-of select="base-uri()"/>
            </xsl:variable>
            <xsl:variable name="filename">
                <xsl:value-of select="tokenize(base-uri(), '/')[last()]"/>
            </xsl:variable>
            <xsl:variable name="folder">
                <xsl:value-of select="tokenize(base-uri(), '/')[last()-1]"/>
            </xsl:variable>
            <xsl:variable name="fileNum">
                <xsl:value-of select="position()"/>
            </xsl:variable>


            <!-- This is just a debugging message so I see the filnames whiz by on the screen
              and I know what the last file was when something breaks  -->
            <!--<xsl:message>
                <xsl:value-of select="$filename"/>
            </xsl:message>-->

            <!-- Create the (hard coded) output file name -->
            <xsl:variable name="outputFilename"
                select="concat('../collections-proc/', $folder, '/', $filename)"/>
            <!-- create output file -->
            <xsl:result-document href="{$outputFilename}" method="xml" indent="yes">

                <xsl:apply-templates/>

            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>

    <!-- By default we just copy the input to the output when it isn't empty -->
    <xsl:template match="*" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- By default we copy the text to the output except we normalize space since it is so messy -->
    <xsl:template match="text()" priority="2">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <!-- If something is entirely empty (no descendent text content or attributes)
          and not matched separately let's get rid of it. -->
    <!--<xsl:template match="node()" priority="-1"/>-->

    <!-- By default, copy attributes -->
    <xsl:template match="@*" priority="-1">
        <xsl:if test="not(normalize-space(.) = '')">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>

    <xsl:template
        match="profileDesc/textClass/keywords/list/item//ref[starts-with(@target, 'http')]">

        <xsl:variable name="key1">


            <xsl:value-of select="@target"/>

        </xsl:variable>

        <xsl:variable name="key2">

            <xsl:choose>
                <xsl:when test="contains($key1, '#')">
                    <xsl:value-of select="substring-before($key1, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$key1"/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:variable>

        <xsl:variable name="key3">

            <xsl:choose>
                <xsl:when test="ends-with($key2, '/')">
                    <xsl:value-of select="substring($key2, 1, string-length($key2) - 1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$key2"/>
                </xsl:otherwise>

            </xsl:choose>

        </xsl:variable>

        <xsl:variable name="key4">
            
            <xsl:choose>
                <xsl:when test="contains($key3, '.html')">
                    <xsl:value-of select="substring-before($key3, '.html')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$key3"/>
                </xsl:otherwise>
            </xsl:choose>
            
            
            
        </xsl:variable>


        <xsl:variable name="key5">

            <xsl:value-of select="tokenize($key4, '/')[last()]"/>

        </xsl:variable>

        <xsl:variable name="key6">

            <xsl:value-of select="concat('subject_', $key5)"/>

        </xsl:variable>

        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:id" select="$key6"/>
            <xsl:apply-templates/>
        </xsl:copy>

        <xsl:message select="$key6"/>


    </xsl:template>







    <!-- to copy return true/false  if something is empty-->
    <xsl:function name="jc:checkEmpty" as="text()">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="output">
            <xsl:choose>
                <xsl:when
                    test="($node//text()[string-length(normalize-space(.)) gt 1]) or ($node//@*[string-length(normalize-space(.)) gt 1])"
                    >false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="normalize-space($output)"/>
    </xsl:function>



</xsl:stylesheet>
