dictionary TMNames = new dictionary;
dictionary DiscordIds = new dictionary;

void ImportUsernames(string names){
    array<string> parts = names.Split(";");

    for (uint i = 0; i < parts.Length; i++)
    {
        if(i = 0 || i % 2 == 0){
            DiscordIds.set(parts[i], parts[i+1]);
            TMNames.set(parts[i+1], parts[i]);
        }
    }
}

string getDiscordUserId(string TMUsername){
    if(DiscordIds.exists(TMUsername))
    {
        return DiscordIds[TMUsername];
    }

    return "Username Not Found";
}


string GetTMName(string discordUserId){
    if(TMNames.exists(discordUserId))
    {
        return TMNames[discordUserId];
    }

    return "Username Not Found";
}