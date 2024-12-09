pageextension 50017 "Physical Inventory Order" extends "Physical Inventory Order"
{
    layout
    {
        addafter(Status)
        {
            field(isPhyInvCOGS; Rec.isPhyInvCOGS)
            {
                ApplicationArea = All;
                trigger OnValidate()
                var
                begin
                    // if Rec.isPhyInvCOGS then begin
                    //     setLinePostingGroups(Rec."No.", Rec.isPhyInvCOGS)
                    // end else
                    //     setLinePostingGroups(Rec."No.", Rec.isPhyInvCOGS);

                    setLinePostingGroups(Rec."No.", Rec.isPhyInvCOGS);

                end;
            }
        }
    }

    actions
    {
        // modify(Post)
        // {
        //     trigger OnBeforeAction()
        //     var

        //     begin

        //     end;

        //     trigger OnAfterAction()
        //     var
        //     begin

        //     end;
        // }
    }

    local procedure setLinePostingGroups(HeaderNo: Code[20]; isPhysInvCOGS: Boolean)
    var
        PhysInvtOrderLine: Record "Phys. Invt. Order Line";
    begin
        PhysInvtOrderLine.SetRange("Document No.", HeaderNo);
        PhysInvtOrderLine.SetRange("Line No.");
        if PhysInvtOrderLine.FindSet() then begin
            repeat
                // if (PhysInvtOrderLine."Gen. Prod. Posting Group" = 'BA') and isPhysInvCOGS then
                //     PhysInvtOrderLine."Gen. Bus. Posting Group" := 'PHYSC'
                // else
                //     PhysInvtOrderLine."Gen. Bus. Posting Group" := '';

                if isPhysInvCOGS then
                    PhysInvtOrderLine."Gen. Bus. Posting Group" := 'PHYSC'
                else
                    PhysInvtOrderLine."Gen. Bus. Posting Group" := '';

                // if PhysInvtOrderLine."Gen. Prod. Posting Group" <> 'BA' then
                //     PhysInvtOrderLine."Gen. Prod. Posting Group" := 'BA';
                PhysInvtOrderLine.Modify();

            until PhysInvtOrderLine.Next() = 0;
        end;
    end;
}
