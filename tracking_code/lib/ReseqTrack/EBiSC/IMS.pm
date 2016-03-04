use strict;
use warnings;

package ReseqTrack::EBiSC::IMS;
use namespace::autoclean;
use Moose;
use LWP::UserAgent;
use JSON qw(decode_json);
use HTTP::Request::Common qw(POST);

has 'base_url' => (is => 'rw', isa => 'Str', default => 'cells-stage.ebisc.org');
#has 'base_url' => (is => 'rw', isa => 'Str', default => 'cells.ebisc.org');
has 'ua' => (is => 'ro', isa => 'LWP::UserAgent', default => sub {return LWP::UserAgent->new;});

has 'user' => (is => 'rw', isa => 'Str');
has 'pass' => (is => 'rw', isa => 'Str');

sub BUILD {
  my ($self) = @_;
  $self->ua->default_header(Authorization => sprintf('ApiKey %s:%s', $self->user, $self->pass));
  $self->ua->timeout(5);
}

sub find_lines {
  my ($self, %options) = @_;
  my $lines = [];
  my $url_path = 'api/v0/cell-lines/?format=json';
  while ($url_path) {
    my $json = $self->query_api($url_path);
    push(@$lines, @{$json->{objects}});
    $url_path = $json->{meta}{next};
  }
  if ($options{lims_fields}) {
    $lines = $self->subset_lims_fields($lines);
  }
  return {objects=>$lines};
}

sub query_api {
  my ($self, $url_path) = @_;
  my $response = $self->ua->get(sprintf('https://%s/%s', $self->base_url, $url_path));
  die $response->status_line if $response->is_error;
  return decode_json($response->content);
}

sub subset_lims_fields {
  my ($self, $lines) = @_;

  my @filtered;
  foreach my $sample (@$lines) {
    my $sample_index = {};

    if ($$sample{name}){$sample_index->{name} = $$sample{name};}
    if ($$sample{alternative_names}){$sample_index->{alternative_names} = $$sample{alternative_names};}
    if ($$sample{biosamples_id}){$sample_index->{biosamples_id} = $$sample{biosamples_id};}
    if ($$sample{ecacc_cat_no}){$sample_index->{ecacc_cat_no} = $$sample{ecacc_cat_no};}
    
    if ($$sample{primary_cell_type}{name}){$sample_index->{primary_cell_type}{name} = $$sample{primary_cell_type}{name};}

    if ($$sample{donor}{gender}){$sample_index->{donor}{gender} = $$sample{donor}{gender};}
    if ($$sample{donor}{biosamples_id}){$sample_index->{donor}{biosamples_id} = $$sample{donor}{biosamples_id};}
    if ($$sample{donor}{internal_donor_ids}){$sample_index->{donor}{internal_donor_ids} = $$sample{donor}{internal_donor_ids};}
    if ($$sample{donor}{phenotypes}){$sample_index->{donor}{phenotypes} = $$sample{donor}{phenotypes};}
    if ($$sample{donor}{karyotype}){$sample_index->{donor}{karyotype} = $$sample{donor}{karyotype};}  #TODO No data yet needs to be tested when data is availible

    if ($$sample{cellline_karyotype}{karyotype}){$sample_index->{cellline_karyotype} = $$sample{cellline_karyotype}{karyotype};}

    if ($$sample{reprogramming_method_vector_free_types}){$sample_index->{reprogramming_method_vector_free_types} = $$sample{reprogramming_method_vector_free_types};}
    if ($$sample{reprogramming_method}{type}){$sample_index->{reprogramming_method}{type} = $$sample{reprogramming_method}{type};}
    if ($$sample{reprogramming_method}{data}{vector}){$sample_index->{reprogramming_method}{data}{vector} = $$sample{reprogramming_method}{data}{vector};}
    if ($$sample{reprogramming_method}{data}{virus}){$sample_index->{reprogramming_method}{data}{virus} = $$sample{reprogramming_method}{data}{virus};}
    if ($$sample{reprogramming_method}{data}{transposon}){$sample_index->{reprogramming_method}{data}{transposon} = $$sample{reprogramming_method}{data}{transposon};}
    if ($$sample{reprogramming_method}{data}{non_integrating_vector_gene_list}){$sample_index->{reprogramming_method}{data}{non_integrating_vector_gene_list} = $$sample{reprogramming_method}{data}{non_integrating_vector_gene_list};}
    if ($$sample{reprogramming_method}{data}{non_integrating_vector_detectable}){$sample_index->{reprogramming_method}{data}{non_integrating_vector_detectable} = $$sample{reprogramming_method}{data}{non_integrating_vector_detectable};}
    if ($$sample{reprogramming_method}{data}{non_integrating_vector_methods}){$sample_index->{reprogramming_method}{data}{non_integrating_vector_method} = $$sample{reprogramming_method}{data}{non_integrating_vector_method};}  #TODO No data yet needs to be tested when data is availible
    if ($$sample{reprogramming_method}{data}{non_integrating_vector_detection_notes}){$sample_index->{reprogramming_method}{data}{non_integrating_vector_detection_notes} = $$sample{reprogramming_method}{data}{non_integrating_vector_detection_notes};}  #TODO No data yet needs to be tested when data is availible
    if ($$sample{reprogramming_method}{data}{integrating_vector_gene_list}){$sample_index->{reprogramming_method}{data}{integrating_vector_gene_list} = $$sample{reprogramming_method}{data}{integrating_vector_gene_list};}
    if ($$sample{reprogramming_method}{data}{integrating_vector_silenced}){$sample_index->{reprogramming_method}{data}{integrating_vector_silenced} = $$sample{reprogramming_method}{data}{integrating_vector_silenced};}
    if ($$sample{reprogramming_method}{data}{integrating_vector_methods}){$sample_index->{reprogramming_method}{data}{integrating_vector_methods} = $$sample{reprogramming_method}{data}{integrating_vector_methods};}  #TODO No data yet needs to be tested when data is availible
    if ($$sample{reprogramming_method}{data}{integrating_silencing_notes}){$sample_index->{reprogramming_method}{data}{integrating_vector_silencing_notes} = $$sample{reprogramming_method}{data}{integrating_vector_silencing_notes};}  #TODO No data yet needs to be tested when data is availible
    
    if ($$sample{primary_disease_diagnosed}){$sample_index->{disease_diagnosed} = $$sample{primary_disease_diagnosed};}
    #FIXME when availible if ($$sample{disease_diagnosed}){$sample_index->{disease_diagnosed} = $$sample{disease_diagnosed};}
    if ($$sample{primary_disease}{name}){$sample_index->{disease_names} = [$$sample{primary_disease}{name}];}
    #FIXME when availible if ($$sample{disease_names}){$sample_index->{disease_names} = $$sample{disease_names};}
    if ($$sample{disease_associated_phenotypes}){$sample_index->{disease_associated_phenotypes} = $$sample{disease_associated_phenotypes};}
    
    if ($$sample{depositor_cellline_culture_conditions}{surface_coating}){$sample_index->{depositor_cellline_culture_conditions}{surface_coating} = $$sample{depositor_cellline_culture_conditions}{surface_coating};}
    if ($$sample{depositor_cellline_culture_conditions}{co2_concentration}){$sample_index->{depositor_cellline_culture_conditions}{co2_concentration} = $$sample{depositor_cellline_culture_conditions}{co2_concentration};}
    if ($$sample{depositor_cellline_culture_conditions}{o2_concentration}){$sample_index->{depositor_cellline_culture_conditions}{o2_concentration} = $$sample{depositor_cellline_culture_conditions}{o2_concentration};}
    if ($$sample{depositor_cellline_culture_conditions}{passage_method}){$sample_index->{depositor_cellline_culture_conditions}{passage_method} = $$sample{depositor_cellline_culture_conditions}{passage_method};}
    if ($$sample{depositor_cellline_culture_conditions}{feeder_cell_type}){$sample_index->{depositor_cellline_culture_conditions}{feeder_cell_type} = $$sample{depositor_cellline_culture_conditions}{feeder_cell_type};}
    if ($$sample{depositor_cellline_culture_conditions}{culture_medium_supplements}){$sample_index->{depositor_cellline_culture_conditions}{culture_medium_supplements} = $$sample{depositor_cellline_culture_conditions}{culture_medium_supplements};}
    if ($$sample{depositor_cellline_culture_conditions}{rock_inhibitor_used_at_passage}){$sample_index->{depositor_cellline_culture_conditions}{rock_inhibitor_used_at_passage} = $$sample{depositor_cellline_culture_conditions}{rock_inhibitor_used_at_passage};}
    if ($$sample{depositor_cellline_culture_conditions}{rock_inhibitor_used_at_cryo}){$sample_index->{depositor_cellline_culture_conditions}{rock_inhibitor_used_at_cryo} = $$sample{depositor_cellline_culture_conditions}{rock_inhibitor_used_at_cryo};}
    if ($$sample{depositor_cellline_culture_conditions}{rock_inhibitor_used_at_thaw}){$sample_index->{depositor_cellline_culture_conditions}{rock_inhibitor_used_at_thaw} = $$sample{depositor_cellline_culture_conditions}{rock_inhibitor_used_at_thaw};}

    if ($$sample{cellline_disease_associated_genotype}{carries_disease_phenotype_associated_variants_flag}){$sample_index->{cellline_disease_associated_genotype}{carries_disease_phenotype_associated_variants_flag} = $$sample{cellline_disease_associated_genotype}{carries_disease_phenotype_associated_variants_flag};}  #TODO No data yet needs to be tested when data is availible
    if ($$sample{cellline_disease_associated_genotype}{variant_of_interest_flag}){$sample_index->{cellline_disease_associated_genotype}{variant_of_interest_flag} = $$sample{cellline_disease_associated_genotype}{variant_of_interest_flag};}  #TODO No data yet needs to be tested when data is availible

    if ($$sample{cellline_certificate_of_analysis}{certificate_of_analysis_flag}){$sample_index->{cellline_certificate_of_analysis}{certificate_of_analysis_flag} = $$sample{cellline_certificate_of_analysis}{certificate_of_analysis_flag};}

    if ($$sample{virology_screening}{virology_screening_flag}){$sample_index->{virology_screening}{virology_screening_flag} = $$sample{virology_screening}{virology_screening_flag};}
    if ($$sample{virology_screening}{hiv1}){$sample_index->{virology_screening}{hiv1} = $$sample{virology_screening}{hiv1};}
    if ($$sample{virology_screening}{hiv2}){$sample_index->{virology_screening}{hiv2} = $$sample{virology_screening}{hiv2};}
    if ($$sample{virology_screening}{hepatitis_b}){$sample_index->{virology_screening}{hepatitis_b} = $$sample{virology_screening}{hepatitis_b};}
    if ($$sample{virology_screening}{hepatitis_c}){$sample_index->{virology_screening}{hepatitis_c} = $$sample{virology_screening}{hepatitis_c};}

    #TODO Uncomment and test when implemented at hPSCreg
    #TODO Charachterisation fields
    #TODO if ($$sample{characterization_marker_expression}{marker_expression_flag}){$sample_index->{characterization_marker_expression}{marker_expression_flag} = $$sample{characterization_marker_expression}{marker_expression_flag};}
    #TODO if ($$sample{characterization_marker_expression}{methods}{method}){$sample_index->{characterization_marker_expression}{methods}{method} = $$sample{characterization_marker_expression}{methods}{method};}
    #TODO if ($$sample{characterization_marker_expression}{methods}{markers}{marker}){$sample_index->{characterization_marker_expression}{methods}{markers}{marker} = $$sample{characterization_marker_expression}{methods}{markers}{marker};}
    #TODO if ($$sample{characterization_marker_expression}{methods}{markers}{expressed}){$sample_index->{characterization_marker_expression}{methods}{markers}{expressed} = $$sample{characterization_marker_expression}{methods}{markers}{expressed};}
    #TODO if ($$sample{characterization_pluritest}{pluritest_flag}){$sample_index->{characterization_pluritest}{pluritest_flag} = $$sample{characterization_pluritest}{pluritest_flag};}
    #TODO if ($$sample{characterization_pluritest}{pluripotency_score}){$sample_index->{characterization_pluritest}{pluripotency_score} = $$sample{characterization_pluritest}{pluripotency_score};}
    #TODO if ($$sample{characterization_pluritest}{novelty_score}){$sample_index->{characterization_pluritest}{novelty_score} = $$sample{characterization_pluritest}{novelty_score};}
    #TODO if ($$sample{characterization_epipluriscore}{epipluriscore_flag}){$sample_index->{characterization_epipluriscore}{epipluriscore_flag} = $$sample{characterization_epipluriscore}{epipluriscore_flag};}
    #TODO if ($$sample{characterization_epipluriscore}{score}){$sample_index->{characterization_epipluriscore}{score} = $$sample{characterization_epipluriscore}{score};}
    #TODO if ($$sample{characterization_epipluriscore}{marker_mcpg}){$sample_index->{characterization_epipluriscore}{marker_mcpg} = $$sample{characterization_epipluriscore}{marker_mcpg};}
    #TODO if ($$sample{characterization_epipluriscore}{marker_OCT4}){$sample_index->{characterization_epipluriscore}{marker_OCT4} = $$sample{characterization_epipluriscore}{marker_OCT4};}
    #TODO if ($$sample{characterization_morphology}{morphology_flag}){$sample_index->{characterization_morphology}{morphology_flag} = $$sample{characterization_morphology}{morphology_flag};}
    #TODO if ($$sample{characterization_hpsc_scorecard}{hpsc_scorecard_flag}){$sample_index->{characterization_hpsc_scorecard}{hpsc_scorecard_flag} = $$sample{characterization_hpsc_scorecard}{hpsc_scorecard_flag};}
    #TODO if ($$sample{characterization_hpsc_scorecard}{self_renewal}){$sample_index->{characterization_hpsc_scorecard}{self_renewal} = $$sample{characterization_hpsc_scorecard}{self_renewal};}
    #TODO if ($$sample{characterization_hpsc_scorecard}{endoderm}){$sample_index->{characterization_hpsc_scorecard}{endoderm} = $$sample{characterization_hpsc_scorecard}{endoderm};}
    #TODO if ($$sample{characterization_hpsc_scorecard}{mesoderm}){$sample_index->{characterization_hpsc_scorecard}{mesoderm} = $$sample{characterization_hpsc_scorecard}{mesoderm};}
    #TODO if ($$sample{characterization_hpsc_scorecard}{ectoderm}){$sample_index->{characterization_hpsc_scorecard}{ectoderm} = $$sample{characterization_hpsc_scorecard}{ectoderm};}
    #TODO if ($$sample{characterization_other_pluripotency_test}{other_pluripotency_test_flag}){$sample_index->{characterization_other_pluripotency_test}{other_pluripotency_test_flag} = $$sample{characterization_other_pluripotency_test}{other_pluripotency_test_flag};}
    #TODO if ($$sample{characterization_other_pluripotency_test}{description}){$sample_index->{characterization_other_pluripotency_test}{description} = $$sample{characterization_other_pluripotency_test}{description};}
    #TODO if ($$sample{characterization_gene_expression_array}{gene_expression_array_flag}){$sample_index->{characterization_gene_expression_array}{gene_expression_array_flag} = $$sample{characterization_gene_expression_array}{gene_expression_array_flag};}
    #TODO if ($$sample{characterization_rna_sequencing}{rna_sequencing_flag}){$sample_index->{characterization_rna_sequencing}{rna_sequencing_flag} = $$sample{characterization_rna_sequencing}{rna_sequencing_flag};}
    #TODO if ($$sample{characterization_differentiation_potency_endoderm}{differentiation_potency_endoderm_flag}){$sample_index->{characterization_differentiation_potency_endoderm}{differentiation_potency_endoderm_flag} = $$sample{characterization_differentiation_potency_endoderm}{differentiation_potency_endoderm_flag};}
    #TODO if ($$sample{characterization_differentiation_potency_endoderm}{detected_cell_types_flag}){$sample_index->{characterization_differentiation_potency_endoderm}{detected_cell_types_flag} = $$sample{characterization_differentiation_potency_endoderm}{detected_cell_types_flag};}
    #TODO if ($$sample{characterization_differentiation_potency_endoderm}{cell_types}{cell_type_tissue}){$sample_index->{characterization_differentiation_potency_endoderm}{cell_types}{cell_type_tissue} = $$sample{characterization_differentiation_potency_endoderm}{cell_types}{cell_type_tissue};}
    #TODO if ($$sample{characterization_differentiation_potency_endoderm}{cell_types}{in_vivo_teratoma}){$sample_index->{characterization_differentiation_potency_endoderm}{cell_types}{in_vivo_teratoma} = $$sample{characterization_differentiation_potency_endoderm}{cell_types}{in_vivo_teratoma};}
    #TODO if ($$sample{characterization_differentiation_potency_endoderm}{cell_types}{in_vitro_spontaneous_differentiation}){$sample_index->{characterization_differentiation_potency_endoderm}{cell_types}{in_vitro_spontaneous_differentiation} = $$sample{characterization_differentiation_potency_endoderm}{cell_types}{in_vitro_spontaneous_differentiation};}
    #TODO if ($$sample{characterization_differentiation_potency_endoderm}{cell_types}{in_vitro_directed_differentiation}){$sample_index->{characterization_differentiation_potency_endoderm}{cell_types}{in_vitro_directed_differentiation} = $$sample{characterization_differentiation_potency_endoderm}{cell_types}{in_vitro_directed_differentiation};}
    #TODO if ($$sample{characterization_differentiation_potency_endoderm}{cell_types}{scorecard}){$sample_index->{characterization_differentiation_potency_endoderm}{cell_types}{scorecard} = $$sample{characterization_differentiation_potency_endoderm}{cell_types}{scorecard};}
    #TODO if ($$sample{characterization_differentiation_potency_endoderm}{cell_types}{other}){$sample_index->{characterization_differentiation_potency_endoderm}{cell_types}{other} = $$sample{characterization_differentiation_potency_endoderm}{cell_types}{other};}
    #TODO if ($$sample{characterization_differentiation_potency_endoderm}{cell_types}{markers}){$sample_index->{characterization_differentiation_potency_endoderm}{cell_types}{markers} = $$sample{characterization_differentiation_potency_endoderm}{cell_types}{markers};}
    #TODO if ($$sample{characterization_differentiation_potency_mesoderm}{differentiation_potency_mesoderm_flag}){$sample_index->{characterization_differentiation_potency_mesoderm}{differentiation_potency_mesoderm_flag} = $$sample{characterization_differentiation_potency_mesoderm}{differentiation_potency_mesoderm_flag};}
    #TODO if ($$sample{characterization_differentiation_potency_mesoderm}{detected_cell_types_flag}){$sample_index->{characterization_differentiation_potency_mesoderm}{detected_cell_types_flag} = $$sample{characterization_differentiation_potency_mesoderm}{detected_cell_types_flag};}
    #TODO if ($$sample{characterization_differentiation_potency_mesoderm}{cell_types}{cell_type_tissue}){$sample_index->{characterization_differentiation_potency_mesoderm}{cell_types}{cell_type_tissue} = $$sample{characterization_differentiation_potency_mesoderm}{cell_types}{cell_type_tissue};}
    #TODO if ($$sample{characterization_differentiation_potency_mesoderm}{cell_types}{in_vivo_teratoma}){$sample_index->{characterization_differentiation_potency_mesoderm}{cell_types}{in_vivo_teratoma} = $$sample{characterization_differentiation_potency_mesoderm}{cell_types}{in_vivo_teratoma};}
    #TODO if ($$sample{characterization_differentiation_potency_mesoderm}{cell_types}{in_vitro_spontaneous_differentiation}){$sample_index->{characterization_differentiation_potency_mesoderm}{cell_types}{in_vitro_spontaneous_differentiation} = $$sample{characterization_differentiation_potency_mesoderm}{cell_types}{in_vitro_spontaneous_differentiation};}
    #TODO if ($$sample{characterization_differentiation_potency_mesoderm}{cell_types}{in_vitro_directed_differentiation}){$sample_index->{characterization_differentiation_potency_mesoderm}{cell_types}{in_vitro_directed_differentiation} = $$sample{characterization_differentiation_potency_mesoderm}{cell_types}{in_vitro_directed_differentiation};}
    #TODO if ($$sample{characterization_differentiation_potency_mesoderm}{cell_types}{scorecard}){$sample_index->{characterization_differentiation_potency_mesoderm}{cell_types}{scorecard} = $$sample{characterization_differentiation_potency_mesoderm}{cell_types}{scorecard};}
    #TODO if ($$sample{characterization_differentiation_potency_mesoderm}{cell_types}{other}){$sample_index->{characterization_differentiation_potency_mesoderm}{cell_types}{other} = $$sample{characterization_differentiation_potency_mesoderm}{cell_types}{other};}
    #TODO if ($$sample{characterization_differentiation_potency_mesoderm}{cell_types}{markers}){$sample_index->{characterization_differentiation_potency_mesoderm}{cell_types}{markers} = $$sample{characterization_differentiation_potency_mesoderm}{cell_types}{markers};}
    #TODO if ($$sample{characterization_differentiation_potency_ectoderm}{differentiation_potency_ectoderm_flag}){$sample_index->{characterization_differentiation_potency_ectoderm}{differentiation_potency_ectoderm_flag} = $$sample{characterization_differentiation_potency_ectoderm}{differentiation_potency_ectoderm_flag};}
    #TODO if ($$sample{characterization_differentiation_potency_ectoderm}{detected_cell_types_flag}){$sample_index->{characterization_differentiation_potency_ectoderm}{detected_cell_types_flag} = $$sample{characterization_differentiation_potency_ectoderm}{detected_cell_types_flag};}
    #TODO if ($$sample{characterization_differentiation_potency_ectoderm}{cell_types}{cell_type_tissue}){$sample_index->{characterization_differentiation_potency_ectoderm}{cell_types}{cell_type_tissue} = $$sample{characterization_differentiation_potency_ectoderm}{cell_types}{cell_type_tissue};}
    #TODO if ($$sample{characterization_differentiation_potency_ectoderm}{cell_types}{in_vivo_teratoma}){$sample_index->{characterization_differentiation_potency_ectoderm}{cell_types}{in_vivo_teratoma} = $$sample{characterization_differentiation_potency_ectoderm}{cell_types}{in_vivo_teratoma};}
    #TODO if ($$sample{characterization_differentiation_potency_ectoderm}{cell_types}{in_vitro_spontaneous_differentiation}){$sample_index->{characterization_differentiation_potency_ectoderm}{cell_types}{in_vitro_spontaneous_differentiation} = $$sample{characterization_differentiation_potency_ectoderm}{cell_types}{in_vitro_spontaneous_differentiation};}
    #TODO if ($$sample{characterization_differentiation_potency_ectoderm}{cell_types}{in_vitro_directed_differentiation}){$sample_index->{characterization_differentiation_potency_ectoderm}{cell_types}{in_vitro_directed_differentiation} = $$sample{characterization_differentiation_potency_ectoderm}{cell_types}{in_vitro_directed_differentiation};}
    #TODO if ($$sample{characterization_differentiation_potency_ectoderm}{cell_types}{scorecard}){$sample_index->{characterization_differentiation_potency_ectoderm}{cell_types}{scorecard} = $$sample{characterization_differentiation_potency_ectoderm}{cell_types}{scorecard};}
    #TODO if ($$sample{characterization_differentiation_potency_ectoderm}{cell_types}{other}){$sample_index->{characterization_differentiation_potency_ectoderm}{cell_types}{other} = $$sample{characterization_differentiation_potency_ectoderm}{cell_types}{other};}
    #TODO if ($$sample{characterization_differentiation_potency_ectoderm}{cell_types}{markers}){$sample_index->{characterization_differentiation_potency_ectoderm}{cell_types}{markers} = $$sample{characterization_differentiation_potency_ectoderm}{cell_types}{markers};}

    #TODO Genetic modification fields

    push(@filtered, $sample_index);
  }
  return \@filtered;
}



1;
