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
                //SalesHeader.Get();
                SalesLine.reset;
                SalesLine.SetRange("Document No.", rec."Document No.");
                SalesLine.SetRange("Item Group No.", rec."Item Group No.");
                if SalesLine.findfirst then begin
                    CommentLine.SetRange("No.", SalesLine."Document No.");
                    CommentLine.SetRange("Document Line No.", SalesLine."Line No.");
                    CommentLine.FindSet();
                    //repeat
                    CommentLine02.Init();
                    //CommentLine02.Validate("Line No.", CommentLine."Line No.");
                    CommentLine02.validate("Document Line No.", Rec."Line No.");
                    CommentLine02.Insert();
                    //until CommentLine.next = 0;

                    // if CommentLine.Count < 1 then begin
                    //     repeat
                    //         CommentLine02.SetRange("No.", Rec."Document No.");
                    //         //CommentLine02.SetFilter("Line No.", '>10000');
                    //         CommentLine02.findfirst;
                    //         CommentLine02.init;
                    //         CommentLine02.Validate("Line No.", CommentLine."Line No.");
                    //         CommentLine02.Insert();
                    //     until CommentLine.next = 0;
                    // end;

                end;


            end;
        }
        field(50002; "Delivery Address"; Text[100])
        {
            Caption = 'Delivery Address';
            TableRelation = "Multiple Delivery Address".Name where("Customer No." = field("Sell-to Customer No."));
        }
    }
}
