package org.opennms.integration.otrs.ticketclient;

import org.opennms.integration.otrs.ticketservice.*;

public class TicketClient {

	public static void main(String[] args) throws Exception {

		TicketServiceLocator service = new TicketServiceLocator();

		/*
		 * uncomment the following to change the endpoint to match your OTRS
		 * server
		 * 
		 * service.setTicketServicePortEndpointAddress(new
		 * java.lang.String("http://myhost:8080/otrs/soap.pl"));
		 * 
		 */

		TicketServicePort_PortType port = service.getTicketServicePort();

		// modify pass and user to suit those defined for your OTRS soap user.

		Credentials creds = new Credentials();

		creds.setPass("pass1");
		creds.setUser("user1");

		TicketCore newTicket = new TicketCore();

		/*
		 * TicketCore needs: [Queue|QueueID] [Priority|PriorityID]
		 * [State|StateID] [Lock|LockID] OwnerID UserID Title
		 */

		newTicket.setQueue("Raw");
		newTicket.setPriority("3 normal");
		newTicket.setState("new");
		newTicket.setLock("unlock");
		newTicket.setOwnerID(1);
		newTicket.setUserID(1);
		newTicket.setTitle("OpenNMS Integration Test Ticket");

		TicketIDAndNumber idAndNumber = port.ticketCreate(newTicket, creds);

		System.out.println("Created Ticket with ID: "
				+ idAndNumber.getTicketID() + " and number: "
				+ idAndNumber.getTicketNumber());

		ArticleCore article1 = new ArticleCore();

		/*
		 * ArticleCore needs: TicketID [ArticleType|ArticleTypeID]
		 * [SenderType|SenderTypeID] From Subject ContentType HistoryType
		 * HistoryCOmment Body UserID
		 */

		article1.setTicketID(idAndNumber.getTicketID());
		article1.setArticleType("note-external");
		article1.setFrom("jonathan@opennms.org");
		article1.setSenderType("agent");
		article1.setSubject("first article");
		article1.setBody("body text for first article");
		article1.setContentType("text/plain; charset=ISO-8859-15");
		article1.setHistoryComment("updated by OpenNMS");
		article1.setHistoryType("OwnerUpdate");
		article1.setUserID(1);

		int article1ID = port.articleCreate(article1, creds);

		System.out.println("Created Article with ID: " + article1ID
				+ " for Ticket ID: " + idAndNumber.getTicketID());

		ArticleCore article2 = new ArticleCore();

		article2.setTicketID(idAndNumber.getTicketID());
		article2.setArticleType("note-external");
		article2.setFrom("jonathan@opennms.org");
		article2.setSenderType("agent");
		article2.setSubject("second article");
		article2.setBody("body text for second article");
		article2.setContentType("text/plain; charset=ISO-8859-15");
		article2.setHistoryComment("updated by OpenNMS");
		article2.setHistoryType("OwnerUpdate");
		article2.setUserID(1);

		int article2ID = port.articleCreate(article2, creds);

		System.out.println("Created Article with ID: " + article2ID
				+ " for Ticket ID: " + idAndNumber.getTicketID());

		// Now play it back ...

		/*
		 * could use:
		 * 
		 * port.ticketGetById(idAndNumber.getTicketId(), creds);
		 * 
		 * instead ...
		 */

		Ticket ticket = port.ticketGetByNumber(idAndNumber.getTicketNumber(),
				creds);

		System.out.println("Ticket with ID: " + ticket.getTicketID()
				+ " and number " + ticket.getTicketNumber());
		System.out.println("Title:    " + ticket.getTitle());

		/*
		 * could use:
		 * 
		 * port.articleGetAllByTicketId(idAndNumber.getTicketId(), creds);
		 * 
		 * instead ...
		 */

		Article[] articlesForTicket = port.articleGetAllByTicketNumber(
				idAndNumber.getTicketNumber(), creds);

		for (Article article : articlesForTicket) {
			System.out.println("Ticket   " + idAndNumber.getTicketID()
					+ " contains article " + article.getArticleID() + " with:");
			System.out.println("Type:    " + article.getArticleType());
			System.out.println("From:    " + article.getFrom());
			System.out.println("Subject: " + article.getSubject());
			System.out.println("Body:    " + article.getBody());
		}
	}
}
