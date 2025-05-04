enum TotDStatus {
    Is,
    IsNot
}

namespace TotDStatus {

    string ToString(TotDStatus status) {
        switch (status) {
            case TotDStatus::Is:
                return "Is";
            case TotDStatus::IsNot:
                return "Is Not";
        }

        throw("Not implemented - TotDStatus: " + status);
        return "";
    }

    TotDStatus FromValue(int status) {
        switch (status) {
            case 0:
                return TotDStatus::Is;
            case 1:
                return TotDStatus::IsNot;
        }

        throw("Not implemented - TotDStatus: " + status);
        return TotDStatus::IsNot;
    }

}
