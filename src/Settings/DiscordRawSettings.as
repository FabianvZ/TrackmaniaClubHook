/*

 /$$$$$$$                               
| $$__  $$                              
| $$  \ $$  /$$$$$$   /$$$$$$$  /$$$$$$ 
| $$$$$$$  |____  $$ /$$_____/ /$$__  $$
| $$__  $$  /$$$$$$$|  $$$$$$ | $$$$$$$$
| $$  \ $$ /$$__  $$ \____  $$| $$_____/
| $$$$$$$/|  $$$$$$$ /$$$$$$$/|  $$$$$$$
|_______/  \_______/|_______/  \_______/

*/

[Setting hidden]
bool settings_SendPB = true;

[Setting hidden]
bool settings_SendRank = true;

[Setting hidden]
string settings_filter_string = "";

[Setting hidden]
string settings_discord_user_id = DiscordDefaults::UserId;

[Setting hidden]
string settings_discord_URL = DiscordDefaults::URL;

/*

  /$$$$$$        /$$                                                         /$$
 /$$__  $$      | $$                                                        | $$
| $$  \ $$  /$$$$$$$ /$$    /$$ /$$$$$$  /$$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$$
| $$$$$$$$ /$$__  $$|  $$  /$$/|____  $$| $$__  $$ /$$_____/ /$$__  $$ /$$__  $$
| $$__  $$| $$  | $$ \  $$/$$/  /$$$$$$$| $$  \ $$| $$      | $$$$$$$$| $$  | $$
| $$  | $$| $$  | $$  \  $$$/  /$$__  $$| $$  | $$| $$      | $$_____/| $$  | $$
| $$  | $$|  $$$$$$$   \  $/  |  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$$|  $$$$$$$
|__/  |__/ \_______/    \_/    \_______/|__/  |__/ \_______/ \_______/ \_______/

*/

[Setting hidden]
bool settings_AdvancedDiscordSettings = false;

[Setting hidden]
string settings_no_medal_string = DiscordDefaults::NoMedal;

[Setting hidden]
string settings_bronze_medal_string = DiscordDefaults::BronzeMedal;

[Setting hidden]
string settings_silver_medal_string = DiscordDefaults::SilverMedal;

[Setting hidden]
string settings_gold_medal_string = DiscordDefaults::GoldMedal;

[Setting hidden]
string settings_at_medal_string = DiscordDefaults::AuthorMedal;

[Setting hidden]
string settings_champion_medal_string = DiscordDefaults::ChampionMedal;

[Setting hidden]
string settings_Body = DiscordDefaults::Body;

[Setting hidden]
string settings_usernames = DiscordDefaults::usernames;

[Setting hidden]
bool settings_debug_log = true;

[Setting hidden]
int clubId = -1;
Json::Value clubs = Json::Object();
bool reloadclubs = true;

#if SIG_DEVELOPER
[Setting name="Send PB" category="Testing"]
#endif
bool force_send_pb = false;

#if SIG_DEVELOPER
[Setting name="Send PB Score" category="Testing"]
#endif
int force_send_pb_time = 1;

#if SIG_DEVELOPER
[Setting name="Position request score" category="Testing"]
#endif
int test_position_time;

#if SIG_DEVELOPER
[Setting name="Request position" category="Testing"]
#endif
bool test_position;

#if SIG_DEVELOPER
[Setting name="Test position result" category="Testing"]
#endif
int test_position_result;

bool showImportPopup = false;

string import_settings_usernames = "";

string import_error_message = "";