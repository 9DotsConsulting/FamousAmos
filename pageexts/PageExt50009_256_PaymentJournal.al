pageextension 50009 PaymentJournal extends "Payment Journal"
{
    //add new customized fields
    layout
    {
        addafter("Bal. Account No.")
        {
            field("Service Code"; Rec."Service Code")
            {
                ApplicationArea = all;
                TableRelation = "Service Code".Code;
            }
            field("Settlement Mode"; Rec."Settlement Mode")
            {
                ApplicationArea = all;
                TableRelation = "Settlement Mode".Code;
            }
            field("Posting Indicator"; Rec."Posting Indicator")
            {
                ApplicationArea = all;
                TableRelation = "Posting Indicator".Code;
            }
            field("Payroll Proxy Type"; Rec."Payroll Proxy Type")
            {
                ApplicationArea = all;
                TableRelation = "Proxy Type".Type;
            }
            field("Purpose Code"; Rec."Purpose Code")
            {
                ApplicationArea = all;
                TableRelation = "Purpose Code"."Purpose Codes";
            }
            field("Proxy ID"; Rec."Proxy ID")
            {
                ApplicationArea = all;
            }
        }
    }
    //add new action for creating payment file


    actions
    {
        //Need to chance button to a better spot
        addafter(Reconcile)
        {
            action(GenerateCIMBPaymentFile) //Bank Payment file export to .txt
            {
                Caption = 'Create Payment File (CIMB)';
                Ellipsis = true;
                Image = Export;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Start the process of generating the CIMB Payment file.';
                ApplicationArea = All;
                trigger OnAction()
                var
                    ExportCodeUnit: Codeunit BankExportGIROFAST;
                    lrGJL: Record "Gen. Journal Line";
                    SelFileType: Record "Gen. Journal Line";

                begin

                    SelFileType.SETRANGE("Journal Template Name", rec."Journal Template Name");
                    SelFileType.SETRANGE("Journal Batch Name", rec."Journal Batch Name");

                    //Need to set based on Payment type - GIRO FAST PayNowGIRO PayNowFast
                    //if (SelFileType."Payment Method Code" = 'DUITNOW') or (SelFileType."Payment Method Code" = 'IT') then
                    ExportCodeUnit.GenerateTextFile(rec);

                    ////////////////
                    //else
                    //if (SelFileType."Payment Method Code" = 'TT') or (SelFileType."Payment Method Code" = 'RENTAS') or (SelFileType."Payment Method Code" = 'IBG') or (SelFileType."Payment Method Code" = 'IAFT') then
                    //ExportCodeUnitUFF.GenerateTextFile(rec);

                    ////////////////
                    lrGJL.SETRANGE("Journal Template Name", rec."Journal Template Name");
                    lrGJL.SETRANGE("Journal Batch Name", rec."Journal Batch Name");
                    if lrGJL.findfirst then
                        repeat
                            ///lrGJL."DOT Generated" := true;
                            //lrGJL."DOT Status" := lrGJL."DOT Status"::Sent;
                            lrGJL.modify(false);
                        until lrGJL.next = 0;
                end;
            }
        }
    }


}
