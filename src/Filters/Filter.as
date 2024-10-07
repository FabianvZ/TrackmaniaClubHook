abstract class Filter
{

    public Filter(Json::Value value, FilterTypes type) 
    {
        super(value);
        value["type"] = type;
    }

    public void Draw();

    public boolean Solve();

}