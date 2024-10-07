class MedalFilter : OrdinalFilter
{
    
    public MedalFilter(Json::Value value)
    {
        super(value, FilterTypes.Rank);
    }

    public bool Solve(PB@ pb) 
    {

    }

}