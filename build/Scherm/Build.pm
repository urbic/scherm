package Scherm::Build;
use base 'Module::Build';
use utf8;

sub new
{
	my $class=shift;
	my $self=Module::Build->new
		(
			dist_name=>'Scherm',
			dist_version=>'1.03',
			build_class=>__PACKAGE__,
			license=>'zlib',
			requires=>
				{
					perl=>'5.12.0',
				},
			configure_requires=>
				{
					'Module::Build'=>'0.38',
				},
			examples_files=>
				{
					'examples/Ticker.pm'=>'examples/Ticker.pm',
					'examples/Terminal2x2/Scherm.pm'=>'examples/Terminal2x2/Scherm.pm',
					'examples/Font/BDF.pm'=>'examples/Font/BDF.pm',
					'examples/FixedMedium-20.bdf'=>'examples/FixedMedium-20.bdf',
					'examples/tetris.pl'=>'examples/tetris.pl',
					'examples/life.pl'=>'examples/life.pl',
					'examples/linedraw.pl'=>'examples/linedraw.pl',
				},
			obs_files=>
				{
					'obs/perl-Scherm.spec'=>'XXX',
				},
			install_path=>
				{
					examples=>'/usr/share/doc/packages/perl-Scherm/examples',
				},
		);
	bless $self, $class;
	$self->add_build_element('examples');
	$self->config_data(terminfo_system_dir=>$self->config('terminfo.system.dir')//'/usr/share/terminfo');
	$self->config_data(xterm_hook=>$self->config('xterm_hook')//1);
	$self->install_path(libdoc_ru=>File::Spec->catdir($self->config('installman3dir'), '..', 'ru', 'man3'));
	return $self;
}

sub manify_lib_pods
{
	my $self=shift;
	
	my $files=$self->_find_pods($self->{properties}{libdoc_dirs});
	return unless keys %$files;

	my $basemandir=File::Spec->catdir($self->blib, 'libdoc');
	File::Path::mkpath($basemandir, 0, oct(777));

	require Pod::Man;
	while(my ($file, $relfile)=each %$files)
	{
		my $manpage=$self->man3page_name($relfile).'.'.$self->config('man3ext');
		my $mandir=$basemandir;
		if($manpage=~s#^(.*)\|(\w+)\.(\w+)$#$1.$3#)
		{
			$mandir.="_$2";
			File::Path::mkpath($mandir);
		}
		my $parser=Pod::Man->new(section=>3, utf8=>1, quotes=>'none'); # libraries go in section 3
		#warn ''.$parser->devise_title()."\n";
		my $outfile=File::Spec->catfile($mandir, $manpage);
		#$self->log_verbose("file=$file relfile=$relfile outfile=$outfile manpage=$manpage mandir=$mandir\n");
		next if $self->up_to_date($file, $outfile);
		$self->log_verbose("Manifying $file -> $outfile\n");
		eval { $parser->parse_from_file($file, $outfile); 1 }
			or $self->log_warn("Error creating '$outfile': $@\n");
			$files->{$file}=$outfile;
	}
}

sub htmlify_pods
{
	my $self=shift;
	my $files=$self->_find_pods($self->{properties}{libdoc_dirs});
	return unless keys %$files;
	
	my $basehtmldir=File::Spec->catdir($self->blib, 'libhtml');
	File::Path::mkpath($basehtmldir, 0, oct(777));

	require Pod::Man;
	while(my ($file, $relfile)=each %$files)
	{
		my $page=$self->man3page_name($relfile);
		my $htmldir=$basehtmldir;
		if($page=~s#^(.*)\|(\w+)$#$1#)
		{
			$htmldir=File::Spec->catdir($htmldir, $2);
			File::Path::mkpath($htmldir);
		}
		my $parser=Pod::Simple::XHTML->new;
		$parser->html_header('<html xmlns="http://www.w3.org/1999/xhtml"><head><title>');
		$parser->html_css(<<__HTML__);
<style>
i
{
	color: blue;
}
</style>
__HTML__
		$parser->output_string(\my $html);
		$parser->html_charset('UTF-8');
		$parser->html_encode_chars('&<>">');
		$parser->parse_file($file);
		my $outfile=File::Spec->catfile($htmldir, "$page.html");
		$self->log_verbose("XHTMLifying $file -> $outfile\n");
		my $html_file=IO::File->new($outfile, '>:utf8');
		$html_file->print($html);
	}
}

sub ACTION_obs
{
	my $self=shift;
	my $specs=$self->_find_file_by_type('spec', 'obs');
		
	my $obsdir=File::Spec->catdir($self->blib, 'obs');
	File::Path::mkpath($obsdir, 0, oct(777));

	my $version=$self->dist_version;
	while(my ($file, $relfile)=each %$specs)
	{
		$self->log_verbose("Setting version in $relfile to $version\n");
		my $outfile=File::Spec->catfile($self->blib, $relfile);
		my $in=IO::File->new($relfile, '<') or die;
		my $out=IO::File->new($outfile, '>') or die "$outfile: $!";
		for(<$in>)
		{
			s/^(Version:\s*)(.*)/$1$version/;
			$out->print($_);
		}
	}
}

sub ACTION_release
{
	my $self=shift;
	$self->depends_on('dist');
	#die join ' ',
	system
		'rsync',
		'-e', $self->config_data('release_connect_prog'),
		#$self->dist_name.'-'.$self->dist_version.'.tar.gz',
		$self->module_name.$self->dist_suffix,
		$self->config_data('release_destination');
}

sub ACTION_examples
{
	my $self=shift;
	#$self->copy_if_modified(from=>'examples', to_dir=>'examples/');

}

return 1;
