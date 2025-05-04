enum FilterType {
    Comparison,
    Time,
    MapName,
    Medal,
    CurrentCampaign,
    Rank,
    TrackOfTheDay,
    WeeklyShorts
}

namespace FilterType {

    string ToString(FilterType filterType) {
        switch (filterType) {
            case FilterType::Comparison:
                return "Comparison";
            case FilterType::Time:
                return "Time";
            case FilterType::MapName:
                return "Map Name";
            case FilterType::Medal:
                return "Medal";
            case FilterType::CurrentCampaign:
                return "Current Campaign";
            case FilterType::WeeklyShorts:
                return "Weekly Shorts";
            case FilterType::Rank:
                return "Rank";
            case FilterType::TrackOfTheDay:
                return "TOTD";
        }

        throw("Not implemented - FilterType: " + filterType);
        return "";
    }

    FilterType FromValue(int filterType) {
        switch (filterType) {
            case 0:
                return FilterType::Comparison;
            case 1:
                return FilterType::Time;
            case 2:
                return FilterType::MapName;
            case 3:
                return FilterType::Medal;
            case 4:
                return FilterType::CurrentCampaign;
            case 5:
                return FilterType::Rank;
            case 6:
                return FilterType::TrackOfTheDay;
            case 7:
                return FilterType::WeeklyShorts;
        }

        throw("Not implemented - FilterType: " + filterType);
        return FilterType::Comparison;
    }

}