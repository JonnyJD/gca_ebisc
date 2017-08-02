#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long;
use XML::Simple;
use JSON qw(encode_json);
use Try::Tiny;
use autodie;
use Data::Dumper;

my ($xmlinfile, $jsonoutfile, $ethicsinfile);

GetOptions("xmlinfile=s" => \$xmlinfile,
  "jsonoutfile=s" => \$jsonoutfile,
  "ethicsinfile=s" => \$ethicsinfile,
);

die "missing json xmlinfile" if !$xmlinfile;
die "missing json jsonoutfile" if !$jsonoutfile;
die "missing ethicsinfile" if !$ethicsinfile;

my %ethics_codes;
open my $fhi, '<', $ethicsinfile or die "could not open $ethicsinfile $!";
my @lines = <$fhi>;
foreach my $line (@lines){
  chomp($line);
  my @parts = split("\t", $line);
  $ethics_codes{$parts[0]} = $parts[1];
}

my $xml_data;
my $xml = new XML::Simple;
$xml_data = $xml->XMLin($xmlinfile,forcearray => 1);

my %ethics = (
  "1: STEMBANNC RECRUITED COHORT - UK Diabetes" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "StemBANCC diabetes PIS v2-7",
    hips_obtain_copy_of_unsigned_consent_form_file => "StemBANCC consent form v 2",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "NRES Committee South Central - Hampshire A",
    hips_approval_number_relation_consent => "13/SC/0179",
    hips_approval_auth_name_proposed_use => "NRES Committee South Central - Hampshire A",
    hips_approval_number_proposed_use => "13/SC/0179",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "1",
    hips_third_party_obligations => "DNA sequencing can only be performed for research into donors specified condition. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "2: UOXF -Bennett - Neuropathy" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "Painful Channelopathies Study Version 2. 07.07.2011",
    hips_obtain_copy_of_unsigned_consent_form_file => "Painful Channelopathies Study Version 2. 07.07.2011",
    hips_material_pseudonymised_or_anonymised => "anonymised",
    hips_approval_auth_name_relation_consent => "NHS-NRES Committee",
    hips_approval_number_relation_consent => "12/LO/0017",
    hips_approval_auth_name_proposed_use => "NHS-NRES Committee",
    hips_approval_number_proposed_use => "12/LO/0017",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "0",
    hips_third_party_obligations => "Only to be used into research into Painful Channelopathies / Pain syndromes. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "3: UCL - Hardy - Cellular Functions…" => {
    hips_genetic_information_access_policy => "no_information",
    hips_provide_copy_of_donor_consent_information_english_file => "Version 1.1 18/12/07",
    hips_obtain_copy_of_unsigned_consent_form_file => "Version 1.0 30/07/07",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "Royal Free Hospital and Medical School Research Ethics Committee",
    hips_approval_number_relation_consent => "07/H0720/161",
    hips_approval_auth_name_proposed_use => "Royal Free Hospital and Medical School Research Ethics Committee",
    hips_approval_number_proposed_use => "07/H0720/161",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "0",
    hips_consent_expressly_prevents_financial_gain_flag => "0",
    hips_third_party_obligations => "Reseach use restriction , only to be used in Parkinson's Disease. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "4: UOXF - Hu - PD" => {
    hips_genetic_information_access_policy => "no_information",
    hips_provide_copy_of_donor_consent_information_english_file => "Version 5, 27/12/11",
    hips_obtain_copy_of_unsigned_consent_form_file => "Version 2, 27/12/11",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "Berkshire Research Ethics Committee",
    hips_approval_number_relation_consent => "10/H0505/71",
    hips_approval_auth_name_proposed_use => "Berkshire Research Ethics Committee",
    hips_approval_number_proposed_use => "10/H0505/71",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "0",
    hips_third_party_obligations => "Research use restriction, only to be used for research into Parkinson's Disease and other neurodegenerative disorders. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "5: UCL - Hardy - AD" => {
    hips_genetic_information_access_policy => "no_information",
    hips_provide_copy_of_donor_consent_information_english_file => "Version 1: 23 July 2009",
    hips_obtain_copy_of_unsigned_consent_form_file => "Version 1: 23 July 2009",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "National Hospital and Institute of Neurology Joint REC",
    hips_approval_number_relation_consent => "09/H0716/64",
    hips_approval_auth_name_proposed_use => "National Hospital and Institute of Neurology Joint REC",
    hips_approval_number_proposed_use => "09/H0716/64",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "0",
    hips_third_party_obligations => "Research use restriction, only to be used for research into Dementias. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "7: EUROWABB - Barrett - Diabetes" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "Euro-WABB Consent Form: Adult Patient. Version 4.1 25/05/2011",
    hips_obtain_copy_of_unsigned_consent_form_file => "Euro-WABB Consent Form: Adult Patient. Version 4.2 30/06/2011",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "National Hospital and Institute of Neurology Joint REC",
    hips_approval_number_relation_consent => "11/WM/0127",
    hips_approval_auth_name_proposed_use => "National Hospital and Institute of Neurology Joint REC",
    hips_approval_number_proposed_use => "11/WM/0127",
    hips_documentation_provided_to_donor_flag => "1",
    hips_documentation_provided_to_donor_input => ["BCH EURO-WABB Assent form v4.0 30-03-11", "UK EURO-WABB_registry_Info_sheet_11-16yrs_v4.1 25-05-11FINAL", "UK EURO-WABB_registry_Info_sheet_Under11yrs_v4.1"],
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "0",
    hips_third_party_obligations => "DNA sequencing can only be performed for research into Diabetes. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "8: UOXF - Talbot - Neuropathy" => {
    hips_genetic_information_access_policy => "no_information",
    hips_provide_copy_of_donor_consent_information_english_file => "Version 1: 1st May 2012",
    hips_obtain_copy_of_unsigned_consent_form_file => "Version 1: 01/06/2012",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "South East Wales Research Ethics Committee",
    hips_approval_number_relation_consent => "12/WA/0186",
    hips_approval_auth_name_proposed_use => "South East Wales Research Ethics Committee",
    hips_approval_number_proposed_use => "12/WA/0186",
    hips_documentation_provided_to_donor_flag => "1",
    hips_documentation_provided_to_donor_input => ["Talbot Neuropathy Consultee Declaration Sheet 01-05-2012", "Talbot Neuropathy Consultee information sheet v1 20-07-2012"],
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "0",
    hips_third_party_obligations => "Research use restriction, only to be used for research into Motor Neuron Diseases. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "9: STEMBANNC RECRUITED COHORT - UK Neuropathy" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "StemBANCC neuropathy PIS v2-6",
    hips_obtain_copy_of_unsigned_consent_form_file => "StemBANCC consent form v 2 ",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "NRES Committee South Central - Hampshire A",
    hips_approval_number_relation_consent => "13/SC/0179",
    hips_approval_auth_name_proposed_use => "NRES Committee South Central - Hampshire A",
    hips_approval_number_proposed_use => "13/SC/0179",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "1",
    hips_third_party_obligations => "DNA sequencing can only be performed for research into donors specified condition. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "10: STEMBANNC RECRUITED COHORT - Migraine" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "StemBANCC migraine PIS v2-6",
    hips_obtain_copy_of_unsigned_consent_form_file => "StemBANCC consent form v 2",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "NRES Committee South Central - Hampshire A",
    hips_approval_number_relation_consent => "13/SC/0179",
    hips_approval_auth_name_proposed_use => "NRES Committee South Central - Hampshire A",
    hips_approval_number_proposed_use => "13/SC/0179",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "1",
    hips_third_party_obligations => "DNA sequencing can only be performed for research into donors specified condition. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "11: STEMBANNC RECRUITED COHORT - Alzheimer's" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "StemBANCC Alzheimer's PIS v2-6",
    hips_obtain_copy_of_unsigned_consent_form_file => "StemBANCC consent form v 2",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "NRES Committee South Central - Hampshire A",
    hips_approval_number_relation_consent => "13/SC/0179",
    hips_approval_auth_name_proposed_use => "NRES Committee South Central - Hampshire A",
    hips_approval_number_proposed_use => "13/SC/0179",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "1",
    hips_third_party_obligations => "DNA sequencing can only be performed for research into donors specified condition. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "12: STEMBANNC RECRUITED COHORT - Bipolar" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "StemBANCC Bipolar PIS v2-8",
    hips_obtain_copy_of_unsigned_consent_form_file => "StemBANCC consent form v 2",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "NRES Committee South Central - Hampshire A",
    hips_approval_number_relation_consent => "13/SC/0179",
    hips_approval_auth_name_proposed_use => "NRES Committee South Central - Hampshire A",
    hips_approval_number_proposed_use => "13/SC/0179",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "1",
    hips_third_party_obligations => "DNA sequencing can only be performed for research into donors specified condition. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "13: STEMBANNC RECRUITED COHORT - Control" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "StemBANCC Healthy controls PIS v2-5",
    hips_obtain_copy_of_unsigned_consent_form_file => "StemBANCC consent form v 2",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "NRES Committee South Central - Hampshire A",
    hips_approval_number_relation_consent => "13/SC/0179",
    hips_approval_auth_name_proposed_use => "NRES Committee South Central - Hampshire A",
    hips_approval_number_proposed_use => "13/SC/0179",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "1",
    hips_third_party_obligations => "DNA sequencing can only be used as a control for research into other diseases. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "14: UOXF - Alzheimer's" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "StemBANCC Alzheimer's PIS v2-6",
    hips_obtain_copy_of_unsigned_consent_form_file => "StemBANCC consent form v 2",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "NRES Committee South Central - Hampshire A",
    hips_approval_number_relation_consent => "13/SC/0179",
    hips_approval_auth_name_proposed_use => "NRES Committee South Central - Hampshire A",
    hips_approval_number_proposed_use => "13/SC/0179",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "1",
    hips_third_party_obligations => "DNA sequencing can only be performed for research into donors specified condition. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  },
  "15: UOXF - Parkinson's Disease" => {
    hips_genetic_information_access_policy => "controlled_access",
    hips_provide_copy_of_donor_consent_information_english_file => "StemBANCC Parkinson's PIS v2-6",
    hips_obtain_copy_of_unsigned_consent_form_file => "StemBANCC consent form v 2",
    hips_material_pseudonymised_or_anonymised => "pseudonymised",
    hips_approval_auth_name_relation_consent => "NRES Committee South Central - Hampshire A",
    hips_approval_number_relation_consent => "13/SC/0179",
    hips_approval_auth_name_proposed_use => "NRES Committee South Central - Hampshire A",
    hips_approval_number_proposed_use => "13/SC/0179",
    hips_documentation_provided_to_donor_flag => "0",
    hips_consent_permits_future_research_flag => "1",
    hips_consent_expressly_prevents_financial_gain_flag => "1",
    hips_third_party_obligations => "DNA sequencing can only be performed for research into donors specified condition. Material shall not be sold, transplanted into any human being or used to create egg or sperm cells (gametes) or embryos. The material shall not be used for direct exploitation. For the purposes of this, Direct exploitation means to develop for commericalization or to commercialize the Material."
  }
);

my %diseases = (
  Alzheimers => {
    disease_flag => "true", 
    primary => "true", 
    purl => "http:\/\/www.ebi.ac.uk\/efo\/EFO_0000249", 
    purl_name => "Alzheimers disease", 
    synonyms => ["Disease", "Alzheimer", "Dementia in Alzheimer's disease", "unspecified (disorder)", "Presenile Alzheimer Dementia", "ALZHEIMERS DIS", "Alzheimers", "sporadic Alzheimer's disease", "DAT - Dementia Alzheimer's type", "Dementia in Alzheimer's disease", "Alzheimer's disease", "NOS", "Alzheimer Dementia", "Presenile", "Dementia", "Alzheimer Type", "Alzheimer Dementia", "Alzheimer's Dementia", "Alzheimer's", "Dementia", "Presenile", "[X]Dementia in Alzheimer's disease (disorder)", "ALZHEIMER DIS", "AD", "[X]Dementia in Alzheimer's disease", "AD - Alzheimer's disease", "Disease", "Alzheimer's", "Alzheimer Disease", "Dementia", "Presenile Alzheimer", "Alzheimer Type Dementia", "Dementia in Alzheimer's disease (disorder)", "Alzheimer's disease (disorder)", "Alzheimers Dementia", "Dementia of the Alzheimer's type"]
  },
  Neuropathy => {
    disease_flag => "true", 
    primary => "true", purl => "http:\/\/www.ebi.ac.uk\/efo\/EFO_0004149", 
    purl_name => "neuropathy"
  },
  Parkinsons => {
    disease_flag => "true", 
    primary => "true", 
    purl => "http:\/\/www.ebi.ac.uk\/efo\/EFO_0002508", 
    purl_name => "Parkinson's disease", 
    synonyms => ["Parkinson's syndrome", "Parkinsons", "Primary Parkinsonism", "Parkinsons disease", "Parkinson disease", "Parkinson's disease (disorder)", "Parkinson's disease NOS", "Parkinson Disease", "Idiopathic", "PARKINSON DIS", "Paralysis agitans", "IDIOPATHIC PARKINSONS DIS", "PARKINSON DIS IDIOPATHIC", "Parkinsonism", "Primary", "Parkinson's Disease", "Lewy Body", "IDIOPATHIC PARKINSON DIS", "Idiopathic PD", "Idiopathic Parkinson Disease", "Lewy Body Parkinson's Disease", "Parkinsonian disorder", "LEWY BODY PARKINSON DIS", "Parkinson's", "Idiopathic Parkinson's Disease", "Parkinson's disease NOS (disorder)", "Lewy Body Parkinson Disease", "PARKINSONS DIS IDIOPATHIC", "PARKINSONS DIS", "Parkinson's Disease", "Idiopathic", "Parkinson syndrome", "PARKINSONS DIS LEWY BODY"]
  },
  Migraine  => {
    disease_flag => "true", 
    primary => "true", 
    purl => "http:\/\/www.ebi.ac.uk\/efo\/EFO_0003821", 
    purl_name => "migraine disorder", 
    synonyms => ["Migraine", "Acute Confusional", "Migraine", "Hemicrania", "Sick Headache", "Migraine", "Abdominal", "Migraines", "Migraines", "Acute Confusional", "Hemicrania Migraine", "Migraine Variant", "Acute Confusional Migraines", "Migraine Syndrome", "Cervical", "Abdominal Migraine", "Headaches", "Sick", "Disorders", "Migraine", "Disorder", "Migraine", "Variants", "Migraine", "Migraine Headache", "Acute Confusional Migraine", "Migraines", "Abdominal", "Headache", "Sick", "Cervical Migraine Syndrome", "Migraine", "Sick Headaches", "Migraine Headaches", "Hemicrania Migraines", "Migraine Variants", "Variant", "Migraine", "Status Migrainosus", "Migraine Disorders", "Cervical Migraine Syndromes", "Headache", "Migraine", "Headaches", "Migraine", "Migraines", "Hemicrania", "Abdominal Migraines", "Migraine Syndromes", "Cervical"]
  },
  Diabetes => {
    disease_flag => "true", 
    primary => "true", 
    purl => "http:\/\/www.ebi.ac.uk\/efo\/EFO_0000400", 
    purl_name => "diabetes mellitus", 
    synonyms => ["Diabetes mellitus (disorder)", "Diabetes", "Diabetes mellitus", "NOS", "DM - Diabetes mellitus", "Diabetes NOS"]
  },
  Bipolar => {
    disease_flag => "true", 
    primary => "true", 
    purl => "http:\/\/www.ebi.ac.uk\/efo\/EFO_0000289", 
    purl_name => "bipolar disorder", 
    synonyms => ["Psychoses", "Manic-Depressive", "Bipolar affective disorder", "current episode depression (disorder)", "Manic bipolar I disorder", "Manic-depressive psychosis", "mixed bipolar affective disorder", "NOS (disorder)", "Disorder", "Bipolar", "Manic bipolar I disorder (disorder)", "Manias", "Bipolar Disorders", "Affective Bipolar Psychosis", "Psychosis", "Bipolar Affective", "Psychosis", "Manic-Depressive", "Manic Depressive Psychosis", "MANIC DIS", "Bipolar Depression", "BIPOLAR DIS", "Manic Disorders", "Unspecified bipolar affective disorder", "NOS (disorder)", "Bipolar affective disorder", "Manic States", "Manic Depressive disorder", "Unspecified bipolar affective disorder", "State", "Manic", "Psychoses", "Manic Depressive", "MANIC DEPRESSIVE ILLNESS", "Mania", "bipolar disorder manic phase", "Unspecified bipolar affective disorder", "NOS", "Psychoses", "Bipolar Affective", "Unspecified bipolar affective disorder", "unspecified (disorder)", "Unspecified bipolar affective disorder", "unspecified", "Psychosis", "Manic Depressive", "Bipolar affective disorder ", "current episode mixed (disorder)", "Disorder", "Manic", "Manic-Depressive Psychoses", "Manic Disorder", "States", "Manic", "mixed bipolar disorder", "[X]Bipolar affective disorder", "unspecified (disorder)", "Unspecified bipolar affective disorder (disorder)", "Bipolar disorder", "unspecified", "Bipolar Affective Psychosis", "Manic-depressive syndrome NOS", "Manic Bipolar Affective disorder", "Manic State", "Bipolar affective disorder", "manic", "unspecified degree", "Bipolar disorder (disorder)", "mixed bipolar affective disorder (disorder)", "Affective Psychosis", "Bipolar", "[X]Bipolar affective disorder", "unspecified", "bipolar disease", "Bipolar affective disorder", "mixed", "unspecified degree", "MDI - Manic-depressive illness", "Manic-depressive illness", "Bipolar disorder", "NOS", "BIPOLAR DISORDER NOS", "mixed bipolar I disorder (disorder)", "Depression", "Bipolar", "Depressive-manic psych.", "Manic-Depression"]
  }
  );

my %cellLines;
for (@{ $xml_data->{'CellLine'} }) {
  my $cellLine = $_;
  my %cellLine_doc = (
    donor => {external_patient_header_id=> $$cellLine{external_patient_header_id}[0], gender => $$cellLine{sex}[0]},
    source_platform => "ebisc",
    type_name => "hiPSC",
    vector_type => "non_integrating",
    non_integrating_vector => "sendai_virus",
    culture_conditions_medium_culture_medium => "mtesr_1",
    karyotyping_flag => "1",
    karyotyping_karyotype => "No abnormalities detected",
    karyotyping_method => "molecular_snp",
    fingerprinting_flag => "0",
    genetic_modification_flag => "0",
    available_flag => "1",
    availability_restrictions => "with_restrictions",
    primary_celltype_purl => "http:\/\/purl.obolibrary.org\/obo\/CL_0000057",
    primary_celltype_ont_name => "fibroblast",

    #Universal ethics responses
    hips_consent_obtained_from_donor_of_tissue_flag => "1",
    hips_no_pressure_stat_flag => "1",
    hips_derived_information_influence_personal_future_treatment_flag => "1",
    hips_provide_copy_of_donor_consent_information_english_flag => "1",
    hips_informed_consent_flag => "0",
    hips_holding_original_donor_consent_flag => "1",
    hips_holding_original_donor_consent_contact_info => "zameel.cader\@ndcn.ox.ac.uk",
    hips_obtain_copy_of_unsigned_consent_form_flag => "1",
    hips_consent_prevents_ips_derivation_flag => "0",
    hips_consent_prevents_availability_to_worldwide_research_flag => "0",
    hips_ethics_review_panel_opinion_relation_consent_form_flag => "1",
    hips_consent_prevents_derived_cells_availability_to_worldwide_research_flag => "0",
    hips_donor_financial_gain_flag => "0",
    hips_ethics_review_panel_opinion_project_proposed_use_flag => "1",
    hips_consent_by_qualified_professional_flag => "1",
    hips_consent_pertains_specific_research_project_flag => "0",
    hips_consent_expressly_prevents_commercial_development_flag => "0",
    hips_consent_permits_stop_of_derived_material_use_flag => "0",
    hips_consent_permits_delivery_of_information_and_data_flag => "0",
    hips_ethics_review_panel_opinion_relation_consent_form_flag => "1",
    hips_third_party_obligations_flag => "1",
    hips_further_constraints_on_use_flag => "0"
  );
  
  my $donor_id = substr($$cellLine{name}[0],3,3);
  print $donor_id, "\n";
  print $ethics_codes{$donor_id}, "\n";
  for my $key (keys(%{$ethics{$ethics_codes{$donor_id}}})){
    print $key, "\n";
    push(@{$cellLine_doc{$key}}, $ethics{$$cellLine{ethics}[0]}{$$cellLine{disease}[0]}{$key});
  }
  if ($$cellLine{disease}){
    push(@{$cellLine_doc{disease_flag}}, "1");
    if ($diseases{$$cellLine{disease}[0]}){
      for my $key (keys($diseases{$$cellLine{disease}[0]})){
        push(@{$cellLine_doc{donor}{$key}}, $diseases{$key}[0]);
      } 
    }else{
      die "missing disease information for $$cellLine{disease}[0]";
    }
  }else{
    push(@{$cellLine_doc{disease_flag}}, "0");
  }
  push(@{$cellLine_doc{alternate_name}}, $$cellLine{name}[0]);
  push(@{$cellLine_doc{usage_approval_flag}}, "research_only");
  
  #Add line to set
  push(@{$cellLines{cellLines}}, %cellLine_doc);
}
my $jsonout = encode_json(\%cellLines);
open my $fho, '>', $jsonoutfile or die "could not open $jsonoutfile $!";
#print $fho $jsonout;
print $jsonout;
close($fho);