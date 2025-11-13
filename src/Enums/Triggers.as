enum Triggers {
    Club,
    Medal,
    Time,
}

namespace Triggers {

    string ToString(Triggers t) {
        switch (t) {
            case Triggers::Club:
                return "Improved Club Position";
            case Triggers::Medal:
                return "Improved Medal";
            case Triggers::Time:
                return "Improved Time";
        }

        throw("Not implemented - Trigger: " + t);
        return "";
    }

    Triggers FromValue(int t) {
        switch (t) {
            case 0:
                return Triggers::Club;
            case 1:
                return Triggers::Medal;
            case 2:
                return Triggers::Time;
        }

        throw("Not implemented - Trigger: " + t);
        return Triggers::Club;
    }

    bool IsTriggered(ClubPB@ pb, Triggers trigger) {
        switch (trigger) {
            case Triggers::Club:
                return pb.ClubPosition < pb.PreviousClubPosition;
            case Triggers::Medal:
                return pb.pb.Medal != Medal::GetReachedMedal(pb.pb.Map, pb.pb.PreviousScore);
            case Triggers::Time:
                return pb.pb.Score < pb.pb.PreviousScore;
        }
        throw("Not implemented - Trigger: " + trigger);
        return false;
    }

}
