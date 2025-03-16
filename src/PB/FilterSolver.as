class FilterSolver
{
    array<Filter@> Filters;

    FilterSolver() { }

    FilterSolver(array<Filter@> filters)
    { 
        Filters = filters;
    }

    void AddFilter(Filter@ filter)
    {
        Filters.InsertLast(filter);
    }

    string Serialize()
    {
        string serialized = "";

        for (uint i = 0; i < Filters.Length; i++)
        {
            auto filter = Filters[i];
            serialized += filter.Serialize();
        }

        return serialized;
    }

    bool Solve(PB@ pb)
    {
        for (uint i = 0; i < Filters.Length; i++)
            Filters[i].Solve(pb);

        return LogicalConnection::Solve(Filters);
    }
}

namespace FilterSolver
{
    FilterSolver FromSettings()
    {
        auto filterParts = settings_filter_string.Split(";");
        if (filterParts.Length > 0) filterParts.RemoveLast();
        array<Filter@> filters;

        for (uint i = 0; i < filterParts.Length; i++)
        {
            string filterString = filterParts[i];
            auto filter = Filter::Deserialize(filterString);
            filters.InsertLast(filter);
        }

        return FilterSolver(filters);
    }
}
