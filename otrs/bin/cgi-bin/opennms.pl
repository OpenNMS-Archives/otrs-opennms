#!/opt/local/bin/perl -w
# --
# bin/cgi-bin/opennms.pl - Dispatcher script for OpenNMS Integration module
# Copyright (C) (Jonathan Sartin) (Jonathan@opennms.org)
# --
# $Id: opennms.pl 18 2008-05-08 17:59:48Z user $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
# --

use strict;
use warnings;

# use ../../ as lib location

use FindBin qw($Bin);
use lib "$Bin/../..";
use lib "$Bin/../../Kernel/cpan-lib";

use SOAP::Transport::HTTP;

use vars qw($VERSION);
$VERSION = qw($Revision: 18 $) [1];

my $ClassMap = {'http://opennms.org/integration/otrs/ticketservice' => 'Kernel::System::TicketService'};

SOAP::Transport::HTTP::CGI->dispatch_with($ClassMap)
							->handle;

