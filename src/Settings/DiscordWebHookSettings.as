[SettingsTab name="Discord" icon="DiscordAlt" order=0]
void RenderDiscordSettings()
{
    RenderResetButton();

    settings_discord_URL = UI::InputText("Discord WebHook-URL", settings_discord_URL);
#if !DEPENDENCY_DISCORD
    settings_discord_user_id = UI::InputText("Discord User-ID", settings_discord_user_id);
#endif

    UI::Text("Club");
    string currentClub ;
    for (uint i = 0; clubs.HasKey("clubList") &&  i < clubs["clubList"].Length; i++)
    {
        if (clubs["clubList"][i]["id"] == clubId)
        {
            string clubname = clubs["clubList"][i]["name"];
            int clubID = clubs["clubList"][i]["id"];
            currentClub = clubname + " (ClubId: " + clubID + ")";
        }
    }
    if (UI::BeginCombo("##ClubComboBox", currentClub))
    {
        for (uint i = 0; clubs.HasKey("clubList") && i < clubs["clubList"].Length; i++)
        {
            string clubname = clubs["clubList"][i]["name"];
            int clubID = clubs["clubList"][i]["id"];
            if (UI::Selectable(clubname + " (ClubId: " + clubID + ")", clubs["clubList"][i]["id"] == clubId))
            {
                clubId = clubs["clubList"][i]["id"];
            }
        }
        UI::EndCombo();
    }
    UI::SameLine();
    if (UI::Button("Reload clubs")) 
    {
        reloadclubs = true;
    }

    UI::BeginTabBar("DiscordPBMessageSettings", UI::TabBarFlags::FittingPolicyResizeDown);
    if (UI::BeginTabItem(Icons::Trophy + " PB"))
    {
        settings_SendPB = UI::Checkbox("Send PB", settings_SendPB);
        
        UI::Text("Shortcut to toggle Send PB: " + ((shortcutKey != 0)? tostring(shortcutKey) : "None"));
        UI::SameLine();
        if (UI::Button("Change shortcut"))
        {
            recordShortcut = true;
        }
        UI::SameLine();
        if (UI::Button("Clear shortcut"))
        {
            shortcutKey = VirtualKey(0);
        }

        UI::Separator();
        UI::Text("Filters");
        FilterSolver@ solver = FilterSolver::FromSettings();
        bool updateSolver = false;
        for (uint i = 0; i < solver.Filters.Length; i++)
        {
            auto filter = solver.Filters[i];
            
            UI::SetNextItemWidth(160);
            if (UI::BeginCombo("##ComboArgument" + i, FilterArgument::ToString(filter.FilterArgument)))
            {
                if (UI::Selectable(FilterArgument::ToString(FilterArgument::Time), filter.FilterArgument == FilterArgument::Time))
                {
                    filter.FilterArgument = FilterArgument::Time;
                    updateSolver = true;
                }
                if (UI::Selectable(FilterArgument::ToString(FilterArgument::Rank), filter.FilterArgument == FilterArgument::Rank))
                {
                    filter.FilterArgument = FilterArgument::Rank;
                    updateSolver = true;
                }
                if (UI::Selectable(FilterArgument::ToString(FilterArgument::Medal), filter.FilterArgument == FilterArgument::Medal))
                {
                    filter.FilterArgument = FilterArgument::Medal;
                    updateSolver = true;
                }
                UI::EndCombo();
            }

            UI::SameLine();
            if (UI::Button(Comparison::ToString(filter.Comparison) + "##" + i, vec2(30, 25)))
            {
                filter.Comparison = Comparison::Next(filter.Comparison);
                updateSolver = true;
            }

            UI::SameLine();
            if (filter.FilterArgument == FilterArgument::Time || filter.FilterArgument == FilterArgument::Rank)
            {
                UI::SetNextItemWidth(160);
                int newValue = UI::InputInt("##inputValue" + i, filter.FilterValue.Value);
                if (filter.FilterValue.Value != newValue)
                {
                    filter.FilterValue.Value = newValue;
                    updateSolver = true;
                }
            }
            else if (filter.FilterArgument == FilterArgument::Medal)
            {
                UI::SetNextItemWidth(160);
                if (UI::BeginCombo("##ComboValue" + i, Medal::ToString(Medal::FromValue(filter.FilterValue.Value))))
                {
                    if (UI::Selectable(Medal::ToString(Medal::No), filter.FilterValue.Value == Medal::ToValue(Medal::No)))
                    {
                        filter.FilterValue = FilterValue(Medal::No);
                        updateSolver = true;
                    }
                    if (UI::Selectable(Medal::ToString(Medal::Bronze), filter.FilterValue.Value == Medal::ToValue(Medal::Bronze)))
                    {
                        filter.FilterValue = FilterValue(Medal::Bronze);
                        updateSolver = true;
                    }
                    if (UI::Selectable(Medal::ToString(Medal::Silver), filter.FilterValue.Value == Medal::ToValue(Medal::Silver)))
                    {
                        filter.FilterValue = FilterValue(Medal::Silver);
                        updateSolver = true;
                    }
                    if (UI::Selectable(Medal::ToString(Medal::Gold), filter.FilterValue.Value == Medal::ToValue(Medal::Gold)))
                    {
                        filter.FilterValue = FilterValue(Medal::Gold);
                        updateSolver = true;
                    }
                    if (UI::Selectable(Medal::ToString(Medal::Author), filter.FilterValue.Value == Medal::ToValue(Medal::Author)))
                    {
                        filter.FilterValue = FilterValue(Medal::Author);
                        updateSolver = true;
                    }
#if DEPENDENCY_CHAMPIONMEDALS
                    if (UI::Selectable(Medal::ToString(Medal::Champion), filter.FilterValue.Value == Medal::ToValue(Medal::Champion)))
                    {
                        filter.FilterValue = FilterValue(Medal::Champion);
                        updateSolver = true;
                    }
#endif
                    UI::EndCombo();
                }
            }

            UI::SameLine();
            if (UI::ButtonColored(Icons::Trash + "##" + i, 0.0f))
            {
                solver.Filters.RemoveAt(i);
                updateSolver = true;
            }

            if (i != solver.Filters.Length - 1 && UI::Button(LogicalConnection::ToString(filter.LogicalConnection) + "##" + i))
            {
                filter.LogicalConnection = LogicalConnection::Next(filter.LogicalConnection);
                updateSolver = true;
            }
        }
        if (updateSolver)
            settings_filter_string = solver.Serialize();

        if (UI::Button(Icons::Plus + " Add a filter"))
        {
            settings_filter_string += Filter::CreateNew().Serialize();
        }

		UI::EndTabItem();
    }

    UI::Separator();

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

    UI::EndTabBar();

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
    
    if (UI::BeginTabItem(Icons::File + " Request body"))
    {
        settings_Body = UI::InputTextMultiline("Request body", settings_Body);
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
        settings_Body = DiscordDefaults::Body;
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
