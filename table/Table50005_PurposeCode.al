table 50005 "Purpose Code"
{
    Caption = 'Purpose Code';
    DataClassification = ToBeClassified;
    LookupPageId = 50005;
    fields
    {
        field(1; "Purpose Codes"; Code[4])
        {
            Caption = 'Purpose Codes';
        }
        field(2; Description; Text[150])
        {
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Purpose Codes")
        {
            Clustered = true;
        }
    }
}
