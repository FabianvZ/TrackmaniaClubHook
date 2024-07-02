enum FilterArgument
{
    Time,
    Rank,
    Medal
}

namespace FilterArgument
{
    string ToString(FilterArgument filterArgument)
    {
        switch (filterArgument)
        {
            case FilterArgument::Time:
                return "Time";
            case FilterArgument::Rank:
                return "Rank";
            case FilterArgument::Medal:
                return "Medal";
        }
        
        throw("Not implemented - FilterArgument: " + filterArgument);
        return "";
    }
    
    FilterArgument FromString(string _string)
    {
        if (_string == "Time") return FilterArgument::Time;
        if (_string == "Rank") return FilterArgument::Rank;
        if (_string == "Medal") return FilterArgument::Medal;
        
        throw("Not implemented - FilterArgument-str: " + _string);
        return FilterArgument::Time;
    }

    int GetValue(FilterArgument filterArgument, PB@ pb)
    {
        switch (filterArgument)
        {
            case FilterArgument::Time:
                return pb.CurrentPB;
            case FilterArgument::Rank:
                return pb.Position;
            case FilterArgument::Medal:
                return Medal::ToValue(pb.Medal);
        }
        
        throw("Not implemented - FilterArgument: " + filterArgument);
        return -1;
    }
}
