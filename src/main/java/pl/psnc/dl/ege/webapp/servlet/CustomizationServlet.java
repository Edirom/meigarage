package pl.psnc.dl.ege.webapp.servlet;

import org.apache.log4j.Logger;
import pl.psnc.dl.ege.EGE;
import pl.psnc.dl.ege.EGEImpl;
import pl.psnc.dl.ege.exception.CustomizationException;
import pl.psnc.dl.ege.types.CustomizationSetting;
import pl.psnc.dl.ege.types.CustomizationSourceInputType;
import pl.psnc.dl.ege.types.DataType;
import pl.psnc.dl.ege.webapp.request.Method;
import pl.psnc.dl.ege.webapp.request.RequestResolver;
import pl.psnc.dl.ege.webapp.request.RequestResolvingException;
import pl.psnc.dl.ege.webapp.request.CustomizationRequestResolver;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Set;

public class CustomizationServlet extends HttpServlet {

    private static final Logger LOGGER = Logger
            .getLogger(CustomizationServlet.class);

    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public CustomizationServlet()
    {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException
    {
        try {
            //resolve request and catch any errors
            RequestResolver rr = new CustomizationRequestResolver(request,
                    Method.GET);
            //print available validation options
            printAvailableCustomizationSettings(response, rr);
        }
        catch (RequestResolvingException ex) {
            if (ex.getStatus().equals(
                    RequestResolvingException.Status.WRONG_METHOD)) {
                //TODO : something with "wrong" method message (and others)
                response.sendError(405, ConversionServlet.R_WRONG_METHOD);
            }
            else {
                throw new ServletException(ex);
            }
        }
    }

    /*
     * Print into response available validation options
     */
    private void printAvailableCustomizationSettings(HttpServletResponse response,
                                           RequestResolver rr)
            throws ServletException
    {
        EGE ege = new EGEImpl();
        try {
            PrintWriter out = response.getWriter();
            Set<CustomizationSetting> css = ((EGEImpl) ege).returnSupportedCustomizationSettings();
            if(css.size() == 0){
                response.setStatus(HttpServletResponse.SC_NO_CONTENT);
                return;
            }
            response.setContentType("text/xml");
            out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out
                    .println("<customizations xmlns:xlink=\"http://www.w3.org/1999/xlink\">");
            String prefix = rr.getRequest().getRequestURL().toString()
                    + (rr.getRequest().getRequestURL().toString().endsWith(
                    RequestResolver.SLASH) ? "" : "/");
            for (CustomizationSetting cs : css) {
                out.println("<customization-setting id=\"" + cs.toString() + "\">");

                out.println("<sources>");
                for(CustomizationSourceInputType s : cs.getSources())
                    out.println("<source id=\"" + s.getId() + "\" name=\"" + s.getName() + "\" type=\"" + s.getType() + "\" path=\"" + s.getPath() + "\"/>");
                out.println("</sources>");

                out.println("<customizations>");
                for(CustomizationSourceInputType s : cs.getCustomizations())
                    out.println("<customization id=\"" + s.getId() + "\" name=\"" + s.getName() + "\" type=\"" + s.getType() + "\" path=\"" + s.getPath() + "\"/>");
                out.println("</customizations>");

                out.println("<outputFormats>");
                for(String s : cs.getOutputFormats())
                    out.println("<outputFormat name=\"" + s + "\"/>");
                out.println("</outputFormats>");


                out.println("</customization-setting>");
            }
            out.println("</customizations>");
        }
        catch (IOException ex) {
            throw new ServletException(ex);
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException
    {
        try {
            RequestResolver rr = new CustomizationRequestResolver(request,
                    Method.POST);
            String[] cs = (String[]) rr.getData();
            performCustomization(cs, rr, response);
        }
        catch (RequestResolvingException ex) {
            if (ex.getStatus().equals(
                    RequestResolvingException.Status.BAD_REQUEST)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            else {
                throw new ServletException(ex);
            }
        }
        catch (CustomizationException ex){
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
        catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    /*
     * Performs customization.
     */
    private void performCustomization(String[] cs, RequestResolver rr,
                                   HttpServletResponse response)
            throws Exception
    {
        LOGGER.info("performCustomization " + cs[0] + " with " + cs[1] + " and " + cs[2] + " to " + cs[3]);
    }
}
