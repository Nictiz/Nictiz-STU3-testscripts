<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:nf="http://www.nictiz.nl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:param name="infoStandard">Medmij Medication</xsl:param>
    <xsl:param name="infoStandardVersion">9.0.7</xsl:param>
    <xsl:param name="fhirVersion">fhir3-0-2</xsl:param>
    <xsl:param name="targetSystem">xis</xsl:param>
    
    <xsl:variable name="shortInfoStandard">
        <xsl:choose>
            <xsl:when test="$infoStandard='Medmij Medication'">
                <xsl:text>mp</xsl:text>
                <xsl:value-of select="substring-before($infoStandardVersion,'.')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="scenarioId" select="/adaxml/data/*/@id"/>
    <xsl:variable name="partId">
        <xsl:choose>
            <xsl:when test="starts-with($scenarioId,'mg-mgr-mg-MA')">ma</xsl:when>
            <xsl:when test="starts-with($scenarioId,'mg-mgr-mg-VV')">vv</xsl:when>
            <xsl:when test="starts-with($scenarioId,'mo-mor-ma')">mo</xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="outputDirBase">
        <xsl:choose>
            <xsl:when test="$infoStandard='Medmij Medication'">Medication</xsl:when>
        </xsl:choose>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="translate($infoStandardVersion,'.','-')"/>
    </xsl:variable>
    
    <xsl:variable name="scenarioNr">
        <xsl:variable name="rawValue" select="/adaxml/data/*/scenario-nr/@value"/>
        <xsl:variable name="replaceChars" select="translate($rawValue,'&lt;&gt;:&quot;/\|?*','         ')"/>
        <xsl:choose>
            <xsl:when test="contains($replaceChars,' ')">
                <xsl:value-of select="substring-before($replaceChars,' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$replaceChars"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="testScriptId">
        <xsl:value-of select="translate(lower-case($infoStandard),' ','-')"/>
        <xsl:if test="not($partId='')">
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$partId"/>
        </xsl:if>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$fhirVersion"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$targetSystem"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="translate($scenarioNr,'.','-')"/>
    </xsl:variable>
    <xsl:variable name="outputFileName">
        <xsl:value-of select="$testScriptId"/>
        <xsl:text>.xml</xsl:text>
    </xsl:variable>
    <xsl:variable name="outputDir">
        <xsl:text>../../../</xsl:text>
        <xsl:value-of select="$outputDirBase"/>
        <xsl:text>/</xsl:text>
        <xsl:choose>
            <xsl:when test="$targetSystem='xis'">XIS-Server</xsl:when>
            <xsl:when test="$targetSystem='phr'">PHR-Client</xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="targetSystemFull">
        <xsl:choose>
            <xsl:when test="$targetSystem='xis'">XIS Server</xsl:when>
            <xsl:when test="$targetSystem='phr'">PHR Client</xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">targetSystem not supported (only 'xis'/'phr' allowed)</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:output indent="yes" method="xml"/>
    
    <!--Function for kebab casing?-->
    
    <xsl:template match="/">
        <!--description vertalen en filteren op speciale karakters-->
        <xsl:variable name="description" select="adaxml/data/*/@desc"/>
        <xsl:variable name="patientName" select="upper-case(nf:removeSpecialCharacters(adaxml/data/*/patient/naamgegevens/geslachtsnaam/achternaam/@value))"/>
        <xsl:result-document href="{string-join(($outputDir, $outputFileName),'/')}">
            <TestScript xmlns="http://hl7.org/fhir" xmlns:nts="http://nictiz.nl/xsl/testscript">
                
                <id value="{$testScriptId}"/>
                <name value="{$infoStandard} - {$targetSystemFull} - Scenario {$scenarioNr}"/>
                <description value="Scenario {$scenarioNr} - {$description}"/>
                
                <nts:patientTokenFixture href="{$shortInfoStandard}-nl-core-patient-{$patientName}-token.xml" type="{$targetSystem}"/>
                
                <xsl:comment>&lt;nts:fixture id="" href=""/></xsl:comment>
                <!--<nts:fixture id="" href=""/>-->
                
                <xsl:comment>&lt;nts:variables href=""/></xsl:comment>
                <!--<nts:variables href=""/>-->
                <xsl:comment>&lt;nts:includeDateT value=""/></xsl:comment>
                <!--<nts:includeDateT value="yes"/>-->
                
                <xsl:comment>&lt;setup>&lt;nts:actions href=""/>&lt;/setup></xsl:comment>
                <!--<setup>
                <nts:actions href=""/>
            </setup>-->
                
                <test id="{$scenarioId}">
                    <name value="Scenario {$scenarioNr}"/>
                    <description value="Scenario {$scenarioNr}"/>
                    <!--<nts:actions href="components/phr-scenario1-searchTask.xml"/>-->
                </test>
                
                <xsl:comment>&lt;teardown>&lt;nts:actions href=""/>&lt;/teardown></xsl:comment>
            </TestScript>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:function name="nf:removeSpecialCharacters" as="xs:string?">
        <xsl:param name="in" as="xs:string?"/>
        <xsl:value-of select="replace(translate($in, '_.', '--'), '[^a-zA-Z0-9-]', '')"/>
    </xsl:function>
    
</xsl:stylesheet>