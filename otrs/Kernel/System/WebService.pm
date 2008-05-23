# --
# Kernel/System/WebService.pm - Super Class for Ticket/Article interface for OpenNMS Integration
# Copyright (C) (Jonathan Sartin) (Jonathan@opennms.org)
# --
# $Id: WebService.pm 18 2008-05-08 17:59:48Z user $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
# --

package Kernel::System::WebService;

use strict;
use warnings;

use SOAP::Lite +trace => 'all';
use Data::Dumper;
use Kernel::Config;
use Kernel::System::Log;
use Kernel::System::DB;
use Kernel::System::PID;
use Kernel::System::Main;
use Kernel::System::Time;
use Kernel::System::User;
use Kernel::System::Group;
use Kernel::System::Queue;
use Kernel::System::Ticket;

use base qw( SOAP::Server::Parameters );

use vars qw($VERSION);
$VERSION = qw($Revision: 18 $) [1];

sub new {
	
	
	my $Class = shift;
	my $Self = {};
	my $som = pop();
	
	# common objects - create as a hashref
	
	$Self->{CommonObject} = {};
	$Self->{CommonObject}->{ConfigObject} = Kernel::Config->new();
	$Self->{CommonObject}->{LogObject}    = Kernel::System::Log->new(
    	LogPrefix => 'OTRS-SOAP',
    	%{$Self->{CommonObject}},
	);
	$Self->{CommonObject}->{MainObject}   = 
		Kernel::System::Main->new(%{$Self->{CommonObject}});
	$Self->{CommonObject}->{DBObject}     = 
		Kernel::System::DB->new(%{$Self->{CommonObject}});
	$Self->{CommonObject}->{PIDObject}    = 
		Kernel::System::PID->new(%{$Self->{CommonObject}});
	$Self->{CommonObject}->{TimeObject}   = 
		Kernel::System::Time->new(%{$Self->{CommonObject}});
	$Self->{CommonObject}->{UserObject}   = 
		Kernel::System::User->new(%{$Self->{CommonObject}});
	$Self->{CommonObject}->{GroupObject}  = 
		Kernel::System::Group->new(%{$Self->{CommonObject}});
	$Self->{CommonObject}->{QueueObject}  = 
		Kernel::System::Queue->new(%{$Self->{CommonObject}});
	$Self->{CommonObject}->{TicketObject} = 
		Kernel::System::Ticket->new(%{$Self->{CommonObject}});
	
	my $header = $som->header();
	my $RequiredUser = $Self->{CommonObject}->{ConfigObject}->Get('SOAP::User');
 	my $RequiredPassword = $Self->{CommonObject}->{ConfigObject}->Get('SOAP::Password');

 	$Self->{CommonObject}->{LogObject}->Log(
		Priority => 'debug',
		Message  => "user: (required) $RequiredUser - (request) $header->{request_header}->{User}",
	);
 
    if ( !defined $RequiredUser || !length( $RequiredUser )
        || !defined $RequiredPassword || !length( $RequiredPassword )
    ) {
        $Self->{CommonObject}->{LogObject}->Log(
            Priority => 'notice',
            Message  => "SOAP::User or SOAP::Password is empty, SOAP access denied!",
        );
        die SOAP::Fault
        	->faultcode('Server.RequestError')
        	->faultstring("Authentication Failure");
        	#->faultdetail("SOAP::User or SOAP::Password is empty, SOAP access denied!");
    }
    if ( $header->{request_header}->{User} ne $RequiredUser || $header->{request_header}->{Pass} ne $RequiredPassword ) {
        $Self->{CommonObject}->{LogObject}->Log(
            Priority => 'notice',
            Message  => "Auth for user $header->{request_header}->{User} failed!",
        );
        die SOAP::Fault
        	->faultcode('Server.RequestError')
        	->faultstring("Authentication Failure");
        	#->faultdetail("Auth for user $header->{request_header}->{User} failed");
    }
    
    bless($Self, $Class);
	
	return $Self;
  
}


1;