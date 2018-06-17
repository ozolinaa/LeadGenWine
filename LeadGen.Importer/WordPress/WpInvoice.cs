using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Importer.WordPress
{
    public class WpInvoice
    {
        public DateTime createdDateTime { get; set; }
        public decimal invoiceSum { get; set; }
        public DateTime? paidDateTime { get; set; }
        public long[] includedOrders { get; set; }
        public long businessID { get; set; }
        public DateTime forPeriod { get; set; }
        public string serviceItem { get; set; }
        public string feeDescription { get; set; }
        public decimal feeSum { get; set; }

        public int buhNumber { get; set; }
        public int facturaNumber { get; set; }
        public int? actNumber { get; set; }

        public string prodRs { get; set; }
        public string prodName { get; set; }
        public string prodKpp { get; set; }
        public string prodKors { get; set; }
        public string prodInn { get; set; }
        public string prodBik { get; set; }
        public string prodBankName { get; set; }
        public string prodAddress { get; set; }

        public string pokRs { get; set; }
        public string pokName { get; set; }
        public string pokKpp { get; set; }
        public string pokKors { get; set; }
        public string pokInn { get; set; }
        public string pokAddress { get; set; }

        public WpInvoice(WpPost post, Dictionary<long, long> BusinessIdMapping)
        {
            createdDateTime = post.post_date.ToUniversalTime();
            PHPSerializer php = new PHPSerializer();
            dynamic wpOrders = php.Deserialize(post.fields["invoice_orders_included"]);
            ArrayList orderString = wpOrders;
            includedOrders = orderString.ToArray().Select(x=>Convert.ToInt64(x)).ToArray();

            businessID = BusinessIdMapping[Convert.ToInt64(post.fields["invoice_for_user_id"])];

            forPeriod = DateTime.ParseExact(post.fields["invoice_for_period"], "yyyyMMdd", CultureInfo.InvariantCulture).ToUniversalTime();

            buhNumber = Convert.ToInt32(post.fields["invoice_buh_number"]);
            facturaNumber = Convert.ToInt32(post.fields["invoice_factura_number"]);

            if (string.IsNullOrEmpty(post.fields["invoice_act_number"]) == false)
                actNumber = Convert.ToInt32(post.fields["invoice_act_number"]);
            if (string.IsNullOrEmpty(post.fields["invoice_paid_date"]) == false)
                paidDateTime = DateTime.ParseExact(post.fields["invoice_paid_date"], "yyyyMMdd", CultureInfo.InvariantCulture).ToUniversalTime();

            invoiceSum = Convert.ToDecimal(post.fields["invoice_sum"]);
            serviceItem = post.fields["inv_service_item"];

            feeDescription = post.fields["fee_descriptions"];
            if (string.IsNullOrEmpty(post.fields["fee_summ"]) == false)
                feeSum = Convert.ToDecimal(post.fields["fee_summ"]);

            prodRs = post.fields["inv_prod_rs"];
            prodName = post.fields["inv_prod_name"];
            prodKpp = post.fields["inv_prod_kpp"];
            prodKors = post.fields["inv_prod_kors"];
            prodInn = post.fields["inv_prod_inn"];
            prodBik = post.fields["inv_prod_bik"];
            prodBankName = post.fields["inv_prod_bank_name"];
            prodAddress = post.fields["inv_prod_address"];

            pokName = post.fields["inv_pok_name"];
            pokKpp = post.fields["inv_pok_kpp"];
            pokInn = post.fields["inv_pok_inn"];
            pokAddress = post.fields["inv_pok_address"];
        }





    }
}
