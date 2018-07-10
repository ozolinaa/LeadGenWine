using Microsoft.AspNetCore.Html;
using PagedList.Core;
using PagedList.Core.Mvc;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace LeadGen.Web.Helpers
{
    public static class ViewHelpers
    {
        public static string ToHtmlString(this IHtmlContent tag)
        {
            using (var writer = new StringWriter())
            {
                tag.WriteTo(writer, System.Text.Encodings.Web.HtmlEncoder.Default);
                return writer.ToString();
            }
        }

        public static PagedListRenderOptions PagedListRenderOptionsLeadGen(IPagedList list)
        {
            PagedListRenderOptions options = PagedListRenderOptions.TwitterBootstrapPager;
            options.UlElementClasses = new string[] { "pagination" };
            options.DisplayLinkToFirstPage = PagedListDisplayMode.IfNeeded;
            options.DisplayLinkToLastPage = PagedListDisplayMode.IfNeeded;
            options.DisplayLinkToNextPage = PagedListDisplayMode.IfNeeded;
            options.DisplayLinkToPreviousPage = PagedListDisplayMode.IfNeeded;

            options.Display = PagedListDisplayMode.IfNeeded; // does not seem to work, that is why do the hack below
            if (list.TotalItemCount <= list.PageSize)
                options.DisplayLinkToIndividualPages = false;

            return options;
        }
    }
}
