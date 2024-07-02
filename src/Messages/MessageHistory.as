class MessageHistory
{
    array<Message@> Messages;

    MessageHistory() {}

    void Add(Message@ message)
    {
        Messages.InsertLast(message);
    }
}
