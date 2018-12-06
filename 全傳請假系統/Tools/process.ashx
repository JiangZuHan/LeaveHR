<%@ WebHandler Language="C#" Class="全傳請假系統.process" %>


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
    /// process 的摘要描述
    /// </summary>
    public class process : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;
        string tbiHRS = ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString;
        string hrs = ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString;
        string conStr = ConfigurationManager.AppSettings["conStr"];
        static DateTime m = DateTime.Parse(DateTime.Now.AddMonths(1).ToString("yyyy-MM-01")).AddDays(-1);//2018_01_18 碩
        string from = m.ToString("yyyy-MM-dd 23:59:59.999");//2018_01_18 碩
        //string datefrom = from.ToString("yyyy-MM-dd 00:00:00.000");//2018_01_18 碩 有from既可
        //string dateto = DateTime.Now.ToString("yyyy-MM-dd 23:59:59.000");//2018_01_18 碩 有from既可
        static DateTime n = DateTime.Parse(DateTime.Now.ToString("yyyy-MM-01"));//2018_01_18 碩，當月月初
        string MonthEarly = n.ToString("yyyy-MM-01 00:00:00.000");//2018_01_18 碩

        HttpContext context = HttpContext.Current;
        public string a1, username, userone, now, PAAK200, username2;
        string sql2, level2sql, level1sql, insertsql, sql1, leavesql;

        public void tenten(HttpContext context)
        {
            userone = context.Session["username"].ToString().Substring(0, 1);//0
            PAAK200 = context.Session["PAAK200"].ToString();
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
        public void ProcessRequest(HttpContext context)
        {
            if (context.Request["mode"] != null)
            {
                string mode = context.Request["mode"].ToString();
                switch (mode)
                {
                    case "aprocess":
                        aprocess(context);
                        break;
                    case "update60":
                        update60(context);
                        break;
                    case "deathtwice":
                        deathtwice(context);
                        break;
                    case "DeathIgt":
                        DeathIgt(context);
                        break;
                    case "DeathIgtupdate":
                        DeathIgtupdate(context);
                        break;
                    case "DeathDateType":
                        DeathDateType(context);
                        break;
                    case "GetWorkHoliday":
                        GetWorkHolidayANDVacation(context);
                        break;

                }
            }
        }
        public void DeathDateType(HttpContext context)
        {
            tenten(context);
            string user = context.Request["user"].ToString();
            int hrsum = Convert.ToInt32(context.Request["hrsum"]);
            string death = context.Request["death"].ToString().Trim();
            string Dstart = context.Request["Dstart"].ToString();
            string sql, sql2;
            string z = DateTime.Parse(now.Substring(0, 4) + "-" + now.Substring(4, 2) + "-" + now.Substring(6, 2)).ToString("yyyy-MM-dd HH:mm:ss.fff");
            DateTime a = DateTime.Parse(z);//登入日

            //判斷該天數別是否還有剩餘時數&百日
            sql = "select top 1 * from [TBI_HRS].[dbo].[HRS08] where username = '" + user + "' and type = '" + death + "' order by ID desc";
            DataTable db = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql);
            if (db.Rows.Count > 0)
            {
                string timeleft = db.Rows[0][5].ToString().Trim();//剩餘時數
                int timeleftNumber = Convert.ToInt32(timeleft);
                string b = db.Rows[0][4].ToString();
                DateTime theEnd = DateTime.Parse(b);//第一百天
                DateTime start = DateTime.Parse(Dstart);
                if (a > theEnd)//如果登入日期大於百日，一律新增
                {
                    context.Response.Write("HRS insert");
                }
                else
                {
                    if (timeleft == "0")//給予新週期(insert)
                    {
                        context.Response.Write("HRS insert");
                    }
                    //else if (start > theEnd)//百日判斷
                    //{
                    //    context.Response.Write("100");
                    //}
                    else//扣舊週期(update)
                    {
                        if (hrsum > timeleftNumber && timeleft != "0")//請假時數大於剩餘時數
                        {
                            context.Response.Write("igt lefttime");//is greater than                    
                        }
                        else
                        {
                            context.Response.Write("HRS update");
                        }
                    }
                }
            }
            else
            {
                sql2 = "select top 1 pa60002,pa60003,pa60004,pa60043,pa60044,pa60047 from [TBI_HRS].[dbo].[PA123] where pa60002 = '" + user + "' ";
                sql2 += "and pa60004 = '8' and pa60043 is null and PA60039 != '5' and pa60044 like '" + death + "%' ";
                sql2 += "and pa60007 > '" + MonthEarly + "' order by pa60007 desc";
                DataTable dc = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);
                string x = DateTime.Parse(dc.Rows[0][5].ToString()).AddDays(100).ToString("yyyy-MM-dd 23:59:59.000");
                DateTime b = DateTime.Parse(x);//第一百天
                if (a > b)//如果
                {
                    context.Response.Write("HRS insert");
                }
                else
                {
                    string pa6044 = dc.Rows[0][4].ToString().Substring(0, 1);//天數別
                    int pa6044TypeAll = Convert.ToInt32(pa6044) * 8 * 60;//所選天數別總時數
                    if (hrsum > pa6044TypeAll)//選取總數超過他所選的天數總數 
                    {
                        context.Response.Write("hrsum");
                    }
                    else //沒有剩餘時數 == 給予時數
                    {
                        context.Response.Write("HRS insert");
                    }
                }
            }
        }

        public void DeathIgt(HttpContext context)
        {
            tenten(context);
            string sql1, sql2;
            string type = context.Request["type"].ToString();
            double hr = Convert.ToDouble(context.Request["hr"]);
            string z = context.Request["from"];// DateTime.Parse(process.now.Substring(0, 4) + "-" + process.now.Substring(4, 2) + "-" + process.now.Substring(6, 2)).ToString("yyyy-MM-dd HH:mm:ss.fff");
            DateTime a = DateTime.Parse(z);
            int typetime = Convert.ToInt32(type) * 8;//天數別總時數
            string Hundred = context.Request["Hundred"];
            if (hr > typetime)//單筆大於天數別總時數
            {
                context.Response.Write("igt");
            }
            else
            {
                sql2 = "select top 1 timeleft,theEnd from TBI_HRS.dbo.HRS08 where username = '" + username + "' and type = '" + type + "' and timeleft != '0' order by ID desc";
                DataTable db = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);
                if (db.Rows.Count > 0)//比較單筆時數是否超過剩餘時數(抓HRS08)
                {
                    DateTime b = DateTime.Parse(db.Rows[0][1].ToString());
                    if (a < b)//登入日小於喪假第一百天，才進行剩餘時數防呆
                    {
                        sql1 = "select sum(PA60011)as pa60011 from TBI_HRS.dbo.PA123 ";
                        sql1 += "where pa60002 = '" + username + "' and pa60004 = '8' and pa60039 != '0' and pa60039 != '5' and pa60044 = '" + type + "' and pa60043 is null ";
                        sql1 += "and pa60007 >'" + MonthEarly + "'";
                        DataTable dc = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
                        if (dc.Rows[0][0].ToString() != "")
                        {
                            double timeleft = Convert.ToInt32(db.Rows[0][0]) / 60 - Convert.ToInt32(dc.Rows[0][0]) / 60;
                            if (timeleft == 0)
                            {
                                context.Response.Write("typeover");
                            }
                            else if (hr > timeleft)
                            {
                                context.Response.Write("timeleft over1");
                            }
                            else
                            {
                                context.Response.Write("true");
                            }
                        }
                        else
                        {
                            if (hr > Convert.ToInt32(db.Rows[0][0]))
                            {
                                context.Response.Write("timeleft over1");
                            }
                            else
                            {
                                context.Response.Write("true");
                            }
                        }

                    }
                    else
                    {
                        context.Response.Write("true");
                    }
                }
                else
                {
                    // 前端訃聞日期沒有取得時
                    if (Hundred.ToUpper() == "NULL")
                    {
                        string sql_Death_GetLastestDate = @"SELECT top 1 SUM(pa60011) 目前使用時數,(PA60044*8*60)總時數,PA60047,pa60044
                                          FROM [TBI_HRS].[dbo].[PA123]
                                          where PA60002='" + username + @"'
                                          and PA60001='" + Enterprise.ConStr + @"'
                                          and PA60043 is  null
                                          group by PA60047,pa60044
                                          having SUM(pa60011)<=(PA60044*8*60)
                                          order by pa60047";

                        sql_Death_GetLastestDate = sql_Death_GetLastestDate.Replace("\r\n", "").Replace("\t", "");

                        DataTable dt_Death_GetLastestDate = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql_Death_GetLastestDate);


                        Hundred = dt_Death_GetLastestDate.Rows[0]["PA60047"].ToString();
                    }
                    // 請假日期 超過 訃聞日期 100 日 就返回錯誤(超過100日錯誤)
                    if (a > DateTime.Parse(Hundred).AddDays(100))
                    {
                        context.Response.Write("hundredover");
                        context.Response.End();
                    }

                    sql1 = "select sum(PA60011)as pa60011 from TBI_HRS.dbo.PA123 ";
                    sql1 += "where pa60002 = '" + username + "' and pa60004 = '8' and pa60039 != '0' and pa60039 != '5' and pa60044 = '" + type + "' and pa60043 is null ";
                    sql1 += "and pa60007 > '" + MonthEarly + "'";
                    DataTable dc = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
                    if (dc.Rows[0][0].ToString() != "")
                    {
                        double timeleft2 = typetime - Convert.ToInt32(dc.Rows[0][0]) / 60;//目前可請時數
                        if (timeleft2 == 0)//如果待審中的喪假已經到達該天數別的上限
                        {
                            context.Response.Write("typeover");
                        }
                        else if (hr > timeleft2)//該假單時數大於目前剩餘可請時數
                        {
                            context.Response.Write("timeleft over2");
                        }
                        else
                        {
                            context.Response.Write("true");
                        }

                    }
                    else
                    {
                        context.Response.Write("true");
                    }
                }

            }

        }
        public void DeathIgtupdate(HttpContext context)
        {
            tenten(context);
            string sql1, sql2;
            string type = context.Request["type"].ToString();
            string water = context.Request["water"].ToString();
            double hr = Convert.ToInt32(context.Request["hr"]);
            string z = DateTime.Parse(now.Substring(0, 4) + "-" + now.Substring(4, 2) + "-" + now.Substring(6, 2)).ToString("yyyy-MM-dd HH:mm:ss.fff");
            DateTime a = DateTime.Parse(z);
            int typetime = Convert.ToInt32(type) * 8;//天數別總時數
            if (hr > typetime)//單筆大於天數別總時數
            {
                context.Response.Write("igt");
            }
            else
            {
                sql2 = "select top 1 timeleft,theEnd from TBI_HRS.dbo.HRS08 where username = '" + username + "' and type = '" + type + "' and timeleft != '0' order by ID desc";
                DataTable db = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);
                if (db.Rows.Count > 0)//比較單筆時數是否超過剩餘時數(抓HRS08)
                {
                    DateTime b = DateTime.Parse(db.Rows[0][1].ToString());
                    if (a < b)//登入日小於喪假第一百天，才進行剩餘時數防呆
                    {
                        sql1 = "select sum(PA60011)as pa60011 from TBI_HRS.dbo.PA123 ";
                        sql1 += "where pa60002 = '" + username + "' and pa60003 != '" + water + "' and pa60004 = '8' and pa60039 != '0' and pa60039 != '5' and pa60044 = '" + type + "' and pa60043 is null ";
                        sql1 += "and pa60007 > '" + MonthEarly + "'";
                        DataTable dc = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
                        if (dc.Rows[0][0].ToString() != "")
                        {
                            double timeleft = Convert.ToInt32(db.Rows[0][0]) / 60 - Convert.ToInt32(dc.Rows[0][0]) / 60;
                            if (timeleft == 0)
                            {
                                context.Response.Write("typeover");
                            }
                            else if (hr > timeleft)
                            {
                                context.Response.Write("timeleft over1");
                            }
                            else
                            {
                                context.Response.Write("true");
                            }
                        }
                        else
                        {
                            if (hr > Convert.ToInt32(db.Rows[0][0]))
                            {
                                context.Response.Write("timeleft over1");
                            }
                            else
                            {
                                context.Response.Write("true");
                            }
                        }

                    }
                    else
                    {
                        context.Response.Write("true");
                    }
                }
                else
                {
                    sql1 = "select sum(PA60011)as pa60011 from TBI_HRS.dbo.PA123 ";
                    sql1 += "where pa60002 = '" + username + "' and pa60003 != '" + water + "' and pa60004 = '8' and pa60039 != '0' and pa60039 != '5' and pa60044 = '" + type + "' and pa60043 is null ";
                    sql1 += "and pa60007 > '" + MonthEarly + "'";
                    DataTable dc = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
                    if (dc.Rows[0][0].ToString() != "")
                    {
                        double timeleft2 = typetime - Convert.ToInt32(dc.Rows[0][0]) / 60;//目前可請時數
                        if (timeleft2 == 0)//如果待審中的喪假已經到達該天數別的上限
                        {
                            context.Response.Write("typeover");
                        }
                        else if (hr > timeleft2)//該假單時數大於目前剩餘可請時數
                        {
                            context.Response.Write("timeleft over2");
                        }
                        else
                        {
                            context.Response.Write("true");
                        }

                    }
                    else
                    {
                        context.Response.Write("true");
                    }
                }

            }

        }

        public void deathtwice(HttpContext context)
        {
            tenten(context);
            string y = now.Substring(0, 4);
            string o = now.Substring(4, 2);
            string p = now.Substring(6, 2);
            string z = DateTime.Parse(now.Substring(0, 4) + "-" + now.Substring(4, 2) + "-" + now.Substring(6, 2)).ToString("yyyy-MM-dd HH:mm:ss.fff");
            DateTime a = DateTime.Parse(z);
            SqlConnection conn = new SqlConnection(tbiHRS);
            conn.Open();
            string sql2 = "select top 1 type,theEnd from TBI_HRS.dbo.HRS08 where username = '" + username + "' and timeleft != '0' order by ID desc";
            DataTable db = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);
            if (db.Rows.Count > 0)//判斷HRS08是否有剩餘時數，有的話代表還有喪假的週期尚未結束
            {
                DateTime b = DateTime.Parse(db.Rows[0][1].ToString());//第一百天
                if (a < b)//登入日小於第一百天，才進行選項上鎖
                {
                    string type = db.Rows[0][0].ToString().Trim();
                    context.Response.Write(type);
                }
            }
            else
            {
                string sql = "select pa60004,pa60043,pa60044,pa60047 from [TBI_HRS].[dbo].[PA123] ";
                sql += "where pa60002 = '" + username + "' and pa60004 = '8' and pa60039 != '0' and pa60039 != '5' and pa60043 is null and pa60044 is not null ";
                sql += "and pa60007 > '" + MonthEarly + "'";
                DataTable dt = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql);
                if (dt.Rows.Count > 0)
                {
                    DateTime b = DateTime.Parse(dt.Rows[0][3].ToString());
                    DateTime c = b.AddDays(100);
                    if (a < c)//登入日小於第一百天，才進行選項上鎖
                    {
                        string pa60044 = dt.Rows[0][2].ToString();
                        context.Response.Write(pa60044);
                    }
                }
            }
        }

        private DataTable queryDataTable1()
        {
            tenten(context);
            string sql1;
            string water = context.Request["water"].ToString();
            sql1 = "select PA60039, PA60041, PA60003 ,PA60043,PA60011 from [TBI_HRS].[dbo].[PA123] where PA60002 = '" + username + "' and PA60003 = '" + water + "' ";
            sql1 += "and pa60043 is null order by PA60003 desc";
            DataSet ds = new DataSet();
            using (SqlConnection conn = new SqlConnection(this.tbiHRS))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql1, conn);
                da.Fill(ds);
            }
            return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();


        }

        public void aprocess(HttpContext context)
        {
            DataTable dt = queryDataTable1();
            string str_json = JsonConvert.SerializeObject(dt, Formatting.Indented);
            context.Response.Write(str_json);
        }


        public void update60(HttpContext context)
        {
            tenten(context);
            DataTable table = queryDataTable1();

            //將pa60043更成1，代表已看過
            SqlConnection conn = new SqlConnection(tbiHRS);
            conn.Open();
            SqlCommand s_com = new SqlCommand();

            s_com.CommandText = "update TBI_HRS.dbo.PA123 set [PA60041]='1' where [PA60002] = '" + username + "' and  [PA60003] = '" + table.Rows[0][2].ToString() + "'";

            s_com.Connection = conn;
            s_com.ExecuteNonQuery();
            conn.Dispose();
            conn.Close();



        }
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        public void GetWorkHolidayANDVacation(HttpContext context)
        {
            var WorkHoliday = Common.GetWorkHoliday();

            var Vacation = Common.GetVacation();

            var result = new { data = new { WorkHoliday = WorkHoliday, Vacation = Vacation }, msg = "" };

            context.Response.Write(JsonConvert.SerializeObject(result));
        }

        //public dynamic GetWorkHoliday(HttpContext context)
        //{
        //    //------------------例假日需補班時段-----------------
        //    //sql_wbs73 [例假日需補班時段 sql 指令] - 底下有說明
        //    //dt_wbs73 [例假日需補班時段 table ] - 取得資料
        //    //data [只取得例假日需補班時段 table 需要的欄位] - 只抓取 時間 BS73002 (轉成 yyyy/MM/dd 格式) 和 BS73003 介紹欄位資料


        //    string sql_wbs73 = @"/* BS73001 = 稅制規則,BS73001 = 區分,BS73001 = 行事曆別
        //                         補上班依據觀察 BS73001=0 , BS73004=2 , BS73005=8
        //                         就會是要補上班的日子*/
        //                            select * from [hrs_mis].[dbo].WBS73
        //                            where BS73002 
        //                            between DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0) and DATEADD(yy,DATEDIFF(yy,-1,GETDATE()),-1)
        //                            and BS73001=0 
        //                            and BS73004=2 
        //                            and BS73005=8 
        //                            order by BS73002";
        //    sql_wbs73 = sql_wbs73.Replace("\r\n", "").Replace("\t", "");

        //    DataTable dt_wbs73 = new DataTable();

        //    using (SqlConnection conn = new SqlConnection(hrs))
        //    {
        //        using (SqlCommand comm = new SqlCommand(sql_wbs73, conn))
        //        {
        //            using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
        //            {
        //                conn.Open();
        //                adapter.Fill(dt_wbs73);
        //            }
        //        }
        //    }


        //    var data = dt_wbs73.Rows.Cast<DataRow>().Select(z =>
        //    {
        //        string temp_date = DateTime.Parse(z["BS73002"].ToString()).ToString("yyyy/MM/dd");
        //        string temp_val = z["BS73003"].ToString();
        //        var temp = new { BS73002 = temp_date, BS73003 = temp_val };
        //        return temp;
        //    });

        //    return data;
        //}

        //public dynamic GetVacation(HttpContext context)
        //{
        //    //------------------國定假日時段-----------------
        //    //sql_wbs73 [國定假日時段 sql 指令] - 底下有說明
        //    //dt_wbs73 [國定假日時段 table ] - 取得資料
        //    //data [只取得國定假日時段 table 需要的欄位] - 只抓取 時間 BS73002 (轉成 yyyy/MM/dd 格式) 和 BS73003 介紹欄位資料


        //    string sql_wbs73 = @"/* BS73001 = 稅制規則,BS73001 = 區分,BS73001 = 行事曆別
        //                         補國定假日依據觀察 BS73001=0 , BS73004=0 or 1 , BS73005=7 or 9
        //                         就會是要補上班的日子*/
        //                            select * from [hrs_mis].[dbo].WBS73
        //                            where BS73002 
        //                            between DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0) and DATEADD(yy,DATEDIFF(yy,-1,GETDATE()),-1)
        //                            and BS73001=0 
        //                            and BS73004 in (0,1)
        //                            and BS73005 in (7,9)
        //                            order by BS73002";
        //    sql_wbs73 = sql_wbs73.Replace("\r\n", "").Replace("\t", "");

        //    DataTable dt_wbs73 = new DataTable();

        //    using (SqlConnection conn = new SqlConnection(hrs))
        //    {
        //        using (SqlCommand comm = new SqlCommand(sql_wbs73, conn))
        //        {
        //            using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
        //            {
        //                conn.Open();
        //                adapter.Fill(dt_wbs73);
        //            }
        //        }
        //    }

        //    var data = dt_wbs73.Rows.Cast<DataRow>().Select(z =>
        //    {
        //        string temp_date = DateTime.Parse(z["BS73002"].ToString()).ToString("yyyy/MM/dd");
        //        string temp_val = z["BS73003"].ToString();
        //        var temp = new { BS73002 = temp_date, BS73003 = temp_val };
        //        return temp;
        //    });

        //    return data;

        //}


    }
}
