class Filter
{
    FilterArgument FilterArgument;
    Comparison Comparison;
    FilterValue FilterValue;
    LogicalConnection LogicalConnection;
    bool Result;

    Filter(FilterArgument filterArgument, Comparison comparison, FilterValue filterValue, LogicalConnection logicalConnection)
    {
        FilterArgument = filterArgument;
        Comparison = comparison;
        FilterValue = filterValue;
        LogicalConnection = logicalConnection;
    }

    void Solve(PB@ pb)
    {
        int argumentValue = FilterArgument::GetValue(FilterArgument, pb);
        int filterValue = FilterValue.Value;
        Result = Comparison::Compare(Comparison, argumentValue, filterValue);
    }

    string Serialize()
    {
        return FilterArgument::ToString(FilterArgument) + 
                "," + Comparison::ToString(Comparison) + 
                "," + FilterValue.ToString() + 
                "," + LogicalConnection::ToString(LogicalConnection) + ";";
    }
}

namespace Filter
{
    Filter CreateNew()
    {
        return Filter(FilterArgument::Medal, Comparison::GreaterOrEqual, FilterValue(Medal::Author), LogicalConnection::And);
    }

    Filter Deserialize(string _string)
    {
        auto parts = _string.Split(",");

        return Filter(FilterArgument::FromString(parts[0]), Comparison::FromString(parts[1]), FilterValue::FromString(parts[2]), LogicalConnection::FromString(parts[3]));
    }
}
