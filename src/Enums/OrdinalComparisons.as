enum OrdinalComparisons {
    LessThan,
    GreaterThan,
    Equal,
    LessThanOrEqual,
    GreaterThanOrEqual
}

namespace OrdinalComparisons {

    string ToString(OrdinalComparisons op) {
        switch (op) {
            case OrdinalComparisons::LessThan:
                return "<";
            case OrdinalComparisons::GreaterThan:
                return ">";
            case OrdinalComparisons::Equal:
                return "==";
            case OrdinalComparisons::LessThanOrEqual:
                return "<=";
            case OrdinalComparisons::GreaterThanOrEqual:
                return ">=";
        }

        throw("Not implemented - OrdinalComparison: " + op);
        return "";
    }

    OrdinalComparisons FromValue(int op) {
        switch (op) {
            case 0:
                return OrdinalComparisons::LessThan;
            case 1:
                return OrdinalComparisons::GreaterThan;
            case 2:
                return OrdinalComparisons::Equal;
            case 3:
                return OrdinalComparisons::LessThanOrEqual;
            case 4:
                return OrdinalComparisons::GreaterThanOrEqual;
        }

        throw("Not implemented - OrdinalComparison: " + op);
        return OrdinalComparisons::Equal;
    }

}
