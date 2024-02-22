page 50005 "Purpose Code"
{
    ApplicationArea = All;
    Caption = 'Purpose Code';
    PageType = List;
    SourceTable = "Purpose Code";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Purpose Codes"; Rec."Purpose Codes")
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
