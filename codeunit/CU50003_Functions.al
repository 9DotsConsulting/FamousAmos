codeunit 50003 "DOT Function"
{
    Permissions = tabledata "Sales Shipment Header" = rmid,
                    tabledata "Sales Shipment Line" = rmid,
                    tabledata "Sales Comment Line" = rmid;
    // procedure CreatePostedSalesShipmentsFromSalesOrder(var SalesOrderHeader: Record "Sales Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    // var
    //     SalesOrderLine: Record "Sales Line";
    //     SalesShipmentLine: Record "Sales Shipment Line";
    // begin
    //     // Find sales orders that meet your criteria
    //     //SalesOrderHeader.SETRANGE("Status", SalesOrderHeader.Status::"Released");
    //     if SalesOrderHeader."Completely Shipped" = false then begin
    //         //if SalesOrderHeader.FINDSET then begin
    //         //repeat
    //         // For each released sales order, create a posted sales shipment
    //         SalesShipmentHeader.INIT;
    //         SalesShipmentHeader."Order No." := SalesOrderHeader."No.";
    //         // Populate other necessary fields in the sales shipment header

    //         // Insert the sales shipment header
    //         SalesShipmentHeader.INSERT(true);

    //         // Find sales lines for the current sales order
    //         SalesOrderLine.SETRANGE("Document Type", SalesOrderLine."Document Type"::Order);
    //         SalesOrderLine.SETRANGE("Document No.", SalesOrderHeader."No.");
    //         if SalesOrderLine.FINDSET then begin
    //             repeat
    //                 // For each sales line, create a corresponding sales shipment line
    //                 SalesShipmentLine.INIT;
    //                 //SalesShipmentLine."Document Type" := SalesShipmentHeader."Document Type"::Order;
    //                 SalesShipmentLine."Document No." := SalesShipmentHeader."No.";
    //                 // Populate other necessary fields in the sales shipment line
    //                 // Transfer relevant data from the sales order line to the sales shipment line
    //                 //SalesShipmentLine."Delivery Address" := SalesOrderLine."Delivery Address"; // Set delivery address from sales order line

    //                 // Insert the sales shipment line
    //                 SalesShipmentLine.INSERT();
    //             until SalesOrderLine.NEXT = 0;
    //         end;

    //         // Post the sales shipment
    //         //SalesShipmentHeader.post;
    //         //until SalesOrderHeader.NEXT = 0;
    //     end;
    //     //Message('%1', SalesOrderHeader."No.");
    // end;

    // procedure InsertShipmentLineFromSalesLine(var SalesShptLine: Record "Sales Shipment Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; SalesShptHeader: Record "Sales Shipment Header")
    // var
    //     recSSH: Record "Sales Shipment Header";
    // begin
    //     //Message('%1', SalesShptHeader."No.");
    //     recSSH.SetRange("No.", SalesShptHeader."No.");
    //     recSSH.SetRange("Order No.", SalesLine."Document No.");
    //     recSSH.SetRange("Ship-to Name", SalesLine."Delivery Address");
    //     if recSSH.FindFirst then begin
    //         repeat
    //             //SalesShptLine
    //             Message('Line no: %1- shipment line %2', SalesLine."Line No.", SalesShptLine."Order No.");
    //             //SalesShptLine.TransferFields(SalesLine);
    //             SalesShptLine.Insert();
    //         until recSSH.next = 0;
    //     end else begin
    //         Message('%1', SalesShptHeader."Ship-to Address");
    //         CreatePostedSalesShipmentsFromSalesOrder(SalesHeader, SalesShptHeader);
    //     end;
    // end;

    trigger OnRun()
    var
        CommentLine: Record "Sales Comment Line";
    begin
        // CommentLine.Reset();
        // CommentLine.SetRange("No.", 'INV-C2404-0002');
        // CommentLine.SetFilter("Document Type", 'Invoice');
        // if CommentLine.FindSet() then
        //     repeat
        //         CommentLine.Delete();
        //     until CommentLine.next = 0;
    end;
}