void Log(const string &in message)
{
    if (!settings_debug_log) return;
    
    trace(message);
}
