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
        array<string> rawParts = settings_filter_string.Split(";");
        Json::Value@ filters;
        Json::Value@ currentGroup;

        for (int i = 0; i < rawParts.Length - 1; i++) {
          Json::Value@ filter = Json::Object();
          array<string> parts = rawParts[i].Split(",");

          if (parts[0] == "Medal") {
            filter["Type"] = FilterType::Medal;
          } else if (parts[0] == "Time") {
            filter["Type"] = FilterType::Time;
          } else if (parts[0] == "Rank") {
            filter["Type"] = FilterType::Rank;
          } 

          if (parts[1] == ">=") {
            filter["OrdinalComparison"] = OrdinalComparisons::GreaterThanOrEqual;
          } else if (parts[1] == "<=") {
            filter["OrdinalComparison"] = OrdinalComparisons::LessThanOrEqual;
          } else if (parts[1] == ">") {
            filter["OrdinalComparison"] = OrdinalComparisons::GreaterThan;
          } else if (parts[1] == "<") {
            filter["OrdinalComparison"] = OrdinalComparisons::LessThan;
          } else if (parts[1] == "==") {
            filter["OrdinalComparison"] = OrdinalComparisons::Equal;
          }

          filter["Value"] = Text::ParseInt(parts[2]);
          if (currentGroup == null) {
            @currentGroup = filter;
          } else {
            @currentGroup = createComparison(currentGroup, filter, Comparisons::And);
          }

          if (parts[3] == "or") {
            if (filters is null) {
              @filters = currentGroup;
            } else {
              @filters = createComparison(currentGroup, filters, Comparisons::Or);
            }
            @currentGroup = null;
          }
        }

        if (currentGroup !is null) {
          if (filters is null) {
            @filters = currentGroup;
          } else {
            @filters = createComparison(currentGroup, filters, Comparisons::Or);
          }
        }
        data["Filters"] = filters;
      }

      Json::Value@ filters = Json::Array();
      filters.Add(data);
      WebhookSettings::settings_webhooks = Json::Write(filters);

      // TODO uncomment this when the migration is ready
      // settings_discord_URL = DiscordDefaults::URL;
      // clubId = -1;
      // settings_filter_string = "";
    }
  }

  Json::Value@ createComparison(Json::Value@ first, Json::Value@ second, Comparisons comparison) {
    Json::Value@ comparisonData = Json::Object();
    comparisonData["Type"] = FilterType::Comparison;
    comparisonData["Comparison"] = comparison;
    comparisonData["FirstFilter"] = first;
    comparisonData["SecondFilter"] = second;
    return comparisonData;
  }

}