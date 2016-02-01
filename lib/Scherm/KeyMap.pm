package Scherm::KeyMap;
use Scherm::Constants qw/:KEY/;

my %keyCapabilities=
(
	kcud1=>KEY_DOWN, kcuu1=>KEY_UP, kcub1=>KEY_LEFT, kcuf1=>KEY_RIGHT,
	khome=>KEY_HOME, kbs=>KEY_BACKSPACE, kf0=>KEY_F0, kf1=>KEY_F1,
	kf2=>KEY_F2, kf3=>KEY_F3, kf4=>KEY_F4, kf5=>KEY_F5,
	kf6=>KEY_F6, kf7=>KEY_F7, kf8=>KEY_F8, kf9=>KEY_F9,
	kf10=>KEY_F10, kf11=>KEY_F11, kf12=>KEY_F12, kf13=>KEY_F13,
	kf14=>KEY_F14, kf15=>KEY_F15, kf16=>KEY_F16, kf17=>KEY_F17,
	kf18=>KEY_F18, kf19=>KEY_F19, kf20=>KEY_F20, kf21=>KEY_F21,
	kf22=>KEY_F22, kf23=>KEY_F23, kf24=>KEY_F24, kf25=>KEY_F25,
	kf26=>KEY_F26, kf27=>KEY_F27, kf28=>KEY_F28, kf29=>KEY_F29,
	kf30=>KEY_F30, kf31=>KEY_F31, kf32=>KEY_F32, kf33=>KEY_F33,
	kf34=>KEY_F34, kf35=>KEY_F35, kf36=>KEY_F36, kf37=>KEY_F37,
	kf38=>KEY_F38, kf39=>KEY_F39, kf40=>KEY_F40, kf41=>KEY_F41,
	kf42=>KEY_F42, kf43=>KEY_F43, kf44=>KEY_F44, kf45=>KEY_F45,
	kf46=>KEY_F46, kf47=>KEY_F47, kf48=>KEY_F48, kf49=>KEY_F49,
	kf50=>KEY_F50, kf51=>KEY_F51, kf52=>KEY_F52, kf53=>KEY_F53,
	kf54=>KEY_F54, kf55=>KEY_F55, kf56=>KEY_F56, kf57=>KEY_F57,
	kf58=>KEY_F58, kf59=>KEY_F59, kf60=>KEY_F60, kf61=>KEY_F61,
	kf62=>KEY_F62, kf63=>KEY_F63, kdl1=>KEY_DL, kil1=>KEY_IL,
	kdch1=>KEY_DC, kich1=>KEY_IC, krmir=>KEY_EIC, kclr=>KEY_CLEAR,
	ked=>KEY_EOS, kel=>KEY_EOL, kind=>KEY_SF, kri=>KEY_SR,
	knp=>KEY_NPAGE, kpp=>KEY_PPAGE, khts=>KEY_STAB, kctab=>KEY_CTAB,
	ktbc=>KEY_CATAB, kent=>KEY_ENTER, kprt=>KEY_PRINT, kll=>KEY_LL,
	ka1=>KEY_A1, ka3=>KEY_A3, kb2=>KEY_B2, kc1=>KEY_C1,
	kc3=>KEY_C3, kcbt=>KEY_BTAB, kbeg=>KEY_BEG, kcan=>KEY_CANCEL,
	kclo=>KEY_CLOSE, kcmd=>KEY_COMMAND, kcpy=>KEY_COPY, kcrt=>KEY_CREATE,
	kend=>KEY_END, kext=>KEY_EXIT, kfnd=>KEY_FIND, khlp=>KEY_HELP,
	kmrk=>KEY_MARK, kmsg=>KEY_MESSAGE, kmov=>KEY_MOVE, knxt=>KEY_NEXT,
	kopn=>KEY_OPEN, kopt=>KEY_OPTIONS, kprv=>KEY_PREVIOUS, krdo=>KEY_REDO,
	kref=>KEY_REFERENCE, krfr=>KEY_REFRESH, krpl=>KEY_REPLACE, krst=>KEY_RESTART,
	kres=>KEY_RESUME, ksav=>KEY_SAVE, kBEG=>KEY_SBEG, kcan=>KEY_SCANCEL,
	kCMD=>KEY_SCOMMAND, kCPY=>KEY_SCOPY, kCRT=>KEY_SCREATE, kDC=>KEY_SDC,
	kDL=>KEY_SDL, kslt=>KEY_SELECT, kEND=>KEY_SEND, kEOL=>KEY_SEOL,
	kEXT=>KEY_SEXIT, kFND=>KEY_SFIND, kHLP=>KEY_SHELP, kHOM=>KEY_SHOME,
	kIC	=>KEY_SIC, kLFT=>KEY_SLEFT, kMSG=>KEY_SMESSAGE, kMOV=>KEY_SMOVE,
	kNXT=>KEY_SNEXT, kOPT=>KEY_SOPTIONS, kPRV=>KEY_SPREVIOUS, kPRT=>KEY_SPRINT,
	kRDO=>KEY_SREDO, kRPL=>KEY_SREPLACE, kRIT=>KEY_SRIGHT, kRES=>KEY_SRSUME,
	kSAV=>KEY_SSAVE, kSPD=>KEY_SSUSPEND, kUND=>KEY_SUNDO, kSPD=>KEY_SUSPEND,
	kUND=>KEY_UNDO, kmous=>KEY_MOUSE,
	# KEY_RESIZE KEY_EVENT		
);

sub new
{
	my $class=shift;
	my $self=shift//{};	# May be copy instead of clone?
	return bless $self, $class;
}

sub setMapping($$)
{
	my $self=shift;
	my $key=shift;
	my $character=shift;
	$self->{$key}=$character;
	#$key=~s/\e/\\E/g;
	#warn "SET MAPPING ".(sprintf '%X', ord $character)." <- $key\n";
}

sub setMappingUnlessDefined($$)
{
	my $self=shift;
	my $key=shift;
	my $character=shift;
	$self->{$key}//=$character;
}

sub deleteMapping($)
{
	delete shift->{shift()};
}

sub getKeyCapNames
{
	return keys %keyCapabilities;
}

sub getKeyCapability
{
	return $keyCapabilities{shift()};
}

return 1;
