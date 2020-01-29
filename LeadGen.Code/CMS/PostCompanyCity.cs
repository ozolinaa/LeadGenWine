using LeadGen.Code.Map;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace LeadGen.Code.CMS
{
	public class PostCompanyCity : Post
	{
		public PostCompanyCity() : base() { }
		public PostCompanyCity(DataRow row) : base(row) { }

		public Location company_city_location
		{
			get { return getFieldByCode("company_city_location").location; }
			set { getFieldByCode("company_city_location").location = value; }
		}
	}
}