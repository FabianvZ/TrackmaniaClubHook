class OrdinalWebhookFilter : WebhookFilterElement {

    int Value {
        get { return Data.HasKey("Value")? Data["Value"] : 0; }
        set { Data["Value"] = value; }
    }

    OrdinalComparisons OrdinalComparison {
        get { return Data.HasKey("OrdinalComparison")? OrdinalComparisons::FromValue(Data["OrdinalComparison"]) : OrdinalComparisons::Equal; }
        set { Data["OrdinalComparison"] = value; }
    }

    OrdinalWebhookFilter(Json::Value@ data, const string &in label) {
        super(data, label);
    }

    int GetValue(PB@ pb) {
        throw("Not implemented - GetValue");
        return 0;
    }

    void DrawSettings() override {
        UI::SetNextItemWidth(60.0f);
        if (UI::BeginCombo("##OrdinalComparison" + label, OrdinalComparisons::ToString(OrdinalComparison))) {
            DrawSelectableOrdinalComparisons({OrdinalComparisons::Equal, OrdinalComparisons::GreaterThan, OrdinalComparisons::LessThan, OrdinalComparisons::GreaterThanOrEqual, OrdinalComparisons::LessThanOrEqual});
            UI::EndCombo();
        }
        UI::SameLine();

        DrawOrdinalValue();
        UI::SameLine();
        
        DrawOrdinalType();
    }

    void DrawOrdinalValue() {
        throw("Not implemented - DrawOrdinalValue");
    }

    void DrawOrdinalType() {
    }

    void DrawSelectableOrdinalComparisons(const array<OrdinalComparisons>@ comparisons) {
        for (uint i = 0; i < comparisons.Length; i++)
        {
            if (UI::Selectable(OrdinalComparisons::ToString(comparisons[i]), OrdinalComparison == comparisons[i]))
            {
                OrdinalComparison = comparisons[i];
                return;
            }
        }
    }

    bool Solve(PB@ pb) override {
        int value = GetValue(pb);
        if (OrdinalComparison == OrdinalComparisons::Equal) {
            return value == Value;
        } else if (OrdinalComparison == OrdinalComparisons::GreaterThan) {
            return value > Value;
        } else if (OrdinalComparison == OrdinalComparisons::LessThan) {
            return value < Value;
        } else if (OrdinalComparison == OrdinalComparisons::GreaterThanOrEqual) {
            return value >= Value;
        } else if (OrdinalComparison == OrdinalComparisons::LessThanOrEqual) {
            return value <= Value;
        }
        return false;
    }
    
}