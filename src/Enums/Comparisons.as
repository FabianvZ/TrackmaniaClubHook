enum Comparisons {
    And,
    Or
}

namespace Comparisons {

    string ToString(Comparisons op) {
        switch (op) {
            case Comparisons::And:
                return "And";
            case Comparisons::Or:
                return "Or";
        }

        throw("Not implemented - Comparison: " + op);
        return "";
    }

    Comparisons FromValue(int op) {
        switch (op) {
            case 0:
                return Comparisons::And;
            case 1:
                return Comparisons::Or;
        }

        throw("Not implemented - Comparison: " + op);
        return Comparisons::And;
    }

}
