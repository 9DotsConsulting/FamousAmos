page 50002 "Settlement Mode"
{
    ApplicationArea = All;
    Caption = 'Settlement Mode';
    PageType = List;
    SourceTable = "Settlement Mode";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
