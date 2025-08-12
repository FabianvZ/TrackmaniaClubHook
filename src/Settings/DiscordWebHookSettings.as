[Setting hidden]
bool settings_SendPB = true;

[Setting hidden]
string settings_discord_user_id = DiscordDefaults::UserId;

[Setting hidden]
bool settings_inline_columns = false;

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
string settings_warrior_medal_string = DiscordDefaults::WarriorMedal;

[Setting hidden]
string settings_usernames = DiscordDefaults::usernames;

[Setting hidden]
bool send_grinding_stats = true;

[Setting hidden]
bool send_when_beating_noone = false;

bool showImportPopup = false;
string import_settings_usernames = "";
string import_error_message = "";

[SettingsTab name="General" icon="Cog" order=0]
void RenderDiscordSettings()
{
    RenderResetButton();

    settings_SendPB = UI::Checkbox("Send PB to Discord", settings_SendPB);
    UI::SetTooltip("Enable to send PBs to Discord. You can set a shortcut for this in the settings tab.");
    settings_inline_columns = UI::Checkbox("Inline columns in webhook", settings_inline_columns);
    UI::SetTooltip("Enable to show show splitted leaderboards next to each other in the webhook. A leaderboard will split at around 30 entries depending on the length of the longest name. If not enabled the leaderboard fragments will be displayed below each other.");

#if DEPENDENCY_GRINDINGSTATS
    send_grinding_stats = UI::Checkbox("Send grinding stats", send_grinding_stats);
#endif

    send_when_beating_noone = UI::Checkbox("Send PB when beating no one", send_when_beating_noone);
    UI::SetTooltip("Enable to send a message to Discord when you beat your own PB, even if you don't beat anyone else. This is useful for grinding.");

#if !DEPENDENCY_DISCORD
    settings_discord_user_id = UI::InputText("Discord User-ID", settings_discord_user_id);
#endif

    UI::SeparatorText("Shortcuts");
    sendPBShortcut.RenderUI();
    forceSendShortcut.RenderUI();

    UI::SeparatorText("Discord ping settings");    
    UI::Text("You can set up a list of Trackmania usernames and Discord user IDs to ping them when you send a message.");

    if (UI::BeginTable("Keybinds", 3, UI::TableFlags::BordersV | UI::TableFlags::BordersH | UI::TableFlags::NoHostExtendX)) {
        UI::TableSetupColumn("Trackmania username", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("Discord user ID", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed);
        UI::TableHeadersRow();

        array<string> parts = settings_usernames.Split("\n");

        for (uint i = 0; i < parts.Length; i++) {
            array<string> nameParts = parts[i].Split(";");
            UI::TableNextRow();

            UI::TableNextColumn();
            UI::SetNextItemWidth(200);
            parts[i] = UI::InputText("##TrackmaniaUsername" + i, nameParts.Length > 0 ? nameParts[0] : "") + ";";

            UI::TableNextColumn();
            UI::SetNextItemWidth(150);
            parts[i] += UI::InputText("##DiscordID" + i, nameParts.Length > 1 ? nameParts[1] : "", UI::InputTextFlags::CharsDecimal);

            UI::TableNextColumn();
            if (UI::ButtonColored(Icons::Trash + "##" + i, 0.0f)) {
                parts.RemoveAt(i);
                i--;
            }
        }

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::SetNextItemWidth(200);
        string newTrackmaniaUsername = UI::InputText("##TrackmaniaUsername" + parts.Length, "");

        UI::TableNextColumn();            
        UI::SetNextItemWidth(150);
        string newDiscordID = UI::InputText("##DiscordID" + parts.Length, "", UI::InputTextFlags::CharsDecimal);

        settings_usernames = string::Join(parts, "\n");
        if (newTrackmaniaUsername.Length > 0 || newDiscordID.Length > 0) {
            settings_usernames += "\n" + newTrackmaniaUsername + ";" + newDiscordID;
        }

        UI::EndTable();
    }

    if (UI::Button(Icons::Clipboard + " export discord ping settings"))
    {
        IO::SetClipboard(settings_usernames);
    }
    UI::SameLine();
    if (UI::Button(Icons::ArrowCircleDown + " import discord ping settings"))
    {
        showImportPopup = true;
    }

    if (showImportPopup) {
        UI::Begin("Import Discord ping settings popup", showImportPopup, UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize);
        import_settings_usernames = UI::InputTextMultiline("##newSettings_usernames", import_settings_usernames);
        UI::Text(import_error_message);

        if (UI::Button("Import")) {
            if (!Contains(import_settings_usernames.Split("\n"), ";")) {
                import_error_message = "Import text not valid";
            } else {
                array<string> parts = settings_usernames.Split("\n");
                array<string> newParts = import_settings_usernames.Split("\n");
                settings_usernames = "";
                import_settings_usernames = "";

                for (uint i = 0; i < parts.Length; i++) {
                    array<string> nameParts = parts[i].Split(";");
                    string entry = parts[i];
                    for (uint j = 0; j < newParts.Length; j++) {
                        if (newParts[j].Split(";")[0] == nameParts[0]) {
                            entry = newParts[j];
                            newParts.RemoveAt(j);
                            break;
                        }
                    }
                    settings_usernames += (settings_usernames.Length > 0? "\n" : "") + entry;
                }

                for (uint i = 0; i < newParts.Length; i++) {
                    settings_usernames += (settings_usernames.Length > 0? "\n" : "") + newParts[i];
                }

                showImportPopup = false;
                import_error_message = "";
            }
        }
        if (UI::Button("Close")) {
            showImportPopup = false;
        }

        UI::End();
    }   

    UI::SeparatorText("Medal emojis");
    RenderMedalInput();
}

void RenderResetButton()
{
    if (UI::ButtonColored("Reset to default", 0.0f))
    {
        settings_discord_user_id = DiscordDefaults::UserId;
        settings_SendPB = true;
        settings_no_medal_string = DiscordDefaults::NoMedal;
        settings_bronze_medal_string = DiscordDefaults::BronzeMedal;
        settings_silver_medal_string = DiscordDefaults::SilverMedal;
        settings_gold_medal_string = DiscordDefaults::GoldMedal;
        settings_at_medal_string = DiscordDefaults::AuthorMedal;
        settings_champion_medal_string = DiscordDefaults::ChampionMedal;
        settings_warrior_medal_string = DiscordDefaults::WarriorMedal;
        settings_usernames = DiscordDefaults::usernames;
    }
}

void RenderMedalInput()
{
    settings_no_medal_string = UI::InputText("##no_medal", settings_no_medal_string);
    RenderMedalInputHelp("no", "<:no_medal:1223567676421570601>");

    settings_bronze_medal_string = UI::InputText("##bronze_medal", settings_bronze_medal_string);
    RenderMedalInputHelp("bronze", "<:bronze_medal:1223564781437583381>");

    settings_silver_medal_string = UI::InputText("##silver_medal", settings_silver_medal_string);
    RenderMedalInputHelp("silver", "<:silver_medal:1223564769491943465>");

    settings_gold_medal_string = UI::InputText("##gold_medal", settings_gold_medal_string);
    RenderMedalInputHelp("gold", "<:gold_medal:1223564758427369472>");

    settings_at_medal_string = UI::InputText("##at_medal", settings_at_medal_string);
    RenderMedalInputHelp("author", "<:at_medal:1223564741642027079>");

#if DEPENDENCY_WARRIORMEDALS
    settings_warrior_medal_string = UI::InputText("##warrior_medal", settings_warrior_medal_string);
    RenderMedalInputHelp("warrior", "<:warrior_medal:1397582674515984555>");
#endif

#if DEPENDENCY_CHAMPIONMEDALS
    settings_champion_medal_string = UI::InputText("##champion_medal", settings_champion_medal_string);
    RenderMedalInputHelp("champion", "<:champion_medal:1223564726500462632>");
#endif
}

void RenderMedalInputHelp(const string &in medalName, const string &in medalId)
{
    UI::SameLine();
    UI::Text("Emoji-ID for " + medalName +" medal");
    if (UI::IsItemHovered())
    {
		UI::BeginTooltip();
		UI::Text("e.g.: " + medalId);
		UI::EndTooltip();
    }
    if (UI::IsItemClicked())
        IO::SetClipboard(medalId);
}
