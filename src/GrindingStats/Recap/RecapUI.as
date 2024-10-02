bool setting_recap_show_menu = false;
bool load_recap = false;
bool setting_recap_show_colors = setting_show_map_name_color;
int total_files = 0;
uint render_amount = 100;

void RenderMenu() {
	if (UI::MenuItem(Icons::List + " Grinding Stats Recap", "",
					 setting_recap_show_menu)) {
		total_files =
			IO::IndexFolder(IO::FromStorageFolder("data"), true).Length;
		setting_recap_show_menu = !setting_recap_show_menu;
	}
}

enum recap_filter {
	all,
	all_with_name,
#if TMNEXT
	current_campaign,
	previous_campaign,
	all_nadeo_campaigns,
#elif MP4 || TURBO
	canyon,
	stadium,
	valley,
	lagoon,
#endif
#if TURBO
	turbo_white,
	turbo_green,
	turbo_blue,
	turbo_red,
	turbo_black,
#endif
	totd,
	custom
}

string recap_filter_string(recap_filter filter) {
	switch (filter) {
	case recap_filter::all:
		return "All Tracks";
	case recap_filter::custom:
		return "Custom";
#if MP4
	case recap_filter::all_with_name:
		return "All Tracks uploaded to TM² Exchange";
	case recap_filter::canyon:
		return "TM² Canyon Titlepack";
	case recap_filter::stadium:
		return "TM² Stadium Titlepack";
	case recap_filter::valley:
		return "TM² Valley Titlepack";
	case recap_filter::lagoon:
		return "TM² Lagoon Titlepack";
#elif TMNEXT
	case recap_filter::all_with_name:
		return "All Tracks uploaded to NadeoServices";
	case recap_filter::current_campaign:
		return "Current seasonal campaign";
	case recap_filter::previous_campaign:
		return "Previous seasonal campaign";
	case recap_filter::all_nadeo_campaigns:
		return "All seasonal campaigns";
	case recap_filter::totd:
		return "All TOTDs";
#elif TURBO
	case recap_filter::canyon:
		return "Canyon";
	case recap_filter::stadium:
		return "Stadium";
	case recap_filter::valley:
		return "Valley";
	case recap_filter::lagoon:
		return "Lagoon";
	case recap_filter::turbo_white:
		return "White Tracks (1-40)";
	case recap_filter::turbo_green:
		return "Green Tracks (41-80)";
	case recap_filter::turbo_blue:
		return "Blue Tracks (81-120)";
	case recap_filter::turbo_red:
		return "Red Tracks (121-160)";
	case recap_filter::turbo_black:
		return "Black Tracks (161-200)";
#endif
	}
	return "";
}

recap_filter current_recap = recap_filter::all;
void RenderRecap() {
	if (UI::Begin("Grinding Stats Recap", setting_recap_show_menu,
				  UI::WindowFlags::NoCollapse | UI::WindowFlags::MenuBar)) {
		// menu bar
		if (UI::BeginMenuBar()) {
			if (UI::MenuItem(Icons::Refresh + " Refresh")) {
				startnew(CoroutineFunc(recap.refresh));
			}
			UI::Text("Filter:");
			if (UI::BeginCombo("", recap_filter_string(current_recap))) {
				add_selectable(recap_filter::all);
#if TMNEXT || MP4
				add_selectable(recap_filter::all_with_name);
#endif

#if TMNEXT
				add_selectable(recap_filter::current_campaign);
				add_selectable(recap_filter::previous_campaign);
				add_selectable(recap_filter::all_nadeo_campaigns);
				add_selectable(recap_filter::totd);
				add_selectable(recap_filter::custom);
#elif MP4
				add_selectable(recap_filter::canyon);
				add_selectable(recap_filter::stadium);
				add_selectable(recap_filter::valley);
				add_selectable(recap_filter::lagoon);
#elif TURBO
				add_selectable(recap_filter::turbo_white);
				add_selectable(recap_filter::turbo_green);
				add_selectable(recap_filter::turbo_blue);
				add_selectable(recap_filter::turbo_red);
				add_selectable(recap_filter::turbo_black);
#endif
				add_selectable(recap_filter::custom);
				UI::EndCombo();
			}
			// bool UI::RadioButton(const string&in label, bool active)
			if (UI::RadioButton("Show colored names",
								setting_recap_show_colors)) {
				setting_recap_show_colors = !setting_recap_show_colors;
			}

			UI::EndMenuBar();
		}
#if TURBO
		uint columns = 6;
#elif MP4 || TMNEXT
		uint columns = 7;
#endif
		if (!load_recap) {
			auto windowWidth = UI::GetWindowSize();
			string text = "You have " + total_files +
						  " files in your Grinding Stats data "
						  "folder.\nThis will take a while depending on how "
						  "many files you "
						  "have.\nIt will lag/freeze the game while loading.";
			vec2 textWidth = Draw::MeasureString(text);
			UI::SetCursorPos(vec2(windowWidth.x / 2 - textWidth.x / 2,
								  windowWidth.y / 2 + 25));
			UI::Text(text);
			UI::SetCursorPos(
				vec2(windowWidth.x / 2 - 200 / 2, windowWidth.y / 2 - 25));
			if (UI::Button("Load Recap", vec2(200, 50))) {
				load_recap = true;
				recap.start();
			}
		}
		if (recap.filtered_elements.Length == 0) {
			UI::SetCursorPos(vec2(10, 60));
			UI::Text("Recap Log");
			for (uint i = 0; i < recap.log.Length; i++) {
				UI::Text(recap.log[i]);
			}
		}

		if (load_recap && UI::BeginTable("Items", columns,
										 UI::TableFlags::Sortable |
											 UI::TableFlags::Resizable |
											 UI::TableFlags::ScrollY)) {
			// headers

			UI::TableSetupColumn("Name",
								 UI::TableColumnFlags::WidthFixed |
									 UI::TableColumnFlags::NoHide,
								 200);
			UI::TableSetupColumn(
				"Time",
				UI::TableColumnFlags::WidthFixed |
					UI::TableColumnFlags::DefaultSort |
					UI::TableColumnFlags::PreferSortDescending |
					UI::TableColumnFlags::NoHide,
				150);
			UI::TableSetupColumn("Finishes", UI::TableColumnFlags::WidthFixed,
								 100);
			UI::TableSetupColumn("Resets", UI::TableColumnFlags::WidthFixed,
								 100);
#if TMNEXT
			UI::TableSetupColumn("Respawns", UI::TableColumnFlags::WidthFixed,
								 100);
#elif MP4
			UI::TableSetupColumn("Title pack",
								 UI::TableColumnFlags::WidthFixed |
									 UI::TableColumnFlags::NoResize,
								 100);
#endif
			UI::TableSetupColumn("Last Played",
								 UI::TableColumnFlags::WidthFixed, 100);
			UI::TableSetupColumn("Custom Recap",
								 UI::TableColumnFlags::WidthFixed, 100);
			UI::TableHeadersRow();

			// sorting
			auto sortSpecs = UI::TableGetSortSpecs();
			if (sortSpecs !is null && (sortSpecs.Dirty || recap.dirty))
				recap.SortItems(sortSpecs);

			// drawing items
			UI::ListClipper clipper(recap.filtered_elements.Length + 1 <
											render_amount
										? recap.filtered_elements.Length + 1
										: render_amount);
			while (clipper.Step()) {
				for (int i = clipper.DisplayStart; i < clipper.DisplayEnd;
					 i++) {
					string name;
					string map_id;
					string time;
					string finishes;
					string resets;
					string respawns;
					string stripped_name;
					string time_modified;
#if MP4
					string titlepack;
#endif
					if (i != 0) {
						RecapElement @element = recap.filtered_elements[i - 1];
						stripped_name = element.stripped_name;
						map_id = element.map_id;
						name = element.name;
						time = element.time;
						finishes = "" + element.finishes;
						resets = "" + element.resets;
						respawns = "" + element.respawns;
						time_modified =
							Time::FormatString("%F %r", element.modified_time);
#if MP4
						titlepack = element.titlepack;
#endif
					} else {
						map_id = "";
						name = "TOTAL (" + recap.filtered_elements.Length + ")";
						stripped_name = name;
						time = Recap::time_to_string(recap.total_time);
						finishes = "" + recap.total_finishes;
						resets = "" + recap.total_resets;
						respawns = "" + recap.total_respawns;
					}
					UI::TableNextRow();
					UI::TableSetColumnIndex(0);
					UI::Text(setting_recap_show_colors ? name : stripped_name);
					if (UI::IsItemHovered() && Meta::IsDeveloperMode()) {
						UI::BeginTooltip();
						if (map_id == stripped_name)
							UI::Text(stripped_name);
						else
							UI::Text(map_id + "\n" + "'" +
									 Text::StripFormatCodes(name) + "'");

						UI::EndTooltip();
					}
					UI::TableSetColumnIndex(1);
					UI::Text(time);
					UI::TableSetColumnIndex(2);
					UI::Text(finishes);
					UI::TableSetColumnIndex(3);
					UI::Text(resets);
#if TMNEXT
					UI::TableSetColumnIndex(4);
					UI::Text(respawns);
#elif MP4
					UI::TableSetColumnIndex(4);
					UI::Text(titlepack);
#endif
#if TURBO
					UI::TableSetColumnIndex(4);
#else
					UI::TableSetColumnIndex(5);
#endif
					UI::Text(time_modified);
					if (i != 0) {
#if TURBO
						UI::TableSetColumnIndex(5);
#else
						UI::TableSetColumnIndex(6);
#endif
						bool is_cust_map =
							setting_custom_recap.Contains(map_id);
						if (UI::Checkbox("##" + map_id, is_cust_map) !=
							is_cust_map) {
							if (is_cust_map)
								remove_custom_map(map_id);
							else add_custom_map(map_id);
						}
					}
				}
			}
			UI::EndTable();
		}
	}
	UI::End();
}

void add_selectable(recap_filter filter) {
	if (UI::Selectable(recap_filter_string(filter), current_recap == filter)) {
		if (current_recap == filter)
			return;
		current_recap = filter;
		startnew(CoroutineFunc(recap.filter_elements));
	}
}

void add_custom_map(const string &in UID) {
	if (setting_custom_recap != "")
		setting_custom_recap += "\n";
	setting_custom_recap += UID;
	setting_custom_recap = setting_custom_recap.Replace("\n\n", "\n");
}

void remove_custom_map(const string &in UID) {
	setting_custom_recap = setting_custom_recap.Replace(UID, "");
	setting_custom_recap = setting_custom_recap.Replace("\n\n", "\n");
	if (setting_custom_recap == "\n")
		setting_custom_recap = "";
}
