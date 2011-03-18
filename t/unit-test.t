#!perl

use strict; use warnings;

use Test::More;
use HTTP::Request;
use LWP::UserAgent;
use LWP::UserAgent::Anonymous;

my ($browser, $request, $response);
$browser  = LWP::UserAgent->new();
$response = $browser->get('http://search.cpan.org/');
plan skip_all => "It appears you don't have internet access."
    unless ($response->is_success);

$browser  = LWP::UserAgent::Anonymous->new();    
$browser->set_retry(1);
$request  = HTTP::Request->new(GET=>'http://www.google.com/');
$response = $browser->anon_request($request);
like($response->status_line, qr/200 OK/);

done_testing();