abstract class JsonSetting
{
        
    protected Json::Value value;

    public JsonSetting(Json::Value value)
    {
        this.value = value;
    }
        
    public string ToString() 
    {
        return Json::Write(value);
    }

}