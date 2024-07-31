void Log(const string &in message)
{
    if (!settings_debug_log) return;
    
    trace(message);
}

bool Contains(array<string> arrayToCheck, string stringToCheck) {
    for (uint i = 0; i < arrayToCheck.Length; i++)
    {
        if (!arrayToCheck[i].Contains(stringToCheck)){
            return false;
        }
    }
    return true;
}