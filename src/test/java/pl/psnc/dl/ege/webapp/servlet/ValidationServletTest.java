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
    StringWriter sw;
    PrintWriter pw;


    @Before
    public void setUp() throws Exception {
        servlet = new ValidationServlet();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        sw = new StringWriter();
        pw = new PrintWriter(sw);
        when(response.getWriter()).thenReturn(pw);
        //mock the value of the request url
        StringBuffer url = new StringBuffer("http://localhost/ege-webservice/Validation/");
        when(request.getRequestURL()).thenReturn(url);
        System.out.println(request.getRequestURL().toString());
        when(request.getContextPath()).thenReturn("/ege-webservice");
        System.out.println(request.getContextPath().toString());
        when(request.getServerName()).thenReturn("localhost");
        when(request.getServerPort()).thenReturn(80);
        when(request.getScheme()).thenReturn("http");
    }

    @Test
    public void doGet() throws ServletException, IOException {
        servlet.doGet(request, response);
        String result = sw.getBuffer().toString().trim();
        System.out.println(result);
        assertEquals(new String("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                "<validations xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"http://localhost/ege-webservice/schemas/validations.xsd\">\n" +
                "<input-data-type id=\"Document formats:MEI 2.1.1,text/xml:MEI 2.1.1,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+2.1.1%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MEI 3.0.0,text/xml:MEI 3.0.0,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+3.0.0%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MEI 4.0.0,text/xml:MEI 4.0.0,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+4.0.0%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MEI 4.0.1 all any,text/xml:MEI 4.0.1 all any,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+4.0.1+all+any%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MEI 4.0.1 cmn,text/xml:MEI 4.0.1 cmn,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+4.0.1+cmn%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MEI 4.0.1 mensural,text/xml:MEI 4.0.1 mensural,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+4.0.1+mensural%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MEI 4.0.1 neumes,text/xml:MEI 4.0.1 neumes,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+4.0.1+neumes%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MEI 4.0.1,text/xml:MEI 4.0.1,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+4.0.1%3Atext%3Axml/\" />\n" +
                "<input-data-type id=\"Document formats:MEI dev,text/xml:MEI dev,text/xml\" xlink:href=\"http://localhost/ege-webservice/Validation/MEI+dev%3Atext%3Axml/\" />\n" +
                "</validations>"), result);
    }

    @Test
    public void doPost() throws ServletException, IOException {
    }

}