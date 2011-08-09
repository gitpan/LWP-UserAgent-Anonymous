package LWP::UserAgent::Anonymous;

use warnings; use strict;

use Carp;
use Clone;
use Net::Telnet;
use Data::Dumper;
use List::Util qw/shuffle/;
use base qw/LWP::UserAgent Clone/;
use LWP::UserAgent::Anonymous::Proxy;

=head1 NAME

LWP::UserAgent::Anonymous - Interface to anonymous LWP::UserAgent.

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 DESCRIPTION

It provides an anonymity to a user agent by  setting the proxy from the pool of 2329  proxies.
It tries to get a valid proxy from the default pool, however,if it can't get hold of any valid
after  trying  $DEFAULT_RETRY_COUNT times, it falls back to non-proxy mode. I have come across
quite  a  few  modules  available  on  CPAN  that  claims to be a frontrunner in this area but
unfortunately they all rely on external website that keeps changing with the time and breaking
the module in the end.I tried not to rely on the external website for proxy server but capture
all the information and keep it locally. Also we have safety net as  well just in case nothing
works.  I promise NOTE: There is no gurantee that you would get anonymous proxy. However there 
is a very good probability of getting one.

    use strict; use warnings; 
    use LWP::UserAgent::Anonymous;

    my $browser = LWP::UserAgent::Anonymous->new();

=cut

$| = 1;
our $DEBUG = 0;
our $DEFAULT_RETRY_COUNT = 3;

=head1 METHODS

=head2 anon_request()

This  is simply acts like proxy handler for user agent. It tries to get hold of  a valid proxy
server,  if  it can't then it simply takes the standard route. This method  behaves exactly as 
method  request()  for LWP::UserAgent  plus  sets  the proxy for you. You can get the internal 
details by switching the debug $LWP::UserAgent::Anonymous::DEBUG.

    use strict; use warnings;
    use LWP::UserAgent::Anonymous;

    my $browser  = LWP::UserAgent::Anonymous->new();
    my $request  = HTTP::Request->new(GET=>'http://www.google.com/');
    my $response = $browser->anon_request($request);

=cut

sub anon_request
{
    my $self  = shift;
    my $clone = $self->clone();
    my $retry = $DEFAULT_RETRY_COUNT;

    print "INFO: Max retry: [$retry]\n" if $DEBUG;
    while ($retry > 0)
    {
        my $proxy = $self->set_proxy();
        if (defined($proxy) && ($proxy =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\:\d{1,6}/))
        {
            $self->proxy(['http','ftp'], $proxy);
            my $response = $self->SUPER::request(@_);
            print {*STDOUT} "INFO: Status " . $response->status_line . "\n" if $DEBUG;
            return $response if (defined($response) && $response->is_success);
        }    
        $retry--;
    }

    print {*STDOUT} "WARN: Unable to get the proxy ... going no-proxy route now.\n" if $DEBUG;
    return $clone->SUPER::request(@_);
}

=head2 get_proxy()

This returns the proxy that was used last time.

    use strict; use warnings;
    use LWP::UserAgent::Anonymous;

    my $browser  = LWP::UserAgent::Anonymous->new();
    my $request  = HTTP::Request->new(GET=>'http://www.google.com/');
    my $response = $browser->anon_request($request);
    print "Proxy used last time : " . $browser->get_proxy(). "\n";

=cut

sub get_proxy
{
    my $self = shift;
    return $self->{_proxy} 
        if (exists($self->{_proxy}) && defined($self->{_proxy}));
    return 'N/A';    
}

=head2 is_it_ok()

This takes in a proxy and validates it by telneting it. Returns 1 on success and 0 on failure.
This is being called by method set_proxy(). 
Expects the proxy in the format of ddd.ddd.ddd.ddd:ddddd.

    use strict; use warnings;
    use LWP::UserAgent::Anonymous;

    my $browser = LWP::UserAgent::Anonymous->new();
    print "Valid proxy.\n" if $browser->is_it_ok('70.186.168.130:9090');

=cut

sub is_it_ok
{
    my $self  = shift;
    my $proxy = shift;

    return 0 unless defined($proxy);

    return 0 if (exists($self->{_buggy}) && exists($self->{_buggy}->{$proxy}));

    $proxy =~ /(.*)\:(.*)/;
    print {*STDOUT} "INFO: Telneting host [$1] on port [$2] ... " if $DEBUG;

    my $telnet = Net::Telnet->new();
    eval { $telnet->open(Host => $1, Port => $2); };
    if ($@)
    {
        $self->{_buggy}->{$proxy} = 1;
        print {*STDOUT} "[FAIL]\n" if $DEBUG;
        return 0;
    }
    my $error = $telnet->errmsg;
    if (defined($error) && ($error ne ''))
    {
        $self->{_buggy}->{$proxy} = 1;
        print {*STDOUT} "[FAIL]\n" if $DEBUG;
        return 0;
    }
    print {*STDOUT} "[OK]\n" if $DEBUG;
    return 1;
}

=head2 set_debug()

Turn debug on or off by passing 1 or 0 respectively.

    use strict; use warnings;
    use LWP::UserAgent::Anonymous;

    my $browser = LWP::UserAgent::Anonymous->new();
    $browser->set_debug(1);

=cut

sub set_debug
{
    my $self = shift;
    $DEBUG = shift;
}

=head2 set_retry()

Set retry count when fetching proxies. By default the count is 3.

    use strict; use warnings;
    use LWP::UserAgent::Anonymous;

    my $browser = LWP::UserAgent::Anonymous->new();
    $browser->set_retry(2);

=cut

sub set_retry
{
    my $self = shift;
    $DEFAULT_RETRY_COUNT = shift;
}

=head2 set_proxy()

This loads up the default list of proxies and shuffles it before picking up one from the list.
This  is  being called by method anon_request(). This *SHOULD* not be called directly, instead 
let method anon_request() handle the call for you.

    use strict; use warnings;
    use LWP::UserAgent::Anonymous;

    my $browser = LWP::UserAgent::Anonymous->new();
    $browser->set_proxy();

=cut

sub set_proxy
{
    my $self = shift;

    my ($proxy, @list);
    @list  = shuffle(@{$LWP::UserAgent::Anonymous::Proxy::DEFAULT});
    $proxy = shift(@list);

    if (defined $proxy)
    {
        return unless ($self->is_it_ok($proxy));

        print {*STDOUT} "INFO: Using proxy [$proxy] ...\n" if $DEBUG;
        $self->{_proxy} = sprintf("http://%s/", $proxy);

        return $self->{_proxy};
    }
    print {*STDOUT} "WARN: No proxy could be found.\n" if $DEBUG;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lwp-useragent-anonymous at rt.cpan.org>,or
 through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=LWP-UserAgent-Anonymous>.
I will be notified and then you'll automatically be notified of progress on your bug as I make 
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc LWP::UserAgent::Anonymous

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=LWP-UserAgent-Anonymous>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/LWP-UserAgent-Anonymous>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/LWP-UserAgent-Anonymous>

=item * Search CPAN

L<http://search.cpan.org/dist/LWP-UserAgent-Anonymous/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the 
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed  in  the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of LWP::UserAgent::Anonymous