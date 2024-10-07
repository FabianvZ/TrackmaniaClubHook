namespace DropDown
{
    string getSelectedOption(string[] options, string selectedOption)
    {
        string result = selectedOption;
        if (UI::BeginCombo("##ComboArgument", selectedOption))
        {
            for (int i = 0; i < options.Length; i++)
            {   
                if (UI::Selectable(options[i], options[i] == selectedOption))
                {
                    result = options[i];
                }
            }
            UI::EndCombo();
        }
        return selectedOption;
    }
}