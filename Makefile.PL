use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Finance::Currency::Convert::Yahoo',
    'VERSION_FROM'	=> 'Yahoo.pm', # finds $VERSION
    'PREREQ_PM'		=> {
		LWP::UserAgent => 0.1,
		HTTP::Request => 0.1,
		HTML::TokeParser => 0.1,
		Carp => 0.0,
		},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Yahoo.pm', # retrieve abstract from module
       AUTHOR     => 'Lee Goddard <lgoddard@cpan.org>') : ()),
);
