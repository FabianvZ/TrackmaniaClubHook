array<array<string>> namesArray(100, array<string>(2));

void ImportUsernames(string names){

    array<string> parts = names.Split("\n");

    for (uint i = 0; i < parts.Length; i++)
    {
        namesArray[i] = parts[i].Split(";");
    }

    // for (uint i = 0; i < parts.Length - 1; i += 2)
    // {
    //     namesArray[i][0] = parts[i];
    //     namesArray[i][1] = parts[i+1];
    // }
}

string getDiscordUserId(string TMUsername){
    for (uint i = 0; i < namesArray.Length; i++)
    {
        if(namesArray[i][0] == TMUsername){
            return namesArray[i][1];
        }
    }

    return "Username Not Found";
}


string GetTMName(string discordUserId){
    for (uint i = 0; i < namesArray.Length; i++)
    {
        if(namesArray[i][1] == discordUserId){
            return namesArray[i][0];
        }
    }

    return "Username Not Found";
}

