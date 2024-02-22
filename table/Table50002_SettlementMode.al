table 50002 "Settlement Mode"
{
    Caption = 'Settlement Mode';
    DataClassification = ToBeClassified;
    LookupPageId = 50002;
    fields
    {
        field(1; "Code"; Code[1])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[150])
        {
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
