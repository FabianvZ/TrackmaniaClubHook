enum RankZones {
    Club,
    World,
    Continent,
    Country,
    Province
}

namespace RankZones {

    string ToString(RankZones rf) {
        switch (rf) {
            case RankZones::Club:
                return "Club";
            case RankZones::World:
                return "World";
            case RankZones::Continent:
                return "Continent";
            case RankZones::Country:
                return "Country";
            case RankZones::Province:
                return "Province";
        }

        throw("Not implemented - RankFilter: " + rf);
        return "";
    }

    RankZones FromValue(int rf) {
        switch (rf) {
            case 0:
                return RankZones::Club;
            case 1:
                return RankZones::World;
            case 2:
                return RankZones::Continent;
            case 3:
                return RankZones::Country;
            case 4:
                return RankZones::Province;
        }

        throw("Not implemented - RankFilter: " + rf);
        return RankZones::Club;
    }

}
