enum Comparison
{
    Less,
    LessOrEqual,
    Equal,
    Greater,
    GreaterOrEqual
}

namespace Comparison
{
    string ToString(Comparison comparison)
    {
        switch (comparison)
        {
            case Comparison::Less:
                return "<";
            case Comparison::LessOrEqual:
                return "<=";
            case Comparison::Equal:
                return "==";
            case Comparison::Greater:
                return ">";
            case Comparison::GreaterOrEqual:
                return ">=";
        }

        throw("Not implemented - Comparison: " + comparison);
        return "";
    }
    
    Comparison FromString(string _string)
    {
        if (_string == "<") return Comparison::Less;
        if (_string == "<=") return Comparison::LessOrEqual;
        if (_string == "==") return Comparison::Equal;
        if (_string == ">") return Comparison::Greater;
        if (_string == ">=") return Comparison::GreaterOrEqual;
        
        throw("Not implemented - Comparison-str: " + _string);
        return Comparison::Equal;
    }

    Comparison Next(Comparison comparison)
    {
        switch (comparison)
        {
            case Comparison::Less:
                return Comparison::LessOrEqual;
            case Comparison::LessOrEqual:
                return Comparison::Equal;
            case Comparison::Equal:
                return Comparison::Greater;
            case Comparison::Greater:
                return Comparison::GreaterOrEqual;
            case Comparison::GreaterOrEqual:
                return Comparison::Less;
        }

        throw("Not implemented - Comparison: " + comparison);
        return Comparison::Equal;
    }

    Comparison Previous(Comparison comparison)
    {
        switch (comparison)
        {
            case Comparison::Less:
                return Comparison::GreaterOrEqual;
            case Comparison::LessOrEqual:
                return Comparison::Less;
            case Comparison::Equal:
                return Comparison::LessOrEqual;
            case Comparison::Greater:
                return Comparison::Equal;
            case Comparison::GreaterOrEqual:
                return Comparison::Greater;
        }

        throw("Not implemented - Comparison: " + comparison);
        return Comparison::Equal;
    }

    bool Compare(Comparison comparison, int value1, int value2)
    {
        switch (comparison)
        {
            case Comparison::Less:
                return value1 < value2;
            case Comparison::LessOrEqual:
                return value1 <= value2;
            case Comparison::Equal:
                return value1 == value2;
            case Comparison::Greater:
                return value1 > value2;
            case Comparison::GreaterOrEqual:
                return value1 >= value2;
        }

        throw("Not implemented - Comparison: " + comparison);
        return false;
    }
}
