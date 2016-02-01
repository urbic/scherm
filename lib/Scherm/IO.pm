package Scherm::IO;
use warnings;
#use Fcntl qw/O_RDWR O_NONBLOCK/;
use POSIX qw/:termios_h/;
use Scherm::KeyMap;
		
my @byteRates
	=(
		0, 50, 75, 110, 134, 150, 200, 300, 600, 1200, 1800, 2400, 4800, 9600,
		19200, 38400,
	);

sub new()
{
	my $class=shift;
	my $self=
		{
			inbuffer=>'',
			outbuffer=>'',
		};
	#$self->{tty}=IO::File->new;
	#$self->{tty}->open('/dev/tty', O_RDWR|O_NONBLOCK)
	#$self->{tty}->open('/dev/tty', O_RDWR)
	#	or croak "Can not open tty: $!";

	my $termios=POSIX::Termios->new;
	$self->{tty}=IO::File->new;
	$self->{tty}->open(POSIX::ttyname(STDOUT->fileno), '+<')
		or die "STDOUT not connected to terminal\n";

	$termios->getattr($self->{tty}->fileno);

	# Get output speed
	$self->{ospeed}=$termios->getispeed;

	# Get byte rate
	$self->{bitrate}=$byteRates[$self->{ospeed}];

    $termios->getattr($self->{tty}->fileno);
	$termios->setlflag($termios->getlflag & ~(ECHO|ECHOK|ICANON));
	$termios->setcc(VTIME, 1);
	$termios->setattr($self->{tty}->fileno, TCSANOW);

	return bless $self, $class;
}

sub putStringBuffered($)
{
	my $self=shift;
	$self->{outbuffer}.=shift;
}

sub flushOutput()
{
	my $self=shift;
	$self->putString($self->{outbuffer});
	$self->{outbuffer}='';
}

sub putString($)
{
	my $self=shift;
	my $input=shift;
	my $output=$input;	# TODO: padding
	utf8::encode($output);
	$self->{tty}->syswrite($output);
}

sub inputPending(;$)
{
	my $self=shift;
	my $wait=shift//0;
	vec(my $rBits='', $self->{tty}->fileno, 1)=1;
	return select($rBits, undef, undef, $wait);
}

sub flushInput()
{
	my $self=shift;
	my $availableBytes=$self->{inbuffer};
	$self->{inbuffer}='';
	$availableBytes.=$self->getByte while $self->inputPending;
	return $availableBytes;
}

sub getByte()
{
	my $self=shift;
	return substr $self->{inbuffer}, 0, 1, ''
		if length $self->{inbuffer};
	sysread($self->{tty}, my $c, 1);
	return $c;
}

sub ungetBytes($)
{
	my $self=shift;
	my $byte=shift;
	substr $self->{inbuffer}, 0, 0, $byte;
}

return 1;
