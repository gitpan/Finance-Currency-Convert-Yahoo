package Finance::Currency::Convert::Yahoo;

use vars qw/$VERSION $DATE $CHAT %currencies/;

$VERSION = 0.04;
$DATE = "28 January 2003 22:33 CET";

=head1 NAME

Finance::Currency::Convert::Yahoo - convert currencies using Yahoo

=head1 SYNOPSIS

	use Finance::Currency::Convert::Yahoo;
	$Finance::Currency::Convert::Yahoo::CHAT = 1;
	$_ = Finance::Currency::Convert::Yahoo::convert(1,'USD','GBP');
	print "Is $_\n" if defined $_;

=head1 DESCRIPTION

Using Finance.Yahoo.com, converts a sum between two currencies.

=cut

use strict;
use Carp;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use HTML::TokeParser;

#
# Glabal variables
#

$CHAT = 0;		# Set for real-time notes to STDERR

our %currencies = (
	'AFA'=>'Afghanistan Afghani', 	'ALL'=>'Albanian Lek', 	'DZD'=>'Algerian Dinar',
	'ADF'=>'Andorran Franc', 	'ADP'=>'Andorran Peseta', 	'ARS'=>'Argentine Peso',
	'AWG'=>'Aruba Florin', 	'AUD'=>'Australian Dollar', 	'ATS'=>'Austrian Schilling',
	'BSD'=>'Bahamian Dollar', 	'BHD'=>'Bahraini Dinar', 	'BDT'=>'Bangladesh Taka',
	'BBD'=>'Barbados Dollar', 	'BEF'=>'Belgian Franc', 	'BZD'=>'Belize Dollar',
	'BMD'=>'Bermuda Dollar', 	'BTN'=>'Bhutan Ngultrum', 	'BOB'=>'Bolivian Boliviano',
	'BWP'=>'Botswana Pula', 	'BRL'=>'Brazilian Real', 	'GBP'=>'British Pound',
	'BND'=>'Brunei Dollar', 	'BIF'=>'Burundi Franc', 	'XOF'=>'CFA Franc (BCEAO)',
	'XAF'=>'CFA Franc (BEAC)', 	'KHR'=>'Cambodia Riel', 	'CAD'=>'Canadian Dollar',
	'CVE'=>'Cape Verde Escudo', 	'KYD'=>'Cayman Islands Dollar', 	'CLP'=>'Chilean Peso',
	'CNY'=>'Chinese Yuan', 	'COP'=>'Colombian Peso', 	'KMF'=>'Comoros Franc',
	'CRC'=>'Costa Rica Colon', 	'HRK'=>'Croatian Kuna', 	'CUP'=>'Cuban Peso',
	'CYP'=>'Cyprus Pound', 	'CZK'=>'Czech Koruna', 	'DKK'=>'Danish Krone',
	'DJF'=>'Dijibouti Franc', 	'DOP'=>'Dominican Peso', 	'NLG'=>'Dutch Guilder',
	'XCD'=>'East Caribbean Dollar', 	'ECS'=>'Ecuadorian Sucre', 	'EGP'=>'Egyptian Pound',
	'SVC'=>'El Salvador Colon', 	'EEK'=>'Estonian Kroon', 	'ETB'=>'Ethiopian Birr',
	'EUR'=>'Euro', 	'FKP'=>'Falkland Islands Pound', 	'FJD'=>'Fiji Dollar',
	'FIM'=>'Finnish Mark', 	'FRF'=>'French Franc', 	'GMD'=>'Gambian Dalasi',
	'DEM'=>'German Mark', 	'GHC'=>'Ghanian Cedi', 	'GIP'=>'Gibraltar Pound',
	'XAU'=>'Gold Ounces', 	'GRD'=>'Greek Drachma', 	'GTQ'=>'Guatemala Quetzal',
	'GNF'=>'Guinea Franc', 	'GYD'=>'Guyana Dollar', 	'HTG'=>'Haiti Gourde',
	'HNL'=>'Honduras Lempira', 	'HKD'=>'Hong Kong Dollar', 	'HUF'=>'Hungarian Forint',
	'ISK'=>'Iceland Krona', 	'INR'=>'Indian Rupee', 	'IDR'=>'Indonesian Rupiah',
	'IQD'=>'Iraqi Dinar', 	'IEP'=>'Irish Punt', 	'ILS'=>'Israeli Shekel',
	'ITL'=>'Italian Lira', 	'JMD'=>'Jamaican Dollar', 	'JPY'=>'Japanese Yen',
	'JOD'=>'Jordanian Dinar', 	'KZT'=>'Kazakhstan Tenge', 	'KES'=>'Kenyan Shilling',
	'KRW'=>'Korean Won', 	'KWD'=>'Kuwaiti Dinar', 	'LAK'=>'Lao Kip', 	'LVL'=>'Latvian Lat',
	'LBP'=>'Lebanese Pound', 	'LSL'=>'Lesotho Loti', 	'LRD'=>'Liberian Dollar',
	'LYD'=>'Libyan Dinar', 	'LTL'=>'Lithuanian Lita', 	'LUF'=>'Luxembourg Franc',
	'MOP'=>'Macau Pataca', 	'MKD'=>'Macedonian Denar', 	'MGF'=>'Malagasy Franc',
	'MWK'=>'Malawi Kwacha', 	'MYR'=>'Malaysian Ringgit', 	'MVR'=>'Maldives Rufiyaa',
	'MTL'=>'Maltese Lira', 	'MRO'=>'Mauritania Ougulya', 	'MUR'=>'Mauritius Rupee',
	'MXN'=>'Mexican Peso', 	'MDL'=>'Moldovan Leu', 	'MNT'=>'Mongolian Tugrik',
	'MAD'=>'Moroccan Dirham', 	'MZM'=>'Mozambique Metical', 	'MMK'=>'Myanmar Kyat',
	'NAD'=>'Namibian Dollar', 	'NPR'=>'Nepalese Rupee', 	'ANG'=>'Neth Antilles Guilder',
	'NZD'=>'New Zealand Dollar', 	'NIO'=>'Nicaragua Cordoba', 	'NGN'=>'Nigerian Naira',
	'KPW'=>'North Korean Won', 	'NOK'=>'Norwegian Krone', 	'OMR'=>'Omani Rial',
	'XPF'=>'Pacific Franc', 	'PKR'=>'Pakistani Rupee', 	'XPD'=>'Palladium Ounces',
	'PAB'=>'Panama Balboa', 	'PGK'=>'Papua New Guinea Kina', 	'PYG'=>'Paraguayan Guarani',
	'PEN'=>'Peruvian Nuevo Sol', 	'PHP'=>'Philippine Peso', 	'XPT'=>'Platinum Ounces',
	'PLN'=>'Polish Zloty', 	'PTE'=>'Portuguese Escudo', 	'QAR'=>'Qatar Rial',
	'ROL'=>'Romanian Leu', 	'RUB'=>'Russian Rouble', 	'WST'=>'Samoa Tala',
	'STD'=>'Sao Tome Dobra', 	'SAR'=>'Saudi Arabian Riyal', 	'SCR'=>'Seychelles Rupee',
	'SLL'=>'Sierra Leone Leone', 	'XAG'=>'Silver Ounces', 	'SGD'=>'Singapore Dollar',
	'SKK'=>'Slovak Koruna', 	'SIT'=>'Slovenian Tolar', 	'SBD'=>'Solomon Islands Dollar',
	'SOS'=>'Somali Shilling', 	'ZAR'=>'South African Rand', 	'ESP'=>'Spanish Peseta',
	'LKR'=>'Sri Lanka Rupee', 	'SHP'=>'St Helena Pound', 	'SDD'=>'Sudanese Dinar',
	'SRG'=>'Surinam Guilder', 	'SZL'=>'Swaziland Lilageni', 	'SEK'=>'Swedish Krona',
	'CHF'=>'Swiss Franc', 	'SYP'=>'Syrian Pound', 	'TWD'=>'Taiwan Dollar',
	'TZS'=>'Tanzanian Shilling', 	'THB'=>'Thai Baht', 	'TOP'=>"Tonga Pa'anga",
	'TTD'=>'Trinida and Tobago Dollar', 	'TND'=>'Tunisian Dinar', 	'TRL'=>'Turkish Lira',
	'USD'=>'US Dollar', 	'AED'=>'UAE Dirham', 	'UGX'=>'Ugandan Shilling',
	'UAH'=>'Ukraine Hryvnia', 	'UYU'=>'Uruguayan New Peso', 	'VUV'=>'Vanuatu Vatu',
	'VEB'=>'Venezuelan Bolivar', 	'VND'=>'Vietnam Dong', 	'YER'=>'Yemen Riyal',
	'YUM'=>'Yugoslav Dinar', 	'ZMK'=>'Zambian Kwacha', 	'ZWD'=>'Zimbabwe Dollar'
);



=head1 USE

Call the module's C<&convert> routine, supplying three arguments:
the amount to convert, and the currencies to convert from and to.

Codes are used to identify currencies: you may view them in the
values of the C<%currencies> hash, where keys are descriptions of
the currencies.

In the event that attempts to convert fail, you will recieve C<undef>
in response, with errors going to STDERR, and notes displayed if
the modules global C<$CHAT> is defined.

In more detail, the module accesses C<http://finance.yahoo.com/m5?a=amount&s=start&t=to>,
where C<start> is the currency being converted, C<to> is the
target currency, and C<amount> is the amount being converted.
The latter is a number; the former two codes defined in our
C<%currencies> hash. (Last checked 07 December 2001).


=cut

sub convert { my ($amount, $from, $to) = (shift,shift,shift);
	die "Please call as ...::convert(\$amount,\$from,\$to) " unless (defined $amount and defined $from and defined $to);
	carp "No such currency code as <$from>." and return undef if not exists $currencies{$from};
	carp "No such currency code as <$to>." and return undef if not exists $currencies{$to};
	carp "Please supply a positive sum to convert <received $amount>." and return undef if $amount<0;
	warn "Converting <$amount> from <$from> to <$to> " if $CHAT;
	my ($doc,$result);
	for my $attempt (0..3){
		warn "Attempt $attempt ...\n" if $CHAT;
		$doc = _get_document($amount,$from,$to);
		# Can't say "last if defined $doc" as $doc may be a Yahoo 404-like error?
		last if defined $doc;
	}
	if (defined $doc){
		$result = _extract_data($doc);
		warn "Got doc" if $CHAT;
	}
	if (defined $doc and defined $result){
		warn "Result:$result\n" if defined $result and defined $CHAT;
		return $amount * $result;
	} elsif (defined $doc and not defined $result){
		carp "Connected to Yahoo but could not read the page: sorry" if defined $CHAT;
		return undef;
	} else {
		carp "Could not connect to Yahoo" if defined $CHAT;
		return undef;
	}
}



#
# PRIVATE SUB get_document
# Accepts: amount, starting currency, target currency
# Returns:
#
sub _get_document { my ($amount,$from,$to) = (shift,shift,shift);
my $doc;
open IN,"test.html" or die;
read IN,$doc,-s IN;
close IN;
return $doc;
	die "get_document requires a \$amount,\$from_currency,\$target_currency arrity" unless (defined $amount and defined $to and defined $from);

	my $ua = LWP::UserAgent->new;												# Create a new UserAgent
	$ua->agent('Mozilla/25.'.(localtime)." (PERL ".__PACKAGE__." $VERSION");	# Give it a type name

	my $url =
		'http://finance.yahoo.com/m5?'
		. 'a='.$amount
		. '&s='.$from
		. '&t='.$to
	;
	warn "Attempting to access <$url> ...\n" if $CHAT;

	# Format URL request
	my $req = new HTTP::Request ('GET',$url) or die "...could not GET.\n" and return undef;
	my $res = $ua->request($req);						# $res is the object UA returned
	if (not $res->is_success()) {						# If successful
		warn"...failed.\n" if $CHAT;
		return undef
	}
	warn "...ok.\n" if $CHAT;

	return $res->content;
}


#
# PRIVATE SUB _extract_data
# Accept: HTML doc as arg
# Return amount on success, undef on failure
# JAN  2003: Data is now in SEVENTH table, second row, second (non-header) cell, in bold
# JULY 2001: Data is in fourth table's fourth TD
# DEC  2001: Data is in FIFTH table
#
sub _extract_data { my $doc = shift;
	my $token;
	my $p = HTML::TokeParser->new(\$doc) or die "Couldn't create TokePraser: $!";
	# Seventh TABLE
	for (1..7){
		while ($token = $p->get_token
			and not (@$token[0] eq 'S' and @$token[1] eq 'table')
		){}
	}
	# Second TR
	for (1..2){
		while ($token = $p->get_token
			and not (@$token[0] eq 'S' and @$token[1] eq 'tr')
		){}
	}
	# Second TD
	for (1..2){
		while ($token = $p->get_token
			and not (@$token[0] eq 'S' and @$token[1] eq 'td')
		){}
	}
	$token = $p->get_token or return undef;
	return undef if @$token[0] ne 'S' and @$token[1] ne 'b';

	$token = $p->get_token or return undef;
	return undef if @$token[0] ne 'T';

	return @$token[1] =~ /^[\d.]+$/ ? @$token[1] : undef;
}


# Checking offline....
# {local *IN;
# open IN, 'C:\Documents and Settings\Administrator\My Documents\Yahoo! Finance - Currency Conversion.htm' or die;
# read IN,$_,-s IN;
# close IN;
# warn &_extract_data ($_);
# online: print convert(1,'HUF','GBP');
# exit;}

=head1 EXPORTS

None by default.

=head1 REVISIONS

Please see the enclosed file CHANGES.

=head1 SEE ALSO

L<LWP::UserAgent>, L<HTTP::Request>, L<HTML::TokeParser>.

=head1 AUTHOR

Lee Goddard L<lgoddard@cpan.org|mailto:lgoddard@cpan.org>.

=head1 COPYRIGHT

Copyright (C) Lee Goddard, 2001 - All Rights Reserved.

This library is free software and may be used only under the same terms as Perl itself.

=cut

1;
__END__
