void OnSettingsLoad(Settings::Section& section) {
    
#if DEPENDENCY_DISCORD
    if (settings_discord_user_id == "")
    {
        for (uint tries = 0; tries < 10; tries++)
        {
            if (Discord::IsReady())
            {
                string discordUserId = Discord::GetUser().ID;
                DiscordDefaults::UserId = discordUserId;
                settings_discord_user_id = discordUserId;
                Log("Got Discord User!");
                break;
            }
            Log("Tried to get Discord User - was not ready!");

            sleep(500);
        }
    }
#endif

    Legacy::migrateOldWebhookSettings();

    sendPBShortcut.key = VirtualKey(section.GetInt("togglePBKey"));
    forceSendShortcut.key = VirtualKey(section.GetInt("forceSendKey"));

    @WebhookSettings::_webhooks = Json::Parse(WebhookSettings::settings_webhooks);
    if (WebhookSettings::_webhooks.GetType() != Json::Type::Array)
    {
        @WebhookSettings::_webhooks = Json::Array();
    }
    for (uint i = 0; i < WebhookSettings::_webhooks.Length; i++)
    {
        WebhookSettings::webhooks.InsertLast(@WebhookSetting(WebhookSettings::_webhooks[i]));
    }
}

void OnSettingsSave(Settings::Section& section) {
    WebhookSettings::settings_webhooks = Json::Write(WebhookSettings::_webhooks);
}