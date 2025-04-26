[SettingsTab name="Discord" icon="DiscordAlt" order=0]
void RenderDiscordSettings()
{
    RenderResetButton();

    settings_discord_URL = UI::InputText("Discord WebHook-URL", settings_discord_URL);
    settings_inline_columns = UI::Checkbox("Inline columns in webhook", settings_inline_columns);

    sendPBShortcut.RenderUI();
    forceSendShortcut.RenderUI();
    
#if !DEPENDENCY_DISCORD
    settings_discord_user_id = UI::InputText("Discord User-ID", settings_discord_user_id);
#endif

    UI::SetNextItemWidth(300);
    UI::Text("Trackmania username");
    UI::SameLine();
    UI::SetNextItemWidth(200);
    UI::Text("Discord user ID");

    array<string> parts = settings_usernames.Split("\n");
    for (uint i = 0; i < parts.Length; i++)
    {
        array<string> nameParts = parts[i].Split(";");

        UI::SetNextItemWidth(300);
        parts[i] = UI::InputText("##TrackmaniaUsername" + i, nameParts.Length > 0 ? nameParts[0] : "") + ";";
        UI::SameLine();

        UI::SetNextItemWidth(200);
        parts[i] += UI::InputText("##DiscordID" + i, nameParts.Length > 1 ? nameParts[1] : "");
            
        UI::SameLine();
        if (UI::ButtonColored(Icons::Trash + "##" + i, 0.0f)) {
            parts.RemoveAt(i);
            i--;
        }
    }
    settings_usernames = string::Join(parts, "\n");

    UI::SetNextItemWidth(300);
    string newTrackmaniaUsername = UI::InputText("##TrackmaniaUsername" + parts.Length, "");
    UI::SameLine();
    UI::SetNextItemWidth(200);
    string newDiscordID = UI::InputText("##DiscordID" + parts.Length, "");
    if (newTrackmaniaUsername.Length > 0 || newDiscordID.Length > 0) {
        settings_usernames += "\n" + newTrackmaniaUsername + ";" + newDiscordID;
    }

    if (UI::Button(Icons::Clipboard	 + " export discord ping settings"))
    {
        IO::SetClipboard(settings_usernames);
    }
    UI::SameLine();
    if (UI::Button(Icons::Clipboard	 + " import discord ping settings"))
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
                showImportPopup = false;
                settings_usernames = import_settings_usernames;
                import_settings_usernames = "";
                import_error_message = "";
            }
        }
        if (UI::Button("Close")) {
            showImportPopup = false;
        }

        UI::End();
    }

#if SIG_DEVELOPER
    settings_AdvancedDiscordSettings = UI::Checkbox("Advanced Settings", settings_AdvancedDiscordSettings);
#else
    if (settings_AdvancedDiscordSettings)
        settings_AdvancedDiscordSettings = UI::Checkbox("Advanced Settings", settings_AdvancedDiscordSettings);
#endif

    if (!settings_AdvancedDiscordSettings) return;

    // Advanced settings

    UI::BeginTabBar("DiscordWebHookSettings", UI::TabBarFlags::FittingPolicyResizeDown);
#if DEPENDENCY_DISCORD
    if (UI::BeginTabItem(Icons::Cogs + " General"))
    {
        settings_discord_user_id = UI::InputText("Discord User-ID", settings_discord_user_id);
		UI::EndTabItem();
    }
#endif
    if (UI::BeginTabItem(Icons::Kenney::Radio + " Medals"))
    {
        RenderMedalInput();
		UI::EndTabItem();
    }
    
    UI::EndTabBar();
}

void RenderResetButton()
{
    if (UI::ButtonColored("Reset to default", 0.0f))
    {
        settings_discord_user_id = DiscordDefaults::UserId;
        settings_discord_URL = DiscordDefaults::URL;
        settings_SendPB = true;
        settings_AdvancedDiscordSettings = false;
        settings_filter_string = "";
        settings_no_medal_string = DiscordDefaults::NoMedal;
        settings_bronze_medal_string = DiscordDefaults::BronzeMedal;
        settings_silver_medal_string = DiscordDefaults::SilverMedal;
        settings_gold_medal_string = DiscordDefaults::GoldMedal;
        settings_at_medal_string = DiscordDefaults::AuthorMedal;
        settings_champion_medal_string = DiscordDefaults::ChampionMedal;
        settings_usernames = DiscordDefaults::usernames;
        reloadclubs = true;
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
