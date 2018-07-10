//using System;
//using System.Collections.Generic;
//using System.Globalization;
//using System.Linq;
//using System.Web;


//namespace LeadGen.Helpers.ModelBinders
//{
//    public class DateTimeBinder : IModelBinder
//    {
//        public object BindModel(ControllerContext controllerContext, ModelBindingContext bindingContext)
//        {
//            var value = bindingContext.ValueProvider.GetValue(bindingContext.ModelName);
//            bindingContext.ModelState.SetModelValue(bindingContext.ModelName, value);

//            return value.ConvertTo(typeof(DateTime), CultureInfo.CurrentCulture);
//        }
//    }
//}