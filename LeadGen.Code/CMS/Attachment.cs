using LeadGen.Code.Helpers;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Hosting;

namespace LeadGen.Code.CMS
{
    public class Attachment
    {
        public enum Type
        {
            Image = 1,
            Audio = 2,
            Other = 3
        };

        public long attachmentID { get; set; }
        public long authorID { get; set; }
        public Type attachmentType { get; set; }
        public string mime { get; set; }
        public string attachmentURL { get; set; }
        public DateTime dateCreated { get; set; }

        public string name { get; set; }
        public string description { get; set; }

        public Dictionary<ImageSize, Uri> images { get; set; }

        public List<Taxonomy.Taxonomy> taxonomies { get; set; }

        public Attachment()
        {
            images = new Dictionary<ImageSize, Uri>();
            taxonomies = new List<Taxonomy.Taxonomy>();
        }

        public Attachment(DataRow row, DataTable metaData) : this()
        {
            InitializeFromDBRow(row);
            InitializeMetaData(metaData);
        }

        public Attachment(SqlConnection con, long AttachmentID) : this()
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandText = "[dbo].[CMS.Attachment.GetByID]";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@AttachmentID", AttachmentID);

                DataTable dt = DBHelper.ExecuteCommandToDataTable(cmd);

                foreach (DataRow attachmentRow in dt.DefaultView.ToTable(true, "AttachmentID", "AuthorID", "DateCreated", "AttachmentTypeID", "AttachmentTypeName", "MIME", "URL", "Name", "Description").Rows)
                {
                    InitializeFromDBRow(attachmentRow);
                    InitializeMetaData(dt.Select(String.Format("AttachmentID = {0}", attachmentRow["AttachmentID"])).CopyToDataTable());
                }
            }
        }

        private void InitializeFromDBRow(DataRow row)
        {
            attachmentID = (long)row["AttachmentID"];
            attachmentType = (Type)(int)row["AttachmentTypeID"];
            mime = row["MIME"].ToString();
            authorID = (long)row["AuthorID"];
            attachmentURL = row["URL"].ToString();
            dateCreated = (DateTime)row["DateCreated"];
            name = (string)row["Name"];
            description = (string)row["Description"];
        }

        private void InitializeMetaData(DataTable metaData)
        {
            foreach (DataRow sizeRow in metaData.DefaultView.ToTable(true, "ImageSizeID", "Code", "CropMode", "MaxHeight", "MaxWidth", "ImageURL").Select("ImageSizeID IS NOT NULL"))
            {
                images.Add(new ImageSize(sizeRow), new Uri((string)sizeRow["ImageURL"]));
            }

            foreach (DataRow taxonomyRow in metaData.DefaultView.ToTable(true, "TaxonomyID", "TaxonomyCode", "TaxonomyName", "IsTag").Select("TaxonomyID IS NOT NULL"))
            {
                Taxonomy.Taxonomy tax = new Taxonomy.Taxonomy(taxonomyRow);
                tax.termList = new List<Taxonomy.Term>();
                foreach (DataRow termRow in metaData.DefaultView.ToTable(true, "TaxonomyID", "TermID", "TermName", "TermURL", "TermParentID", "TermThumbnailURL").Select(String.Format("TaxonomyID = {0}", taxonomyRow["TaxonomyID"])))
                {
                    tax.termList.Add(new Taxonomy.Term(termRow) { isChecked = true });
                }
                taxonomies.Add(tax);
            }
        }

        private static Type GetFileTypeByName(string fileName)
        {
            //Determine File Type by the mimeType
            string mimeType = MimeMapping.GetMimeMapping(fileName).ToLower().Split('/').First();
            switch (mimeType)
            {
                case "image":
                    return Type.Image;
                case "audio":
                    return Type.Audio;
                default:
                    return Type.Other;
            }
        }

        protected static string GetMD5HashFromInputStream(Stream inputStream)
        {
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] retVal = md5.ComputeHash(inputStream);
            inputStream.Seek(0, SeekOrigin.Begin);


            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < retVal.Length; i++)
            {
                sb.Append(retVal[i].ToString("x2"));
            }

            return sb.ToString();
        }

        public static Attachment ProcessNew(SqlConnection con, long authorID, string fileName, Stream fileStream, int year = 0, int month = 0)
        {
            if (year == 0)
                year = DateTime.UtcNow.Year;

            if (month == 0)
                month = DateTime.UtcNow.Month;

            long attachmentID;
            bool isNewAttachment;
            Type fileType = GetFileTypeByName(fileName);

            //Create new Attachment
            using (SqlCommand cmd = new SqlCommand("[dbo].[CMS.Attachment.ProcessNew]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@AuthorID", authorID);
                cmd.Parameters.AddWithValue("@AttachmentTypeID", (int)fileType);
                cmd.Parameters.AddWithValue("@MIME", MimeMapping.GetMimeMapping(fileName));
                cmd.Parameters.AddWithValue("@FileHash", GetMD5HashFromInputStream(fileStream));
                cmd.Parameters.AddWithValue("@FileSizeBytes", fileStream.Length);

                SqlParameter isNewAttachmentParameter = new SqlParameter();
                isNewAttachmentParameter.ParameterName = "@isNewAttachment";
                isNewAttachmentParameter.SqlDbType = SqlDbType.Bit;
                isNewAttachmentParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(isNewAttachmentParameter);

                SqlParameter attachmentIDParameter = new SqlParameter();
                attachmentIDParameter.ParameterName = "@AttachmentID";
                attachmentIDParameter.SqlDbType = SqlDbType.BigInt;
                attachmentIDParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(attachmentIDParameter);

                cmd.ExecuteNonQuery();
                isNewAttachment = (bool)isNewAttachmentParameter.Value;
                attachmentID = (long)attachmentIDParameter.Value;
            }

            if (isNewAttachment)
            {
                //Set File URL 
                string clearedFileName = CMSManager.ClearURL(Path.GetFileNameWithoutExtension(fileName)) + Path.GetExtension(fileName);
                string attachmentHostName = ConfigurationManager.AppSettings["AzureStorageHostName"].Trim('/');
                string fileURL = string.Format("{0}/{1}/{2}/{3}/{4}", attachmentHostName, "cms", year.ToString().PadLeft(4, '0'), month.ToString().PadLeft(2, '0'), clearedFileName).ToLower();

                bool attachmentUrlSetSuccessfully = false;
                while (attachmentUrlSetSuccessfully == false)
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand("[dbo].[CMS.Attachment.SetURL]", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;

                            cmd.Parameters.AddWithValue("@AttachmentID", attachmentID);
                            cmd.Parameters.AddWithValue("@URL", fileURL);

                            cmd.ExecuteNonQuery();
                        }

                        attachmentUrlSetSuccessfully = true;
                    }
                    catch (Exception)
                    {
                        //Insert "_" before "."
                        fileURL = fileURL.Insert(fileURL.LastIndexOf('.'), "_");
                    }
                }

                //Save File
                using (AzureStorageClient client = new AzureStorageClient())
                {
                    client.SaveFile(fileStream, new Uri(fileURL));
                }

                //Process Image Sizes
                if (fileType == Type.Image)
                    ProcessImageSizes(con, attachmentID, fileStream, fileURL);
            }

            return new Attachment(con, attachmentID);
        }

        protected static void ProcessImageSizes(SqlConnection con, long attachmentID, Stream imageStream, string originalFileURL)
        {
            foreach (ImageSize size in CMSManager.GetImageSizes(con))
            {
                Stream resizedImageStream = size.Resize(imageStream);

                if (resizedImageStream == null)
                    continue;

                //Insert size code before the file extension (before last . in the file name)
                string sizedFileURL = originalFileURL.Insert(originalFileURL.LastIndexOf('.'), "_"+size.code).ToLower();

                //Save File
                using (AzureStorageClient client = new AzureStorageClient())
                {
                    client.SaveFile(resizedImageStream, new Uri(sizedFileURL));
                }

                size.InsertImage(con, attachmentID, sizedFileURL);
            }
        }

        public bool TryDelete(SqlConnection con)
        {
            bool result = false;

            Attachment attachmentToDelete = new Attachment(con, attachmentID);
            if (attachmentToDelete != null)
            {
                using (SqlCommand cmd = new SqlCommand("[dbo].[CMS.Attachment.Delete]", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@AttachmentID", attachmentID);

                    SqlParameter returnParameter = new SqlParameter();
                    returnParameter.ParameterName = "@Result";
                    returnParameter.SqlDbType = SqlDbType.Bit;
                    returnParameter.Direction = ParameterDirection.ReturnValue;
                    cmd.Parameters.Add(returnParameter);

                    cmd.ExecuteNonQuery();
                    result = Convert.ToBoolean(returnParameter.Value);
                }
                if (result)
                    attachmentToDelete.DeleteFromStorage();
            }

            return result;
        }

        protected void DeleteFromStorage()
        {
            List<Uri> filesToDelete = new List<Uri>() { new Uri(attachmentURL) };
            if (images != null)
                filesToDelete.AddRange(images.Select(x => x.Value));
            filesToDelete.ForEach(x => DeleteFileFromStorage(x));
        }

        protected static void DeleteFileFromStorage(Uri fileURL)
        {
            using (AzureStorageClient client = new AzureStorageClient())
            {
                client.DeleteFile(fileURL);
            }
        }

        public void LinkToPost(SqlConnection con, long postID)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[CMS.Post.Attachment.Link]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PostID", postID);
                cmd.Parameters.AddWithValue("@AttachmentID", attachmentID);

                cmd.ExecuteNonQuery();
            }
        }

        public int UnlinkFromPost(SqlConnection con, long postID)
        {
            int AttachmentLinkCount = 0;

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[CMS.Post.Attachment.Unlink]";

                cmd.Parameters.AddWithValue("@PostID", postID);
                cmd.Parameters.AddWithValue("@AttachmentID", attachmentID);

                SqlParameter outputParameter = new SqlParameter();
                outputParameter.ParameterName = "@AttachmentUsed";
                outputParameter.SqlDbType = SqlDbType.Int;
                outputParameter.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outputParameter);

                cmd.ExecuteNonQuery();

                AttachmentLinkCount = (int)outputParameter.Value;
            }

            return AttachmentLinkCount;
        }


        public void LoadTaxonomies(SqlConnection con, int postTypeID, bool loadTerms = false, bool termsCheckedOnly = true)
        {
            taxonomies = PostTypeAttachmentTaxonomy.SelectFromDB(con, postTypeID, enabledOnly: true).Select(x => x.taxonomy).ToList();

            if (loadTerms = true && termsCheckedOnly == true)
            {
                taxonomies.ForEach(x => x.termList = CMSterm.SelectFromDB(con, AttachmentID: attachmentID));
                taxonomies.ForEach(x => x.termList.ForEach(y => y.isChecked = true));
            }
            else if (loadTerms = true && termsCheckedOnly == false)
            {
                taxonomies.ForEach(x => x.LoadTerms(con));
                List<Taxonomy.Term> selectedTerms = CMSterm.SelectFromDB(con, AttachmentID: attachmentID);

                foreach (Taxonomy.Taxonomy tax in taxonomies)
                    foreach (Taxonomy.Term term in tax.termList)
                        if (selectedTerms.Exists(x => x.ID == term.ID))
                            term.isChecked = true;
            }
        }

        public bool UpdateInDB(SqlConnection con)
        {
            UpdateBasicData(con);
            UpdateTermsFromTaxonomyList(con);
            return true;
        }


        private void UpdateTermsFromTaxonomyList(SqlConnection con)
        {

            using (SqlCommand cmd = new SqlCommand("[dbo].[CMS.Attachment.Term.RemoveAll]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@AttachmentID", attachmentID);
                cmd.ExecuteNonQuery();
            }

            if (taxonomies != null)
            {
                foreach (Taxonomy.Term tax in taxonomies.SelectMany(x => x.termList).Where(x => x.isChecked == true))
                {
                    using (SqlCommand cmd = new SqlCommand("[dbo].[CMS.Attachment.Term.Add]", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.AddWithValue("@Attachment", attachmentID);
                        cmd.Parameters.AddWithValue("@TermID", tax.ID);

                        cmd.ExecuteNonQuery();
                    }
                }
            }

        }

        private void UpdateBasicData(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[CMS.Attachment.Update]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@AttachmentID", attachmentID);
                cmd.Parameters.AddWithValue("@Name", name ?? "");
                cmd.Parameters.AddWithValue("@Description", description ?? "");
                cmd.ExecuteNonQuery();
            }
        }

        public Uri GetImageURLBySizeCode(string code)
        {
            if (images != null)
            {
                ImageSize foundSize = images.Keys.Where(x => x.code == code).FirstOrDefault();
                if (foundSize.code == code)
                {
                    return images[foundSize];
                }
            }
            return new Uri(attachmentURL);
        }

        public static Attachment UploadFromURL(SqlConnection connection, long loginID, Uri fileUri, int year = 0, int month = 0)
        {
            if (year == 0)
                year = DateTime.UtcNow.Year;

            if (month == 0)
                month = DateTime.UtcNow.Month;

            Attachment attachment = null;
            string filename = System.IO.Path.GetFileName(fileUri.LocalPath);
            using (HttpClient client = new HttpClient())
            {
                HttpResponseMessage response = client.GetAsync(fileUri).Result;
                if (response.IsSuccessStatusCode == false)
                    return attachment;

                Stream stream = response.Content.ReadAsStreamAsync().Result;
                attachment = ProcessNew(connection, loginID, filename, stream, year, month);
            }
            return attachment;
        }

    }
}