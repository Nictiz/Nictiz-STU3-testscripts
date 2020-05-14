# GenerateTestScript

A tool to write FHIR TestScript instances that are more readable, better maintainable and can leverage reusable building blocks.

The approach is to use a custom dialect to enhance the FHIR TestScript syntax with a custom dialect, which is transformed using XSL to a regular FHIR TestScript. The custom dialect may be mixed with normal FHIR TestScript syntax at will. The transformation also takes care of adding the boilerplate stuff: url, date, publisher, contact, origin and destination.

## Custom dialect

### Namespace

All the custom elements use the following namespace:

    xmlns:nts="http://nictiz.nl/xsl/testscript"

### Recursive inclusion of components

One of the core principles in this method is that it should be possible to easily include other files as reusable components. Such a component includes everything that is needed for performing part of a test: the actions, the asserts, but also variables, fixtures, rules _and_ possibly other components.

To define a component, simply create an .xml file with the necessary content enclosed in the following tags:

    <nts:component xmlns="http://hl7.org/fhir" xmlns:nts="http://nictiz.nl/xsl/testscript">
        ...
    </nts:component>

Normally, these components are collected in a subdirectory called "components" relative to the TestScript. This location may be overridden using the `projectComponentFolder` parameter of the stylesheet when applying the transformation.

Additionally, the subdirectory "common-components" next to where this README resides contains building blocks that can be used across *all* projects. The location of this folder, relative to the TestScript, may be set using the `commonComponentFolder` parameter of the stylesheet during transformation.

A building block can then be included using:

    <nts:include value=".." scope="project|common"/>

Where `value` should be the name of the file to include (the ".xml" part may be omitted). The `scope` attribute defaults to "project" if it is ommitted

Alternatively, the following form may be used:

    <nts:include href="..."/>

to refer to a file directly.

*Note*: the transformation will take care of putting all included variables, fixtures, etc. in the right place in the resulting TestScript. If different components define the same variable, fixture, etc., it will be deduplicated. If they define a different variable, fixture, etc. with the same id, an error will be thrown.

#### Passing parameters

It is possible to pass parameters to included components, using the `nts:with-parameter` element. The syntax is:

    <nts:include value="..">
        <nts:with-parameter name="param1" value="...">
        <nts:with-parameter name="param2" value="...">
        ...
    </nts:include>

In the corresponding component, the variable can be used with the XSL syntax for variables:

    <nts:component ...>
        <variable>
            <name value="foo"/>
            <defaultValue value="{$param1}/>
        </variable>
    </nts:component>

In a component, a default value for a variable can be added using the `nts:parameter` element. This way, a component can be included without specifying a parameter value, while the parameter value can be overridden by specifying an `nts:with-parameter` element while including. 

Compare the following two examples (the first wil result in a value of 'foo' for `{$param1}`, the second will result in a value of 'bar' for `{$param1}`):

    <nts:include value="..">
        <nts:with-parameter name="param1" value="foo">
    </nts:include>    
    <nts:component ...>
        <nts:parameter name="param1" value="bar"/>    
        <variable>
            <name value="foo"/>
            <defaultValue value="{$param1}/>
        </variable>
    </nts:component>

    <nts:include value=".."/> 
    <nts:component ...>
        <nts:parameter name="param1" value="bar"/>    
        <variable>
            <name value="foo"/>
            <defaultValue value="{$param1}/>
        </variable>
    </nts:component>    

It is also possible to recursively pass along parameters to other includes, simply by using the `{$...}` expansion in the `value` attribute of the next `<nts:with-parameter ...>` element.

If you use a parameter in a component without passing it from the caller or without specifying a default value, an error will be thrown.

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

### Accepted return format

By adding an `nts:accept` attribute to the `TestScript` root, xml, json or both xml and json outputs (space separated) can be generated. If no `nts:accept` attribute is present, only an xml variant will be generated.

    nts:accept="xml|json|xml json"

## Running the transformation

The transformation is performed with the `generateTestScript.xsl` stylesheet, which may be found in the `xslt` folder.

Parameters:

* `testscriptBase` is an alternative base `node()` of the TestScript from which inclusions are done (see XSLT's `document()` for more information). It can be used when the TestScript content is stored in a variable, to indicate where inclusions should be made from. Note that recursive includes are relative to their parent file, not to this base.

## Building

TBD.

## Schematron

A schematron is available that can be used to check both the input TestScript files and the component files. It is reasonably complete and covers everything on the root level of the input files.

It can be found at `schematron/NictizTestScript.sch` relative to this README.
