# --
# Kernel/System/TicketService.pm - Ticket/Article interface for OpenNMS Integration
# Copyright (C) (Jonathan Sartin) (Jonathan@opennms.org)
# --
# $Id: TicketService.pm 19 2008-05-08 21:23:34Z user $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
# --

package Kernel::System::TicketService;

@ISA = ("Kernel::System::WebService");

use strict;
use warnings;

use Kernel::System::WebService;
use SOAP::DateTime;
use Data::Dumper;
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
    
    my @RequiredField = ('UserID', 'Title', 'OwnerID');
    
    foreach (@RequiredField) {
		if ( $TicketReq->{$_} ) {
			$Ticket{$_} = $TicketReq->{$_};
		} else {
			die SOAP::Fault
       			->faultcode('Server.RequestError')
       			->faultstring("Require $_ ");
		}
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

sub TicketStateSet() {

	my $Self = shift->new(@_);
	my $TicketStateSetReq = shift();
		
	# Better have a TicketID - check that first
	
	unless ($Self->{CommonObject}->{TicketObject}->TicketGet(TicketID => $TicketStateSetReq->{TicketID})) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "No such ticket: $ArticleReq->{TicketID}");
    	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No such ticket: $ArticleReq->{TicketID}");
	}
    
	$Self->{CommonObject}->{TicketObject}->StateSet(TicketID => $TicketStateSetReq->{TicketID},
													UserID => $TicketStateSetReq->{UserID},
													State => $TicketStateSetReq->{State});
													
	return;
    
}

sub TicketStateIDSet() {

	my $Self = shift->new(@_);
	my $TicketStateSetReq = shift();
		
	# Better have a TicketID - check that first
	
	unless ($Self->{CommonObject}->{TicketObject}->TicketGet(TicketID => $TicketStateSetReq->{TicketID})) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "No such ticket: $ArticleReq->{TicketID}");
    	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No such ticket: $ArticleReq->{TicketID}");
	}
    
	$Self->{CommonObject}->{TicketObject}->StateSet(TicketID => $TicketStateSetReq->{TicketID},
													UserID => $TicketStateSetReq->{UserID},
													State => $TicketStateSetReq->{StateID});
													
	return;
    
}

sub ArticleCreate() {
	
	my $Self = shift->new(@_);
	my $ArticleReq = shift;
	my %Article;
	
	# Better have a TicketID - check that first
	
	unless ($Self->{CommonObject}->{TicketObject}->TicketGet(TicketID => $ArticleReq->{TicketID})) {
		$Self->{CommonObject}->{LogObject}->Log(
			Priority => 'error',
			Message => "No such ticket: $ArticleReq->{TicketID}");
    	die SOAP::Fault
       		->faultcode('Server.RequestError')
        	->faultstring("No such ticket: $ArticleReq->{TicketID}");
	}
	
	
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
    
    my @RequiredField = ('UserID', 'TicketID', 'From', 'Subject', 'Body', 
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

1;
