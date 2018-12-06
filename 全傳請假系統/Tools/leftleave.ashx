<%@ WebHandler Language="C#" CodeBehind="leftleave.ashx" Class="全傳請假系統.leftleave" %>


using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Net.Mail;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.IO;
using HR.DBUtility;
namespace 全傳請假系統
{

    /// <summary>
    /// leftleave 的摘要描述
    /// </summary>
    public class leftleave : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;
        string tbiHRS = ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString;
        string hrs = ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString;
        string conStr = ConfigurationManager.AppSettings["conStr"];
        static DateTime m = DateTime.Parse(DateTime.Now.AddMonths(1).ToString("yyyy-MM-01")).AddDays(-1);//2018_01_18 碩
        string from = m.ToString("yyyy-MM-dd 23:59:59.999");//2018_01_18 碩
                                                            //string datefrom = from.tostring("yyyy-mm-dd 00:00:00.000");//2018_01_18 碩 有from既可
                                                            //string dateto = datetime.now.tostring("yyyy-mm-dd 23:59:59.000");//2018_01_18 碩 有from既可
        static DateTime n = DateTime.Parse(DateTime.Now.ToString("yyyy-MM-01"));//2018_01_18 碩，當月月初
        string MonthEarly = n.ToString("yyyy-MM-01 00:00:00.000");//2018_01_18 碩
        public  string a1, username, userone, now, username2;
        HttpContext context = HttpContext.Current;

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            if (context.Request["mode"] != null)
            {
                string mode = context.Request["mode"].ToString();

                //Initial
                tenten(context);

                switch (mode)
                {
                    case "nine"://特 nine
                        ninehr(context);
                        break;

                    case "two"://事 two
                        two(context);
                        break;

                    case "eight":
                        eight(context);
                        break;

                    case "eightupdate":
                        eightupdate(context);
                        break;

                    case "ninehr": //特的累計
                        ninehr(context);
                        break;
                    case "ten": //補休剩餘
                        ten(context);
                        break;

                }

            }
        }

        public  void tenten(HttpContext context)
        {
            userone = context.Session["username"].ToString().Substring(0, 1);//0

            a1 = context.Session["db"].ToString();
            now = context.Session["now"].ToString();

            if (context.Session["username"].ToString().StartsWith("0") == true && context.Session["username"].ToString().Length == 5)
            {
                username = context.Session["username"].ToString().Substring(1);
            }
            else
            {
                username = context.Session["username"].ToString();
            }
        }

        /**  事假  **/
        private DataTable twotable()
        {
            tenten(context);
            string sql;
            sql = "SELECT sum(pa60011)/60 as pa60011 ";
            sql += "FROM [hrs_mis].[dbo].[WPA60] ";
            sql += "where PA60001='"+Enterprise.ConStr+"' AND PA60004 = '2' and PA60002 = '" + username + "' and PA60006 like '%" + DateTime.Now.ToString("yyyy") + "%'";

            DataSet ds = new DataSet();
            using (SqlConnection conn = new SqlConnection(hrs))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.Fill(ds);
            }


                        //TBI_HRS 的事假時數總和
            sql = @"SELECT SUM(PA60011) total_ 
FROM[TBI_HRS].[dbo].[PA123]
WHERE PA60001 = '"+Enterprise.ConStr_produceline+@"'
AND pa60043 is null
AND PA60002 = '"+username+ @"'
AND PA60004 = '2' /* 2 = 事假 */
AND PA60039 in(1,2,3,4)
";

            int sum1 = 0;
            int sum2 = 0;

            DataTable temptable1 = BOSSQL.TBIHRSExecuteQuery(sql);

            //TBI_HRS 時數
            if (temptable1.Rows[0]["total_"] != DBNull.Value)
                sum1 = int.Parse(temptable1.Rows[0]["total_"].ToString());

            //HRS_MIS 時數
            if (ds.Tables[0].Rows[0]["PA60011"] != DBNull.Value)
                sum2 = int.Parse(ds.Tables[0].Rows[0]["PA60011"].ToString());

            //合併
            ds.Tables[0].Rows[0]["PA60011"] = (sum1 + sum2)/60;


            return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
        }
        public void two(HttpContext context)
        {
            DataTable dt = this.twotable();
            string str_json = JsonConvert.SerializeObject(dt, Formatting.Indented);
            context.Response.Write(str_json);
        }

        /**  事假  **/
        /**  特休累計  **/
        public void ninehr(HttpContext context)
        {

            string sql;

            sql = @"select sum(PA86010) as PA86010, sum(PA86011) as PA86011 
                    from [hrs_mis].[dbo].[WPA86]
                    where PA86002='" + username + "' and PA86001='"+Enterprise.ConStr+"' and PA86004='"+DateTime.Now.ToString("yyyy")+"' and PA86007 <= getdate()".Replace("\r\n", "").Replace("\t", "");


            DataTable dt = new DataTable();
            dt = BOSSQL.hrsExecuteQuery(sql);


            //------------------WPA60 特休時數 + WPA123 特休時數-----------------
            //dt_wpa123 [請假仿WPA60資料表] - 取得目前特休所有剩餘時數，並和WPA86已使用時數加總
            string user = username.TrimStart('0').PadLeft(4, '0');

            string sql_wpa123 = @"/*WPA73*/
                         SELECT *
                         FROM [TBI_HRS].[dbo].[PA123]
                         where PA60001='" + conStr + @"'
                         and PA60004=9
                         and PA60043 is null
                         and PA60039  not in (0,5)
                         and PA60002='" + user + "'";

            sql_wpa123 = sql_wpa123.Replace("\r\n", "").Replace("\t", "");

            DataTable dt_wpa123 = new DataTable();

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString))
            {
                using (SqlCommand comm = new SqlCommand())
                {

                    using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
                    {
                        comm.Connection = conn;
                        comm.CommandText = sql_wpa123;
                        conn.Open();
                        adapter.Fill(dt_wpa123);
                    }
                }
            }

            float cost_wpa123 = dt_wpa123.Rows.Cast<DataRow>().Sum(z => int.Parse(z["PA60011"].ToString()));

            //設定 ReadOnly 才可更改資料
            dt.Columns["PA86011"].ReadOnly = false;

            int usedTime = 0;

            if (dt.Rows[0]["PA86011"] != DBNull.Value)
            {
                usedTime = int.Parse(dt.Rows[0]["PA86011"].ToString());
            }

            dt.Rows[0]["PA86011"] = usedTime + cost_wpa123;

            //將未來啟用時間加入傳回資料項目中
            IsFutureHasDate(dt, user);

            string str_json = JsonConvert.SerializeObject(dt, Formatting.Indented);

            context.Response.Write(str_json);

        }


        //將未來啟用時間加入傳回資料項目中
        public void IsFutureHasDate(DataTable result_dt, string user)
        {
            string sql__ = @"select PA86002,PA86007,PA86008
                          from [hrs_mis].[dbo].[WPA86]
                          where PA86002='" + user + @"'
                          and PA86001='"+Enterprise.ConStr+@"'
                          and PA86007>GETDATE()";

            sql__ = sql__.Replace("\r\n", "").Replace("\t", "");

            DataTable dt___ = new DataTable();

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString))
            {
                using (SqlCommand comm = new SqlCommand())
                {

                    using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
                    {
                        comm.Connection = conn;
                        comm.CommandText = sql__;
                        conn.Open();
                        adapter.Fill(dt___);
                    }
                }
            }

            if (dt___.Rows.Count > 0)
            {
                string EnableDate = dt___.Rows[0]["PA86007"].ToString();

                result_dt.Columns.Add("PA86007");
                result_dt.Rows[0]["PA86007"] =DateTime.Parse(EnableDate).ToString("yyyy-MM-dd");
            }
        }

        public void eight(HttpContext context)
        {
            tenten(context);
            string sql1, sql2;
            string type = context.Request["type"].ToString();
            int typetime = Convert.ToInt32(type) * 8;
            string z = DateTime.Parse(now.Substring(0, 4) + "-" + now.Substring(4, 2) + "-" + now.Substring(6, 2)).ToString("yyyy-MM-dd HH:mm:ss.fff");
            DateTime a = DateTime.Parse(z);
            sql1 = "select top 1 PA60044 from TBI_HRS.dbo.PA123 ";
            sql1 += "where pa60002 = '" + username + "' and pa60004 = '8' and pa60039 != '0' and pa60039 != '5' and pa60044 = '" + type + "' ";
            sql1 += "and pa60043 is null and pa60007 > '" + MonthEarly + "' order by pa60007 desc";
            DataTable dt = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
            if (dt.Rows.Count > 0)//判斷是否有待審中的假單
            {
                sql1 = "select sum(PA60011)as pa60011 from TBI_HRS.dbo.PA123 ";
                sql1 += "where pa60002 = '" + username + "' and pa60004 = '8' and pa60039 != '0' and pa60039 != '5' ";
                sql1 += "and pa60044 = '" + type + "' and pa60043 is null and pa60007 > '" + MonthEarly + "'";
                DataTable dc = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);//將待審中的假單的時數加總起來

                sql2 = "select top 1 timeleft,theEnd from TBI_HRS.dbo.HRS08 where username = '" + username + "' and type = '" + type + "' and timeleft != '0' order by ID desc";
                DataTable db = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);
                if (db.Rows.Count > 0)//判斷HRS08是否有剩餘時數
                {
                    DateTime b = DateTime.Parse(db.Rows[0][1].ToString());//第一百天
                    if (a > b)//登入日超過第一百天，結束這次喪假週期
                    {
                        context.Response.Write("false");
                    }
                    else
                    {
                        double timeleft = Convert.ToInt32(db.Rows[0][0]) / 60 - Convert.ToInt32(dc.Rows[0][0]) / 60;//HRS08有剩餘時數的話，可請時數：HRS08-PA123待審假單總時數
                        context.Response.Write(timeleft);
                    }
                }
                else
                {
                    double timeleft2 = typetime - Convert.ToInt32(dc.Rows[0][0]) / 60;//HRS08沒有剩餘時數的話，可請時數：天數別總時數-PA123待審假單總時數
                    context.Response.Write(timeleft2);
                }
            }
            else
            {
                sql2 = "select top 1 timeleft,theEnd from TBI_HRS.dbo.HRS08 where username = '" + username + "' and type = '" + type + "' and timeleft != '0' order by ID desc";
                DataTable db = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);
                if (db.Rows.Count > 0)//判斷HRS08是否有剩餘時數
                {
                    double timeleft3 = Convert.ToInt32(db.Rows[0][0]) / 60;
                    DateTime b = DateTime.Parse(db.Rows[0][1].ToString());//第一百天
                    if (a > b)//登入日超過第一百天，結束這次喪假週期
                    {
                        context.Response.Write("false");
                    }
                    else
                    {
                        if (timeleft3 != 0)
                        {
                            context.Response.Write(timeleft3);
                        }
                        else
                        {
                            context.Response.Write("false");
                        }
                    }
                }
                else
                {
                    context.Response.Write("false");
                }
            }
        }
        public void eightupdate(HttpContext context)
        {
            tenten(context);
            string sql1, sql2;
            string type = context.Request["type"].ToString();
            string water = context.Request["water"].ToString();
            int typetime = Convert.ToInt32(type) * 8;
            string z = DateTime.Parse(now.Substring(0, 4) + "-" + now.Substring(4, 2) + "-" + now.Substring(6, 2)).ToString("yyyy-MM-dd HH:mm:ss.fff");
            DateTime a = DateTime.Parse(z);
            sql1 = "select top 1 PA60044 from TBI_HRS.dbo.PA123 ";
            sql1 += "where pa60002 = '" + username + "' and pa60003 != '" + water + "' and pa60004 = '8' and pa60039 != '0' and pa60039 != '5' and pa60044 = '" + type + "' ";
            sql1 += "and pa60043 is null and pa60007 > '" + MonthEarly + "' order by pa60007 desc";
            DataTable dt = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
            if (dt.Rows.Count > 0)//判斷是否有待審中的假單
            {
                sql1 = "select sum(PA60011)as pa60011 from TBI_HRS.dbo.PA123 ";
                sql1 += "where pa60002 = '" + username + "' and pa60003 != '" + water + "'  and pa60004 = '8' and pa60039 != '0' and pa60039 != '5' ";
                sql1 += "and pa60044 = '" + type + "' and pa60043 is null and pa60007 > '" + MonthEarly + "'";
                DataTable dc = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);//將待審中的假單的時數加總起來

                sql2 = "select top 1 timeleft,theEnd from TBI_HRS.dbo.HRS08 where username = '" + username + "' and type = '" + type + "' and timeleft != '0' order by ID desc";
                DataTable db = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);
                if (db.Rows.Count > 0)//判斷HRS08是否有剩餘時數
                {
                    DateTime b = DateTime.Parse(db.Rows[0][1].ToString());//第一百天
                    if (a > b)//登入日超過第一百天，結束這次喪假週期
                    {
                        context.Response.Write("false");
                    }
                    else
                    {
                        double timeleft = Convert.ToInt32(db.Rows[0][0]) / 60 - Convert.ToInt32(dc.Rows[0][0]) / 60;//HRS08有剩餘時數的話，可請時數：HRS08-PA123待審假單總時數
                        context.Response.Write(timeleft);
                    }
                }
                else
                {
                    double timeleft2 = typetime - Convert.ToInt32(dc.Rows[0][0]) / 60;//HRS08沒有剩餘時數的話，可請時數：天數別總時數-PA123待審假單總時數
                    context.Response.Write(timeleft2);
                }
            }
            else
            {
                sql2 = "select top 1 timeleft,theEnd from TBI_HRS.dbo.HRS08 where username = '" + username + "' and type = '" + type + "' and timeleft != '0' order by ID desc";
                DataTable db = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);
                if (db.Rows.Count > 0)//判斷HRS08是否有剩餘時數
                {
                    double timeleft3 = Convert.ToInt32(db.Rows[0][0]) / 60;
                    DateTime b = DateTime.Parse(db.Rows[0][1].ToString());//第一百天
                    if (a > b)//登入日超過第一百天，結束這次喪假週期
                    {
                        context.Response.Write("false");
                    }
                    else
                    {
                        if (timeleft3 != 0)
                        {
                            context.Response.Write(timeleft3);
                        }
                        else
                        {
                            context.Response.Write("false");
                        }
                    }
                }
                else
                {
                    context.Response.Write("false");
                }
            }
        }
        public void ten(HttpContext context)
        {
            //------------------抓取補休-----------------
            //WPA73 [加班申請資料] - 抓補休有剩餘時數的資筆數，並把資料全部相加，取得總剩餘時數
            //WPA123 [請假仿WPA60資料表] - 取得目前補休所有剩餘時數，並和WPA73得出總剩餘時數做加總

            bool insert = context.Request["insert"] != null ? false : true;

            string user = context.Session["username"].ToString().TrimStart('0').PadLeft(4, '0');

            string sql_wpa73 = @"/*WPA73*/
                         SELECT *
                         FROM [hrs_mis].[dbo].[WPA73]
                         where PA73002='" + user + @"'
                         and PA73001='"+Enterprise.ConStr+@"'
                         and PA73011 is not null
                         and PA73013 is not null
                         and PA73013>=  DateADD(day,DATEDIFF(DAY,0,GETDATE()),0) 
                         ";
            if (insert == true)
            {
                string from = DateTime.Parse(context.Request["from"].ToString()).ToString("yyyy/MM/dd");

                sql_wpa73 += "and PA73006 < '" + from + "' ";

            }
            sql_wpa73 += " order by PA73007";


            string sql_wpa123 = @"/*WPA73*/
                         SELECT *
                         FROM [TBI_HRS].[dbo].[PA123]
                         where PA60001='" + conStr + @"'
                         and PA60004=10
                         and PA60043 is null
                         and PA60039  not in (0,5)
                         and PA60002='" + user + "'";

            sql_wpa73 = sql_wpa73.Replace("\r\n", "").Replace("\t", "");
            sql_wpa123 = sql_wpa123.Replace("\r\n", "").Replace("\t", "");

            DataSet ds = new DataSet();

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString))
            {
                using (SqlCommand comm = new SqlCommand())
                {

                    using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
                    {
                        comm.Connection = conn;
                        comm.CommandText = sql_wpa73;
                        conn.Open();
                        adapter.Fill(ds, "WPA73_u");

                    }
                }
            }

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString))
            {
                using (SqlCommand comm = new SqlCommand())
                {

                    using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
                    {
                        comm.Connection = conn;
                        comm.CommandText = sql_wpa123;
                        conn.Open();
                        adapter.Fill(ds, "WPA123_u");
                    }
                }
            }

            DataTable dt_wpa73 = ds.Tables["WPA73_u"];
            DataTable dt_wpa123 = ds.Tables["WPA123_u"];

            float rest_wpa73 = dt_wpa73.Rows.Cast<DataRow>().Sum(z => int.Parse(z["PA73011"].ToString()) - int.Parse(z["PA73012"].ToString()));
            float cost_wpa123 = dt_wpa123.Rows.Cast<DataRow>().Sum(z => int.Parse(z["PA60011"].ToString()));
            float rest = (rest_wpa73 - cost_wpa123) / 60f;

            var result = new { rest = rest };

            context.Response.Write(JsonConvert.SerializeObject(result));


        }

        /**  特休累計  **/

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}