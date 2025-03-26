namespace DiscordDefaults
{
    string UserId = "";
    string URL = "https://discord.com/api/webhooks/";

    string Header = """
    {
    "Content-Type": "application/json"
    }
    """;

    string Body = """
    {
        "username": "Trackmania",
        "avatar_url": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCHBYTbusq8rivJAHP59YQbUtiqoqpbiPUS2Mdxi_pDgiYqGtttj0sS3EO05JS6Xama2A&usqp=CAU",
        "flags": 4096,
        "content": "#[[[UserName]]([UserLink]) (<@[UserDiscordId]>) got a new PB [Medal] beating [Losers]",
        "embeds": [
        {
            "color": 65290,
            "fields": [
            {
                "name": "Map",
                "value": "[[[MapName]]([MapLink]) by [[[MapAuthorName]]([MapAuthorLink])"
            },
            {
                "name": "Time",
                "value": "[Time][TimeDelta]",
                "inline": true
            },
            {
                "name": "Rank",
                "value": "[Rank]",
                "inline": true
            },
            {
                "name": "\u200B",
                "value": "\u200B",
                "inline": true
            },
            {
                "name": "GrindTime",
                "value": "[GrindTime]",
                "inline": false
            },
            {
                "name": "Finishes",
                "value": "[Finishes]",
                "inline": true
            },
            {
                "name": "Resets",
                "value": "[Resets]",
                "inline": true
            },
            {
                "name": "\u200B",
                "value": "\u200B",
                "inline": true
            },
            {
                "name": "Club Leaderboard",
                "value": "[ClubLeaderboard]",
                "inline": true
            },
            {
                "name": "\u200B",
                "value": "[Times]",
                "inline": true
            },
            {
                "name": "\u200B",
                "value": "\u200B",
                "inline": true
            }
            ],
            "thumbnail": {
                "url": "[ThumbnailLink]"
            }
        }
        ]
    }
    """;

    string usernames = "Lokulicious;237184238602944513";


    string NoMedal = "<:no_medal:1258140533897953383>";
    string BronzeMedal = "<:bronze_medal:1258140076697714698>";
    string SilverMedal = "<:silver_medal:1258161706014740641>";
    string GoldMedal = "<:gold_medal:1258139948301943015>";
    string AuthorMedal = "<:author_medal:1258140024663445575>";
    string ChampionMedal = "<:champion_medal:1258164329576923248>";
}
