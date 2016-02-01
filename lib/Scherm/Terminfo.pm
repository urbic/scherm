package Scherm::Terminfo;
use IO::File;
use feature 'state';
use Scherm::ConfigData;

my @booleanNames=qw/
	bw		am		xsb		xhp		xenl	eo		gn		hc
	km		hs		in		da		db		mir		msgr	os
	eslok	xt		hz		ul		xon		nxon	mc5i	chts
	nrrmc	npc		ndscr	ccc		bce		hls		xhpa	crxm
	daisy	xvpa	sam		cpix	lpix
/;

#	backspaces_with_bs
#	crt_no_scrolling
#	no_correctly_working_cr
#	gnu_has_meta_key
#	linefeed_is_newline
#	has_hardware_tabs
#	return_does_clr_eol

my @numberNames=qw/
	cols	it		lines	lm		xmc		pb		vt		wsl
	nlab	lh		lw		ma		wnum	colors	pairs	ncv
	bufsz	spinv	spinh	maddr	mjump	mcs		mls		npins
	orc		orl		orhi	orvi	cps		widcs	btns	bitwin
	bitype
/;

#	magic_cookie_glitch_ul
#	carriage_return_delay
#	new_line_delay
#	backspace_delay
#	horizontal_tab_delay
#	number_of_function_keys

my @stringNames=qw/
	cbt		bel		cr		csr		tbc		clear	el		ed
	hpa		cmdch	cup		cud1	home	civis	cub1	mrcup
	cnorm	cuf1	ll		cuu1	cvvis	dch1	dl1		dsl
	hd		smacs	blink	bold	smcup	smdc	dim		smir
	invis	prot	rev		smso	smul	ech		rmacs	sgr0
	rmcup	rmdc	rmir	rmso	rmul	flash	ff		fsl
	is1		is2		is3		if		ich1	il1		ip		kbs
	ktbc	kclr	kctab	kdch1	kdl1	kcud1	krmir	kel
	ked		kf0		kf1		kf10	kf2		kf3		kf4		kf5
	kf6		kf7		kf8		kf9		khome	kich1	kil1	kcub1
	kll		knp		kpp		kcuf1	kind	kri		khts	kcuu1
	rmkx	smkx	lf0		lf1		lf10	lf2		lf3		lf4
	lf5		lf6		lf7		lf8		lf9		rmm		smm		nel
	pad		dch		dl		cud		ich		indn	il		cub
	cuf		rin		cuu		pfkey	pfloc	pfx		mc0		mc4
	mc5		rep		rs1		rs2		rs3		rf		rc		vpa
	sc		ind		ri		sgr		hts		wind	ht		tsl
	uc		hu		iprog	ka1		ka3		kb2		kc1		kc3
	mc5p	rmp		acsc	pln		kcbt	smxon	rmxon	smam
	rmam	xonc	xoffc	enacs	smln	rmln	kbeg	kcan
	kclo	kcmd	kcpy	kcrt	kend	kent	kext	kfnd
	khlp	kmrk	kmsg	kmov	knxt	kopn	kopt	kprv
	kprt	krdo	kref	krfr	krpl	krst	kres	ksav
	kspd	kund	kBEG	kCAN	kCMD	kCPY	kCRT	kDC
	kDL		kslt	kEND	kEOL	kEXT	kFND	kHLP	kHOM
	kIC		kLFT	kMSG	kMOV	kNXT	kOPT	kPRV	kPRT
	kRDO	kRPL	kRIT	kRES	kSAV	kSPD	kUND	rfi
	kf11	kf12	kf13	kf14	kf15	kf16	kf17	kf18
	kf19	kf20	kf21	kf22	kf23	kf24	kf25	kf26
	kf27	kf28	kf29	kf30	kf31	kf32	kf33	kf34
	kf35	kf36	kf37	kf38	kf39	kf40	kf41	kf42
	kf43	kf44	kf45	kf46	kf47	kf48	kf49	kf50
	kf51	kf52	kf53	kf54	kf55	kf56	kf57	kf58
	kf59	kf60	kf61	kf62	kf63	el1		mgc		smgl
	smgr	fln		sclk	dclk	rmclk	cwin	wingo	hup
	dial	qdial	tone	pulse	hook	pause	wait	u0
	u1		u2		u3		u4		u5		u6		u7		u8
	u9		op		oc		initc	initp	scp		setf	setb
	cpi		lpi		chr		cvr		defc	swidm	sdrfq	sitm
	slm		smicm	snlq	snrmq	sshm	ssubm	ssupm	sum
	rwidm	ritm	rlm		rmicm	rshm	rsubm	rsupm	rum
	mhpa	mcud1	mcub1	mcuf1	mvpa	mcuu1	porder	mcud
	mcub	mcuf	mcuu	scs		smgb	smgbp	smglp	smgrp
	smgt	smgtp	sbim	scsd	rbim	rcsd	subcs	supcs
	docr	zerom	csnm	kmous	minfo	reqmp	getm	setaf
	setab	pfxl	devt	csin	s1ds	s2ds	s3ds	s4ds
	smglr	smgtb	birep	binel	bicr	colornm	defbi	endbi
	setcolor slines	dispc	smpch	rmpch	smsc	rmsc	pctrm
	scesc	scesa	ehhlm	elhlm	elohlm	erhlm	ethlm	evhlm
	sgr1	slength
/;
#	termcap_init2
#	termcap_reset
#	linefeed_if_not_lf
#	backspace_if_not_bs
#	r_non_function_keys
#	arrow_key_map
#	acs_ulcorner
#	acs_llcorner
#	acs_urcorner
#	acs_lrcorner
#	acs_ltee
#	acs_rtee
#	acs_btee
#	acs_ttee
#	acs_hline
#	acs_vline
#	acs_plus
#	memory_lock
#	memory_unlock
#	box_chars_1


sub new(;$)
{
	my $class=shift;
	my $self={};
	
	my $termName=shift//$ENV{TERM};
	my $tiPath=$ENV{TERMINFO};
	my $infoFileName;

	# Get terminal description file name
	$tiPath=Scherm::ConfigData->config('terminfo_system_dir')
		unless defined $tiPath and -f "$tiPath/".substr($termName, 0, 1)."/$termName";
	$infoFileName="$tiPath/".substr($termName, 0, 1)."/$termName";
	
	# Open file
	my $info=IO::File->new($infoFileName, '<')
		or die "Can not open terminfo file $infoFileName: $!\n";
	
	# Read header
	$info->read($_, 12);
	my ($magic, $namesSize, $bc, $nc, $sc, $ss)
		=unpack 'v*';
	
	# Check for magic
	die "Improper terminfo file: wrong magic number\n" if 0x011A!=$magic;

	# Get names
	$info->read($_, $namesSize);
	$self->{names}=[split /\|/, unpack 'Z*'];

	# Get booleans
	for(my $i=0; $i<$bc; $i++)
	{
		$info->read($_, 1);
		$self->{booleans}{$booleanNames[$i]}=1
			if unpack 'C' and defined $booleanNames[$i];
	}
	$info->read($_, 1) if $info->tell % 2;

	# Get numbers
	for(my $i=0; $i<$nc; $i++)
	{
		$info->read($_, 2);
		$_=unpack 'v';
		$self->{numbers}{$numberNames[$i]}=$_
			if $_!=0xFFFF and $numberNames[$i];
	}

	# Get offsets
	$info->read($_, 2*$sc);
	my @offsets=unpack 'v*';
		
	# Get strings
	$info->read(my $stringsTable, $ss);

	for(my $i=0; $i<$sc; $i++)
	{
		$self->{strings}{$stringNames[$i]}
				=unpack 'Z*', substr($stringsTable, $offsets[$i])
			if $offsets[$i]!=0xFFFF and defined $stringNames[$i];
	}
	
	$info->read($_, 1) if $info->tell % 2; #TODO eof

	# Get extended capabilities
	if($info->read($_, 10)==10)	# TODO 0
	{
		my (@booleanCapabilities, @numberCapabilities, @stringCapabilities);

		($bc, $nc, $sc, $ss, my $lo)=unpack 'v*';

		# Get extended booleans
		for(my $i=0; $i<$bc; $i++)
		{
			$info->read($_, 1);
			push @booleanCapabilities, (unpack 'C')? 1: 0;

		}
		$info->read($_, 1) if $info->tell % 2;

		# Get extended numbers
		for(my $i=0; $i<$nc; $i++)
		{
			$info->read($_, 2);
			$_=unpack 'v';
			$numberCapabilities[$i]=$_;
		}

		# Get offsets
		$info->read($_, 2*(2*$sc+$bc+$nc));
		@offsets=unpack 'v*';

		# Get strings and names
		$info->read($stringsTable, $lo);

		# Get extended string capabilities
		my $maxOffset=0;
		for(my $i=0; $i<$sc; $i++)
		{
			my $offset=$offsets[$i];
			if($offset!=0xFFFF)
			{
				my $capability=unpack 'Z*', substr($stringsTable, $offset);
				$stringCapabilities[$i]=$capability;
				my $nextOffset=$offset+length($capability)+1;
				$maxOffset=$nextOffset if $maxOffset<$nextOffset;
			}
		}
		
		# Get extended boolean names
		my @extBooleanNames;
		for(my $i=$sc; $i<$sc+$bc; $i++)
		{
			my $offset=$offsets[$i];
			my $capName=unpack 'Z*', substr($stringsTable, $offset+$maxOffset);
			$extBooleanNames[$i-$sc]=$capName if $offset!=0xFFFF;
		}
		for(my $i=0; $i<@extBooleanNames; $i++)
		{
			$self->{booleans}{$extBooleanNames[$i]}=$booleanCapabilities[$i]
				if defined $booleanCapabilities[$i];
		}
		
		# Get extended number names
		my @extNumberNames;
		for(my $i=$sc+$bc; $i<$sc+$bc+$nc; $i++)
		{
			my $offset=$offsets[$i];
			my $capName=unpack 'Z*', substr($stringsTable, $offset+$maxOffset);
			$extNumberNames[$i-$sc-$bc]=$capName if $offset!=0xFFFF;
		}
		for(my $i=0; $i<@extNumberNames; $i++)
		{
			$self->{numbers}{$extNumberNames[$i]}=$numberCapabilities[$i]
				if $numberCapabilities[$i]!=0xFFFF;
		}

		# Get extended string names
		my @extStringNames;
		for(my $i=$sc+$bc+$nc; $i<2*$sc+$bc+$nc; $i++)
		{
			my $offset=$offsets[$i];
			my $capName=unpack 'Z*', substr($stringsTable, $offset+$maxOffset);
			push @extStringNames, $capName if $offset!=0xFFFF;
		}
		for(my $i=0; $i<@extStringNames; $i++)
		{
			$self->{strings}{$extStringNames[$i]}=$stringCapabilities[$i]
				if defined $stringCapabilities[$i];
		}
	}
	$info->close;
	
	bless $self, $class;
	return $self;
}

sub showCapabilities
{
	my $self=shift;
	print {STDERR} join('|', @{$self->{names}}), "\n";
	for my $cap(sort keys %{$self->{booleans}})
	{
		print {STDERR} "\t$cap,\n" if $self->{booleans}{$cap};
	}
	for my $cap(sort keys %{$self->{numbers}})
	{
		print {STDERR} "\t$cap#$self->{numbers}{$cap},\n";
	}
	for my $cap(sort keys %{$self->{strings}})
	{
		my $capValueHR;
		for my $c(split '', $self->{strings}{$cap})
		{
			if($c eq "\e")
			{
				$capValueHR.="\\E";
			}
			elsif(ord $c<32)
			{
				$capValueHR.="^".chr(ord($c)+64);
			}
			else
			{
				$capValueHR.=$c;
			}
		}
		print {STDERR} "\t$cap=$capValueHR,\n";
	}
}

sub getNames()
{
	return @{shift->{names}};
}

sub getBoolean($)
{
	return shift->{booleans}{shift()};
}

sub getNumber($)
{
	return shift->{numbers}{shift()};
}

sub getString($)
{
	return shift->{strings}{shift()};
}

sub setBoolean($$)
{
	my $self=shift;
	my $capName=shift;
	$self->{booleans}{$capName}=shift;
}

sub setNumber($$)
{
	my $self=shift;
	my $capName=shift;
	$self->{numbers}{$capName}=shift;
}

sub setString($$)
{
	my $self=shift;
	my $capName=shift;
	$self->{strings}{$capName}=shift;
}

sub setBooleanUnlessDefined($$)
{
	my $self=shift;
	my $capName=shift;
	$self->{booleans}{$capName}//=shift;
}

sub setNumberUnlessDefined($$)
{
	my $self=shift;
	my $capName=shift;
	$self->{numbers}{$capName}//=shift;
}

sub setStringUnlessDefined($$)
{
	my $self=shift;
	my $capName=shift;
	$self->{strings}{$capName}//=shift;
}

sub applyParameters($$$;@)
{
	my $self=shift;
	my $bitRate=shift;
	my $linesAffected=shift;
	my $input=shift;
	#my $yyy=$input;

	my $padCharacter=$self->getString('pad')//"\0";
	my $lowestBitRate=$self->getNumber('pb')//0;

	my $output='';
	my @stack;
	my $flag=1;
	state %variables;
	while($input)
	{
		if($input=~s/^\%p([1-9])//)
		{
			push @stack,  $_[$1-1];
		}
		elsif($input=~s/^\%([\%cdx])//)
		{
			$output.=sprintf "\%$1", pop @stack;
		}
		elsif($input=~s/^\%((?:\:?[\#\-\+ ])?(?:[1-9]+(?:\.\d+)?)?[doXxs])//)
		{
			$output.=sprintf "\%$1", pop @stack;
		}
		elsif($input=~s/^\%P([A-Za-z])//)
		{
			$variables{$1}=pop @stack;
		}
		elsif($input=~s/^\%g([A-Za-z])//)
		{
			push @stack, $variables{$1};
		}
		elsif($input=~s/^\%\'(.)\'//)
		{
			push @stack, ord $1;
		}
		elsif($input=~s/^\%\{(\d+)\}//)
		{
			push @stack, $1;
		}
		elsif($input=~s/^\%l//)
		{
			push @stack, length pop @stack;
		}
		elsif($input=~s/^\%\+//)
		{
			push @stack, (pop(@stack)+pop(@stack));
		}
		elsif($input=~s/^\%\-//)
		{
			push @stack, (pop(@stack)-pop(@stack));
		}
		elsif($input=~s/^\%\*//)
		{
			push @stack, (pop(@stack)*pop(@stack));
		}
		elsif($input=~s/^\%\///)
		{
			push @stack, (pop(@stack)/pop(@stack));
		}
		elsif($input=~s/^\%m//)
		{
			push @stack, (pop(@stack) % pop(@stack));
		}
		elsif($input=~s/^\%\&//)
		{
			push @stack, (pop(@stack)&(pop(@stack)));
		}
		elsif($input=~s/^\%\|//)
		{
			push @stack, (pop(@stack)|pop(@stack));
		}
		elsif($input=~s/^\%\^//)
		{
			push @stack, (pop(@stack)^pop(@stack));
		}
		elsif($input=~s/^\%=//)
		{
			push @stack, 0+(pop(@stack)==pop(@stack));
		}
		elsif($input=~s/^\%<//)
		{
			push @stack, 0+(pop(@stack)<pop(@stack));	#TODO
		}
		elsif($input=~s/^\%>//)
		{
			push @stack, 0+(pop(@stack)>pop(@stack));	#TODO
		}
		elsif($input=~s/^\%A//)
		{
			push @stack, (pop(@stack) and pop(@stack));
		}
		elsif($input=~s/^\%O//)
		{
			push @stack, (pop(@stack) or pop(@stack));
		}
		elsif($input=~s/^\%!//)
		{
			push @stack, not(pop @stack);
		}
		elsif($input=~s/^\%\~//)
		{
			push @stack, ~(pop @stack);
		}
		elsif($input=~s/^\%i//)
		{
			$_[0]++;
			$_[1]++;
		}
		elsif($input=~s/^\%[\?;]//)	{ }
		elsif($input=~s/^\%t//)
		{
			$input=~s/^.*?\%[e;]// unless ($flag=pop @stack);
		}
		elsif($input=~s/^\%e//)
		{
			$input=~s/^.*?\%;// if $flag;
		}
		elsif($input=~s/^\$<(\d+)(\*?)(\/?)>//)	# Padding
		{
			$output.=
				$padCharacter x int($bitRate/8000*$1*($2? $linesAffected: 1))
				if ($3 or $bitRate>=$lowestBitRate);
		}
		else
		{
			$output.=substr $input, 0, 1, '';
		}
	#my $xxx=$output;
	#$xxx=~s/\e/\\E/g;
	#$yyy=~s/\e/\\E/g;
	#warn "APPLY: out=$xxx\nAPPLY: in=$yyy\n";
	}
	return $output;
}

sub scanParameters($$)
{
	my $capability=shift;
	my $string=shift;
	my @parameters;
	my $decrementFlag=0;

	while(length $capability)
	{
		if($capability=~s/^\%i//)
		{
			$decrementFlag++;
		}
		elsif($capability=~s/^\%d//)
		{
			if($string=~s/^(\d+)//)
			{
				push @parameters, $1;
			}
			else
			{
				return;
			}
		}
		elsif($capability=~s/^\%c//)
		{
			if($string=~s/^(.)//)
			{
				push @parameters, $1;
			}
			else
			{
				return;
			}
		}
		elsif($capability=~s/^\%\[(.*?)\]//)
		{
			my $characters='';
			my $charList=$1;
			while(my $c=substr $string, 0, 1, '')
			{
				if(index($charList, $c)>=0)
				{
					$characters.=$c;
				}
				else
				{
					substr $string, 0, 0, $c;
					last;
				}				
			}
			push @parameters, $characters;

		}
		elsif($capability=~s/^(.)//)
		{
			unless($1 eq substr $string, 0, 1, '')
			{
				return;
			}
		}
	}

	while($decrementFlag-->0)
	{
		$parameters[0]--;
		$parameters[1]--;
	}

	return @parameters;
}

sub getBooleanNames()
{
	return @booleanNames;
}

sub getNumberNames()
{
	return @numberNames;
}

sub getStringNames()
{
	return @stringNames;
}

return 1;
