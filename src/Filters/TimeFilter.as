class TimeFilter : OrdinalFilter
{
    
    public TimeFilter(Json::Value value)
    {
        super(value, FilterTypes.Time);
    }

}