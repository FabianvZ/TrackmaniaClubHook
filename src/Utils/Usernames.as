array<array<string>> namesArray(100, array<string>(2));

void ImportUsernames(string names){

    array<string> parts = names.Split("\n");

    for (uint i = 0; i < parts.Length; i++)
    {
        namesArray[i] = parts[i].Split(";");
    }
    Log("Loaded " + parts.Length + " discordIds:");

    for (uint i = parts.Length; i < 100; i++) {
        namesArray[i][0] = "";
        namesArray[i][1] = "";
    }
}

string GetDiscordUserId(string TMUsername){
    for (uint i = 0; i < namesArray.Length; i++)
    {
        if(namesArray[i][0] == TMUsername){
            return "<@" + namesArray[i][1] + ">";
        }
    }

    return TMUsername;
}

string GetTMName(string discordUserId){
    for (uint i = 0; i < namesArray.Length; i++)
    {
        if(namesArray[i][1] == discordUserId){
            return namesArray[i][0];
        }
    }

    return "empty";
}