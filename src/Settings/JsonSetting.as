class JsonSetting 
{

    Json::Value@ Data;

    JsonSetting(Json::Value@ data) {
        @this.Data = data;
    }

    bool Draw() {
        throw("Not implemented - Draw");
        return false;
    }

}