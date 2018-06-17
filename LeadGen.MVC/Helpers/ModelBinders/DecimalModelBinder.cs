using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LeadGen.Helpers.ModelBinders
{
    public class DecimalModelBinder : DefaultModelBinder
    {
        //This model binder allows to parce digits with . as well as , as fraction separator
        //http://stackoverflow.com/questions/14400643/accept-comma-and-dot-as-decimal-separator
        //https://msdn.microsoft.com/en-us/library/9k6z9cdw(v=vs.110).aspx
        public override object BindModel(ControllerContext controllerContext, ModelBindingContext bindingContext)
        {
            var valueProviderResult = bindingContext.ValueProvider.GetValue(bindingContext.ModelName);

            if (valueProviderResult == null)
                return base.BindModel(controllerContext, bindingContext);

            CultureInfo[] cultures = { new CultureInfo("en-US"), new CultureInfo("ru-RU") };
            foreach (CultureInfo culture in cultures)
            {
                try
                {
                    return Convert.ToDecimal(valueProviderResult.AttemptedValue, culture);
                }
                catch (FormatException e)
                {
                }
            }
            return null;
        }
    }
}