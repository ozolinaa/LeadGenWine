using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LeadGen.Code;
using LeadGen.Code.Taxonomy;
using LeadGen.Code.CMS;
using LeadGen.Code.Sys;
using LeadGen.Importer.EPESI;
using LeadGen.Importer.WordPress;
using System.Net.Http;
using System.IO;
using LeadGen.Code.Business;
using LeadGen.Code.Helpers;
using LeadGen.Code.Lead;
using System.Data;
using System.Globalization;
using LeadGen.Code.Business.Inovice;
using System.Collections;

namespace LeadGen.Importer
{
    public class Importer : IDisposable
    {
        public SqlConnection con;

        public Importer()
        {
            con = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
            con.Open();
        }


        public void ImportTaxonomyCity()
        {
            Console.WriteLine("Starting City Taxonomy Import...");

            List<WpTerm> terms = new List<WpTerm>();
            using (WordPressClient wp = new WordPressClient())
            {
                terms.AddRange(wp.LoadCityTaxonomy());
                terms.AddRange(wp.LoadKladCityTaxonomy());
                Console.WriteLine("Processing City Taxonomy...");
            }

            int leadGenCityTaxonomyID = Code.Taxonomy.Taxonomy.SelectFromDB(con, TaxonomyCode: "city").First().ID;
            foreach (WpTerm wpterm in terms)
            {
                Term newTerm = ImportTerm(wpterm, leadGenCityTaxonomyID, "russia");
            }
        }

        public void ImportTaxonomyCMSCategory()
        {
            Console.WriteLine("Starting CMS Categoy Taxonomy...");

            List<WpTerm> terms = null;
            using (WordPressClient wp = new WordPressClient())
            {
                terms = wp.LoadCMSCategoryTaxonomy();
                Console.WriteLine("Processing CMS Categoy Taxonomy...");
            }

            int cmsCatTaxonomyID = Taxonomy.SelectFromDB(con, TaxonomyCode: "cms_category").First().ID;
            foreach (WpTerm wpterm in terms)
            {
                Term newTerm = ImportTerm(wpterm, cmsCatTaxonomyID);
            }
        }

        public void ImportTaxonomyCMSTag()
        {
            Console.WriteLine("Starting CMS Tag Taxonomy...");
            List<WpTerm> terms = null;
            using (WordPressClient wp = new WordPressClient())
            {
                terms = wp.LoadCMSTagTaxonomy();
                Console.WriteLine("Processing CMS Tag Taxonomy...");
            }

            int cmsTagTaxonomyID = Taxonomy.SelectFromDB(con, TaxonomyCode: "cms_tag").First().ID;
            foreach (WpTerm wpterm in terms)
            {
                Term newTerm = ImportTerm(wpterm, cmsTagTaxonomyID);
            }
        }

        public void ImportTaxonomyPamTag()
        {
            Console.WriteLine("Starting Pam Tag Taxonomy...");
            List<WpTerm> terms = null;
            using (WordPressClient wp = new WordPressClient())
            {
                terms = wp.LoadPamTagTaxonomy();
                Console.WriteLine("Processing Pam Tag Taxonomy...");
            }

            int pamTagTaxonomyID = Taxonomy.SelectFromDB(con, TaxonomyCode: "cms_pam_tag").First().ID;
            foreach (WpTerm wpterm in terms)
            {
                Term newTerm = ImportTerm(wpterm, pamTagTaxonomyID);
            }
        }




        public void SyncCrmCompaniesEPESICompanies()
        {
            List<Company> companies = null;
            string epesiConnectionString = ConfigurationManager.ConnectionStrings["IzgPam_EPESI"].ConnectionString;
            Dictionary<string, int> epesiGroupMapping = new Dictionary<string, int>() {
                { "ru_regions", 667 }, { "by_regions", 957 }, { "ua_regions", 1060 }, { "group", 645 }, { "company_type", 671 }
            };

            using (Client client = new Client(epesiConnectionString, epesiGroupMapping))
            {
                companies = client.CompanySelect();
            }

            Dictionary<string, Dictionary<long, long>> businessOldIdMappingByCountry = new Dictionary<string, Dictionary<long, long>>();
            businessOldIdMappingByCountry.Add("ru", BusinessSelectOldIds(con, 1));
            businessOldIdMappingByCountry.Add("ua", BusinessSelectOldIds(con, 2));
            businessOldIdMappingByCountry.Add("by", BusinessSelectOldIds(con, 3));

            foreach (Company company in companies)
            {
                bool result = SyncCrmCompanyWithPost(company, businessOldIdMappingByCountry);
                Console.WriteLine(result + " - " + company.ToString());
            }
        }

        public void ImportPostsMasterData()
        {
            Console.WriteLine("ImportMasterPostsData...");
            List<WpPost> wpMasters = null;
            Dictionary<string,WpPost> wpAttachments = null;
            List<WpTerm> wpPhotoAdditionTaxonomy = null;
            List<WpTerm> wpPhotoMaterialTaxonomy = null;
            List<WpTerm> wpPhotoShapeTaxonomy = null;
            List<WpTerm> wpPhotoPriceTaxonomy = null;

            using (WordPressClient wp = new WordPressClient())
            {
                wpMasters = wp.LoadMasterPosts();
                wpAttachments = wp.LoadAttachmentPosts();
                wpPhotoAdditionTaxonomy = wp.LoadPhotoAdditionTaxonomy();
                wpPhotoMaterialTaxonomy = wp.LoadPhotoMaterialTaxonomy();
                wpPhotoShapeTaxonomy = wp.LoadPhotoShapeTaxonomy();
                wpPhotoPriceTaxonomy = wp.LoadPhotoPriceTaxonomy();
            }

            //Import photo terms
            Taxonomy photoAdditionTaxonomy = Taxonomy.SelectFromDB(con, TaxonomyCode: "photo_accessories").First();
            Taxonomy photoMaterialTaxonomy = Taxonomy.SelectFromDB(con, TaxonomyCode: "photo_material").First();
            Taxonomy photoShapeTaxonomy = Taxonomy.SelectFromDB(con, TaxonomyCode: "photo_shape").First();
            Taxonomy photoPriceTaxonomy = Taxonomy.SelectFromDB(con, TaxonomyCode: "photo_price_range").First();
            wpPhotoAdditionTaxonomy.ForEach(x => ImportTerm(x, photoAdditionTaxonomy.ID));
            wpPhotoShapeTaxonomy.ForEach(x => ImportTerm(x, photoShapeTaxonomy.ID));
            wpPhotoMaterialTaxonomy.ForEach(x => ImportTerm(x, photoMaterialTaxonomy.ID));
            wpPhotoPriceTaxonomy.ForEach(x => ImportTerm(x, photoPriceTaxonomy.ID));

            List<Taxonomy> photoTaxonomies = new List<Taxonomy>() { photoAdditionTaxonomy , photoMaterialTaxonomy , photoShapeTaxonomy , photoPriceTaxonomy };
            photoTaxonomies.ForEach(x => x.LoadTerms(con));
            
            foreach (WpPost wpMaster in wpMasters)
            {
                //Populate wpMasters With AttachmentDetails
                foreach (string attachmentUrl in wpMaster.attachments.Keys.ToArray())
                {
                    if (wpAttachments.ContainsKey(attachmentUrl))
                    {
                        wpMaster.attachments[attachmentUrl] = wpAttachments[attachmentUrl];
                    }
                }

                UpdateMasterPost(wpMaster, photoTaxonomies);
            }
        }

        public void ImportPostsArticle()
        {
            Console.WriteLine("Import PamArticles...");
            List<WpPost> pamPosts = null;
            using (WordPressClient wp = new WordPressClient())
            {
                pamPosts = wp.LoadArticlePosts();
            }

            foreach (WpPost articlePost in pamPosts)
            {
                ImportArticlePost(articlePost);
            }
        }

        public void ImportPages()
        {
            Console.WriteLine("Starting Importing Pages...");
            List<WpPost> pagePosts = new List<WpPost>();
            using (WordPressClient wp = new WordPressClient())
            {
                pagePosts = wp.LoadPages();
            }

            foreach (WpPost pagePost in pagePosts)
            {
                ImportPagePost(pagePost);
            }
        }

        public void ImportPostsKlad()
        {
            Console.WriteLine("Import KladPosts...");
            List<WpPost> kladPosts = null;
            using (WordPressClient wp = new WordPressClient())
            {
                kladPosts = wp.LoadKladPosts();
            }
            foreach (WpPost kladPost in kladPosts)
            {
                ImportKladPost(kladPost);
            }
        }

        public void ImportPostsPam()
        {
            Console.WriteLine("Import Pam Posts...");
            List<WpPost> pamPosts = null;
            using (WordPressClient wp = new WordPressClient())
            {
                pamPosts = wp.LoadPamPosts();
            }

            foreach (WpPost kladPost in pamPosts)
            {
                ImportPamPost(kladPost);
            }
        }

        public void ImportBusinesses(long countryID, string prefix = "")
        {
            Console.WriteLine("Importing Businesses...");

            List<WpBusiness> businesses = null;
            using (WordPressClient wp = new WordPressClient())
            {
                businesses = wp.LoadBusinesses(prefix);
            }

            List<Business> existingBusineses = Business.SelectFromDB(con).ToList();
            foreach (WpBusiness business in businesses)
            {
                Console.WriteLine("Importing WpBusiness ID:{0} Nane:{1}", business.ID, business.public_company_name);
                ImportBusiness(business, countryID, existingBusineses);
            }
        }

        public void ImportLeads(long countryID)
        {
            Console.WriteLine("Importing Leads...");

            string prefix;

            switch (countryID)
            {
                case 2:
                    prefix = "ua";
                    break;
                case 3:
                    prefix = "by";
                    break;
                default:
                    prefix = "";
                    break;
            }

            
            Dictionary<long, long> businessOldIdMapping = BusinessSelectOldIds(con, countryID);
            List<Term> cityTerms = Term.SelectFromDB(con, TaxonomyCode: "city");
            List<Term> priceTerms = Term.SelectFromDB(con, TaxonomyCode: "monument_price_range");
            List<Term> shapeTerms = Term.SelectFromDB(con, TaxonomyCode: "monument_shape");
            List<Term> materialTerms = Term.SelectFromDB(con, TaxonomyCode: "monument_material");
            List<Term> accessoriesTerms = Term.SelectFromDB(con, TaxonomyCode: "monument_accessories");
            List<Term> businessTypeTerms = Term.SelectFromDB(con, TaxonomyCode: "monument_business_type");


            List<WpPost> leads = new List<WpPost>();
            using (WordPressClient wp = new WordPressClient())
            {
                Console.WriteLine("Loading Published Leads");
                List<WpPost> leadsPublished = wp.LoadLeadPosts("publish", prefix);
                Console.WriteLine("Loading Draft Leads");
                List<WpPost> leadsDraft = wp.LoadLeadPosts("draft", prefix);
                Console.WriteLine("Loading Pending Leads");
                List<WpPost> leadsPending = wp.LoadLeadPosts("pending", prefix);

                leads.AddRange(leadsPublished);
                leads.AddRange(leadsDraft);
                leads.AddRange(leadsPending);

                foreach (WpPost lead in leads)
                {
                    lead.LoadMetaData(wp.conn, prefix);

                    if (leadsPublished.Contains(lead))
                        lead.fields.Add("status", "publish");

                    if (leadsDraft.Contains(lead))
                        lead.fields.Add("status", "draft");

                    if (leadsPending.Contains(lead))
                        lead.fields.Add("status", "pending");

                    //try
                    //{
                        ImportLead(lead, businessOldIdMapping, cityTerms, priceTerms, shapeTerms, materialTerms, accessoriesTerms, businessTypeTerms);
                        Console.WriteLine(string.Format("LeadID {0} : OK", lead.ID));
                    //}
                    //catch (Exception e)
                    //{
                    //    Console.WriteLine(string.Format("LeadID {0} : ERROR - {1}", lead.ID, e.Message));
                    //}
                }
            }



        }

        public void ImportInvoices(long countryID)
        {
            DeleteExistingInvoices(countryID);

            Console.WriteLine("Importing Invoices...");

            string prefix;

            switch (countryID)
            {
                case 2:
                    prefix = "ua";
                    break;
                case 3:
                    prefix = "by";
                    break;
                default:
                    prefix = "";
                    break;
            }


            List<WpPost> invoicePosts = null;
            using (WordPressClient wp = new WordPressClient())
            {
                invoicePosts = wp.LoadWpInvoicesPosts(prefix);
            }

            Dictionary<long, long> businessOldIdMapping = BusinessSelectOldIds(con, countryID);
            List<WpInvoice> wpInvoices = invoicePosts.Select(x => new WpInvoice(x, businessOldIdMapping)).ToList();
            foreach (WpInvoice wpInvoice in wpInvoices)
            {
                importInvoice(wpInvoice, countryID);
            }
        }


        public void ImportReviews(long countryID)
        {
            Console.WriteLine("Importing Reviews...");

            string prefix;

            switch (countryID)
            {
                case 2:
                    prefix = "ua";
                    break;
                case 3:
                    prefix = "by";
                    break;
                default:
                    prefix = "";
                    break;
            }

            List<WpPost> publishedReviews = null;
            List<WpPost> pendingReviews = null;

            using (WordPressClient wp = new WordPressClient())
            {
                publishedReviews = wp.LoadLeadReviews("publish", prefix);
                pendingReviews = wp.LoadLeadReviews("pending", prefix);
            }

            List<WpPost> reviewPosts = new List<WpPost>();
            reviewPosts.AddRange(publishedReviews);
            reviewPosts.AddRange(pendingReviews);

            Dictionary<long, long> businessOldIdMapping = BusinessSelectOldIds(con, countryID);
            foreach (WpPost reviewPost in reviewPosts)
            {
                if (publishedReviews.Contains(reviewPost))
                    reviewPost.fields.Add("status", "publish");

                if (pendingReviews.Contains(reviewPost))
                    reviewPost.fields.Add("status", "pending");

                ImportReviewPost(reviewPost, businessOldIdMapping);
            }
        }

        private void ImportReviewPost(WpPost post, Dictionary<long, long> businessIdMapping)
        {
            //PHPSerializer php = new PHPSerializer();
            //dynamic wpOrder = php.Deserialize(post.fields["review_from_order"]);
            //ArrayList orderStrings = wpOrder;
            string[] titleParts = post.post_title.Split('№');
            if (titleParts.Length != 3)
                return;

            long leadID = Convert.ToInt64(titleParts[2]);

            Console.WriteLine("Importing Review fir Lead ID " + leadID);

            Review review = new Review(leadID);
            review.authorName = post.fields["review_fio"];
            review.reviewText = post.post_content;
            review.reviewDateTime = post.post_date;

            if (post.fields["review_for_reg_master"] != "null" && string.IsNullOrEmpty(post.fields["review_for_reg_master"]) == false)
                review.businessID = businessIdMapping[Convert.ToInt64(post.fields["review_for_reg_master"])];

            if (string.IsNullOrEmpty(post.fields["review_for_not_reg_master"]) == false)
            {
                review.otherBusinessName = post.fields["review_for_not_reg_master"];
                review.otherBusiness = true;
            }

            if (string.IsNullOrEmpty(post.fields["review_order_not_complete"]) == false && post.fields["review_order_not_complete"] == "1")
                review.notCompleted = true;
            if (string.IsNullOrEmpty(post.fields["price_pam"]) == false)
                review.orderPricePart1 = Convert.ToDecimal(post.fields["price_pam"]);
            if (string.IsNullOrEmpty(post.fields["price_install"]) == false)
                review.orderPricePart2 = Convert.ToDecimal(post.fields["price_install"]);


            review.LoadMeasures(con);
            if (string.IsNullOrEmpty(post.fields["rating_price"]) == false)
                review.measureScores[Review.Measure.Price] = Convert.ToInt16(post.fields["rating_price"]);
            if (string.IsNullOrEmpty(post.fields["rating_quality"]) == false)
                review.measureScores[Review.Measure.Quality] = Convert.ToInt16(post.fields["rating_quality"]);
            if (string.IsNullOrEmpty(post.fields["rating_speed"]) == false)
                review.measureScores[Review.Measure.Speed] = Convert.ToInt16(post.fields["rating_speed"]);
            if (string.IsNullOrEmpty(post.fields["rating_comfort"]) == false)
                review.measureScores[Review.Measure.Comfort] = Convert.ToInt16(post.fields["rating_comfort"]);

            review.SaveInDB(con);
            if (post.fields["status"] == "publish")
                review.Publish(con, 1);
        }



        private void importInvoice(WpInvoice wpInvoice, long countryID)
        {
            Invoice invoice = Invoice.GenerateInvoiceForBusiness(con,
                wpInvoice.businessID,
                wpInvoice.forPeriod.Year,
                wpInvoice.forPeriod.Month,
                wpInvoice.createdDateTime
            );

            Console.WriteLine("Importing WpInvoice ID " + invoice.ID);

            string sql_numbers = "UPDATE [dbo].[Business.Invoice] SET [LegalNumber] = " + wpInvoice.buhNumber + ", [LegalFacturaNumber] = " + wpInvoice.facturaNumber + " WHERE [InvoiceID] = " + invoice.ID;
            using (SqlCommand cmd = new SqlCommand(sql_numbers, con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.ExecuteNonQuery();
            }

            invoice.legalNumber = wpInvoice.buhNumber;
            invoice.legalFacturaNumber = wpInvoice.facturaNumber;

            invoice.legalBilling = new Billing()
            {
                name = wpInvoice.prodName,
                address = wpInvoice.prodAddress,
                code1 = wpInvoice.prodInn,
                code2 = wpInvoice.prodKpp,
                bankName = wpInvoice.prodBankName,
                bankCode1 = wpInvoice.prodBik,
                bankCode2 = wpInvoice.prodKors,
                bankAccount = wpInvoice.prodRs,
                countryID = countryID
            };

            invoice.buisnessBilling = new Billing()
            {
                name = wpInvoice.pokName,
                address = wpInvoice.pokAddress,
                code1 = wpInvoice.pokInn,
                code2 = wpInvoice.pokKpp,
                countryID = countryID
            };

            invoice.lines = new List<InvoiceLine>();
            invoice.lines.Add(new InvoiceLine() { ID = 1, description = wpInvoice.serviceItem, unitPrice = wpInvoice.invoiceSum, isLeadLine = true, tax = 0, quantity = 1 });
            if (wpInvoice.feeSum > 0)
                invoice.lines.Add(new InvoiceLine() { ID = 2, description = wpInvoice.feeDescription, unitPrice = wpInvoice.feeSum, isLeadLine = false, tax = 0, quantity = 1 });
            invoice.totalSum = wpInvoice.invoiceSum + wpInvoice.feeSum;

            foreach (InvoiceLine invoiceLine in invoice.lines)
            {
                invoice.LineAdd(con, invoiceLine.description, invoiceLine.unitPrice, invoiceLine.quantity, 0);
                if (invoiceLine.isLeadLine)
                {
                    foreach (long leadID in wpInvoice.includedOrders)
                    {
                        string sql = "UPDATE [dbo].[Business.Lead.Completed] SET [InvoiceID] = " + invoice.ID + ", [InvoiceLineID] = " + invoiceLine.ID + " WHERE [LeadID] = " + leadID;
                        using (SqlCommand cmd = new SqlCommand(sql, con))
                        {
                            cmd.CommandType = CommandType.Text;
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }



            invoice.UpdateInDB(con);

            invoice.Publish(con, wpInvoice.createdDateTime);

            if (wpInvoice.paidDateTime != null)
            {
                invoice.SetPaid(con, wpInvoice.paidDateTime.Value);
            }


        }

        public static void DeleteExistingLeads(SqlConnection con)
        {
            string sql = "DELETE FROM [dbo].[System.Token] WHERE [TokenAction] = '"+Token.Action.LeadReviewCreate.ToString() +"' " +
                "DELETE FROM [dbo].[System.Token] WHERE [TokenAction] = '" + Token.Action.LeadEmailConfirmation.ToString() + "' " +
                "DELETE FROM [dbo].[Business.Lead.Completed] " +
                "DELETE FROM [dbo].[Business.Lead.ContactsRecieved] " +
                "DELETE FROM [dbo].[Business.Lead.NotInterested] " +
                "DELETE FROM [dbo].[Business.Lead.Important] " +
                "DELETE FROM [dbo].[Business.Invoice.Line] " +
                "DELETE FROM [dbo].[Business.Invoice] " +
                "DELETE FROM [dbo].[Lead.Field.Value.Taxonomy] " +
                "DELETE FROM[dbo].[Lead.Field.Value.Scalar] " +
                "DELETE FROM [dbo].[Lead.Review.Measure.Score] DELETE FROM [dbo].[Lead.Review] " + 
                "DELETE FROM [dbo].[Lead]";
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.ExecuteNonQuery();
            }
        }

        private void DeleteExistingInvoices(long countryID)
        {
            string sql = "UPDATE BL SET BL.InvoiceID = NULL, BL.InvoiceLineID = NULL FROM [dbo].[Business.Lead.Completed] BL INNER JOIN [dbo].[Business.Invoice] I ON I.InvoiceID = BL.InvoiceID WHERE I.LegalCountryID = " + countryID +
                "DELETE IL FROM [dbo].[Business.Invoice.Line] IL INNER JOIN [dbo].[Business.Invoice] I ON I.InvoiceID = IL.InvoiceID WHERE I.LegalCountryID = " + countryID +
                "DELETE FROM [Business.Invoice] WHERE LegalCountryID = " + countryID;
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.ExecuteNonQuery();
            }
        }

        private class WpLeadBusinessMeta
        {
            long leadID;
            long businessID;
            DateTime? contacts_get_date;
            DateTime? completed_date;
            DateTime? important_date;
            DateTime? not_interested_date;
            decimal? completed_sum;

            public WpLeadBusinessMeta(long leadID, long businessID, long wpBusinessID, Dictionary<string,string> fields)
            {
                this.leadID = leadID;
                this.businessID = businessID;

                string contactsDateKey = "order_contacts_get_date_by_user_id_" + wpBusinessID;
                string completeDateKey = "order_confirm_completed_date_by_user_id_" + wpBusinessID;
                string completeSumKey = "order_completed_sum_by_user_id_" + wpBusinessID;
                string notInterestedDateKey = "order_is_not_interested_date_by_user_id_" + wpBusinessID;
                string importantDateKey = "order_important_date_by_user_id_" + wpBusinessID;

                if (fields.Keys.Contains(contactsDateKey))
                    contacts_get_date = DateTime.ParseExact(fields[contactsDateKey], "yyyyMMdd", CultureInfo.InvariantCulture).ToUniversalTime();
                if (fields.Keys.Contains(completeDateKey))
                    completed_date = DateTime.ParseExact(fields[completeDateKey], "yyyyMMdd", CultureInfo.InvariantCulture).ToUniversalTime();
                if (fields.Keys.Contains(notInterestedDateKey))
                    not_interested_date = DateTime.ParseExact(fields[notInterestedDateKey], "yyyyMMdd", CultureInfo.InvariantCulture).ToUniversalTime();
                if (fields.Keys.Contains(importantDateKey))
                    important_date = DateTime.ParseExact(fields[importantDateKey], "yyyyMMdd", CultureInfo.InvariantCulture).ToUniversalTime();
                if (fields.Keys.Contains(completeSumKey))
                    completed_sum = Convert.ToDecimal(fields[completeSumKey]);
            }

            public static IEnumerable<long> GetWpBusinessIDsFromFields(Dictionary<string, string> fields)
            {
                List<long> ids = new List<long>();

                string contactsDateKey = "order_contacts_get_date_by_user_id_";
                string completeDateKey = "order_confirm_completed_by_user_id_";
                string completeSumKey = "order_completed_sum_by_user_id_";
                string notInterestedDateKey = "order_is_not_interested_date_by_user_id_";
                string importantDateKey = "order_important_date_by_user_id_";


                foreach (string key in fields.Keys)
                {
                    if (key.StartsWith(contactsDateKey))
                        ids.Add(Convert.ToInt64(key.Replace(contactsDateKey, "")));
                    if (key.StartsWith(completeDateKey))
                        ids.Add(Convert.ToInt64(key.Replace(completeDateKey, "")));
                    if (key.StartsWith(notInterestedDateKey))
                        ids.Add(Convert.ToInt64(key.Replace(notInterestedDateKey, "")));
                    if (key.StartsWith(completeSumKey))
                        ids.Add(Convert.ToInt64(key.Replace(completeSumKey, "")));
                    if (key.StartsWith(importantDateKey))
                        ids.Add(Convert.ToInt64(key.Replace(importantDateKey, "")));
                }

                return ids.Distinct();
            }

            public void SaveBusinessData(SqlConnection con)
            {
                Business business = Business.SelectFromDB(con, businessID: businessID).First();
                business.leadManager = new LeadManager(con, business.ID, business.adminLoginID);
                business.leadManager.systemFeePercent = 5;

                if (contacts_get_date != null)
                    business.leadManager.GetContacts(leadID, contacts_get_date.Value.AddHours(12));
                if (not_interested_date != null)
                    business.leadManager.SetNotInterested(leadID, not_interested_date.Value.AddHours(12));
                if (important_date != null)
                    business.leadManager.SetImportant(leadID, important_date.Value.AddHours(12));
                if (completed_date != null && completed_sum != null)
                    business.leadManager.SetCompleted(leadID, completed_sum.Value, completed_date);
            }
        }

        private void ImportLead(WpPost wpLead, Dictionary<long, long> businessIdMapping, List<Term> cityTerms, List<Term> priceTerms, List<Term> shapeTerms, List<Term> materialTerms, List<Term> accessoriesTerms, List<Term> businessTypeTerms)
        {
            try
            {
                InsertCustomLead(wpLead);
            }
            catch (Exception e)
            {
                return;
            }
            //LeadItem lead = LeadItem.SelectFromDB(con, leadID: (long)wpLead.ID).First();
            LeadItem lead = new LeadItem() { ID = (long)wpLead.ID, email = wpLead.fields["order_email"].Trim().ToLower(), adminDetails = new AdminDetails(), businessDetails = new BusinessDetails() };
            lead.LoadFieldStructure(con, false);

            List<Term> businessTypes = new List<Term>() { businessTypeTerms.First(x => x.ID == 48) };
            if (wpLead.fields.Keys.Contains("order_get_offers_from") && wpLead.fields["order_get_offers_from"] == "internet_also")
                businessTypes.Add(businessTypeTerms.First(x => x.ID == 49));
            lead.getFieldByCode("businessType").fieldTerms = businessTypes;
            lead.getFieldByCode("material").fieldTerms = materialTerms.Where(x => wpLead.taxonomies["pam_material"].Contains(x.termURL)).ToList();
            lead.getFieldByCode("shape").fieldTerms = shapeTerms.Where(x => wpLead.taxonomies["pam_shape"].Contains(x.termURL)).ToList();
            lead.getFieldByCode("accessories").fieldTerms = accessoriesTerms.Where(x => wpLead.taxonomies["pam_addition"].Contains(x.termURL)).ToList();

            lead.getFieldByCode("businessType").fieldTerms.ForEach(x => x.isChecked = true);
            lead.getFieldByCode("material").fieldTerms.ForEach(x => x.isChecked = true);
            lead.getFieldByCode("shape").fieldTerms.ForEach(x => x.isChecked = true);
            lead.getFieldByCode("accessories").fieldTerms.ForEach(x => x.isChecked = true);

            lead.getFieldByCode("city").fieldTerms = cityTerms.Where(x => wpLead.taxonomies["pam_city"].Contains(x.termURL)).ToList();
            lead.getFieldByCode("city").fieldTerms.ForEach(x => x.isChecked = true);
            if (lead.getFieldByCode("city").fieldTerms.Count > 0)
                lead.getFieldByCode("city").termIDSelected = lead.getFieldByCode("city").fieldTerms.First().ID;

            lead.getFieldByCode("price").fieldTerms = priceTerms.Where(x => wpLead.taxonomies["pam_price"].Contains(x.termURL)).ToList();
            lead.getFieldByCode("price").fieldTerms.ForEach(x => x.isChecked = true);
            if (lead.getFieldByCode("price").fieldTerms.Count > 0)
                lead.getFieldByCode("price").termIDSelected = lead.getFieldByCode("price").fieldTerms.First().ID;



            if (wpLead.fields.Keys.Contains("order_execute_date") && string.IsNullOrEmpty(wpLead.fields["order_execute_date"]) == false)
            {
                try{lead.getFieldByCode("executeDate").fieldDatetime = DateTime.ParseExact(wpLead.fields["order_execute_date"], "yyyyMMdd", CultureInfo.InvariantCulture).ToUniversalTime();}
                catch (Exception)
                {}
            }
            if (wpLead.fields.Keys.Contains("order_delivery_and_installation"))
                lead.getFieldByCode("installationRequired").fieldBool = wpLead.fields["order_delivery_and_installation"].ToString() == "1" ? true : false;
            if (wpLead.fields.Keys.Contains("order_comment"))
                lead.getFieldByCode("comments").fieldText = wpLead.fields["order_comment"].ToString();
            if (wpLead.fields.Keys.Contains("order_for_whom"))
                lead.getFieldByCode("pamName").fieldText = wpLead.fields["order_for_whom"].ToString();
            if (wpLead.fields.Keys.Contains("order_сemetery_name"))
                lead.getFieldByCode("cemetery").fieldText = wpLead.fields["order_сemetery_name"].ToString();
            if (wpLead.fields.Keys.Contains("oder_fio"))
                lead.getFieldByCode("name").fieldText = wpLead.fields["oder_fio"].ToString();
            if (wpLead.fields.Keys.Contains("order_phone"))
                lead.getFieldByCode("phone").fieldText = wpLead.fields["order_phone"].ToString();
            if (wpLead.fields.Keys.Contains("order_show_phone"))
                lead.getFieldByCode("phoneIsAvailableForBusiness").fieldBool = wpLead.fields["order_show_phone"].ToString() == "1" ? true : false;
            if (wpLead.fields.Keys.Contains("order_time_comment"))
                lead.getFieldByCode("contactComment").fieldText = wpLead.fields["order_time_comment"].ToString();

            lead.UpdateFieldGroupsInDB(con);

            foreach (long wpBusinessID in WpLeadBusinessMeta.GetWpBusinessIDsFromFields(wpLead.fields))
            {
                WpLeadBusinessMeta bm = new WpLeadBusinessMeta(lead.ID, businessIdMapping[wpBusinessID], wpBusinessID, wpLead.fields);
                bm.SaveBusinessData(con);
            }



            if (wpLead.fields.Keys.Contains("order_review_key") && string.IsNullOrEmpty(wpLead.fields["order_review_key"]) == false)
            {
                Token token = new Token(con, Token.Action.LeadReviewCreate.ToString(), lead.ID.ToString(), wpLead.fields["order_review_key"]);
            }

            if (wpLead.fields.Keys.Contains("order_confirm_key") && string.IsNullOrEmpty(wpLead.fields["order_confirm_key"]) == false)
            {
                Token token = new Token(con, Token.Action.LeadEmailConfirmation.ToString(), lead.ID.ToString(), wpLead.fields["order_confirm_key"]);
            }
            else
            {
                LeadItem.EmailConfirm(con, lead.ID);
            }

            if (wpLead.fields["status"] == "publish")
            {
                lead.TryPublish(con, 1, wpLead.post_date);
            }

            if (wpLead.fields.Keys.Contains("order_canceled_publish_date") && string.IsNullOrEmpty(wpLead.fields["order_canceled_publish_date"]) == false)
                lead.TryUnPublishByUser(con, canceledPublishDateTime: DateTime.ParseExact(wpLead.fields["order_canceled_publish_date"], "yyyyMMdd", CultureInfo.InvariantCulture).ToUniversalTime());

            if (wpLead.fields.Keys.Contains("order_hide_date") && string.IsNullOrEmpty(wpLead.fields["order_hide_date"]) == false)
                lead.TryUnPublishByAdmin(con, 1, canceledPublishDateTime: DateTime.ParseExact(wpLead.fields["order_hide_date"], "yyyyMMdd", CultureInfo.InvariantCulture).ToUniversalTime());


        }

        private void InsertCustomLead(WpPost lead)
        {
            using (SqlCommand cmd = new SqlCommand("INSERT INTO [dbo].[Lead] ([LeadID] ,[CreatedDateTime], [Email]) VALUES ("+ lead.ID+ ", '"+ lead.post_date.ToString("yyyy-MM-dd HH:mm:ss") + "', '"+ lead.fields["order_email"].Trim().ToLower() + "')", con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.ExecuteNonQuery();
            }
        }

        private void BusinessUpdateOldID(long ID, long oldID)
        {
            using (SqlCommand cmd = new SqlCommand("UPDATE [dbo].[Business] SET [OldID] = "+ oldID + " WHERE [BusinessID] = " + ID, con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.ExecuteNonQuery();
            }
        }

        private void InvoiceUpdateActNumber(long invoiceID, long actNumber)
        {
            using (SqlCommand cmd = new SqlCommand("UPDATE [dbo].[Business.Invoice] SET [LegalActNumber] = " + actNumber + " WHERE [InvoiceID] = " + invoiceID, con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.ExecuteNonQuery();
            }
        }

        private static Dictionary<long, long> BusinessSelectOldIds(SqlConnection con, long countryID)
        {
            Dictionary<long, long> result = new Dictionary<long, long>();

            using (SqlCommand cmd = new SqlCommand("SELECT B.BusinessID, B.OldID FROM [dbo].[Business] B WHERE B.OldID IS NOT NULL", con))
            {
                cmd.CommandType = System.Data.CommandType.Text;

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);
                foreach (DataRow row in dt.Rows)
                {
                    result.Add((long)row["OldID"], (long)row["BusinessID"]);
                }
            }

            return result;
        }

        private void ReplaceLeadID(SqlConnection con, long oldLeadID, long newLeadID)
        {
            using (SqlCommand cmd = new SqlCommand("UPDATE [dbo].[Lead] SET[LeadID] = "+ newLeadID + " WHERE [LeadID] = " + oldLeadID, con))
            {
                cmd.CommandType = System.Data.CommandType.Text;

                cmd.ExecuteNonQuery();
            }
        }

        private void ImportBusiness(WpBusiness wpBusiness, long countryID, List<Business> existingBusineses)
        {
            if (string.IsNullOrEmpty(wpBusiness.email))
                return;

            if (string.IsNullOrEmpty(wpBusiness.represent_site.ToString().Trim()))
                wpBusiness.represent_site = "Site for BusinessID " + wpBusiness.ID;

            if (string.IsNullOrEmpty(wpBusiness.public_company_name.ToString().Trim()))
                wpBusiness.public_company_name = "Name for BusinessID " + wpBusiness.ID;

            Login login = Login.SelectOne(con, wpBusiness.email);
            if (login == null)
            {
                string tempPassword = SysHelper.GenerateRandomString();
                login = Login.Create(con, Login.UserRoles.business_admin, wpBusiness.email, tempPassword);
                Login.EmailConfirm(con, login.ID);
            }

            Business business = existingBusineses.FirstOrDefault(x => x.webSite.ToLower() == wpBusiness.represent_site.ToLower() && x.name.ToLower() == wpBusiness.public_company_name.ToLower());
            if (business == null)
            {
                business = Business.Create(con, wpBusiness.public_company_name, wpBusiness.represent_site, countryID);
                business.LinkLogin(con, login); //Link login to business
            }

            BusinessUpdateOldID(business.ID, Convert.ToInt64(wpBusiness.ID));

            //Set basic data
            business.name = wpBusiness.public_company_name;
            business.webSite = wpBusiness.represent_site;
            business.address = wpBusiness.real_address;
            business.Update(con);

            //Set contact data
            business.contact = new Contact()
            {
                email = wpBusiness.represent_email,
                name = wpBusiness.represent_fio,
                phone = wpBusiness.represent_tel,
                skype = wpBusiness.represent_skype
            };
            business.contact.Update(con, business.ID);

            //Set billing data
            business.billing = new Billing()
            {
                address = wpBusiness.jur_address,
                code1 = wpBusiness.jur_inn,
                code2 = wpBusiness.jur_kpp,
                countryID = countryID,
                name = wpBusiness.jur_name
            };
            business.billing.Update(con, business.ID);

            //Process notification settings
            NotificationSettings.Frequency frequency = NotificationSettings.Frequency.Daily;
            if (wpBusiness.notification_mode == "each")
                frequency = NotificationSettings.Frequency.Immediate;
            NotificationSettings.FrequencyTryUpdate(con, business.ID, frequency);
            //Load and clear emailList in NotificationSettings
            business.notification = new NotificationSettings(){ frequency = frequency };
            business.notification.LoadEmailList(con, business.ID);
            foreach (NotificationSettings.NotificationEmail email in business.notification.emailList)
                Code.Business.NotificationSettings.EmailRemove(con, business.ID, email.address);
            //Try insert email1 and email2 (if it is different) to the list
            try{ business.notification.emailList.Add(new NotificationSettings.NotificationEmail(new System.Net.Mail.MailAddress(wpBusiness.notification_email1.Trim()).ToString().ToLower())); }
            catch (Exception) {}
            if (wpBusiness.notification_email1.Trim().ToLower() != wpBusiness.notification_email2.Trim().ToLower())
                try{business.notification.emailList.Add(new NotificationSettings.NotificationEmail(new System.Net.Mail.MailAddress(wpBusiness.notification_email2.Trim()).ToString().ToLower()));}
                catch (Exception) { }
            //Save list values to the database
            foreach (NotificationSettings.NotificationEmail email in business.notification.emailList)
                NotificationSettings.EmailAdd(con, business.ID, email.address);

            //Process requested permissions

            // Get requested requestedPermittionsIDs
            List<long[]> requestedPermittionsIDs = new List<long[]>();
            business.LoadLeadPermissions(con);
            // Update permissions
            business.UpdateRequestedPermissions(con, requestedPermittionsIDs, business.leadPermissions);


            List<long[]> permissionsToApprove = new List<long[]>();

            // Just in case reload updated leadPermissions
            business.LoadLeadPermissions(con, onlyCurrentlyRequested: false);
            //Approve permittions if they match permissionsToApprove
            foreach (LeadPermittion permittion in business.leadPermissions)
                foreach (long[] ids in permissionsToApprove)
                    if (permittion.terms.Select(x => x.ID).OrderBy(x=>x).SequenceEqual(ids.OrderBy(x => x)))
                        permittion.Approve(con, 1);
        }

        private void ImportArticlePost(WpPost wpPost)
        {
            //Get or Create The Post
            int postTypeID = 2;
            Post post = Post.SelectFromDB(con, typeID: postTypeID, postURL: CMSManager.ClearURL(wpPost.post_url)).FirstOrDefault();
            if (post == null)
                post = Post.SelectFromDB(con, postID: Post.CreateNew(con, 1, postTypeID)).First();

            post.postStatus = new Post.Status() { ID = 50, name = "Published" };

            PopulateLeadGenPostFromWpPostWithStandardData(post, wpPost);

            //Process Taxonomies
            post.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: false);

            List<Term> cmsTagTerms = post.taxonomies.First(x => x.taxonomy.code == "cms_tag").taxonomy.termList;
            cmsTagTerms.ForEach(x => x.isChecked = false);
            foreach (string termUrl in wpPost.taxonomies["post_tag"])
                cmsTagTerms.First(x => x.termURL == termUrl).isChecked = true;

            List<Term> cmsCategoryTerms = post.taxonomies.First(x => x.taxonomy.code == "cms_category").taxonomy.termList;
            cmsCategoryTerms.ForEach(x => x.isChecked = false);
            foreach (string termUrl in wpPost.taxonomies["category"])
                cmsCategoryTerms.First(x => x.termURL == termUrl).isChecked = true;

            //Save Processed Post
            string errormsg = "";
            bool result = post.Update(con, ref errormsg);
            Console.WriteLine(String.Format("Pam Post ID:{0} Updated:{1}", post.ID, result));
        }

        static Dictionary<string, int> startPosts = new Dictionary<string, int>() {
            {"izgotovleniepamyatnikov", 1}
        };
        private void ImportPagePost(WpPost wpPost)
        {


            string wpPostUrl = CMSManager.ClearURL(wpPost.post_url);
            if (startPosts.Keys.Contains(wpPostUrl))
            {
                ImportTypeStartPost(wpPost);
                return;
            }


            //Get or Create The Post
            int postTypeID = (int)CMSManager.PostTypesBuiltIn.Page;
            Post post = Post.SelectFromDB(con, typeID: postTypeID, postURL: wpPostUrl).FirstOrDefault();
            if (post == null)
                post = Post.SelectFromDB(con, postID: Post.CreateNew(con, 1, postTypeID)).First();

            post.postStatus = new Post.Status() { ID = 50, name = "Published" };

            PopulateLeadGenPostFromWpPostWithStandardData(post, wpPost);

            //Save Processed Post
            string errormsg = "";
            bool result = post.Update(con, ref errormsg);
            Console.WriteLine(String.Format("Page Post ID:{0} Updated:{1}", post.ID, result));
        }

        private void ImportTypeStartPost(WpPost wpPost)
        {
            string wpPostUrl = CMSManager.ClearURL(wpPost.post_url);
            int postTypeID = startPosts[wpPostUrl];

            //Get Get start page
            PostType postType = PostType.SelectFromDB(con, TypeID: postTypeID).First();
            postType.LoadStartPost(con);
            Post post = postType.startPost;

            PopulateLeadGenPostFromWpPostWithStandardData(post, wpPost);
            post.postURL = ""; // Overvrite the default url loaded from the wpPost (startPost has empty URL)

            //Save Processed Post
            string errormsg = "";
            bool result = post.Update(con, ref errormsg);
            Console.WriteLine(String.Format("Post Type ID:{0} Start Page Updated:{1}", post.ID, result));
        }
        

        private void ImportPamPost(WpPost wpPost)
        {
            //Get or Create The Post
            int postTypeID = 7;
            Post post = Post.SelectFromDB(con, typeID: postTypeID, postURL: CMSManager.ClearURL(wpPost.post_url)).FirstOrDefault();
            if (post == null)
                post = Post.SelectFromDB(con, postID: Post.CreateNew(con, 1, postTypeID)).First();

            post.postStatus = new Post.Status() { ID = 50, name = "Published" };

            PopulateLeadGenPostFromWpPostWithStandardData(post, wpPost);

            //Process Taxonomies
            post.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: false);
            List<Term> pamTagTerms = post.taxonomies.First(x => x.taxonomy.code == "cms_pam_tag").taxonomy.termList;
            pamTagTerms.ForEach(x => x.isChecked = false);
            foreach (string termUrl in wpPost.taxonomies["pam_mogila_tag"])
                pamTagTerms.First(x => x.termURL == termUrl).isChecked = true;

            //Process Fields
            post.LoadFields(con);
            post.getFieldByCode("pam_map").location = WordPressClient.parseWpMap(wpPost.fields["klad_map"]);
            post.getFieldByCode("pam_map").location.name = post.title;

            //Save Processed Post
            string errormsg = "";
            bool result = post.Update(con, ref errormsg);
            Console.WriteLine(String.Format("Pam Post ID:{0} Updated:{1}", post.ID, result));
        }

        private void ImportKladPost(WpPost wpPost)
        {
            //Get or Create The Post
            int postTypeID = 3;
            Post post = Post.SelectFromDB(con, typeID: postTypeID, postURL: CMSManager.ClearURL(wpPost.post_url)).FirstOrDefault();
            if (post == null)
                post = Post.SelectFromDB(con, postID: Post.CreateNew(con, 1, postTypeID)).First();

            post.postStatus = new Post.Status() { ID = 50, name = "Published" };

            PopulateLeadGenPostFromWpPostWithStandardData(post, wpPost);

            //Process Taxonomies
            post.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: false);
            List<Term> cityTerms = post.taxonomies.First(x => x.taxonomy.code == "city").taxonomy.termList;
            cityTerms.ForEach(x => x.isChecked = false);
            foreach (string termUrl in wpPost.taxonomies["pam_city_klad"])
                cityTerms.First(x => x.termURL == termUrl).isChecked = true;

            //Process Fields
            post.LoadFields(con);
            post.getFieldByCode("klad_phone").fieldText = wpPost.fields["klad_phone"];
            post.getFieldByCode("klad_site").fieldText = wpPost.fields["klad_site"];
            post.getFieldByCode("klad_email").fieldText = wpPost.fields["klad_email"];
            post.getFieldByCode("klad_address").fieldText = wpPost.fields["klad_address"];
            post.getFieldByCode("klad_map").fieldText = wpPost.fields["klad_map"];
            post.getFieldByCode("klad_map").location = WordPressClient.parseWpMap(wpPost.fields["klad_map"]);
            post.getFieldByCode("klad_map").location.address = wpPost.fields["klad_address"];
            post.getFieldByCode("klad_map").location.name = post.title;

            //Save Processed Post
            string errormsg = "";
            bool result = post.Update(con, ref errormsg);
            Console.WriteLine(String.Format("Klad Post ID:{0} Updated:{1}", post.ID, result));
        }

        private void UpdateMasterPost(WpPost wpMaster, List<Taxonomy> photoTaxonomies )
        {
            int crmID = Convert.ToInt32(wpMaster.fields["crm_company_id"]);
            Post master = Post.SelectFromDB(con, "master_crmID", numberValue: crmID).First();
            string originalMasterName = master.title;
            PopulateLeadGenPostFromWpPostWithStandardData(master, wpMaster, photoTaxonomies);
            master.title = originalMasterName;
            master.postStatus = new Post.Status() { ID = 50, name = "Published" };
            string errormsg = "";
            bool result = master.Update(con, ref errormsg);
            Console.WriteLine(String.Format("Post For Master ID {0} Updated: {1}", master.ID, result));
        }

        private void PopulateLeadGenPostFromWpPostWithStandardData(Post post, WpPost wpPost, List<Taxonomy> photoTaxonomies = null)
        {
            post.title = wpPost.post_title;
            post.postURL = wpPost.post_url;
            post.content = wpPost.post_content;
            post.contentIntro = wpPost.seo_under_h1;
            post.dateCreated = wpPost.post_date;
            post.SEO = wpPost.seo;
            UploadWpPostAttachments(post, wpPost, photoTaxonomies);
        }

        private void UploadWpPostAttachments(Post post, WpPost wpPost, List<Taxonomy> photoTaxonomies)
        {
            //Do not load attachments (temporary, whyle debugging only)
            //return;

            post.LoadAttachments(con);

            //Parse post content
            HtmlAgilityPack.HtmlDocument doc = new HtmlAgilityPack.HtmlDocument();
            doc.LoadHtml(post.content);

            Dictionary<string, string> contentImages = new Dictionary<string, string>();
            foreach (var img in doc.DocumentNode.Descendants("img"))
                if (!contentImages.Keys.Contains(img.Attributes["src"].Value))
                    contentImages.Add(img.Attributes["src"].Value, img.Attributes["alt"].Value);

            //Get image urls from post content
            List<string> contentImageUrls = contentImages.Keys.ToList();
            //Add wpPost.attachment_urls to the contentImageUrls
            contentImageUrls.AddRange(wpPost.attachments.Keys);
            //Add thumbnail_url
            if (string.IsNullOrEmpty(wpPost.thumbnail_url) == false)
                contentImageUrls.Add(wpPost.thumbnail_url);

            //Upload and attach files to the post
            post.LoadAttachments(con);
            foreach (string attachmentURL in contentImageUrls.Distinct())
            {
                string modifiedAttachmentURL = CMSManager.ClearURL(attachmentURL.Replace("http://izgotovleniepamyatnikov.ru/wp-content/uploads/", "http://static.izgotovleniepamyatnikov.ru/cms/"));
                if (post.attachmentList.FirstOrDefault(x => x.attachmentURL == modifiedAttachmentURL) != null)
                    continue;

                try
                {
                    bool isThumbnail = attachmentURL == wpPost.thumbnail_url;
                    Attachment postAttachment = UploadAttachmentToPost(post, new Uri(attachmentURL), isThumbnail);
                    if (contentImages.Keys.Contains(attachmentURL))
                    {
                        string contentDescripyion = contentImages[attachmentURL];
                        if (string.IsNullOrEmpty(contentDescripyion) == false)
                        {
                            postAttachment.description = contentDescripyion;
                            postAttachment.UpdateInDB(con);
                        }
                            
                    }
                }
                catch (Exception)
                {
                }
            }


            //Update attachment taxonomies
            if (wpPost.attachments.Any() == false || photoTaxonomies == null)
                return;

            post.LoadAttachments(con);

            Dictionary<string, string> taxCodeDict = new Dictionary<string, string>() {
                {"photo_accessories", "pam_foto_addition" },
                {"photo_material", "pam_foto_material" },
                {"photo_shape", "pam_foto_shape" },
                {"photo_price_range", "pam_foto_price" }
            };

            foreach (Attachment attachment in post.attachmentList)
            {
                string modifiedAttachmentURL = CMSManager.ClearURL(attachment.attachmentURL.Replace("http://static.izgotovleniepamyatnikov.ru/cms/", "http://izgotovleniepamyatnikov.ru/wp-content/uploads/"));
                if (wpPost.attachments.ContainsKey(modifiedAttachmentURL) == false)
                    continue;
                WpPost wpAttachment = wpPost.attachments[modifiedAttachmentURL];

                attachment.taxonomies = photoTaxonomies;
                foreach (Taxonomy tax in photoTaxonomies)
                {
                    IEnumerable<string> wpTaxTerms = wpAttachment.taxonomies[taxCodeDict[tax.code]];
                    var tmpTax = attachment.taxonomies.First(x => x.code == tax.code);
                    tmpTax.termList.ForEach(x => x.isChecked = false); //Uncheck any existing terms (just in case)
                    tmpTax.termList.Where(x => wpTaxTerms.Contains(x.termURL)).ToList().ForEach(x => x.isChecked = true);
                }

                attachment.UpdateInDB(con);
            }



        }


        private Code.CMS.Attachment UploadAttachmentToPost(Post post, Uri attachmentUri, bool isThumbnail = true)
        {
            if (attachmentUri.Segments.Length < 6)
                return null;

            int year = Convert.ToInt32(attachmentUri.Segments[3].Trim('/'));
            int month = Convert.ToInt32(attachmentUri.Segments[4].Trim('/'));

            Attachment attachment = Attachment.UploadFromURL(con, 1, attachmentUri, year, month);
            if (attachment == null)
                return null;

            attachment.LinkToPost(con, post.ID);

            if (isThumbnail)
                post.thumbnailAttachmentID = attachment.attachmentID;

            return attachment;
        }

        private Dictionary<string, Word> parseCityWords(Dictionary<string, string> fields)
        {
            Dictionary<string, Word> words = new Dictionary<string, Word>();
            Word cityWord = null;
            Word regionWord = null;
            foreach (KeyValuePair<string,string> item in fields)
            {
                if (item.Key == "case_genitive" && string.IsNullOrEmpty(item.Value) == false)
                {
                    if (cityWord == null)
                        cityWord = new Word();
                    cityWord.genitiveSingular = item.Value;
                }
                if (item.Key == "case_prepositional" && string.IsNullOrEmpty(item.Value) == false)
                {
                    if (cityWord == null)
                        cityWord = new Word();
                    cityWord.prepositionalSingular = item.Value;
                }
                if (item.Key == "region_name" && string.IsNullOrEmpty(item.Value) == false)
                {
                    if (regionWord == null)
                        regionWord = new Word();
                    regionWord.nominativeSingular = item.Value;
                }
                if (item.Key == "region_name_case_genitive" && string.IsNullOrEmpty(item.Value) == false)
                {
                    if (regionWord == null)
                        regionWord = new Word();
                    regionWord.genitiveSingular = item.Value;
                }
                if (item.Key == "region_name_case_prepositional" && string.IsNullOrEmpty(item.Value) == false)
                {
                    if (regionWord == null)
                        regionWord = new Word();
                    regionWord.prepositionalSingular = item.Value;
                }
            }
            if (cityWord != null)
                words.Add("city", cityWord);
            if (regionWord != null)
                words.Add("region", regionWord);

            return words;
        }

        private Term ImportTerm(WpTerm wpTerm, int taxonomyID, string parentSlug = "")
        {
            Console.WriteLine("Importing " + wpTerm.ToString() + "...");

            Term term = Term.SelectFromDB(con, TermURL: CMSManager.ClearURL(wpTerm.slug), TaxonomyID: taxonomyID).FirstOrDefault();
            if (term == null)
                term = new Term();

            term.name = wpTerm.name;
            term.termURL = wpTerm.slug;

            //Determine term.parentID by parentSlug
            if (String.IsNullOrEmpty(parentSlug) == false)
            {
                Term parentTerm = Term.SelectFromDB(con, TaxonomyID: taxonomyID, TermURL: CMSManager.ClearURL(parentSlug)).FirstOrDefault();
                if (parentTerm == null)
                    throw new Exception(string.Format("Can not load parent term for wpTerm: name - {0}, slug = {1}, parentSlug = {2}", term.name, term.termURL, parentSlug));
                term.parentID = parentTerm.ID;
            }



            //Insert Term
            string errorMessage = "";
            if (term.ID == 0)
            {
                term.TryInsert(con, taxonomyID, ref errorMessage);
                //Check if term was created
                if (term.ID == 0)
                    throw new Exception(string.Format("Can not create term: name - {0}, slug = {1}", term.name, term.termURL));
            }
            else
            {
                term.TryUpdate(con, ref errorMessage);
                if (string.IsNullOrEmpty(errorMessage) == false)
                    throw new Exception(string.Format("Can not update term: name - {0}, slug = {1}", term.name, term.termURL));
            }

            int cityTaxonomy = 3;
            int[] leadTaxonomies = new int[] { cityTaxonomy, 4, 5, 6, 7, 8 };
            if (leadTaxonomies.Contains(taxonomyID))
            {
                bool allowInOrder = false;
                string city_include_in_lists = "";
                if (taxonomyID == cityTaxonomy)
                {
                    if (wpTerm.fields.TryGetValue("city_include_in_lists", out city_include_in_lists) && String.IsNullOrEmpty(city_include_in_lists) == false && Convert.ToInt32(wpTerm.fields["city_include_in_lists"]) == 1)
                        allowInOrder = true;
                }
                else
                    allowInOrder = true;

                if (allowInOrder)
                    LeadConfiguration.FieldMetaTermSetAllowance(con, term.ID, true);
            }




                

            Dictionary<string, Word> newWords = null;

            if (wpTerm.taxonomy == "pam_city")
                newWords = parseCityWords(wpTerm.fields);

            //Create and Set newWors
            if (newWords != null)
            {
                foreach (KeyValuePair<string, Word> newWord in newWords)
                {
                    newWord.Value.SaveInDB(con);
                    term.SetSystemWord(con, newWord.Value.ID.Value, newWord.Key);
                }
            }


            //Update related term posts
            PagedList.IPagedList<Post> termPostsToUpdate = null;
            if (wpTerm.taxonomy == "pam_city")
                termPostsToUpdate = Post.SelectFromDB(con, typeID: 15, forTermID: term.ID);
            else if (wpTerm.taxonomy == "pam_city_klad")
                termPostsToUpdate = Post.SelectFromDB(con, typeID: 16, forTermID: term.ID);
            else
                termPostsToUpdate = Post.SelectFromDB(con, forTermID: term.ID);

            if (termPostsToUpdate != null)
                foreach (var post in termPostsToUpdate)
                {
                    if (post.Url == "moskva")
                    {
                        string ttt = post.Url;
                    }
                    UpdateTermRelatedPost(post, wpTerm);
                }



            // As the last step call the same import function recursiveley for all child terms
            if (wpTerm.childTerms != null)
                foreach (WpTerm wpChildTerm in wpTerm.childTerms)
                    ImportTerm(wpChildTerm, taxonomyID, wpTerm.slug);

            return term;

        }

        private void UpdateTermRelatedPost(Post post, WpTerm wpTerm)
        {
            if(wpTerm.SEO != null)
                post.SEO = wpTerm.SEO;

            string newTitle = wpTerm.name;
            if (wpTerm.fields != null && wpTerm.fields.TryGetValue("city_h1_text", out newTitle) && String.IsNullOrEmpty(newTitle) == false)
                post.title = newTitle;

            string newContent = String.Empty;
            if (wpTerm.fields != null && wpTerm.fields.TryGetValue("city_page_content", out newContent) && String.IsNullOrEmpty(newContent) == false)
                post.content = newContent;

            string newContentIntro = String.Empty;
            if (wpTerm.fields != null && wpTerm.fields.TryGetValue("seo_under_h1", out newContentIntro) && String.IsNullOrEmpty(newContentIntro) == false)
                post.contentIntro = newContentIntro;
                
            string newContentEnding = String.Empty;
            if (wpTerm.fields != null && wpTerm.fields.TryGetValue("city_page_content_after", out newContentEnding) && String.IsNullOrEmpty(newContentEnding) == false)
                post.contentEnding = newContentEnding;

            //Update post
            string errorMsg = "";
            bool postUpdated = post.Update(con, ref errorMsg);
        }

        private bool SyncCrmCompanyWithPost(Company company, Dictionary<string, Dictionary<long, long>> businessOldIdMappingByCountry)
        {
            bool result;

            Post post = Post.SelectFromDB(con, "master_crmID", numberValue: company.ID).FirstOrDefault();
            if (post == null)
                post = Post.SelectFromDB(con, postID: Post.CreateNew(con, 1, 6)).First();


            //Prepare Term Lists
            post.LoadTaxonomies(con, loadTerms: true, termsCheckedOnly: false);
            List<Term> cityTerms = post.taxonomies.First(x => x.taxonomy.code == "city").taxonomy.termList;
            List<Term> crmTypeTerms = post.taxonomies.First(x => x.taxonomy.code == "crm_company_type").taxonomy.termList;
            List<Term> crmGroupTerms = post.taxonomies.First(x => x.taxonomy.code == "crm_company_group").taxonomy.termList;
            //Uncheck terms
            cityTerms.ForEach(x => x.isChecked = false);
            crmTypeTerms.ForEach(x => x.isChecked = false);
            crmGroupTerms.ForEach(x => x.isChecked = false);
            //Check terms with data from CRM
            company.groups["ru_regions"].ForEach(x => setTermsCheckedByEpesiGroup(x, cityTerms, 1));
            company.groups["ua_regions"].ForEach(x => setTermsCheckedByEpesiGroup(x, cityTerms, 2));
            company.groups["by_regions"].ForEach(x => setTermsCheckedByEpesiGroup(x, cityTerms, 3));
            company.groups["company_type"].ForEach(x => setTermsCheckedByEpesiGroup(x, crmTypeTerms));
            company.groups["group"].ForEach(x => setTermsCheckedByEpesiGroup(x, crmGroupTerms));


            post.LoadFields(con);

            post.getFieldByCode("master_crmID").fieldNumber = company.ID;
            post.title = company.name;

            //Set system_user_id loaded from businessOldIdMappingByCountry
            if (string.IsNullOrEmpty(company.fields["system_user_id"]) == false)
            {
                long system_user_id = Convert.ToInt64(company.fields["system_user_id"]);
                if (company.groups["by_regions"].Count > 0 && businessOldIdMappingByCountry["by"].ContainsKey(system_user_id))
                    post.getFieldByCode("master_businessID").fieldNumber = businessOldIdMappingByCountry["by"][system_user_id];
                if (company.groups["ua_regions"].Count > 0 && businessOldIdMappingByCountry["ua"].ContainsKey(system_user_id))
                    post.getFieldByCode("master_businessID").fieldNumber = businessOldIdMappingByCountry["ua"][system_user_id];
                if (company.groups["ru_regions"].Count > 0 && businessOldIdMappingByCountry["ru"].ContainsKey(system_user_id))
                    post.getFieldByCode("master_businessID").fieldNumber = businessOldIdMappingByCountry["ru"][system_user_id];
            }

            post.getFieldByCode("master_phone").fieldText = company.fields["phone"];
            post.getFieldByCode("master_site").fieldText = company.fields["site_url"];
            post.getFieldByCode("master_email").fieldText = company.fields["email_repeated"];
            if(string.IsNullOrEmpty(post.getFieldByCode("master_email").fieldText))
                post.getFieldByCode("master_email").fieldText = company.fields["email"];

            post.getFieldByCode("master_address1").fieldText = company.fields["address_1"];
            post.getFieldByCode("master_address2").fieldText = company.fields["address_2"];
            post.getFieldByCode("master_address3").fieldText = company.fields["address_3"];
            post.getFieldByCode("master_addressManufacture").fieldText = company.fields["manufacture_address"];

            post.getFieldByCode("master_doNotSendLeads").fieldBool = false;
            if (string.IsNullOrEmpty(company.fields["do_not_mail_orders"]) == false)
                post.getFieldByCode("master_doNotSendLeads").fieldBool = company.fields["do_not_mail_orders"] == "1";

            post.getFieldByCode("master_doNotRobotMail").fieldBool = false;
            if (string.IsNullOrEmpty(company.fields["do_not_robot_mail"]) == false)
                post.getFieldByCode("master_doNotRobotMail").fieldBool = company.fields["do_not_robot_mail"] == "1";

            bool do_not_advertise = false;
            if (string.IsNullOrEmpty(company.fields["do_not_advertise"]) == false && company.fields["do_not_advertise"] == "1")
                do_not_advertise = true;

            if(post.postStatus == null || post.postStatus.ID < 50)
                post.postStatus = new Post.Status() { ID = 30, name = "Pending" };

            string errorMessage = "";
                result = post.Update(con, ref errorMessage);

            return result;
        }

        private static void setTermsCheckedByEpesiGroup(Group group, List<Term> terms, long? parentTermID = null)
        {
            Term term = terms.FirstOrDefault(x => x.parentID == parentTermID && x.name.Equals(group.name, StringComparison.OrdinalIgnoreCase));
            if (term != null)
            {
                term.isChecked = true;
                if (group.child != null)
                    setTermsCheckedByEpesiGroup(group.child, terms, term.ID);
            }
        }

        public void Dispose()
        {
            if (con != null)
            {
                con.Close();
                con.Dispose();
            }
        }
    }
}
