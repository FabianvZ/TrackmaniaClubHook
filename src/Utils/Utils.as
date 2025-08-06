array<string> markdownChars = { "\\", "*", "_", "`", "[", "]", "~", ">", "#", "+", "-", "=", "|", "{", "}", ".", "!", "@" };

void Log(const string &in message)
{ 
    trace(message);
}

bool Contains(array<string> arrayToCheck, const string &in stringToCheck) {
    for (uint i = 0; i < arrayToCheck.Length; i++)
    {
        if (!arrayToCheck[i].Contains(stringToCheck)){
            return false;
        }
    }
    return true;
}

string EscapeMarkdown(const string &in text) {
    string result = text;
    for (uint i = 0; i < markdownChars.Length; i++) {
        string ch = markdownChars[i];
        result = result.Replace(ch, "\\" + ch);
    }
    return result;
}