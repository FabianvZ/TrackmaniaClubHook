class Message
{
    WebHook@ WebHook;
    uint64 CreatedAt;
    bool Sent = false;
    uint64 SentAt;
    bool Completed = false;
    Networking::Response@ response;

    Message(WebHook@ webHook)
    {
        @WebHook = webHook;
        CreatedAt = Time::Now;
    }

    Networking::Response@ Send()
    {
        Sent = true;
        SentAt = Time::Now;
        @response = WebHook.Send();
        Completed = true;
        return response;
    }
}
