// reportextension 50005 "DOT Sales Invoice" extends "Standard Sales - Invoice"
// {
//     dataset
//     {
//         add(Header)
//         {
//             column(CompanyLogo; CI.Picture) { }
//             column(City; CI.City) { }
//             column(PostCode; CI."Post Code") { }
//             column(Phone_No; CI."Phone No.") { }
//             column(CoRegNo; CI."Registration No.") { }
//             column(VAT_Registration_No_; CI."VAT Registration No.") { }
//             column(Deliver_On; "Deliver On") { }
//             column(Salesperson_Code; "Salesperson Code") { }
//         }
//         add(Line)
//         {
//             column(Comments; Comments) { }
//             column(RunningNo; RunningNo) { }
//         }
//         modify(Line)
//         {
//             trigger OnAfterAfterGetRecord()
//             begin
//                 CrLf[1] := 13;
//                 CrLf[2] := 10;
//                 lrInvoiceLine := Line;
//                 if "Line No." < CountNo then
//                     RunningNo := 0;
//                 if (Type.AsInteger() <> 0) and (lrInvoiceLine."Line No." > 0) then begin
//                     RunningNo += 1;
//                     //CountNo := "Line No." + RunningNo;
//                 end;
//                 CommentLine.reset;
//                 CommentLine.SetRange("No.", Line."Document No.");
//                 CommentLine.SetRange("Document Line No.", Line."Line No.");
//                 CommentLine.SetFilter("Document Type", 'Invoice');
//                 if CommentLine.findset then
//                     repeat
//                         Comments := CommentLine.Comment + CrLf + Comments;
//                     until CommentLine.next = 0;
//             end;
//         }
//     }

//     requestpage
//     {
//         // Add changes to the requestpage here
//     }

//     rendering
//     {
//         layout("Famous Amos - Sales Invoice")
//         {
//             Type = RDLC;
//             LayoutFile = './reportextlayout/ReportExt50005_1306_SalesInvoice.rdlc';
//         }
//     }
//     trigger OnPreReport()
//     begin
//         CI.Get;
//         CI.CalcFields(Picture);
//     end;

//     var
//         CI: Record "Company Information";
//         FormatAddress: Codeunit "Format Address";
//         CustAddrShipTo, ShipToAddrTest : array[8] of text[100];
//         RunningNo, CountNo : Integer;
//         lrInvoiceLine: record "Sales Invoice Line";
//         Comments: text;
//         CommentLine: record "Sales Comment Line";
//         CrLf: text[2];
// }