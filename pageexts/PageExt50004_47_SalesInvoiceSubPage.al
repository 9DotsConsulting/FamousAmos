pageextension 50004 SalesInvoiceSubPage extends "Sales Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Item Group No."; Rec."Item Group No.")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Line no"; Rec."DOT Line No.")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }

    //=========================================================================//
    //Transfer customization to Posted Sales Invoice Page
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
    begin
        //SetIndicator(Format(Rec."Document Type"), Rec."Document No.");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
    begin
        //SetIndicator(Format(Rec."Document Type"), Rec."Document No.");
    end;

    trigger OnModifyRecord(): Boolean
    var
    begin
        //SetIndicator(Format(Rec."Document Type"), Rec."Document No.");
    end;

    trigger OnOpenPage()
    var
    begin
        //SetIndicator(Format(Rec."Document Type"), Rec."Document No.");
    end;

    /*
        //Get total loop based on total number of lines
        local procedure GetTotalLoop(DocType: Text; DocNo: Code[20]): Integer
        var
            SL: Record "Sales Line";
            TotalLines: Integer;
        begin
            SL.Reset();
            TotalLines := 0;
            SL.SetFilter("Document Type", DocType);
            SL.SetFilter("Document No.", DocNo);
            if SL.FindSet() then begin
                repeat
                    TotalLines := TotalLines + 1;
                until SL.Next() = 0;
                exit(TotalLines);
            end;
            exit(0);

        end;
    */

    //Set the indicator for each line based on current line filter keys
    local procedure SetIndicator(DocType: Text; DocNo: Code[20])
    var
        SL: Record "Sales Line";
        OuterSL: Record "Sales Line";
        Count: Integer;

        GLNo: Integer;
        ItemGroupNo: Code[20];
        UnitPrice: Decimal;
    begin
        //SL.Reset();
        //SL.SetFilter("Document Type", DocType);
        //SL.SetFilter("Document No.", DocNo);
        OuterSL.Reset();
        OuterSL.SetFilter("Document Type", DocType);
        OuterSL.SetFilter("Document No.", DocNo);
        Count := 0;
        if OuterSL.FindSet() then begin
            repeat
                SL.Reset();
                SL.SetFilter("Document Type", DocType);
                SL.SetFilter("Document No.", DocNo);

                //Get filter value for GLNo, ItemGroupNo, Unit Price here
                GLNo := OuterSL."Line No.";
                ItemGroupNo := OuterSL."Item Group No.";
                UnitPrice := OuterSL."Unit Price";
                Count := Count + 1;

                if SL.FindSet() then begin
                    repeat
                        //Put filter here and assign value to relevant lines

                        if (GLNo = SL."Line No.") and (ItemGroupNo = SL."Item Group No.") and (UnitPrice = SL."Unit Price") then begin
                            SL."Set Indicator" := Format(Count);
                            //SL.Modify(false);
                        end;
                    until SL.Next() = 0;
                end;
            until OuterSL.next() = 0;
        end;
    end;
    //=========================================================================//
}
