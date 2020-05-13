<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns="http://hl7.org/fhir"
    xmlns:f="http://hl7.org/fhir"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:nts="http://nictiz.nl/xsl/testscript"
    exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:include href="../general/xslt/generateTestScript.xsl"/>
    
    <xsl:variable name="outputDir" select="'../../FHIR3-0-1-MM201901-Dev/Questionnaires-1-0-0'"/>
    
    <!-- Main template to generate the actual tests scripts for PHR and XIS. This template is standalone, it doesn't work on XML content. --> 
    <xsl:template name="generateAll">

        <!-- Write out the PHR scripts in a straightforward way -->
        <xsl:variable name="phr_dir" select="'PHR-Client'"/>
        <xsl:for-each select="collection(string-join(($phr_dir, '?select=*.xml'), '/'))">
            <xsl:variable name="document" select="document(document-uri(.))"/>
            <xsl:variable name="inputDir" select="concat(substring-before(string(base-uri($document)),$phr_dir),$phr_dir)"/>
            <xsl:result-document href="{string-join(($outputDir, $phr_dir, tokenize(document-uri(.), '/')[last()]), '/')}">
                <xsl:apply-templates select="$document">
                    <xsl:with-param name="inputDir" select="$inputDir"/>
                </xsl:apply-templates>
            </xsl:result-document>
        </xsl:for-each>
        
        <!-- Write out the XIS scripts in two versions: one with a setup step, used for internal testing against the
             WildFHIR dev server, and one without the setup, used as the actual test scripts. -->
        <xsl:variable name="xis_dir" select="'XIS-Server'"/>
        <xsl:for-each select="collection(string-join(($xis_dir, '?select=*.xml'), '/'))">
            <xsl:variable name="document" select="document(document-uri(.))"/>
            <xsl:variable name="document_stripped">
                <xsl:apply-templates mode="stripSetup" select="$document"/>
            </xsl:variable>
            <xsl:variable name="inputDir" select="concat(substring-before(string(base-uri($document)),$xis_dir),$xis_dir)"/>
            
            <xsl:result-document href="{string-join(($outputDir, $xis_dir, tokenize(document-uri(.), '/')[last()]), '/')}">
                <xsl:apply-templates select="$document_stripped">
                    <xsl:with-param name="inputDir" select="$inputDir"/>
                </xsl:apply-templates>
            </xsl:result-document>
            <xsl:result-document href="{string-join(($outputDir, concat($xis_dir, '-nictiz-intern'), tokenize(document-uri(.), '/')[last()]), '/')}">
                <xsl:apply-templates select="$document">
                    <xsl:with-param name="inputDir" select="$inputDir"/>
                </xsl:apply-templates>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Templates used to filter out the setup element -->
    <xsl:template match="f:TestScript/f:setup" mode="stripSetup" />
    <xsl:template match="@*|node()" mode="stripSetup">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="stripSetup"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>