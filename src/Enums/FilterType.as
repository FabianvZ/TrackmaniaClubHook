enum FilterType {
    Comparison,
    TimeUnit,
    Map,
    Medal,
    Campaign
}

namespace FilterType {

    string ToString(FilterType filterType) {
        switch (filterType) {
            case FilterType::Comparison:
                return "Comparison";
            case FilterType::TimeUnit:
                return "TimeUnit";
            case FilterType::Map:
                return "Map";
            case FilterType::Medal:
                return "Medal";
            case FilterType::Campaign:
                return "Campaign";
        }

        throw("Not implemented - FilterType: " + filterType);
        return "";
    }

    FilterType FromValue(int filterType) {
        switch (filterType) {
            case 0:
                return FilterType::Comparison;
            case 1:
                return FilterType::TimeUnit;
            case 2:
                return FilterType::Map;
            case 3:
                return FilterType::Medal;
            case 4:
                return FilterType::Campaign;
        }

        throw("Not implemented - FilterType: " + filterType);
        return FilterType::Comparison;
    }

}