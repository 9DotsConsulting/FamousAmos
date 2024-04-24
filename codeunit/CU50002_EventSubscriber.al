codeunit 50002 "DOT Subscribers"
{
    Permissions = tabledata "Sales Shipment Header" = rmid,
                    tabledata "Sales Shipment Line" = rmid;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", OnBeforeRunSalesPost, '', false, false)]
    local procedure "Sales-Post (Yes/No)_OnBeforeRunSalesPost"(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; var SuppressCommit: Boolean)
    var
        NoOfShip, CreateShip : Integer;
        SalesLine, SalesLine02 : record "Sales Line";
        SHAddress: text;
        DlvAddress: array[5] of Text;
        DlvAddr: text;
        DuplicatesFilter: text[100];
        Description: text[100];
    begin
        SO := SalesHeader."No.";
        SHAddress := SalesHeader."Sell-to Customer Name";
        DuplicatesFilter := '';
        Description := '';

        if SalesHeader."Document Type" = "Sales Document Type"::Order then begin
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.Count < 1 then begin
                exit;
            end;

            if SalesHeader."No. Series" = 'SO-CORP' then begin
                // Need to add additional handling such as posting Ship + Invoice and Invoice
                IsHandled := true; //else (CORP) use multiple posting
                                   // Loop 3 times, but you will need to find and calculate how many different Shipping Address
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                // //SalesLine.SetRange("Delivery Address", SalesHeader."Ship-to Address");

                SalesLine.SetCurrentKey("Delivery Address");
                SalesLine.Ascending(true);
                if SalesLine.findset then
                    repeat
                        if Description <> SalesLine."Delivery Address" then begin
                            SalesLine.SetFilter("Delivery Address", '<>%1', SHAddress);
                            SalesLine02.reset;
                            SalesLine02.SetRange("Delivery Address", SalesLine."Delivery Address");
                            if SalesLine02.count > 1 then begin
                                Description := SalesLine."Delivery Address";
                                if DuplicatesFilter = '' then
                                    DuplicatesFilter := SalesLine."Delivery Address"
                                else
                                    DlvAddr := SalesLine."Delivery Address";
                            end;
                            NoOfShip += 1;
                        end;
                    until SalesLine.next = 0;
                //if (DuplicatesFilter <> '') AND (DlvAddr <> '') then NoOfShip := SalesLine.count;
                repeat
                    SalesPost.Run(SalesHeader);
                    NoOfShip -= 1;
                until NoOfShip = 0;
            end else
                exit;
        end else
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostLines, '', false, false)]
    local procedure "Sales-Post_OnBeforePostLines"(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary)
    var
        TempSalesLine, NextSalesLine : Record "Sales Line";
        SalesShptLine: Record "Sales Shipment Line";
        SalesShptHeader: record "Sales Shipment Header";
    begin

        if SalesHeader."Document Type" = "Sales Document Type"::Order then begin
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.Count < 1 then begin
                exit;
            end;
            if SalesHeader."No. Series" = 'SO-CORP' then begin
                // TempSalesLine is to copy from SalesLine record
                TempSalesLine.SetRange("Document Type", SalesLine."Document Type");
                TempSalesLine.SetRange("Document No.", SalesLine."Document No.");
                // We do not want SalesLine that is without Qty. to Ship
                TempSalesLine.SetFilter("Qty. to Ship", '<>%1', 0);
                TempSalesLine.FindFirst();

                // We create NextSalesLine is to compare TempSalesLine and NextSalesline if they are the same delivery address
                TempSalesLine.Next();
                NextSalesLine := TempSalesLine;
                // Set TempSalesLine back to first record
                // TempSalesLine.FindFirst(); //this is not working correctly if 1st and 2nd line same delivery address
                TempSalesLine.findlast(); //this is not working correctly if 1st and last line same delivery address - current use

                // If TempSalesLine and NextSalesLine has different data, then filter SalesLine
                if TempSalesLine."Delivery Address" <> NextSalesLine."Delivery Address" then begin
                    // When you filter SalesLine, the standard Post event will post this filtered result
                    SalesLine.SetRange("Delivery Address", TempSalesLine."Delivery Address");
                    SalesLine.SetFilter("Qty. to Ship", '<>%1', 0);
                    SalesLine.FindSet();
                end;
            end else
                exit;
        end else if SalesHeader."Document Type" = "Sales Document Type"::Invoice then begin
            if SalesHeader."Posting No. Series" = 'S-INV' then begin
                exit;
            end else begin
                SalesLine.SetFilter("Shipment No.", '<>%1', '');
                SalesLine.SetFilter("Qty. to Invoice", '<>%1', 0);
                if SalesLine.FindSet() then begin
                    repeat
                        SalesShptHeader.SetRange("No.", SalesLine."Shipment No.");
                        SalesShptHeader.findset;
                        SalesShptHeader."Ship-to Code" := '';
                        SalesShptHeader.modify;
                    until SalesLine.next = 0;
                end;
            end;
        end else
            exit;

        //notes : // If TempSalesLine and NextSalesLine has different data, then filter SalesLine
        //if TempSalesLine."Shortcut Dimension 1 Code" <> NextSalesLine."Shortcut Dimension 1 Code" then begin
        // SalesShptLine.SetRange("Order No.", SalesLine."Document No.");
        // SalesShptLine.SetRange("No.", SalesLine."No.");
        // if SalesShptLine.FindSet() then begin
        //     SalesLine.SetRange("Delivery Address", TempSalesLine."Delivery Address");
        //     SalesLine.FindSet();
        // end;
        // if TempSalesLine."Delivery Address" <> NextSalesLine."Delivery Address" then begin
        //     //SalesShptHeader.SetRange("Ship-to Name", SalesLine."Delivery Address");
        //     // When you filter SalesLine, the standard Post event will post this filtered result
        //     //SalesLine.SetRange("Shortcut Dimension 1 Code", TempSalesLine."Shortcut Dimension 1 Code");
        //     SalesShptHeader.SetRange("Order No.", TempSalesLine."Document No.");
        //     if SalesShptHeader.findfirst then begin
        //         // SalesShptHeader."Delivery Address" := SalesLine."Delivery Address";
        //         // SalesShptHeader.modify;
        //         SalesLine.SetRange("Delivery Address", SalesShptHeader."Ship-to Name");
        //         SalesLine.FindSet();
        //     end;
        //     //end;
        //     //     if TempSalesLine."Delivery Address" = NextSalesLine."Delivery Address" then begin
        //     //         SalesLine.SetRange("Delivery Address", TempSalesLine."Delivery Address");
        //     //         SalesLine.FindSet();
        //end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesLines, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesLines"(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; WhseShip: Boolean; WhseReceive: Boolean; var SalesLinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingInvoiced: Boolean; var TempSalesLineGlobal: Record "Sales Line" temporary)
    var
        MultiAddress: record "Multiple Delivery Address";
        SalesShptLine: record "Sales Shipment Line";
    begin
        if SalesHeader."Document Type" = "Sales Document Type"::Order then begin
            SalesShptLine.SetRange("Document No.", SalesShipmentHeader."No.");
            if SalesShptLine.Count < 1 then begin
                exit;
            end;

            if SalesHeader."No. Series" = 'SO-CORP' then begin
                TempSalesLineGlobal.SetFilter("Qty. to Ship", '<>%1', 0);
                TempSalesLineGlobal.FindFirst();
                MultiAddress.SetRange(Name, TempSalesLineGlobal."Delivery Address");
                MultiAddress.FindFirst();
                SalesShipmentHeader."Ship-to Name" := TempSalesLineGlobal."Delivery address";
                SalesShipmentHeader."Ship-to Code" := MultiAddress.Code;
                SalesShipmentHeader."Ship-to Address" := MultiAddress.Address;
                SalesShipmentHeader.Modify();

                SalesShptLine.SetRange("Document No.", SalesShipmentHeader."No.");
                SalesShptLine.SetFilter(Quantity, '=%1', 0);
                if SalesShptLine.findset then
                    repeat
                        SalesShptLine.Delete(true);
                    until SalesShptLine.next = 0;
            end else
                exit;
            // end else if SalesHeader."Document Type" = "Sales Document Type"::Invoice then begin
            //     TempSalesLineGlobal.SetFilter("Qty. to Invoice", '<>1', 0);
            //     TempSalesLineGlobal.FindFirst();
            //     MultiAddress.SetRange(Name, TempSalesLineGlobal."Delivery Address");
            //     MultiAddress.FindFirst();
            //     //SalesShipmentHeader."Ship-to Name" := TempSalesLineGlobal."Delivery address";
            //     SalesShipmentHeader."Ship-to Code" := MultiAddress.Code;
            //     //SalesShipmentHeader."Ship-to Address" := MultiAddress.Address;
            //     SalesShipmentHeader.Modify();

            //     SalesShptLine.SetRange("Document No.", SalesShipmentHeader."No.");
            //     SalesShptLine.SetFilter(Quantity, '=%1', 0);
            //     if SalesShptLine.findset then
            //         repeat
            //             SalesShptLine.Delete(true);
            //         until SalesShptLine.next = 0;
        end else
            exit;
    end;


    var
        SalesPost: Codeunit "Sales-Post";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SO, SI : text;
        ok: Boolean;
}