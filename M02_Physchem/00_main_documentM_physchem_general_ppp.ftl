<?xml version="1.0" encoding="UTF-8"?>

<#-- Import common modules to quickly access their substance and study content -->
<#import "macros_common_general.ftl" as com>
<#import "macros_common_studies_and_summaries.ftl" as studyandsummaryCom>
<#import "common_module_physical_chemical_summary_properties.ftl" as keyPhysChemSummary/>
<#import "common_module_human_health_hazard_assessment_of_physicochemical_properties.ftl" as keyPhyschem>
<#import "common_module_biological_properties_microorganism.ftl" as keyBioPropMicro>
<#import "appendixE_physchem.ftl" as keyAppendixE>

<#assign locale = "en" />
<#assign sysDateTime = .now>

<#-- Initialize the following variables:
	* _dossierHeader (:DossierHashModel) //The header document of a proper or 'raw' dossier, can be empty
	* _subject (:DocumentHashModel) //The dossier subject document or, if not in a dossier context, the root document, never empty
	-->
<@com.initializeMainVariables/>

<#--Initialize relevance-->
<@com.initiRelevanceForPPP relevance/>

<#--<#global dataset = mixture/>-->
<#assign ownerLegalEntity = iuclid.getDocumentForKey(_subject.OwnerLegalEntity) />
<#assign docUrl=iuclid.webUrl.entityView(_subject.documentKey)/>

<#--get name of the entity-->
<#if _subject.documentType=="MIXTURE">
    <#assign entName><@com.text _subject.MixtureName/></#assign>
    <#assign docEntName="P"/>
<#elseif _subject.documentType=="SUBSTANCE">
    <#assign entName><@com.text _subject.ChemicalName/></#assign>
    <#assign docEntName="A"/>
</#if>

<#--section number hardcoded for individual sections-->
<#assign sectionNb="2"/>

<#--get the context, and docname to print
    NOTE: this works for dossier only; in future also for dataset.-->
<#assign workingContext=""/>
<#assign docFullName=""/>
<#assign docName=""/>
<#if _subject.submissionType?has_content>
    <#if _subject.submissionType?matches(".*MICRO.*", "i")>
        <#assign workingContext="MICRO"/>
        <#assign docName="M"+docEntName/>

        <#if _subject.documentType=="MIXTURE">
            <#assign docFullName="Physical, chemical and technical properties of the plant protection product"/>

        <#elseif _subject.documentType=="SUBSTANCE">
            <#assign docFullName="Biological properties of the micro-organism"/>
        </#if>

    <#elseif _subject.submissionType?matches(".*MAXIM.*", "i") >
        <#assign workingContext="MRL"/>
        <#assign docName="MRL"/>

        <#assign docFullName="Physical and chemical properties of the active substance"/>

        <#-- get just the active substance-->
        <#if _subject.documentType=="MIXTURE">
            <#assign activeSubstanceList = getActiveSubstanceComponents(_subject) />
            <#if activeSubstanceList?has_content>
                <#assign activeSubstance = activeSubstanceList[0] />
            </#if>
            <#global _subject=activeSubstance/>
        </#if>

    <#else>
        <#assign workingContext="CHEM"/>
        <#assign docName="C"+docEntName/>

        <#if _subject.documentType=="MIXTURE">
            <#assign docFullName="Physical, chemical and technical properties of the plant protection product"/>

        <#elseif _subject.documentType=="SUBSTANCE">
            <#assign docFullName="Physical and chemical properties of the active substance"/>
        </#if>
    </#if>
</#if>

<#--interim solution: if there is no working context (because RGen run from dataset) just print an error message in an empty document-->
<#if workingContext?has_content>
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

                <para role="rule">

                <@com.emptyLine/>
                <ulink url="${docUrl}">${entName}</ulink>
                </para>

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

        <#-- Here add all the parts-->
        <chapter label="${docName} ${sectionNb}">
            <title role="HEAD-1">${docFullName}</title>
            <#include "02_physchem.ftl" encoding="UTF-8" />
        </chapter>

        <#-- Annex for materials-->
        <chapter label="Annex">
            <title role="HEAD-1">Information on Test Material</title>
            <#include "Annex2_test_materials.ftl" encoding="UTF-8" />
        </chapter>

    </book>
<#else>
    <book version="5.0" xmlns="http://docbook.org/ns/docbook" xmlns:xi="http://www.w3.org/2001/XInclude">
        <info>
            <title>Please, run Report Generator from a dossier.</title>
        </info>
        <part></part>
    </book>

</#if>


<#function getActiveSubstanceComponents mixture>

    <#local componentsList = []/>

    <#local compositionList = iuclid.getSectionDocumentsForParentKey(mixture.documentKey, "FLEXIBLE_RECORD", "MixtureComposition") />

    <#list compositionList as composition>
        <#local componentList = composition.Components.Components />
        <#list componentList as component>
            <#if component.Reference?has_content && isComponentActiveSubstance(component)>
                <#local substance = iuclid.getDocumentForKey(component.Reference)/>
                <#if substance?has_content && substance.documentType=="SUBSTANCE">
                    <#local componentsList = com.addDocumentToSequenceAsUnique(substance, componentsList)/>
                </#if>
            </#if>
        </#list>
    </#list>

    <#return componentsList />
</#function>

<#function isComponentActiveSubstance component>
    <#return component.Function?has_content && com.picklistValueMatchesPhrases(component.Function, ["active substance"]) />
</#function>
