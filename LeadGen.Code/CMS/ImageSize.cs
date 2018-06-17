using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeadGen.Code.CMS
{
    public struct ImageSize
    {
        public int id;
        public string code;
        public int maxWidth;
        public int maxHeight;
        public string cropMode;

        public ImageSize(DataRow row)
        {
            id = (int)row["ImageSizeID"];
            code = (string)row["Code"];
            maxHeight = (int)row["MaxHeight"];
            maxWidth = (int)row["MaxWidth"];
            cropMode = row["CropMode"].ToString();
        }

        public void InsertImage(SqlConnection con, long attachmentID, string url)
        {
            using (SqlCommand cmd = new SqlCommand("[dbo].[CMS.Attachment.Image.Insert]", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@AttachmentID", attachmentID);
                cmd.Parameters.AddWithValue("@ImageSizeOptionID", id);
                cmd.Parameters.AddWithValue("@URL", url);

                cmd.ExecuteNonQuery();
            }
        }



        public Stream Resize(Stream srcImageStream)
        {
            Stream resizedImageStream = null;
            using (var srcImage = Image.FromStream(srcImageStream))
            {
                float imageRatio = (float)srcImage.Width / (float)srcImage.Height;

                int newWidth;
                int newHeight;

                if (maxWidth /srcImage.Width > maxHeight / srcImage.Height)
                {
                    newWidth = maxWidth;
                    newHeight = (int)(newWidth * imageRatio);
                }
                else
                {
                    newHeight = maxHeight;
                    newWidth = (int)(newHeight * imageRatio);
                }
                    

                if (newWidth < srcImage.Width)
                {
                    using (var newImage = new Bitmap(newWidth, newHeight))
                    using (var graphics = Graphics.FromImage(newImage))
                    {
                        graphics.SmoothingMode = SmoothingMode.AntiAlias;
                        graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                        graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
                        graphics.DrawImage(srcImage, new Rectangle(0, 0, newWidth, newHeight));
                        resizedImageStream = new MemoryStream();
                        newImage.Save( resizedImageStream, srcImage.RawFormat);
                        resizedImageStream.Seek(0, SeekOrigin.Begin);
                    }
                }
            }
            srcImageStream.Seek(0, SeekOrigin.Begin);

            return resizedImageStream;
        }
    }
}
