pageextension 50002 PostedSalesInvoicePage extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Work Description")
        {
            field("Deliver On"; rec."Deliver On")
            {
                ApplicationArea = All;
                Visible = true;
                MultiLine = true;
                //Editable = true;
            }
        }
        modify("Work Description")
        {
            Visible = false;
        }
        //pageexts/PageExt50002_132 PostedSalesInvoicePage.al (21,36) - Error AL0275: 'Ship-to Phone No.' 
        // is an ambiguous reference between 'Ship-to Phone No.' defined by the extension 'Base Application by Microsoft 
        // (25.2.26921.0)' and 'Ship-to Phone No.' defined by the extension 'FamousAmos by 9Dots (1.0.0.2)'. 
        // addafter("Ship-to Contact")
        // {
        //     field("Phone No."; rec."Ship-to Phone No.") //
        //     {
        //         ApplicationArea = All;
        //     }
        // }
    }



    //=========================================================================//
    //Transfer customization to Posted Sales Invoice Page
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
    begin

        SetIndicator(Rec."Sell-to Customer No.", Rec."No.");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
    begin

        SetIndicator(Rec."Sell-to Customer No.", Rec."No.");
    end;

    trigger OnModifyRecord(): Boolean
    var
    begin

        SetIndicator(Rec."Sell-to Customer No.", Rec."No.");
    end;

    trigger OnOpenPage()
    var
    begin

        SetIndicator(Rec."Sell-to Customer No.", Rec."No.");
    end;

    /*
        //Get total loop based on total number of lines
        local procedure GetTotalLoop(DocType: Text; DocNo: Code[20]): Integer
        var
            SIL: Record "Sales Line";
            TotalLines: Integer;
        begin
            SIL.Reset();
            TotalLines := 0;
            SIL.SetFilter("Document Type", DocType);
            SIL.SetFilter("Document No.", DocNo);
            if SIL.FindSet() then begin
                repeat
                    TotalLines := TotalLines + 1;
                until SIL.Next() = 0;
                exit(TotalLines);
            end;
            exit(0);

        end;
    */

    //Set the indicator for each line based on current line filter keys
    local procedure SetIndicator(SellToCustNo: Code[20]; DocNo: Code[20])
    var
        SIL: Record "Sales Invoice Line";
        OuterSIL: Record "Sales Invoice Line";
        Count: Integer;

        GLNo: Text;
        ItemGroupNo: Code[20];
        UnitPrice: Decimal;
    begin
        //SIL.Reset();
        //SIL.SetFilter("Document Type", DocType);
        //SIL.SetFilter("Document No.", DocNo);
        OuterSIL.Reset();
        OuterSIL.SetFilter("Sell-to Customer No.", SellToCustNo);
        OuterSIL.SetFilter("Document No.", DocNo);
        OuterSIL.SetRange("Line No.");
        Count := 0;
        if OuterSIL.FindSet() then begin
            repeat
                SIL.Reset();
                SIL.SetFilter("Sell-to Customer No.", SellToCustNo);
                SIL.SetFilter("Document No.", DocNo);
                SIL.SetRange("Line No.");

                //Get filter value for GLNo, ItemGroupNo, Unit Price here
                GLNo := Format(OuterSIL."No.");
                ItemGroupNo := OuterSIL."Item Group No.";
                UnitPrice := OuterSIL."Unit Price";
                Count := Count + 1;

                if SIL.FindSet() then begin
                    repeat
                        //Put filter here and assign value to relevant lines

                        if (GLNo = Format(SIL."No.")) and (ItemGroupNo = SIL."Item Group No.") and (UnitPrice = SIL."Unit Price") then begin
                            SIL."Set Indicator" := Format(Count);
                            //Message(Format(SIL."Line No.") + '' + Format(Count));
                            //SIL.Modify(false);
                        end;
                    until SIL.Next() = 0;
                end;
            until OuterSIL.next() = 0;
            //SIL.Modify(false);
        end;
    end;
    //=========================================================================//

}
