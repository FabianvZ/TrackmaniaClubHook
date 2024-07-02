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
        /*
        array<bool> values;
        bool temp = true;
        for (uint i = 0; i < Filter.Length; i++)
        {
            auto filter = Filters[i];
            if (filter.Calculate(PB) && temp)
            {
                if (filter.LogicalConnection == LogicalConnection::OR)
                {
                    values.InsertLast(temp);
                    temp = true;
                }

                continue;
            }
            temp = false;
            if (filter.LogicalConnection == LogicalConnection::OR)
            {
                values.InsertLast(temp);
                temp = true;
            }
        }
        values.InsertLast(temp);

        for (uint i = 0; i < values.Length; i++)
            if (values[i]) return true;

        return false;
        */
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
