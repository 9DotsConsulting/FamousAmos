pageextension 50010 "Customer Card Extension" extends "Customer Card"
{
    actions
    {
        addlast(navigation)
        {
            action("Mulitple Delivery Address")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Mulitple Delivery Address';
                Image = ShipAddress;
                ToolTip = 'Where a customer order has requested the delivery to be shipped to multiple addresses, each has to be issued with printed form sales delivery with the delivery address stated .';

                RunObject = Page "Multiple Delivery Address List";
                RunPageLink = "Customer No." = field("No.");
            }
        }

        addlast(Category_Category9)
        {
            actionref("Mulitple Delivery Address_Promoted"; "Mulitple Delivery Address") { }
        }
    }
}
