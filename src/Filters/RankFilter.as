class RankFilter : OrdinalFilter
{
    
    public RankFilter(Json::Value value)
    {
        super(value, FilterTypes.Rank);
    }

}