package Scherm;

use utf8;
use 5.10.1;
use strict;
use warnings;
use Carp;
use Scherm::IO;
use Scherm::Terminfo;
use Scherm::Constants qw/:CURSOR :KEY :COLOR :DIR :ATTR/;
use Scherm::ConfigData;

{
	local $SIG{__WARN__}=sub {};
	require 'sys/ioctl.ph';
}

our $VERSION='1.02';

use base 'Exporter';

# Re-export Scherm::Constants symbols
our %EXPORT_TAGS=%Scherm::Constants::EXPORT_TAGS;
our @EXPORT_OK=@Scherm::Constants::EXPORT_OK;

#####

sub new
{
	my $class=shift;
	my $self=
		{
			io=>Scherm::IO->new,
			terminfo=>Scherm::Terminfo->new,
			keymap=>Scherm::KeyMap->new,
		};
	return bless $self, $class;
}

#####

sub getTerminfoNames()
{
	return shift->{terminfo}->getNames;
}

#####

sub getTerminfoBoolean($)
{
	return shift->{terminfo}->getBoolean(shift);
}

#####

sub getTerminfoNumber($)
{
	return shift->{terminfo}->getNumber(shift);
}

#####

sub getTerminfoString($)
{
	return shift->{terminfo}->getString(shift);
}

#####

sub setTerminfoBoolean($$)
{
	return shift->{terminfo}->setBoolean(@_);
}

#####

sub setTerminfoNumber($$)
{
	return shift->{terminfo}->setNumber(@_);
}

#####

sub setTerminfoString($$)
{
	return shift->{terminfo}->setString(@_);
}

#####

sub initialize()
{
	my $self=shift;

	# Run program [iprog]
	my $initProgram=$self->getTerminfoString('iprog');
	system $initProgram
		if defined $initProgram and -e $initProgram;

	# Output [is1], [is2]
	my $initString1=$self->getTerminfoString('is1');
	$self->putString($initString1) if defined $initString1;
	my $initString2=$self->getTerminfoString('is2');
	$self->putString($initString2) if defined $initString2;

	# Set margins [mgc], [smgl], [smgr]
	# TODO

	# Set tabs [tbc], [hts]
	# TODO

	# Print file [if]
	my $initFile=$self->getTerminfoString('if');
	if(defined $initFile and -r $initFile)
	{
		open my $initFileHandle, '<', $initFile
			or die "Can not open initialization file $initFile: $!\n";
		$self->putString($_) while $initFileHandle->read($_, 4096);
		close $initFileHandle;
	}

	# Output [is3]
	my $initString3=$self->getTerminfoString('is3');
	$self->putString($initString3) if defined $initString3;

	$self->refresh;
	$self->{io}->flushInput;
}

#####

sub reset()
{
	my $self=shift;
	
	# Run program [iprog]
	my $initProgram=$self->getTerminfoString('iprog');
	system $initProgram
		if defined $initProgram and -e $initProgram;

	# Output [is1], [is2]
	my $initString1=$self->getTerminfoString('rs1');
	$self->putString($initString1) if defined $initString1;
	my $initString2=$self->getTerminfoString('rs2');
	$self->putString($initString2) if defined $initString2;

	# Set margins [mgc], [smgl], [smgr]
	# TODO

	# Set tabs [tbc], [hts]
	# TODO

	# Print file [if]
	my $initFile=$self->getTerminfoString('rf');
	if(defined $initFile and -r $initFile)
	{
		open my $initFileHandle, '<', $initFile
			or die "Can not open initialization file $initFile: $!\n";
		$self->putString($_) while $initFileHandle->read($_, 4096);
		close $initFileHandle;
	}

	# Output [is3]
	my $initString3=$self->getTerminfoString('is3');
	$self->putString($initString3) if defined $initString3;

	$self->refresh;
	$self->{io}->flushInput;
}

#####

sub putString($)
{
	shift->{io}->putStringBuffered(shift);
}

#####

sub putStringCapability($$;@)
{
	my $self=shift;
	my $linesAffected=shift;
	my $string=shift;
	$self->putString
		(
			$self->{terminfo}->applyParameters
				($self->{io}{bitrate}, $linesAffected, $string, @_)
		);
}

#####

sub refresh()
{
	shift->{io}->flushOutput;
}

#####

sub getScreenSize()
{
	my $self=shift;
	if(ioctl($self->{io}{tty}, &TIOCGWINSZ, my $size=''))
	{
		return unpack 'S2', $size;
	}
	elsif(defined $ENV{LINES} and defined $ENV{COLUMNS})
	{
		return @ENV{qw/LINES COLUMNS/};
	}
	else
	{
		return
		(
			$self->getTerminfoNumber('lines'),
			$self->getTerminfoNumber('cols')
		);
	}
}

#####

sub delay
{
	select(undef, undef, undef, shift);
}

#####

sub clearScreen()
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('clear');
	$self->putStringCapability(1, $capstring);	#TODO
}

#####

sub clearToEndOfLine()
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('el');
	$self->putStringCapability(1, $capstring);	#TODO
}

#####

sub clearToBeginningOfLine()
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('el1');
	$self->putStringCapability(1, $capstring);	#TODO
}

#####

sub clearToEndOfScreen()
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('ed');
	$self->putStringCapability(1, $capstring);	#TODO
}

#####

sub setCursorVisibility($)
{
	my $self=shift;
	my $mode=shift//CURSOR_NORMAL;
	my $capability=qw/civis cnorm cvvis/[$mode];
	my $capstring=$self->getTerminfoString($capability);
	$self->putStringCapability(0, $capstring);
}

#####

sub setCursorStyle($)
{
	my $self=shift;
	my $style=shift;
	my $capstring=$self->getTerminfoString('Ss');
	$self->putStringCapability(0, $capstring, $style);
}

#####

sub moveCursor($$)
{
	my $self=shift;
	my $row=shift//0;
	my $col=shift//0;
	my $capstring=$self->getTerminfoString('cup');
	$self->putStringCapability(0, $capstring, $row, $col);
}

#####

sub moveCursorToRow($)
{
	my $self=shift;
	my $row=shift//0;
	my $capstring=$self->getTerminfoString('vpa');
	$self->putStringCapability(0, $capstring, $row);
}

#####

sub moveCursorToColumn($)
{
	my $self=shift;
	my $col=shift//0;
	my $capstring=$self->getTerminfoString('hpa');
	$self->putStringCapability(0, $capstring, $col);
}

#####

sub moveCursorHome
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('home');
	$self->putStringCapability(0, $capstring);
}

#####

sub shiftCursor($$)
{
	my $self=shift;
	my $dir=shift;
	my $n=shift//1;
	my $capability=qw/cuf cuu cub cud/[$dir];
	#TODO: $capability.='1' if $n==1;
	my $capstring=$self->getTerminfoString($capability);
	$self->putStringCapability(1, $capstring, $n);	#TODO
}

#####
sub locateCursor
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('u7');
	$self->putStringCapability(0, $capstring);
	$self->refresh;

	# Get response
	1 until $self->{io}->inputPending;	# Wait for input
	my $input=$self->{io}->flushInput;
	$capstring=$self->getTerminfoString('u6');
	my @parameters=Scherm::Terminfo::scanParameters($capstring, $input);

	return @parameters if @parameters==2;
	$self->{io}->ungetBytes($input);
}

#####

sub setBackground($)
{
	my $self=shift;
	my $color=shift;
	my $capstring=$self->getTerminfoString('setab');
	$self->putStringCapability(0, $capstring, $color);
}

#####

sub setForeground($)
{
	my $self=shift;
	my $color=shift;
	my $capstring=$self->getTerminfoString('setaf');
	$self->putStringCapability(0, $capstring, $color);
}

#####

sub setColor($$)
{
	my $self=shift;
	my $foregroundColor=shift;
	my $backgroundColor=shift;
	$self->setForeground($foregroundColor);
	$self->setBackground($backgroundColor);
}

#####

sub setStandout
{
	my $self=shift;
	my $switch=shift;
	my $capstring=$self->getTerminfoString($switch? 'smso': 'rmso');
	$self->putStringCapability(0, $capstring);
}

#####

sub setUnderline
{
	my $self=shift;
	my $switch=shift;
	my $capstring=$self->getTerminfoString($switch? 'smul': 'rmul');
	$self->putStringCapability(0, $capstring);
}

#####

sub setReverse
{
	my $self=shift;
	my $switch=shift;	# TODO
	my $capstring=$self->getTerminfoString('rev');
	$self->putStringCapability(0, $capstring);
}

#####

sub setBlink
{
	my $self=shift;
	my $switch=shift;
	my $capstring=$self->getTerminfoString('blink');
	$self->putStringCapability(0, $capstring);
}

#####

sub setAttribute($)
{
	my $self=shift;
	my $attribute=shift;
	my $capstring=$self->getTerminfoString('sgr');
	$self->putStringCapability
		(
			0,
			$capstring,
			$attribute & ATTR_STANDOUT,
			$attribute & ATTR_UNDERLINE,
			$attribute & ATTR_REVERSE,
			$attribute & ATTR_BLINK,
			$attribute & ATTR_DIM,
			$attribute & ATTR_BOLD,
			$attribute & ATTR_PROTECT,
			$attribute & ATTR_ALTCHARSET
		);
}

#####

sub bell
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('bel');
	$self->putStringCapability(1, $capstring);
}

#####

sub flash
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('flash');
	$self->putStringCapability(1, $capstring);
}

#####

sub insertLines
{
	my $self=shift;
	my $num=shift;
	my $capstring=$self->getTerminfoString($num==1? 'il1': 'il');
	$self->putStringCapability($num, $capstring, $num);
}

#####

sub deleteLines
{
	my $self=shift;
	my $num=shift;
	my $capstring=$self->getTerminfoString($num==1? 'dl1': 'dl');
	$self->putStringCapability($num, $capstring, $num);
}

#####

sub insertCharacters($)
{
	my $self=shift;
	my $num=shift;
	my $capstring=$self->getTerminfoString($num==1? 'ich1': 'ich');
	$self->putStringCapability(1, $capstring, $num);
}

#####

sub deleteCharacters($)
{
	my $self=shift;
	my $num=shift;
	my $capstring=$self->getTerminfoString($num==1? 'dch1': 'dch');
	$self->putStringCapability(1, $capstring, $num);
}

#####

sub saveCursor()
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('sc');
	$self->putStringCapability(1, $capstring);
}

#####

sub restoreCursor()
{
	my $self=shift;
	my $capstring=$self->getTerminfoString('rc');
	$self->putStringCapability(0, $capstring);
}

#####

sub writeString($)
{
	my $self=shift;
	my $string=shift;
	$self->putString($string);
}

#####

sub fillCharacter($$$)
{
	my $self=shift;
	#my $character=substr shift, 0, 1;
	my $character=shift;
	$character=~s/^(\X).*/$1/;
	my $height=shift;
	my $width=shift;
	while($height--)
	{
		$self->saveCursor;
		$self->writeString($character x $width);
		$self->restoreCursor;
		$self->shiftCursor(DIR_DOWN);
	}
}

#####

sub drawHLine($$)
{
	shift->fillCharacter(shift, 1, shift);
}

#####

sub drawVLine($$)
{
	shift->fillCharacter(shift, shift, 1);
}

#####

sub setupKeyMap
{
	my $self=shift;
	my $keymap=$self->{keymap};
	for my $capability(Scherm::KeyMap::getKeyCapNames())
	{
		my $capstring=$self->getTerminfoString($capability);
		my $mapping=Scherm::KeyMap::getKeyCapability($capability);
		$keymap->setMapping($capstring=>$mapping)
			if defined $capstring;
	}

	# B2 key TODO for XTerm
	$keymap->setMappingUnlessDefined("\e[E"=>KEY_B2);
	$keymap->setMappingUnlessDefined("\e[C"=>KEY_RIGHT);
	$keymap->setMappingUnlessDefined("\e[A"=>KEY_UP);
	$keymap->setMappingUnlessDefined("\e[D"=>KEY_LEFT);
	$keymap->setMappingUnlessDefined("\e[B"=>KEY_DOWN);
}

#####

sub getCharacter(;$)
{
	my $self=shift;
	my $wait=shift;
	my $byteString;
	my @matching=keys %{$self->{keymap}};
	my $character;
	while($self->{io}->inputPending($wait))
	{
		$wait//=0;
		my $byte=$self->{io}->getByte;
		$byteString.=$byte;
		@matching=grep { 0==index $_, $byteString } @matching;
		if(@matching==0)	# Not in keymap
		{
			$character=substr $byteString, 0, 1, '';
			$self->{io}->ungetBytes($byteString);
			last;
		}
		elsif(@matching==1)
		{
			return $self->{keymap}{$byteString}
				if defined $self->{keymap}{$byteString};
			next;
		}
		else
		{
			next;
		}
	}

	# UTF-8 support
	if(defined $character and ${^UTF8LOCALE})
	{
		if(vec $character, 7, 1)	# Multi-byte character
		{
			my $l=1;
			$character.=$self->{io}->getByte
				while vec $character, 7-$l++, 1;
			# Return decoded character or replacement character when error
			return utf8::decode($character)? $character: "\x{FFFD}";
		}
	}
	return $character;
}

#####

sub getXTermCapability
{
	my $self=shift;

	# Send request
	$self->putStringCapability(0, "\eP+q\%p1\%s\e\\", uc unpack 'H*', shift);
	$self->refresh;

	# Get response
	1 until $self->{io}->inputPending;	# Wait for input
	my $input=$self->{io}->flushInput;
	my @parameters=Scherm::Terminfo::scanParameters
		(
			"\eP%d+r%[=;0123456789ABCDEF]\e\\",
			$input
		);

	# Decode response
	my $capstring=pack 'H*', ((split '=', $parameters[1])[1]//'')
		if $parameters[0];
	return $capstring;
}

#####

sub setup
{
	my $self=shift;
	$self->setupXTerm;
	$self->setupKeyMap;
}

#####

sub setupXTerm
{
	my $self=shift;
	my ($termName)=$self->getTerminfoNames;
	return unless $termName=~m/^xterm/
		and 0+Scherm::ConfigData->config('xterm_hook');

	for my $capability(Scherm::Terminfo::getBooleanNames)
	{
		my $capstring=$self->getXTermCapability($capability);
		$self->setTermifoBoolean($capability=>$capstring)
			if defined $capstring;
	}
	for my $capability(Scherm::Terminfo::getNumberNames, 'Co')
	{
		my $capstring=$self->getXTermCapability($capability);
		$self->setTerminfoNumber($capability=>$capstring)
			if defined $capstring;
	}
	for my $capability(Scherm::Terminfo::getStringNames, 'TN')
	{
		my $capstring=$self->getXTermCapability($capability);
		$self->setTerminfoString($capability=>$capstring)
			if defined $capstring;
	}
}

#####

return 1;
