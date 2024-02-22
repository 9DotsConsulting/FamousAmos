page 50001 "Service Code"
{
    ApplicationArea = All;
    Caption = 'Service Code';
    PageType = List;
    SourceTable = "Service Code";
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
