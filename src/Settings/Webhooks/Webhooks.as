[Setting hidden]
string settings_webhooks = "[{}]";	
array<WebhookSetting@> webhooks;

[SettingsTab name="Discord webhooks" icon="DiscordAlt" order=1]
void RenderDiscordWebhookSettings(){

    UI::BeginTabBar("DiscordPBMessageSettings", UI::TabBarFlags::FittingPolicyResizeDown);
    for (uint i = 0; i < webhooks.Length; i++) {
        if (UI::BeginTabItem(Icons::Trophy + " " + webhooks[i].Name +" " + i))
        {
            if (WebhookSetting(webhooks[i]).Draw()){
                webhooks.RemoveAt(i);
            }
            UI::EndTabItem();
        }   
    }
    UI::EndTabBar();
  
    UI::Separator();
    if (UI::Button(Icons::Plus + " Add a webhook"))
    {
        webhooks.InsertLast(WebhookSetting(Json::Object()));
    }

    settings_webhooks = Json::Write(webhooks);
}