enum LogicalConnection
{
    And,
    Or
}

namespace LogicalConnection
{
    string ToString(LogicalConnection logicalConnection)
    {
        switch (logicalConnection)
        {
            case LogicalConnection::And:
                return "and";
            case LogicalConnection::Or:
                return "or";
        }

        throw("Not implemented - LogicalConnection: " + logicalConnection);
        return "";
    }

    LogicalConnection FromString(string _string)
    {
        if (_string == "and") return LogicalConnection::And;
        if (_string == "or") return LogicalConnection::Or;

        throw("Not implemented - LogicalConnection-str: " + _string);
        return LogicalConnection::And;
    }

    LogicalConnection Next(LogicalConnection logicalConnection)
    {
        switch (logicalConnection)
        {
            case LogicalConnection::And:
                return LogicalConnection::Or;
            case LogicalConnection::Or:
                return LogicalConnection::And;
        }

        throw("Not implemented - LogicalConnection: " + logicalConnection);
        return LogicalConnection::And;
    }

    bool Solve(array<Filter@> filters)
    {
        bool temp = true;
        for (uint i = 0; i < filters.Length; i++)
        {
            Filter@ filter = filters[i];
            temp = filter.Result && temp;
            if (filter.LogicalConnection == LogicalConnection::Or && i != filters.Length - 1)
            {
                if (temp) return true;
                temp = true;
            }
        }

        return temp;
    }
}
