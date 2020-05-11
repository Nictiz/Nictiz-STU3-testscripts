# GenerateTestScript

A tool to write FHIR TestScript instances that are more readable, better maintainable and can leverage reusable building blocks.

The approach is to use a custom dialect to enhance the FHIR TestScript syntax with a custom dialect, which is transformed using XSL to a regular FHIR TestScript. The custom dialect may be mixed with normal FHIR TestScript syntax at will. The transformation also takes care of adding the boilerplate stuff: url, date, publisher, contact, origin and destination.

## Custom dialect

### Namespace

All the custom elements use the following namespace:

    xmlns:nts="http://nictiz.nl/xsl/testscript"

### Recursive inclusion of parts

One of the core principles in this method is that it should be possible to easily include other files as reusable components. Such a component includes everything that is needed for performing part of a test: the actions, the asserts, but also variables, fixtures, rules _and_ possibly other components.

To define a component, simply create an .xml file with the necessary content enclosed in the following tags:

    <nts:parts xmlns="http://hl7.org/fhir" xmlns:nts="http://nictiz.nl/xsl/testscript">
        ...
    </nts:parts>

Normally, these components are collected in a subdirectory called "components" relative to the TestScript. This location may be overridden using the `projectComponentFolder` parameter of the stylesheet when applying the transformation.

Additionally, the subdirectory "common-components" next to where this README resides contains building blocks that can be used across *all* projects. The location of this folder, relative to the TestScript, may be set using the `commonComponentFolder` parameter of the stylesheet during transformation.

A building block can then be included using:

    <nts:include value=".." scope="project|common"/>

Where `value` should be the name of the file to include (the ".xml" part may be omitted). The `scope` attribute defaults to "project" if it is ommitted

Alternatively, the following form may be used:

    <nts:include href="..."/>

to refer to a file directly.

*Note*: the transformation will take care of putting all included variables, fixtures, etc. in the right place in the resulting TestScript. If different components define the same variable, fixture, etc., it will be deduplicated. If they define a different variable, fixture, etc. with the same id, an error will be thrown.

### Fixtures, profiles and rules

For fixtures, profiles and rules, custom elements have been made that are a bit more concise than their FHIR equivalents.
  
Fixtures and rules can be defined using:

    <nts:fixture id=".." href=".."/>
    <nts:rule id=".." href=".."/>

As a convenience, `href` is considered to be relative to a predefined fixtures folder. It defaults to "../_reference", but this may be overridden using the `referenceBase` stylesheet parameter when applying the transformation.

Profiles may be defined using:

    <nts:profile id=".." value=".."/>

### Patient token and date T

There are two special elements for use cases that are common across Nictiz test scripts.

The first one for including the patient authorization token in the TestScript:

    <nts:patientTokenFixture href="..">

The `href` attribute should point to the `Patient` instance containing the token, as is commonly done with the Nictiz test scripts. The `nts:scenario` attribute on the TestScript root determines how this tag is expanded:

* for "server", a variable will be created which the test script executor can set, defaulting to the value from the fixture.
* for "client", the fixture will be included and a variable called "patient-token-id" will be created that reads the value from the fixture

The second element is to indicate that the "date T" variable should be defined for the testscript:

    <nts:includeDateT value="yes|no">

If this element is present, and `value` is absent or set to "yes", a variable for setting date T will be included in the TestScript.

### Scenario: server (xis) or client (phr)

There may be differences for xis and phr scenarios in how a TestScript is transformed. The scenario must therefore be indicated using the following attribute on the `TestScript` root:

    nts:scenario="server|client"

## Running the transformation

The transformation is performed with the `generateTestScript.xsl` stylesheet, which may be found in the `xslt` folder.

Parameters:

* `testscriptBase` is an alternative base `node()` of the TestScript from which inclusions are done (see XSLT's `document()` for more information). It can be used when the TestScript content is stored in a variable, to indicate where inclusions should be made from. Note that recursive includes are relative to their parent file, not to this base.

## Building

TBD.

## Schema(tron)

TBD.