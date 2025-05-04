enum TimeUnit {
    Milliseconds,
    Seconds,
    Minutes
}

namespace TimeUnit {

    string ToString(TimeUnit unit) {
        switch (unit) {
            case TimeUnit::Milliseconds:
                return "Milliseconds";
            case TimeUnit::Seconds:
                return "Seconds";
            case TimeUnit::Minutes:
                return "Minutes";
        }

        throw("Not implemented - TimeUnit: " + unit);
        return "";
    }

    TimeUnit FromValue(int unit) {
        switch (unit) {
            case 0:
                return TimeUnit::Milliseconds;
            case 1:
                return TimeUnit::Seconds;
            case 2:
                return TimeUnit::Minutes;
        }

        throw("Not implemented - TimeUnit: " + unit);
        return TimeUnit::Milliseconds;
    }

}