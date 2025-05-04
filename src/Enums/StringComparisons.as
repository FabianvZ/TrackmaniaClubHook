enum StringComparisons {
    Is,
    IsNot,
    Contains,
    DoesNotContain
}

namespace StringComparisons {

    string ToString(StringComparisons op) {
        switch (op) {
            case StringComparisons::Is:
                return "Is";
            case StringComparisons::IsNot:
                return "Is Not";
            case StringComparisons::Contains:
                return "Contains";
            case StringComparisons::DoesNotContain:
                return "Does Not Contain";
        }

        throw("Not implemented - StringComparison: " + op);
        return "";
    }

    StringComparisons FromValue(int op) {
        switch (op) {
            case 0:
                return StringComparisons::Is;
            case 1:
                return StringComparisons::IsNot;
            case 2:
                return StringComparisons::Contains;
            case 3:
                return StringComparisons::DoesNotContain;
        }

        throw("Not implemented - StringComparison: " + op);
        return StringComparisons::Is;
    }

}
