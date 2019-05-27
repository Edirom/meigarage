package pl.psnc.dl.ege.webapp.request;

import pl.psnc.dl.ege.types.DataType;

import javax.servlet.http.HttpServletRequest;

public class CustomizationRequestResolver extends RequestResolver {
    public static final String CUSTOMIZATION_SLICE_BASE = "Customization/";

    private static final String EN = "en";


    public CustomizationRequestResolver(HttpServletRequest request, Method method)
            throws RequestResolvingException
    {
        this.method = method;
        this.request = request;
        init();
    }


    private void init()
            throws RequestResolvingException
    {
        if (method.equals(Method.GET)) {
            resolveGET();
        }
        else if (method.equals(Method.POST)) {
            resolvePOST();
        }
    }


    private void resolvePOST()
            throws RequestResolvingException
    {
        String[] queries = resolveQueries();
        if(queries.length > 1){
            DataType dataType = decodeDataType(queries[1]);
            data = dataType;
            operation = OperationId.PERFORM_CUSTOMIZATION;
        }
        else{
            throw new RequestResolvingException(RequestResolvingException.Status.BAD_REQUEST);
        }
    }


    private void resolveGET()
            throws RequestResolvingException
    {
        String[] queries = resolveQueries();
        if(queries.length == 1){
            operation = OperationId.PRINT_CUSTOMIZATIONS;
        }
        else{
            throw new RequestResolvingException(RequestResolvingException.Status.WRONG_METHOD);
        }
    }

    private String[] resolveQueries()
    {
        String params = request.getRequestURL().toString();
        params = (params.endsWith(SLASH) ? params : params + SLASH);
        params = params.substring(params.indexOf(CUSTOMIZATION_SLICE_BASE),
                params.length());
        String[] queries = params.split(SLASH);
        return queries;
    }

    @Override
    public String getLocale()
    {
        return null;
    }
}
