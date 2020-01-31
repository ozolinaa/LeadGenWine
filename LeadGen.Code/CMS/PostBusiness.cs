using LeadGen.Code.Map;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace LeadGen.Code.CMS
{
	public class PostBusiness : Post
	{
		public PostBusiness() : base() { }
		public PostBusiness(DataRow row) : base(row) { }

		public string company_web_site_official { 
			get { return getFieldByCode("company_web_site_official").fieldText; } 
			set { getFieldByCode("company_web_site_official").fieldText = value; } 
		}

		public string company_web_site_other
		{
			get { return getFieldByCode("company_web_site_other").fieldText; }
			set { getFieldByCode("company_web_site_other").fieldText = value; }
		}

		public string company_public_email
		{
			get { return getFieldByCode("company_public_email").fieldText; }
			set { getFieldByCode("company_public_email").fieldText = value; }
		}
		public long? company_notification_phone
		{
			get { return getFieldByCode("company_notification_phone").fieldNumber; }
			set { getFieldByCode("company_notification_phone").fieldNumber = value; }
		}
		public long? company_public_phone
		{
			get { return getFieldByCode("company_public_phone").fieldNumber; }
			set { getFieldByCode("company_public_phone").fieldNumber = value; }
		}
		public string company_notification_email
		{
			get { return getFieldByCode("company_notification_email").fieldText; }
			set { getFieldByCode("company_notification_email").fieldText = value; }
		}
		public Location company_notification_location
		{
			get { return getFieldByCode("company_notification_location").location; }
			set { getFieldByCode("company_notification_location").location = value; }
		}
		public bool company_notification_do_not_send_leads
		{
			get { return getFieldByCode("company_notification_do_not_send_leads").fieldBool; }
			set { getFieldByCode("company_notification_do_not_send_leads").fieldBool = value; }
		}
		public long? company_businessId
		{
			get { return getFieldByCode("company_businessId").fieldNumber; }
			set { getFieldByCode("company_businessId").fieldNumber = value; }
		}
		public string company_crmId
		{
			get { return getFieldByCode("company_crmId").fieldText; }
			set { getFieldByCode("company_crmId").fieldText = value; }
		}

		public void UnsubscribeFromNewLeads(SqlConnection con)
		{
			LoadFields(con);
			PostField field = getFieldByCode("company_notification_do_not_send_leads");
			field.fieldBool = true; //TRUE means DO NOT send
			field.SaveToDB(con, ID);

			if (!string.IsNullOrEmpty(company_crmId))
			{
				try
				{
					using (Clients.CRM.ICRMClient crmClient = Clients.CRM.CRMClient.GetClient())
					{
						crmClient.SetOptOutEmailLeadNotifications(company_crmId, field.fieldBool);
					}
				}
				catch (Exception e)
				{
					Sys.Log.Insert(e.ToString());
				}
			}

		}
	}
}