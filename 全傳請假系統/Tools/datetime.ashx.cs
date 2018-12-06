using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using HR.DBUtility;

namespace 全傳請假系統.Tools
{
    /// <summary>
    /// datetime 的摘要描述
    /// </summary>
    public class datetime : IHttpHandler, IRequiresSessionState
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



        /// <summary>
        /// 時數計算
        /// </summary>
        /// <param name="context"></param>
        public void time(HttpContext context)
        {
            double hr = Common.Admin_sumhr(context,Enterprise.ConStr);
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