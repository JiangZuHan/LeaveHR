using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using HR.DBUtility;
using Newtonsoft.Json;
using System.Web.SessionState;

namespace 全傳請假系統.Tools
{
    /// <summary>
    /// datetime_produceline 的摘要描述
    /// </summary>
    public class datetime_produceline : IHttpHandler, IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            string mode = context.Request["mode"].ToString();

            if (mode != "")
            {
                switch (mode)
                {
                    case "time":
                        time(context);
                        break;
                }
            }
        }
        public void time(HttpContext context)
        {
            double hr = Common.Spot_sumhr(context,Enterprise.ConStr_produceline);
            context.Response.Write(hr);
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