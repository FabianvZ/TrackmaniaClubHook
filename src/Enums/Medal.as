enum Medal
{
    No,
    Bronze,
    Silver,
    Gold,
    Author,
    Champion
}

namespace Medal
{
    string ToString(Medal medal)
    {
        switch (medal)
        {
            case Medal::No:
                return "No Medal";
            case Medal::Bronze:
                return "Bronze";
            case Medal::Silver:
                return "Silver Medal";
            case Medal::Gold:
                return "Gold Medal";
            case Medal::Author:
                return "Author Medal";
            case Medal::Champion:
                return "Champion Medal";
        }

        throw("Not implemented - Medal: " + medal);
        return "";
    }

    string ToDiscordString(Medal medal)
    {
        switch (medal)
        {
            case Medal::No:
                return settings_no_medal_string;
            case Medal::Bronze:
                return settings_bronze_medal_string;
            case Medal::Silver:
                return settings_silver_medal_string;
            case Medal::Gold:
                return settings_gold_medal_string;
            case Medal::Author:
                return settings_at_medal_string;
            case Medal::Champion:
                return settings_champion_medal_string;
        }

        throw("Not implemented - Medal: " + medal);
        return "";
    }

    int ToValue(Medal medal)
    {
        switch (medal)
        {
            case Medal::No:
                return 0;
            case Medal::Bronze:
                return 1;
            case Medal::Silver:
                return 2;
            case Medal::Gold:
                return 3;
            case Medal::Author:
                return 4;
            case Medal::Champion:
                return 5;
        }

        throw("Not implemented - Medal: " + medal);
        return -1;
    }

    
    Medal FromValue(int value)
    {
        switch (value)
        {
            case 0:
                return Medal::No;
            case 1:
                return Medal::Bronze;
            case 2:
                return Medal::Silver;
            case 3:
                return Medal::Gold;
            case 4:
                return Medal::Author;
            case 5:
                return Medal::Champion;
        }

        throw("Not implemented - Medal-int: " + value);
        return Medal::No;
    }
}
