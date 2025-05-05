namespace Legacy {

  [Setting hidden]
  string settings_filter_string = "";

  [Setting hidden]
  string settings_discord_URL = DiscordDefaults::URL;

  [Setting hidden]
  int clubId = -1;

  void migrateOldWebhookSettings() {
    if (settings_discord_URL != DiscordDefaults::URL || clubId != -1 || settings_filter_string != "") {
      Json::Value@ data = Json::Object();
      data["WebhookUrl"] = settings_discord_URL;
      data["Name"] = "Old Webhook";
      data["ClubId"] = clubId;

      if (settings_filter_string != "") {
        Json::Value@ filter = Json::Object();
        
      }

      // TODO uncomment this when the migration is ready
      // settings_discord_URL = DiscordDefaults::URL;
      // clubId = -1;
      // settings_filter_string = "";


    }
  }

  void migrateOldGrindingStatsData() {
    auto old_path = IO::FromStorageFolder("data");
    if (IO::FolderExists(old_path)) {
      UI::ShowNotification("Discord Rivalry Ping", "Moving Grinding Stats data to Grinding stats plugin.", UI::HSV(0.10f, 1.0f, 1.0f), 2500);
      auto new_path = IO::FromDataFolder("PluginStorage/GrindingStats/data");
      if (IO::FolderExists(new_path)) {

              auto old = IO::IndexFolder(old_path, true);
              for (uint i = 0; i < old.Length; i++) {
                  const string[] @parts = old[i].Split("/");
                  const string name = new_path + "/" + parts[parts.Length - 1];
                  if (IO::FileExists(name)) {
                      print("Combining " + old[i] + " and " + name);
                      Json::Value new_file = Json::FromFile(name);
                      Json::Value old_file = Json::FromFile(old[i]);

                      new_file["finishes"] = Text::Format("%6d", getValue(new_file["finishes"]) + getValue(old_file["finishes"]));
                      new_file["resets"] = Text::Format("%6d", getValue(new_file["resets"]) + getValue(old_file["resets"]));
                      new_file["time"] = Text::Format("%11d", getValue(new_file["time"]) + getValue(old_file["time"]));
                      new_file["respawns"] = Text::Format("%6d", getValue(new_file["respawns"]) + getValue(old_file["respawns"]));

                      Json::ToFile(name, new_file);
                      IO::Delete(old[i]);
                  } 
                  else {
                      print("moving " + old[i] + " to " + name);
                      IO::Move(old[i], name);
                  }
              }
              UI::ShowNotification("Discord Rivalry Ping", "Completed Data Transfer", UI::HSV(0.35f, 1.0f, 1.0f), 10000);
              IO::DeleteFolder(old_path);
      } else {
              IO::Move(old_path, new_path);
              if (IO::IndexFolder(old_path, true).Length == 0) {
                  IO::DeleteFolder(old_path);
              }
          }
    }
  }

  int getValue(Json::Value value) 
  {
      switch (value.GetType())
      {
          case Json::Type::String:
              return Text::ParseUInt64(value);
          case Json::Type::Number:
              return value;
      }
      return 0;
  }

}