class FilterValue
{
    int Value;

    FilterValue() 
    {
        Value = 0;
    }

    FilterValue(int value)
    {
        Value = value;
    }

    FilterValue(Medal medal)
    {
        Value = Medal::ToValue(medal);
    }

    string ToString()
    {
        return "" + Value;
    }
}

namespace FilterValue
{
    FilterValue FromString(string _string)
    {
        return FilterValue(Text::ParseInt(_string));
    }
}
