namespace DiscordDefaults
{
    string UserId = "";
    string URL = "https://discord.com/api/webhooks/";

    string Header = """
{
    "Content-Type": "application/json"
}""";

    string Body = """
{
    "username": "Trackmania",
    "avatar_url": """ + "\"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCHBYTbusq8rivJAHP59YQbUtiqoqpbiPUS2Mdxi_pDgiYqGtttj0sS3EO05JS6Xama2A&usqp=CAU\"" + """,
    "flags": """ + (1 << 12) + """,
    "content": "#[[[UserName]]([UserLink]) (<@[UserDiscordId]>) got a new PB [Medal]",
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
        }
        ],
        "thumbnail": {
            "url": "[ThumbnailLink]"
        }
    }
    ]
}""";

    string NoMedal = "<:no_medal:1223567676421570601>";
    string BronzeMedal = "<:bronze_medal:1223564781437583381>";
    string SilverMedal = "<:silver_medal:1223564769491943465>";
    string GoldMedal = "<:gold_medal:1223564758427369472>";
    string AuthorMedal = "<:at_medal:1223564741642027079>";
    string ChampionMedal = "<:champion_medal:1223564726500462632>";
}
