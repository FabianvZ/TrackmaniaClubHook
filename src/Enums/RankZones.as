enum RankZones {
    World,
    Continent,
    Country,
    Province,
    Club
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
                return RankZones::World;
            case 1:
                return RankZones::Continent;
            case 2:
                return RankZones::Country;
            case 3:
                return RankZones::Province;
            case 4:
                return RankZones::Club;
        }

        throw("Not implemented - RankFilter: " + rf);
        return RankZones::Club;
    }

}
