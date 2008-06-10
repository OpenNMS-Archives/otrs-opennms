package org.opennms.integration.otrs.ticketclient;

import org.opennms.integration.otrs.ticketservice.*;

import java.rmi.RemoteException;

import junit.framework.TestCase;

import org.apache.axis.AxisFault;

public class TicketClientTest extends TestCase {

	private Credentials creds = new Credentials("opennms","opennms");
	private TicketServicePort_PortType port;
	private TicketServiceLocator service;
	private TicketCore numericTicket;
	private TicketCore textualTicket;
	protected ArticleCore defaultArticle;
	
	// defaults for ticket
	
	private Integer defaultQueueID  = new Integer(2);
	private String defaultQueue = new String("Raw");
	private Integer defaultLockID = new Integer(1);
	private String defaultLock = new String("unlock");
	private Integer defaultPriorityID = new Integer(3);
	private String defaultPriority = new String("3 normal");
	private Integer defaultStateID = new Integer(1);
	private String defaultState = new String("new");
	private Integer defaultOwnerID = new Integer(1);
	private String defaultOwner = new String("root@localhost");
	private String defaultUser = new String("root@localhost");
	private Integer defaultUserID = new Integer(1);
	private String defaultTitle = new String("OpenNMS Integration Test");
	
	// defaults for article
	
	private String defaultArticleArticleType = new String("note-external");
	private String defaultArticleFrom = new String("jonathan@opennms.org");
	private String defaultArticleSenderType= new String("agent");
	private String defaultArticleSubject = new String("default subject");
	private String defaultArticleBody = new String("default body text");
	private String defaultArticleContentType = new String("text/plain; charset=ISO-8859-15");
	private String defaultArticleHistoryComment = new String("updated by OpenNMS");
	private String defaultArticleHistoryType = new String("OwnerUpdate");
	
	protected Ticket createTicket;
	protected Ticket getTicket;

	protected void setUp() throws Exception {

		super.setUp();

		service = new TicketServiceLocator();

		service.setTicketServicePortEndpointAddress(new java.lang.String(
				"http://localhost/otrs/opennms.pl"));

		port = service.getTicketServicePort();
		
		numericTicket = new TicketCore();

		numericTicket.setLockID(defaultLockID);
		numericTicket.setQueueID(defaultQueueID);
		numericTicket.setPriorityID(defaultPriorityID);
		numericTicket.setStateID(defaultStateID);
		numericTicket.setOwnerID(defaultOwnerID);
		numericTicket.setUserID(defaultUserID);
		numericTicket.setTitle(defaultTitle);
		
		textualTicket = new TicketCore();

		textualTicket.setLock(defaultLock);
		textualTicket.setQueue(defaultQueue);
		textualTicket.setPriority(defaultPriority);
		textualTicket.setState(defaultState);
		textualTicket.setOwnerID(defaultOwnerID);
		textualTicket.setUser(defaultUser);
		textualTicket.setTitle(defaultTitle);
		
		defaultArticle = new ArticleCore();
		
		defaultArticle.setArticleType(defaultArticleArticleType);
		defaultArticle.setFrom(defaultArticleFrom);
		defaultArticle.setSenderType(defaultArticleSenderType);
		defaultArticle.setSubject(defaultArticleSubject);
		defaultArticle.setBody(defaultArticleBody);
		defaultArticle.setContentType(defaultArticleContentType);
		defaultArticle.setHistoryComment(defaultArticleHistoryComment);
		defaultArticle.setHistoryType(defaultArticleHistoryType);
		defaultArticle.setUser(defaultUser);
		
	}

	public void testNoUserTicketCreate() {

		try {
			port.ticketCreate(numericTicket, new Credentials("", ""));
			fail("SOAPfault expected");
		} catch (AxisFault af) {
			assertEquals("Authentication Failure", af.getFaultString());
		} catch (RemoteException e) {
			// ignore
		}

	}

	public void testBadUserTicketCreate() {

		try {
			port.ticketCreate(numericTicket, new Credentials("opennms", ""));
			fail("Axisfault expected");
		} catch (AxisFault af) {
			assertEquals("Authentication Failure", af.getFaultString());
		} catch (RemoteException e) {
			// ignore
		}

	}

	public void testBadPassTicketCreate() {
    	
    	try{
    		port.ticketCreate(numericTicket, new Credentials("opennms","badpass"));
    		fail("SOAPfault expected");
    	} catch( AxisFault af ) {
  		      assertEquals("Authentication Failure",  af.getFaultString() );
        } catch (RemoteException e) {
  		// ignore
        }
    	
    }

/*
 *  Commented the following tests out as they may be unsafe on a running OTRS instance.
 *    - OTRS is unhappy about tickets created without articles
 *
 *	public void testNumericTicketCreate() {
 *
 *		TicketIDAndNumber idAndNumber = null;
 *		Ticket retrievedTicket = null;
 *		
 *		try {
 *			idAndNumber = port.ticketCreate(numericTicket, creds);
 *		} catch (RemoteException e) {
 *			// TODO Auto-generated catch block
 *			e.printStackTrace();
 *		}
 *
 *		assertNotNull(idAndNumber);
 *		
 *		try {
 *			retrievedTicket = port.ticketGetByID(idAndNumber.getTicketID(),
 *					creds);
 *		} catch (RemoteException e) {
 *			e.printStackTrace();
 *		}
 *
 *		// Compare all the fields to the defaults (should get out what we put in)
 *		
 *		assertEquals(defaultQueue, retrievedTicket.getQueue());
 *		assertEquals(defaultQueueID, retrievedTicket.getQueueID());
 *		assertEquals(defaultPriority, retrievedTicket.getPriority());
 * 		assertEquals(defaultPriorityID, retrievedTicket.getPriorityID());
 *		assertEquals(defaultState, retrievedTicket.getState());
 *		assertEquals(defaultStateID, retrievedTicket.getStateID());
 *		assertEquals(defaultLock, retrievedTicket.getLock());
 *		assertEquals(defaultLockID, retrievedTicket.getLockID());
 *		assertEquals(defaultOwner, retrievedTicket.getOwner());
 *		assertEquals(defaultOwnerID, retrievedTicket.getOwnerID());
 *		assertEquals(defaultTitle, retrievedTicket.getTitle());
 *		
 *	}
 *	
 *	public void testTextualTicketCreate() {
 *
 *		TicketIDAndNumber idAndNumber = null;
 *		Ticket retrievedTicket = null;
 *		
 *		try {
 *			idAndNumber = port.ticketCreate(textualTicket, creds);
 *		} catch (RemoteException e) {
 *			// TODO Auto-generated catch block
 *			e.printStackTrace();
 *		}
 *
 *		assertNotNull(idAndNumber);
 *	
 *		try {
 *			retrievedTicket = port.ticketGetByNumber(idAndNumber.getTicketNumber(),
 *					creds);
 *		} catch (RemoteException e) {
 *			e.printStackTrace();
 *		}
 *
 *		// Compare all the fields to the defaults (should get out what we put in)
 *		
 *		assertEquals(defaultQueue, retrievedTicket.getQueue());
 *		assertEquals(defaultQueueID, retrievedTicket.getQueueID());
 *		assertEquals(defaultPriority, retrievedTicket.getPriority());
 *		assertEquals(defaultPriorityID, retrievedTicket.getPriorityID());
 *		assertEquals(defaultState, retrievedTicket.getState());
 *		assertEquals(defaultStateID, retrievedTicket.getStateID());
 *		assertEquals(defaultLock, retrievedTicket.getLock());
 *		assertEquals(defaultLockID, retrievedTicket.getLockID());
 *		assertEquals(defaultOwner, retrievedTicket.getOwner());
 *		assertEquals(defaultOwnerID, retrievedTicket.getOwnerID());
 *		assertEquals(defaultTitle, retrievedTicket.getTitle());
 *
 *	}
 */
	
	public void testArticle() {
		
		TicketIDAndNumber idAndNumber = null;
		
		Integer articleID = null;
		Article articleByID = null;
		
		try {
			idAndNumber = port.ticketCreate(textualTicket, creds);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		defaultArticle.setTicketID(idAndNumber.getTicketID());
		
		try {
			articleID = port.articleCreate(defaultArticle, creds);
			assertNotNull(articleID);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		try {
			articleByID = port.articleGetByID(articleID,creds);	
			assertNotNull(articleByID);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	
		//ssertEquals(defaultArticleArticleType,articleByID.getArticleType());
		assertEquals(defaultArticleFrom,articleByID.getFrom());
		assertEquals(defaultArticleSenderType,articleByID.getSenderType());
		assertEquals(defaultArticleSubject,articleByID.getSubject());
		assertEquals(defaultArticleBody,articleByID.getBody());
		assertEquals(defaultArticleContentType,articleByID.getContentType());
	}
	
	public void testMultipleArticle() throws InterruptedException {
		
		TicketIDAndNumber idAndNumber = null;
		
		Integer articleID1 = null;
		Integer articleID2 = null;
		String	articleBody1 = new String("First");
		String	articleBody2 = new String("Second");
		Article [] articlesByTicketNumber = null;
		Article [] articlesByTicketID = null;
		
		try {
			idAndNumber = port.ticketCreate(textualTicket, creds);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		defaultArticle.setTicketID(idAndNumber.getTicketID());
		defaultArticle.setBody(articleBody1);
		
		try {
			articleID1 = port.articleCreate(defaultArticle, creds);
			assertNotNull(articleID1);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		defaultArticle.setBody(articleBody2);
		
		// Sleep for a second to stop local tests failing on slow local database
		
		Thread.sleep(1000);
		
		try {
			articleID2 = port.articleCreate(defaultArticle, creds);
			assertNotNull(articleID2);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		try {
			articlesByTicketID = port.articleGetAllByTicketID(idAndNumber.getTicketID(), creds);
			assertNotNull(articlesByTicketID);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	
		
		for (Article article : articlesByTicketID) {
			
			assertEquals(defaultArticleFrom,article.getFrom());
			assertEquals(defaultArticleSenderType,article.getSenderType());
			assertEquals(defaultArticleSubject,article.getSubject());
			assertEquals(defaultArticleContentType,article.getContentType());
			
			if (article.getArticleID().equals(articleID1) ) {
				assertEquals(articleBody1,article.getBody());
			} else if (article.getArticleID().equals(articleID2) ) {
				assertEquals(articleBody2,article.getBody());
			} else {
				fail("unexpected article id in returned array by ID: " + article.getArticleID().toString() );
			}
		}
		
		// Do that again by ticket number rather than ID
		
		try {
			articlesByTicketNumber = port.articleGetAllByTicketNumber(idAndNumber.getTicketNumber(), creds);
			assertNotNull(articlesByTicketNumber);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	
		
		for (Article article : articlesByTicketNumber) {
			
			assertEquals(defaultArticleFrom,article.getFrom());
			assertEquals(defaultArticleSenderType,article.getSenderType());
			assertEquals(defaultArticleSubject,article.getSubject());
			assertEquals(defaultArticleContentType,article.getContentType());
			
			if (article.getArticleID().equals(articleID1) ) {
				assertEquals(articleBody1,article.getBody());
			} else if (article.getArticleID().equals(articleID2) ) {
				assertEquals(articleBody2,article.getBody());
			} else {
				fail("unexpected article id in returned array by Number: " + article.getArticleID().toString() );
			}
		}
	}
	
	
public void testGetByNumber() throws InterruptedException {
		
		TicketIDAndNumber idAndNumber = null;
		TicketWithArticles ticketWithArticles = null;
		
		Integer articleID1 = null;
		Integer articleID2 = null;
		String	articleBody1 = new String("First article in getByNumber");
		String	articleBody2 = new String("Second article in getByNumer");
		Article [] articlesByTicketNumber = null;
		Article [] articlesByTicketID = null;
		
		try {
			idAndNumber = port.ticketCreate(textualTicket, creds);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		defaultArticle.setTicketID(idAndNumber.getTicketID());
		defaultArticle.setBody(articleBody1);
		
		try {
			articleID1 = port.articleCreate(defaultArticle, creds);
			assertNotNull(articleID1);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		defaultArticle.setBody(articleBody2);
		
		// Sleep for a second to stop local tests failing on slow local database
		
		Thread.sleep(1000);
		
		try {
			articleID2 = port.articleCreate(defaultArticle, creds);
			assertNotNull(articleID2);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		// Now get the whole lot:
		
		try {
			ticketWithArticles = port.getByNumber(idAndNumber.getTicketNumber(), creds);
		} catch (RemoteException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		// Check the title is what I put in.
		
		assertEquals(textualTicket.getTitle(),ticketWithArticles.getTicket().getTitle());
	
		
		for (Article article : ticketWithArticles.getArticles()) {
			
			assertEquals(defaultArticleFrom,article.getFrom());
			assertEquals(defaultArticleSenderType,article.getSenderType());
			assertEquals(defaultArticleSubject,article.getSubject());
			assertEquals(defaultArticleContentType,article.getContentType());
			
			if (article.getArticleID().equals(articleID1) ) {
				assertEquals(articleBody1,article.getBody());
			} else if (article.getArticleID().equals(articleID2) ) {
				assertEquals(articleBody2,article.getBody());
			} else {
				fail("unexpected article id in returned array by ID: " + article.getArticleID().toString() );
			}
		}
		
	}

public void testTicketStateUpdate() throws InterruptedException {
	
	long ticketNumber = createTicketAndArticle("testTicketStateUpdate Subject", 
								"testRicketStateUpdate Body");
	
	TicketWithArticles openTicket = null;
	TicketWithArticles closedTicket = null;
	
	try {
		openTicket = port.getByNumber(ticketNumber, creds);
	} catch (RemoteException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	
	assertEquals("new",openTicket.getTicket().getState());
	
	TicketStateUpdate stateUpdate = new TicketStateUpdate();
	
	stateUpdate.setState("closed successful");
	stateUpdate.setTicketNumber(ticketNumber);
	stateUpdate.setUser("root@localhost");
	
	try {
		port.ticketStateUpdate(stateUpdate, creds);
	} catch (RemoteException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}
	
	
	Thread.sleep(1000);
	
	try {
		closedTicket = port.getByNumber(ticketNumber, creds);
	} catch (RemoteException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	
	assertEquals("closed successful",closedTicket.getTicket().getState());
	
}

private long createTicketAndArticle(String ticketSubject, String articleBody) throws InterruptedException {
	
	TicketIDAndNumber idAndNumber = null;
	
	Integer articleID1 = null;
	String	articleBody1 = new String("First article in getByNumber");
	
	try {
		idAndNumber = port.ticketCreate(textualTicket, creds);
	} catch (RemoteException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	
	defaultArticle.setTicketID(idAndNumber.getTicketID());
	defaultArticle.setBody(articleBody1);

	
	try {
		articleID1 = port.articleCreate(defaultArticle, creds);
		assertNotNull(articleID1);
	} catch (RemoteException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	
	return idAndNumber.getTicketNumber();
	
}

}