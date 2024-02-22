table 50003 "Posting Indicator"
{
    Caption = 'Posting Indicator';
    DataClassification = ToBeClassified;
    LookupPageId = 50003;
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
