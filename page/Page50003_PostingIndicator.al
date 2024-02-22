page 50003 "Posting Indicator"
{
    ApplicationArea = All;
    Caption = 'Posting Indicator';
    PageType = List;
    SourceTable = "Posting Indicator";
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
