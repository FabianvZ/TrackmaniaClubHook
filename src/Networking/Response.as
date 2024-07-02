namespace Networking
{
    class Response
    {
        int StatusCode;
        string ErrorMessage;

        Response(int statusCode, const string &in errorMessage)
        {
            StatusCode = statusCode;
            ErrorMessage = errorMessage;
        }
    }
}
