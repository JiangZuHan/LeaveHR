using HR.DBUtility;
using HR.WebModel;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace 全傳請假系統.Tools
{
    /// <summary>
    /// OrganizationShow 的摘要描述
    /// </summary>
    public class OrganizationShow : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            if (context.Request["mode"] != null)
            {
                string ClassId = context.Request["mode"].ToString();
                switch (ClassId)
                {
                    case "Organiz":
                        Organiz(context);
                        break;
                }
            }
        }

        private void Organiz(HttpContext context)
        {
            string xSTNWORK = WebPublic.GetJsonClient("STNWORK", context);
            List<string> STNWORK;
            STNWORK = WebPublic.xLevel(xSTNWORK);
        }


        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}