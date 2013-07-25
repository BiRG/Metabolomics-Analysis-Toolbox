#!/usr/bin/perl
use autodie;

# Usage:
# list_glbio_files.pl > file_list
#
# lists all files in the current directory that are definitely glbio
# files, starting from a list of known glbio files. This is a
# conservative list, files may be omitted if they don't call another
# known glbio file. (All files named *glbio* or *GLBIO*, however, will
# be tagged as glbio files.
#
# I am creating this list in preparation to moving the GLBIO
# experiment files to their own subdirectory (and renaming the
# directory to something like 2013_summit_focused_validation)


# Read matlab files in directory
my @files = glob("*.m");

# Make hash for known glbio files
my %known_glbio; 
my %possibly_non_glbio;
foreach my $file (@files){
    if ($file =~ m/glbio/i || $file eq "exercise_hist_simplify.m" || 
	$file eq "nssd_data_dist.m" || 
	$file eq "peak_loc_estimate_for_random_spec.m" ||
	$file eq "peak_separation_experiment_results_printer.m" ||
	$file eq "probability_of_peak_merging_in_random_spec.m" ||
	$file eq "random_spec_from_nssd_data.m"){
	$known_glbio{$file} = 1;
    }else{
	$possibly_non_glbio{$file} = 1;
    }
}

# Read the call graph (I know, I could have just done this in one
# file, but this was more modular and easier to test)
my @call_graph_edges_text = `/usr/bin/perl which_files_call_others.pl`;

# Convert edges text to hash of arrays - calls{file} = array
# containing each filename called by file
my %calls;
foreach my $file (@files){
    $calls{$file} = [];
}
foreach (@call_graph_edges_text){
    chomp;
    my ($caller, $called) = split(/\t/);
    push $calls{$caller}, $called;
}

# Mark every file that calls a known glbio file as a glbio
# file. Repeat until no files change status.
my $no_files_were_changed;
do{
    $no_files_were_changed = 1;
    # Make a temporary array of the unknown files 
    my @old_non_glbio = keys %possibly_non_glbio;
    foreach my $caller (@old_non_glbio){
	my $called = $calls{$caller};
	foreach my $callee (@$called){
	    if (exists $known_glbio{$callee}) {
		$no_files_were_changed = 0;
		delete $possibly_non_glbio{$caller};
		$known_glbio{$caller} = 1;
		last;
	    }
	}
    }
} until($no_files_were_changed);

# Print results
for my $file (keys %known_glbio){
    print "$file\n";
}
