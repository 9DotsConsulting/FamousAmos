tableextension 50013 "Phys. Invt. Order Header" extends "Phys. Invt. Order Header"
{
    fields
    {
        field(50001; "isPhyInvCOGS"; Boolean)
        {
            InitValue = false;
            Caption = 'Enable Phy. Inv COGS posting account';
            DataClassification = ToBeClassified;
        }
    }
}
