<?xml version="1.0" encoding="UTF-8"?>

<#--Documents M - Section 12 (C&L) for a mixture/product. -->

<#-- Import common modules to quickly access their substance and study content -->
<#import "macros_common_general.ftl" as com>
<#import "macros_common_studies_and_summaries.ftl" as studyandsummaryCom>
<#import "common_module_classification_and_labelling.ftl" as keyCl>

<#assign locale = "en" />
<#assign sysDateTime = .now>

<#-- Initialize the following variables:
	* _dossierHeader (:DossierHashModel) //The header document of a proper or 'raw' dossier, can be empty
	* _subject (:DocumentHashModel) //The dossier subject document or, if not in a dossier context, the root document, never empty
	-->
<@com.initializeMainVariables/>

<#--Initialize relevance-->
<@com.initiRelevanceForPPP relevance/>

<#assign ownerLegalEntity = iuclid.getDocumentForKey(_subject.OwnerLegalEntity) />
<#assign docUrl=iuclid.webUrl.entityView(_subject.documentKey)/>

<#--section number hardcoded for individual sections-->
<#-- it's only for chemical PPPP -->
<#assign sectionNb="12"/>
<#assign docFullName="Classification and labelling of the plant protection product"/>
<#assign entName><@com.text _subject.MixtureName/></#assign>
<#assign docName="CP"/>
<#if _subject.submissionType?has_content>
    <#if !(_subject.submissionType?matches(".*MICRO.*", "i")) && !(_subject.submissionType?matches(".*MAXIM.*", "i")) >
        <#assign workingContext="CHEM"/>
    </#if>
</#if>

<#--get error message if no active substance or dossier-->
<#if !(workingContext??)>
    <#assign errorMessage="Please, run Report Generator from a dossier.">
</#if>

<#--interim solution: if there is no working context (because RGen run from dataset) just print an error message in an empty document-->
<#if !(errorMessage??)>
<book version="5.0" xmlns="http://docbook.org/ns/docbook" xmlns:xi="http://www.w3.org/2001/XInclude">

    <#assign left_header_text = ''/>
    <#assign central_header_text = com.getReportSubject(rootDocument).name?html />
    <#assign right_header_text = ''/>

    <#assign left_footer_text = sysDateTime?string["dd/MM/yyyy"] + " - IUCLID 6 " + iuclid6Version!/>
    <#assign central_footer_text = 'M${docName} - Section ${sectionNb}' />
    <#assign right_footer_text = ''/>

    <info>


        <title>
            <#--			NOTE it overlaps in the ToC...-->
            <para role="i6header5_nobold"><#if ownerLegalEntity?has_content><@com.text ownerLegalEntity.GeneralInfo.LegalEntityName/></#if></para>
            <@com.emptyLine/>

            <para role="rule"/>

            <@com.emptyLine/>
            <ulink url="${docUrl}">${entName}</ulink>

        </title>

        <subtitle>
            <para role="align-center">
            </para>
            <@com.emptyLine/>
            <para role="rule"/>
        </subtitle>

        <subtitle>
            <para role="align-right">
                <para role="HEAD-3">Document M-${docName}<?linebreak?>Section ${sectionNb}</para>
                <@com.emptyLine/>
                <para role="HEAD-4">${docFullName}</para>
                <@com.emptyLine/>
                <@com.emptyLine/>
            </para>
        </subtitle>

        <cover>
            <para role="align-right">
                <para role="cover.i6subtext">
                    ${left_footer_text}
                </para>
            </para>
        </cover>
        <@com.metadataBlock left_header_text central_header_text right_header_text left_footer_text central_footer_text right_footer_text />
    </info>

    <chapter label="${docName} ${sectionNb}">
        <title role="HEAD-1">${docFullName}</title>
        <#include "10_12_cl.ftl" encoding="UTF-8" />
    </chapter>

</book>
<#else>
    <book version="5.0" xmlns="http://docbook.org/ns/docbook" xmlns:xi="http://www.w3.org/2001/XInclude">
        <info>
            <title>${errorMessage}</title>
        </info>
        <part></part>
    </book>

</#if>