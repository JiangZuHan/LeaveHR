using HR.DBUtility;
using HR.DBUtility.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.SessionState;


namespace 全傳請假系統.Tools
{
    /// <summary>
    /// MasterPage 的摘要描述
    /// </summary>
    public class MasterPage : IHttpHandler, IRequiresSessionState
    {

        private User user = default(User);
        private HttpContext context_;


        public void ProcessRequest(HttpContext context)
        {
            this.user = new User(context);
            this.context_ = context;

            if (context.Request.QueryString["t"] == null)
                return;

            string t = user.context.Request.QueryString["t"].ToString();

            switch (t)
            {
                case "Update_NavBar_bos":
                    Update_NavBar_bos();
                    break;
            }


        }

        /// <summary>
        /// 更新 BAR 上面的待審核數
        /// </summary>
        private void Update_NavBar_bos()
        {
            //行政
            DataTable dt;

            //現場
            DataTable dt2;


            if (user.Username=="A02")
            {
                dt = Administrator.GetValue(this.context_, Identity.Administrator);

                dt2 = Spot.GetValue(this.context_, Identity.Spot);
            }
            else
            {
                dt = Administrator.GetValue(user.context, Identity.Administrator);
                dt2 = Spot.GetValue(user.context, Identity.Spot);
            }



            int Administrator_count = dt.Rows.Count;
            int Spot_count = dt2.Rows.Count;


            //string result = JsonConvert.SerializeObject(new { Admin_count = Administrator_count, Spot_count = Spot_count });

            //user.context.Response.Write(result);
   

            user.context.Response.Write("if($('#check>a').length){" +
                    "$('#check a').append('<span class=\"badge badge-light\" style=\"margin-left: 2px;\">' +" + Administrator_count + " + '</span>')" +
                "}");
            user.context.Response.Write("if($('#check2>a').length){" +
                     "$('#check2 a').append('<span class=\"badge badge-light\" style=\"margin-left: 2px;\">' +" + Spot_count + " + '</span>')" +
                 "}");



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