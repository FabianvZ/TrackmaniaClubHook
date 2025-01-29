[SettingsTab name="Discord webhooks" icon="DiscordAlt" order=1]
void RenderDiscordWebhookSettings(){

    Json::Value@ data = Json::Parse(settings_webhooks);

    UI::BeginTabBar("DiscordPBMessageSettings", UI::TabBarFlags::FittingPolicyResizeDown);
    for (int i = 0; i < data.Length; i++) {
        if (UI::BeginTabItem(Icons::Trophy + " Webhook " + i))
        {
            if (WebhookSetting(data[i]).Draw()){
                data.Remove(i);
            }
            UI::EndTabItem();
        }   
    }
    UI::EndTabBar();
  
    UI::Separator();
    if (UI::Button(Icons::Plus + " Add a webhook"))
    {
        data.Add(Json::Object());
    }

    settings_webhooks = Json::Write(data);
}