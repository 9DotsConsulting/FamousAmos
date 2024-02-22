page 50004 "Proxy Type"
{
    ApplicationArea = All;
    Caption = 'Proxy Type';
    PageType = List;
    SourceTable = "Proxy Type";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Type; Rec.Type)
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
