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

package Kernel::System::TicketService;

@ISA = ("Kernel::System::WebService");

use strict;
use warnings;

use Kernel::System::WebService;
use SOAP::DateTime;
use integer;
use constant URI => "http://opennms.org/integration/otrs/TicketService";

use vars qw($VERSION);
$VERSION = qw($Revision: 19 $) [1];

sub new {
 
    my $class = shift;
    
    return $class if ref($class);
    
    my $Self = $class->SUPER::new(@_);
 
    return $Self;

}

sub TicketGetByID() {

	my $Self = shift->new(@_);
	my $TicketID = shift;

	my %Ticket = $Self->{CommonObject}->{TicketObject}->TicketGet(
		TicketID => $TicketID
	);

	unless (%Ticket) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "No such ticket: $TicketID");
    	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No such ticket: $TicketID");
	}
	
	my $Created = ConvertDate( $Ticket{Created} );
	
	my @TicketResponse = 
	(
		SOAP::Data->name("TicketID" => $Ticket{TicketID})->type("int"),
		SOAP::Data->name("TicketNumber" => $Ticket{TicketNumber})->type("long"),
		SOAP::Data->name("Title" => $Ticket{Title})->type("string"),
		SOAP::Data->name("Age" => $Ticket{Age})->type("int"),
		SOAP::Data->name("State" => $Ticket{State})->type("string"),
		SOAP::Data->name("StateID" => $Ticket{StateID})->type("int"),
		SOAP::Data->name("StateType" => $Ticket{State})->type("string"),
		SOAP::Data->name("Priority" => $Ticket{Priority})->type("string"),
		SOAP::Data->name("PriorityID" => $Ticket{PriorityID})->type("int"),
		SOAP::Data->name("Lock" => $Ticket{Lock})->type("string"),
		SOAP::Data->name("LockID" => $Ticket{LockID})->type("int"),
		SOAP::Data->name("UnlockTimeout" => $Ticket{UnlockTimeout})->type("int"),
		SOAP::Data->name("Queue" => $Ticket{Queue})->type("string"),
		SOAP::Data->name("QueueID" => $Ticket{QueueID})->type("int"),
		SOAP::Data->name("GroupID" => $Ticket{GroupID})->type("int"),
		SOAP::Data->name("CustomerID" => $Ticket{CustomerID})->type("string"),
		SOAP::Data->name("CustomerUserID" => $Ticket{CustomerUserID})->type("string"),
		SOAP::Data->name("Owner" => $Ticket{Owner})->type("string"),
		SOAP::Data->name("OwnerID" => $Ticket{OwnerID})->type("int"),
		SOAP::Data->name("Responsible" => $Ticket{Responsible})->type("string"),
		SOAP::Data->name("ResponsibleID" => $Ticket{ResponsibleID})->type("int"),
		SOAP::Data->name("Type" => $Ticket{Type})->type("string"),
		SOAP::Data->name("TypeID" => $Ticket{TypeID})->type("int"),
		SOAP::Data->name("SLAID" => $Ticket{SLAID})->type("int"),
		SOAP::Data->name("ServiceID" => $Ticket{ServiceID})->type("int"),
		SOAP::Data->name("Created" => $Created)->type("dateTime"),
		SOAP::Data->name("CreateTimeUnix" => $Ticket{CreateTimeUnix})->type("long"),
		SOAP::Data->name("UntilTime" => $Ticket{UntilTime})->type("long"),
		SOAP::Data->name("EscalationStartTime" => $Ticket{EscalationStartTime})->type("long"),
		SOAP::Data->name("EscalationResponseTime" => $Ticket{EscalationResponseTime})->type("long"),
		SOAP::Data->name("EscalationSolutionTime" => $Ticket{EscalationSolutionTime})->type("long"),
	);
    
    return SOAP::Data->name( "Ticket" )
			->attr( {"xmlns:tns" => URI } )
			->type( "tns:Ticket" )
			->value( \SOAP::Data->value(@TicketResponse) );
	
}

sub TicketGetByNumber() {

	my $Self = shift->new(@_);
	my $TicketNumber = shift();
		
	my $TicketID = $Self->{CommonObject}->{TicketObject}->TicketIDLookup(TicketNumber => $TicketNumber);
    
    unless ($TicketID) {
		$Self->{CommonObject}->{LogObject}->Log( Priority => 'error', 
			Message => "No TicketID for TicketNumber $TicketNumber" );
       	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No TicketID for TicketNumber $TicketNumber");
	}
    
    return $Self->TicketGetByID($TicketID);
    
}

sub GetById() {
	
	my $Self = shift->new(@_);
	my $TicketID = shift();
		
    my $Ticket =  $Self->TicketGetByID($TicketID);
    my $Articles =  $Self->ArticleGetAllByTicketID($TicketID);
    
    my @GetByIdResponse = 
	(
		SOAP::Data->value($Ticket),
		SOAP::Data->value($Articles)
 	);
 	
    return SOAP::Data->name( "ticketWithArticles" )
			->attr( {"xmlns:tns" => URI } )
			->type( "tns:TicketWithArticles" )
			->value( \SOAP::Data->value(@GetByIdResponse) );
	
}

sub GetByNumber() {
	
	my $Self = shift->new(@_);
	my $TicketNumber = shift();
		
	my $TicketID = $Self->{CommonObject}->{TicketObject}->TicketIDLookup(TicketNumber => $TicketNumber);
    
    unless ($TicketID) {
		$Self->{CommonObject}->{LogObject}->Log( Priority => 'error', 
			Message => "No TicketID for TicketNumber $TicketNumber" );
       	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No TicketID for TicketNumber $TicketNumber");
	};
    
    my $Ticket =  $Self->TicketGetByID($TicketID);
    my $Articles =  $Self->ArticleGetAllByTicketID($TicketID);
    
    my @GetByNumberResponse = 
	(
		SOAP::Data->value($Ticket),
		SOAP::Data->value($Articles)
 	);
 	
    return SOAP::Data->name( "ticketWithArticles" )
			->attr( {"xmlns:tns" => URI } )
			->type( "tns:TicketWithArticles" )
			->value( \SOAP::Data->value(@GetByNumberResponse) );
	
}


sub TicketCreate() {
	
	my $Self = shift->new(@_);
	my $TicketReq = shift;
	my $UserID = shift;
	my %Ticket;
	
    my @AlternateField = ('Queue', 'Priority', 'State', 'Lock');
    
    foreach (@AlternateField) {
		if ( $TicketReq->{$_.'ID'} ) {
			$Ticket{$_.'ID'} = $TicketReq->{$_.'ID'};
		} elsif ($TicketReq->{$_}) {
			$Ticket{$_} = $TicketReq->{$_};
		} else {
			die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring('Require '.$_.' or '.$_.'ID');
		}
    }
    
    my @RequiredField = ('Title', 'OwnerID');
    
    foreach (@RequiredField) {
		if ( $TicketReq->{$_} ) {
			$Ticket{$_} = $TicketReq->{$_};
		} else {
			die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring("Require $_ ");
		}
    }
    
    # Need UserID or User, but have to look up UserID if given User.
    
    if ( $TicketReq->{UserID} ) {
			$Ticket{UserID} = $TicketReq->{UserID};
		} elsif ($TicketReq->{User}) {
			$Ticket{UserID} = $Self->GetUserIDForUser( \$TicketReq->{User} );
		} else {
			die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring('Require UserID or User');
	}
	

	my $TicketID = $Self->{CommonObject}->{TicketObject}->TicketCreate(%Ticket);
    
    unless ($TicketID) {
    	die SOAP::Fault
    		->faultcode('Server.RequestError')
        	->faultstring("Unable to create Ticket");
    }
    
    my $TicketNumber = $Self->{CommonObject}->{TicketObject}->TicketNumberLookup(TicketID => $TicketID);
    
    my @TicketIDAndNumber = 
	(
		SOAP::Data->name("TicketID" => $TicketID)->type("int"),
		SOAP::Data->name("TicketNumber" => $TicketNumber)->type("long"),
	);


    return SOAP::Data->name( "TicketIDAndNumber" )
			->attr( {"xmlns:tns" => URI } )
			->type( "tns:TicketIDAndNumber" )
			->value( \SOAP::Data->value(@TicketIDAndNumber) );

}

sub TicketStateUpdate() {

	my $Self = shift->new(@_);
	my $TicketStateUpdateReq = shift();
	my $UserID;
	my $TicketID;
		
	# Need TicketID or TicketNumber, make sure we've got one or the other. 
	# Look up the TicketID from the TicketNumber if that's what was presented.
	
	if ($TicketStateUpdateReq->{TicketNumber}) {
		$TicketID = $Self->{CommonObject}->{TicketObject}->TicketIDLookup(TicketNumber => $TicketStateUpdateReq->{TicketNumber});
	} elsif ($TicketStateUpdateReq->{TicketID}) {
		$TicketID = $TicketStateUpdateReq->{TicketID};
	} else {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "Require TicketID or TicketNumber");
		die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("Require TicketID or TicketNumber");
	};
	
	# Check the TicketID is valid
	
	unless ($Self->{CommonObject}->{TicketObject}->TicketGet(TicketID => $TicketID)) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "No such ticket: $TicketID");
    	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No such ticket: $TicketID");
	}
	
	# Need UserID or User, but have to look up UserID if given User.
	
	if ( $TicketStateUpdateReq->{UserID} ) {
			$UserID = $TicketStateUpdateReq->{UserID};
		} elsif ($TicketStateUpdateReq->{User}) {
			$UserID = $Self->GetUserIDForUser( \$TicketStateUpdateReq->{User});
		} else {
			$Self->{CommonObject}->{LogObject}->Log(
				Priority => 'error',
				Message => "Require UserID or User");
			die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring('Require UserID or User');
	}
	
	# Update, using ticketID and UserID with State or StatID depending on
	# which was offered in the request.
    
    if ( $TicketStateUpdateReq->{State} ) {
		$Self->{CommonObject}->{TicketObject}->StateSet(TicketID => $TicketID,
												UserID => $UserID,
												State => $TicketStateUpdateReq->{State});
		$Self->{CommonObject}->{LogObject}->Log(
				Priority => 'error',
				Message => "UPDATED STATE");
    	} elsif  ( $TicketStateUpdateReq->{StateID} ) {
    		$Self->{CommonObject}->{TicketObject}->StateSet(TicketID => $TicketID,
													UserID => $UserID,
													StateID => $TicketStateUpdateReq->{StateID});
			$Self->{CommonObject}->{LogObject}->Log(
				Priority => 'error',
				Message => "UPDATED STATEID");
    	} else {
    		$Self->{CommonObject}->{LogObject}->Log(
				Priority => 'error',
				Message => "Require StateID or State");
    		die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring('Require StateID or State');
    		
    	}
}

sub ArticleCreate() {
	
	my $Self = shift->new(@_);
	my $ArticleReq = shift;
	my %Article;
	my $TicketID;
	
	# Better have a TicketID - check that first
	
	if ($ArticleReq->{TicketNumber}) {
		$TicketID = $Self->{CommonObject}->{TicketObject}->TicketIDLookup(TicketNumber => $ArticleReq->{TicketNumber});
	} elsif ($ArticleReq->{TicketID}) {
		$TicketID = $ArticleReq->{TicketID};
	} else {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "Require TicketID or TicketNumber");
		die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("Require TicketID or TicketNumber");
	};
	
	unless ($Self->{CommonObject}->{TicketObject}->TicketGet(TicketID => $TicketID)) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "No such ticket: $TicketID");
    	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No such ticket: $TicketID");
	}
	
	$Article{TicketID} = $TicketID;
	
	
	# (Need ArticleType or ArticleTypeID) and (SenderType or SenderTypeID)
	# prefer ID version
	
	my @AlternateField = ('ArticleType', 'SenderType');
    
    foreach (@AlternateField) {
		if ( defined( $ArticleReq->{$_.'ID'} )) {
			$Article{$_.'ID'} = $ArticleReq->{$_.'ID'};
		} elsif (defined( $ArticleReq->{$_} )) {
			$Article{$_} = $ArticleReq->{$_};
		} else {
			die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring('Require '.$_.' or '.$_.'ID');
		}
    }
    
    # Need From Subject Body ContentType HistoryType HistoryComment
    
    my @RequiredField = ('From', 'Subject', 'Body', 
    					 'ContentType', 'HistoryType', 'HistoryComment');
    
    foreach (@RequiredField) {
		if ( defined( $ArticleReq->{$_} )) {
			$Article{$_} = $ArticleReq->{$_};
		} else {
			die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring("Require $_ ");
		}
    }
    
    # Need UserID or User, but have to look up UserID if given User.
    
    if ( $ArticleReq->{UserID} ) {
			$Article{UserID} = $ArticleReq->{UserID};
		} elsif ($ArticleReq->{User}) {
			$Article{UserID} = $Self->GetUserIDForUser( \$ArticleReq->{User});
		} else {
			die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring('Require UserID or User');
	}
    
    my $ArticleID =  $Self->{CommonObject}->{TicketObject}->ArticleCreate(%Article);
    
     unless ($ArticleID) {
    	die SOAP::Fault
    		->faultcode('Server.RequestError')
        	->faultstring("Unable to create Article");
    }
    
    $Self->{CommonObject}->{LogObject}->Log( Priority => 'error', 
			Message => "Created Article $ArticleID" );
    
    return $ArticleID;
}

sub ArticleGetByID() {

	my $Self = shift->new(@_);
	my $ArticleID = shift;

	my %Article = $Self->{CommonObject}->{TicketObject}->ArticleGet(
		ArticleID => $ArticleID
	);
	
	unless (%Article) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "No such article: $ArticleID");
    	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No such article: $ArticleID");
	}

	my $FormattedArticle = FormatArticle($Self, \%Article);

	return $FormattedArticle;

}

sub ArticleGetAllByTicketID() {

	my $Self = shift->new(@_);
	my $TicketID = shift;
	my @ArticleList = ();
	
	unless ($Self->{CommonObject}->{TicketObject}->TicketGet(TicketID => $TicketID)) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "No such ticket: $TicketID");
    	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No such ticket: $TicketID");
	}
	
	my @Articles = $Self->{CommonObject}->{TicketObject}->ArticleGet(
		TicketID => $TicketID
	);
	

	unless (@Articles) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error', 
			Message => "No articles available for ticket: $TicketID" );
    	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No articles available for ticket $TicketID");
	}
	
	foreach my $Article ( @Articles ) {
		push( @ArticleList, FormatArticle($Self,$Article) )
	}
	
	return FormatTypedArray( "Articles",
							 "Article",
							 \@ArticleList,
							 "tns",
							 URI);

}

sub ArticleGetAllByTicketNumber() {

	my $Self = shift->new(@_);
	my $TicketNumber = shift();
		
	my $TicketID = $Self->{CommonObject}->{TicketObject}->TicketIDLookup(TicketNumber => $TicketNumber);
    
    unless ($TicketID) {
		$Self->{CommonObject}->{LogObject}->Log( Priority => 'error', 
			Message => "No TicketID for TicketNumber $TicketNumber" );
       	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No TicketID for TicketNumber $TicketNumber");
	}
    
    return $Self->ArticleGetAllByTicketID($TicketID);
    
}

sub FormatArticle(){

	my $Self = shift;
	my $Article = shift();

    my @Message = 
	(
		SOAP::Data->name("ArticleID" => $Article->{ArticleID})->type("int"),
		SOAP::Data->name("TicketID" => $Article->{TicketID})->type("int"),
		SOAP::Data->name("ArticleTypeID" => $Article->{ArticleTypeID})->type("int"),
		SOAP::Data->name("ArticleType" => $Article->{ArticleType})->type("string"),
		SOAP::Data->name("SenderTypeID" => $Article->{SenderTypeID})->type("int"),
		SOAP::Data->name("SenderType" => $Article->{SenderType})->type("string"),
		SOAP::Data->name("From" => $Article->{From})->type("string"),
		SOAP::Data->name("To" => $Article->{To})->type("string"),
		SOAP::Data->name("CC" => $Article->{CC})->type("string"),
		SOAP::Data->name("Subject" => $Article->{Subject})->type("string"),
		SOAP::Data->name("ContentType" => $Article->{ContentType})->type("string"),
		SOAP::Data->name("MessageID" => $Article->{MessageID})->type("string"),
		SOAP::Data->name("IncomingTime" => $Article->{IncomingTime})->type("long"),
		SOAP::Data->name("ContentPath" => $Article->{ContentPath})->type("string"),
		SOAP::Data->name("ValidID" => $Article->{ValidID})->type("int"),
		SOAP::Data->name("Body" => $Article->{Body})->type("string"),
	);


    return SOAP::Data->name( "Article" )
			->attr( {"xmlns:tns" => URI } )
			->type( "tns:Article" )
			->value( \SOAP::Data->value(@Message) );

}

sub FormatTypedArray
{
  my ( $name, $type, $array, $ns, $uri ) = @_;
  $ns ||= "xsd";
  my $count = scalar( @$array );
  my $attr = {"soapenc:arrayType" =>
              "$ns:${type}\[$count]"};
  $attr->{"xmlns:$ns"} = $uri if ( $uri );

  my $formatted_array = [];
  
  foreach my $item ( @$array )
  {
    push ( @$formatted_array,
           SOAP::Data->type($type)->value($item) );
  }
  
  return SOAP::Data->name( $name )
                   ->attr( $attr )
                   ->value( $formatted_array );
}

sub GetUserIDForUser(){

	my $Self = shift;
	my $User = shift();
	my $UserID;
	
	
	$UserID = $Self->{CommonObject}->{UserObject}->UserLookup( UserLogin => ${$User} );

	unless ($UserID) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "no UserID for ${$User}");
		die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring("no UserID for ${$User}");
	};

    return $UserID;
}

1;
