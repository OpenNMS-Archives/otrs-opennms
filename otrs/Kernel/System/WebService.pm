# This file is part of the OpenNMS(R) Application.
#
# OpenNMS(R) is Copyright (C) 2002-2008 The OpenNMS Group, Inc. All rights
# reserved.  OpenNMS(R) is a derivative work, containing both original code,
# included code and modified code that was published under the GNU General
# Public License. Copyrights for modified and included code are below.
#
# OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
#
# Copyright (C) Jonathan Sartin (Jonathan@opennms.org)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# For more information contact:
# OpenNMS Licensing <license@opennms.org>
# http://www.opennms.org/
# http://www.opennms.com/

# Kernel/System/WebService.pm - Super Class for Ticket/Article interface for OpenNMS Integration


package Kernel::System::WebService;

use strict;
use warnings;

use SOAP::Lite;
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
    }
    if ( $header->{request_header}->{User} ne $RequiredUser || $header->{request_header}->{Pass} ne $RequiredPassword ) {
        $Self->{CommonObject}->{LogObject}->Log(
            Priority => 'notice',
            Message  => "Auth for user $header->{request_header}->{User} failed!",
        );
        die SOAP::Fault
        	->faultcode('Server.RequestError')
        	->faultstring("Authentication Failure");
    }
    
    bless($Self, $Class);
	
	return $Self;
  
}


1;
