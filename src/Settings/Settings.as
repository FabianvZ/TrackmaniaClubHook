void OnSettingsLoad(Settings::Section& section) {
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