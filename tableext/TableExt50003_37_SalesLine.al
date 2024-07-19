tableextension 50003 SalesLine extends "Sales Line"
{
    fields
    {
        field(50001; "Item Group No."; Code[20])
        {
            Caption = 'Item Group No.';
            //DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                CommentLine, CommentLine02 : Record "Sales Comment Line";
                SalesLine: Record "Sales Line";
                SalesHeader: Record "Sales Header";
            begin
                CommentLine.reset;
                SalesLine.reset;
                SalesLine.SetRange("Document No.", rec."Document No.");
                SalesLine.SetRange("Item Group No.", rec."Item Group No.");
                if SalesLine.findfirst then begin
                    CommentLine.SetRange("Document Type", SalesLine."Document Type");
                    CommentLine.SetRange("No.", SalesLine."Document No.");
                    CommentLine.SetRange("Document Line No.", SalesLine."Line No.");
                    if CommentLine.findfirst then
                        CommentLine02.CopyLineComments(rec."Document Type", rec."Document Type", CommentLine."No.", Rec."Document No.", CommentLine."Document Line No.", Rec."Line No.");
                end else begin
                    CommentLine.SetRange("Document Type", rec."Document Type");
                    CommentLine.SetRange("No.", rec."Document No.");
                    CommentLine.SetRange("Document Line No.", Rec."Line No.");
                    if CommentLine.FindFirst then
                        CommentLine.DeleteComments(Rec."Document Type", Rec."Document No.")
                    else
                        exit;
                end;


            end;
        }
        field(50002; "Delivery Address"; Text[100])
        {
            Caption = 'Delivery Address';
            TableRelation = "Multiple Delivery Address".Name where("Customer No." = field("Sell-to Customer No."));
        }
        field(50003; "Shipment-Order No."; Code[20])
        {
            //please do not remove - note from Clarissa
            //this is to get the comment line from sales order (posted sales shipment), because if get from posted sales shipment 
            //the commentLine.DocumentNo will be incorrect as user may select more than 1 shipment no and it can lead to missing comment
        }

        field(50100; "Set Indicator"; Code[5])
        {
            Caption = 'Set Indicator';
        }
    }
}
