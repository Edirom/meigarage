package pl.psnc.dl.ege.webapp.servlet;

import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;

public class ValidationServletTest {
    private ValidationServlet servlet;
    @Mock
    private HttpServletRequest request;
    @Mock
    private HttpServletResponse response;

    @Before
    public void setUp() throws Exception {
        servlet = new ValidationServlet();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
    }

    @Test
    public void doGet() throws ServletException, IOException {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(response.getWriter()).thenReturn(pw);
        //mock the value of the request url
        StringBuffer url = new StringBuffer("http://localhost/ege-webservice/Validation/");
        when(request.getRequestURL()).thenReturn(url);
        System.out.println(request.getRequestURL().toString());
        servlet.doGet(request, response);
        String result = sw.getBuffer().toString().trim();
        System.out.println(result);
        assertEquals(result, new String("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                "<validations xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n" +
                "<input-data-type id=\"Document formats:EAD,text/xml:EAD,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/EAD%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:ENRICH,text/xml:ENRICH,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/ENRICH%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MASTER,text/xml:MASTER,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MASTER%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MEI 4.0,text/xml:MEI 4.0,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+4.0%3Atext%3Axml/\" />\n" +
                "</validations>"));
    }

    @Test
    public void doPost() {
    }

    @Test
    public void printValidationResult() {
    }
}