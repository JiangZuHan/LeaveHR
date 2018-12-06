<%@ WebHandler Language="C#" Class="leaveuser" %>

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
using System.Threading.Tasks;
using System.Threading;
using HR.DBUtility;
using HR.DBUtility.Models;

//申請相關資料
public class Insert_form_data
{
    public string id;
    public string user;
    public string water;
    public string from;
    public string to;
    public string hr;
    public string cause;
    public string name;
    public string death1;
    public string death2;
    public string CoDpath;
    public string updeath;
    public string jobuser;

}

public class leaveuser : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    //連接資料庫
    string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;
    string tbiHRS = ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString;
    string hrs = ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString;
    string conStr = ConfigurationManager.AppSettings["conStr"];
    public static DateTime from = DateTime.Now;
    public static string datefrom = from.ToString("yyyy-MM-dd");
    public readonly bool IsDebug = Convert.ToBoolean(int.Parse(ConfigurationManager.AppSettings["IsDebug"]));//true = 測試模式 , false = 正式模式


    public static DateTime to = DateTime.Parse(DateTime.Now.AddMonths(1).ToString("yyyy-MM-01")).AddDays(-1);
    public static string dateto = to.ToString("yyyy-MM-dd");
    HttpContext context = HttpContext.Current;
    string a1, username, userone, now, PAAK200, username2;
    string sql2, level2sql, level1sql, insertsql, sql1, leavesql;
    //bossone的
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
        username2 = context.Session["username"].ToString();//給tbi的username用
    }
    public void ProcessRequest(HttpContext context)
    {

        if (context.Request["pass"] != null)
        {
            string pass = context.Request["pass"].ToString();
            switch (pass)
            {
                case "yes":
                    yespass(context);
                    break;

                case "no":
                    nopass(context);
                    break;

                case "bossone":
                    bossone(context);
                    break;

                case "bos":
                    bos(context);
                    break;

                case "user":
                    user(context);
                    break;

                case "jobagent":
                    jobagent(context);
                    break;

                case "logout":
                    logout(context);
                    break;

                case "level2":
                    level2(context);
                    break;

                case "level1":
                    level1(context);
                    break;

                case "insert":
                    insert(context);
                    break;

                case "upload":
                    upload(context);
                    break;

                case "navbar":
                    navbar(context);
                    break;

                case "dptall":
                    dptall(context);
                    break;

                case "leaveall":
                    leaveall(context);
                    break;

                case "week":
                    week(context);
                    break;

                case "update":
                    update(context);
                    break;

                case "datecheck":
                    datecheck(context);
                    break;

                case "datecheck2":
                    datecheck2(context);
                    break;

                case "gender":
                    gender(context);
                    break;

                case "delete":
                    delete(context);
                    break;

                case "chief":
                    chief(context);
                    break;

                case "uptime":
                    uptime(context);
                    break;

                case "HRupdate":
                    HRupdate(context);
                    break;

                case "HRdelete":
                    HRdelete(context);
                    break;

                case "HRupload":
                    HRupload(context);
                    break;

                //case "CheckSession":
                //    CheckSession(context);
                //    break;

                case "HRdelete_2":
                    HRdelete_2(context);
                    break;


            }

        }

    }


    //------------------查看目前 Session 狀況-----------------
    //public void CheckSession(HttpContext context)
    //{
    //    userone = context.Session["username"].ToString().Substring(0, 1);//0
    //    PAAK200 = context.Session["PAAK200"].ToString();
    //    a1 = context.Session["db"].ToString();
    //    now = context.Session["now"].ToString();
    //    if (context.Session["username"].ToString().StartsWith("0") == true && context.Session["username"].ToString().Length == 5)
    //    {
    //        username = context.Session["username"].ToString().Substring(1);
    //    }
    //    else
    //    {
    //        username = context.Session["username"].ToString();
    //    }
    //    context.Response.Write("username:" + context.Session["username"] + "\n");
    //    context.Response.Write("PAAK200:" + context.Session["PAAK200"] + "\n");
    //    context.Response.Write("db:" + context.Session["db"] + "\n");
    //    context.Response.Write("now:" + context.Session["now"] + "\n");
    //}


    public void delete(HttpContext context)
    {
        string deletebtn = context.Request["deletebtn"].ToString();
        string pa60002 = context.Request["pa60002"].ToString();
        string id = context.Request["id"].ToString();
        string from = context.Request["from"].ToString();
        string to = context.Request["to"].ToString();
        string hr = context.Request["hr"].ToString();
        string cause = context.Request["cause"].ToString();
        string name = context.Request["name"].ToString();
        string[] A = from.Split('T');
        string[] B = to.Split('T');
        string datefrom = A[0] + " " + A[1];
        string dateto = B[0] + " " + B[1];

        LeaveApplicationForm modal1 = Common.Get_LeaveApplicationForm(deletebtn, pa60002, Enterprise.ConStr);

        //課級以上有審核過  之假單都不可刪除
        if (modal1.status != 1)
        {
            context.Response.Write(JsonConvert.SerializeObject(new { status = 1, content = "此假單已不可刪除，若要刪除請聯繫人資" }));

            return;
        }


        SqlConnection conn = new SqlConnection(tbiHRS);
        conn.Open();
        SqlCommand s_com = new SqlCommand();

        s_com.CommandText = "update TBI_HRS.dbo.PA123 set [PA60043]='1' where PA60001='" + Enterprise.ConStr + "' AND [PA60002] = '" + pa60002 + "' and  [PA60003] = '" + deletebtn + "'";

        s_com.Connection = conn;
        s_com.ExecuteNonQuery();

        conn.Close();
        var task1 = Task.Factory.StartNew(() =>
        {
            SqlConnection cob = new SqlConnection(tbi);
            cob.Open();//開啟資料庫
            string sql2 = "select CNname, Email from [tbi].[dbo].[Users] where username='" + username2 + "'";
            SqlCommand tbii = new SqlCommand(sql2, cob);
            DataTable dt = new DataTable();
            dt.Load(tbii.ExecuteReader());
            if (dt.Rows.Count > 0 && dt.Rows[0][1].ToString() != "")
            {
                string idcn = "select top 1 PA25008 from [hrs_mis].[dbo].[WPA25] where PA25001='" + Enterprise.ConStr + "' AND PA25003 = '" + id + "'";
                DataTable cnn = new DataTable();
                cnn = BOSSQL.hrsExecuteQuery(idcn);
                DataTable bt = new DataTable();
                string mailsql;
                mailsql = " select LUSERID, SUSERID, DUSERID, MUSERID from [tbi].[dbo].[Users],[tbi].[dbo].[XSingOrd], [tbi].[dbo].[Winton_mf2000] ";
                mailsql += "where a2 = ProgNo and mf200 = STN_WORK and a1 = '" + a1.Trim() + "' and a1 = hrs ";
                mailsql += "and username = '" + username2 + "'";
                bt = BOSSQL.ExecuteQuery(mailsql);

                DataTable cn = new DataTable();
                string mailname;
                mailname = " select CNname, Email from [tbi].[dbo].[Users] where (username = '" + bt.Rows[0]["SUSERID"].ToString() + "' ";
                mailname += "or username = '" + bt.Rows[0]["DUSERID"].ToString() + "' or username = '" + bt.Rows[0]["MUSERID"].ToString() + "' ";
                mailname += "or username = '" + bt.Rows[0]["LUSERID"].ToString() + "' ) and username != '" + username2 + "'";
                cn = BOSSQL.ExecuteQuery(mailname);

                for (int k = 0; k < cn.Rows.Count; k++)
                {
                    if (cn.Rows[k]["Email"].ToString() != "")
                    {
                        //SmtpClient smtp = new SmtpClient();
                        //MailMessage msg = new MailMessage();
                        //msg.CC.Add(new MailAddress("a22931628@tbimotion.com.tw", "主管"));
                        //msg.From = new MailAddress(dt.Rows[0]["Email"].ToString(), dt.Rows[0]["CNname"].ToString());  /// 寄件者的信箱,寄件者的名字
                        ////msg.To.Add(new MailAddress("a22931628@tbimotion.com.tw", "主管"));    ///收件者
                        //msg.To.Add(new MailAddress(cn.Rows[k]["Email"].ToString(), cn.Rows[k]["CNname"].ToString()));    //收件者
                        //msg.Subject = "取消請假通知單"; // 主旨
                        //msg.Body = "請假資訊：\n假別：" + cnn.Rows[0][0].ToString() + "\n請假起迄：" + datefrom + " 至 " + dateto + "\n請假時數：" + hr + "小時\n備註：" + cause + "\n職務代理人：" + name + "\n\n\n此筆假單已刪除，請貴主管無需做簽核動作\n此為系統自動發送，請勿直接回覆"; // 內文

                        //smtp.SendCompleted += (sender, e) =>
                        //{

                        //    string ApplyUser = e.UserState.ToString().Split(';')[0];

                        //    string to_ = e.UserState.ToString().Split(';')[1];

                        //    string Type_ = "取消請假通知單";

                        //    string CRUD = "Delete";

                        //    FinishSendEamil_Event(ApplyUser, to_, Type_, CRUD);
                        //};
                        //string userState = dt.Rows[0]["CNname"].ToString() + ";" + cn.Rows[k]["CNname"].ToString();

                        //if (this.IsDebug != true) smtp.SendAsync(msg, userState);


                        Dictionary<string, string> to_list = new Dictionary<string, string>();
                        to_list.Add(cn.Rows[k]["CNname"].ToString(), cn.Rows[k]["Email"].ToString());

                        string body = "請假資訊：\n假別：" + cnn.Rows[0][0].ToString() + "\n請假起迄：" + datefrom + " 至 " + dateto + "\n請假時數：" + hr + "小時\n備註：" + cause + "\n職務代理人：" + name + "\n\n\n此筆假單已刪除，請貴主管無需做簽核動作\n此為系統自動發送，請勿直接回覆"; // 內文

                        Common.SendMail(to_list, "取消請假通知單", body);
                    }
                }
            }
            tbii.Cancel();
            cob.Dispose();
            cob.Close();
        });
        Thread.Sleep(500);


        context.Response.Write(JsonConvert.SerializeObject(new { status = 99, content = "此假單已刪除成功" }));
    }
    private DataRow GetMail(string username, HttpContext context)
    {
        tenten(context);
        DataTable dt = BOSSQL.ExecuteQuery(@"Declare @x nvarchar(50)
                                                set @x='" + this.username + @"'
                                                SELECT CNname,Email
                                                FROM [tbi].[dbo].[Users]
                                                where RIGHT('0000000' + SUBSTRING(@x, PATINDEX('%[^0]%', @x), LEN(@x)), 5)=Username");

        DataRow maill = dt.Rows[0];

        return maill;
    }
    public void HRdelete(HttpContext context)
    {//人資專用delete
        string deletebtn = context.Request["deletebtn"].ToString();
        string pa60002 = context.Request["pa60002"].ToString();
        string id = context.Request["id"].ToString();
        string from = context.Request["from"].ToString();
        string to = context.Request["to"].ToString();
        string hr = context.Request["hr"].ToString();
        string cause = context.Request["cause"].ToString();
        string pa39 = context.Request["pa39"].ToString();
        string nopass = context.Request["nopass"].ToString();

        DataRow FromMail = GetMail(username2, context);

        DataRow ToMail = GetMail(pa60002, context);



        string cnn_sql = "select cnname from [tbi].[dbo].[Users] where username = '" + username2 + "'";
        DataTable cnn_dt = BOSSQL.ExecuteQuery(cnn_sql);

        string sql_pa123_del = "UPDATE TBI_HRS.dbo.PA123 SET PA60039 = '5', PA60042 = '" + cnn_dt.Rows[0]["cnname"].ToString() + "：" + nopass + "' WHERE PA60002 = '" + pa60002 + "' AND PA60003 = '" + deletebtn + "'";

        using (SqlConnection conn = new SqlConnection(tbiHRS))
        {
            using (SqlCommand comm = new SqlCommand(sql_pa123_del, conn))
            {
                conn.Open();
                comm.ExecuteNonQuery();
            }
        }

        //SmtpClient smtp = new SmtpClient();
        //MailMessage msg = new MailMessage();
        //msg.From = new MailAddress(FromMail["Email"].ToString(), FromMail["CNname"].ToString());  /// 寄件者的信箱,寄件者的名字
        //msg.To.Add(new MailAddress(ToMail["Email"].ToString(), ToMail["CNname"].ToString()));    ///收件者
        ////msg.To.Add(new MailAddress("a22931628@tbimotion.com.tw", "總經理"));
        //msg.Subject = "退件通知單"; // 主旨
        //msg.Body = "申請者 : " + pa60002 + " ,申請 " + from + " ~ " + to + " 資料，因為 " + nopass + " 所以人資判定退件，請重新申請.";

        //smtp.SendCompleted += (sender, e) =>
        //{

        //    string ApplyUser = e.UserState.ToString().Split(';')[0];

        //    string to_ = e.UserState.ToString().Split(';')[1];

        //    string Type_ = "人資退件通知單";

        //    string CRUD = "Delete";

        //    FinishSendEamil_Event(ApplyUser, to_, Type_, CRUD);
        //};
        //string userState = FromMail["CNname"].ToString() + ";" + ToMail["CNname"].ToString();
        //if (this.IsDebug != true) smtp.SendAsync(msg, userState);


        Dictionary<string, string> to_list = new Dictionary<string, string>();
        to_list.Add(ToMail["CNname"].ToString(), ToMail["Email"].ToString());

        string body = "申請者 : " + pa60002 + " ,申請 " + from + " ~ " + to + " 資料，因為 " + nopass + " 所以人資判定退件，請重新申請.";

        Common.SendMail(to_list, "人資退件通知單", body);
    }
    public void HRdelete_2(HttpContext context)
    {
        ////人資刪除
        //string user = context.Request["user"].ToString();
        //string id = context.Request["id"].ToString();


        //string sql_pa123_del = "UPDATE TBI_HRS.dbo.PA123 SET PA60043 = '1' WHERE PA60002 = '" + user + "' AND PA60003 = '" + id + "'";
        //using (SqlConnection conn = new SqlConnection(tbiHRS))
        //{
        //    using (SqlCommand comm = new SqlCommand(sql_pa123_del, conn))
        //    {
        //        conn.Open();
        //        comm.ExecuteNonQuery();
        //    }
        //}




        tenten(context);

        //最高主管刪除
        string Applyuser = context.Request["user"].ToString();
        string water = context.Request["id"].ToString();
        string type = context.Request["TYP"].ToString();
        string STN_WORK;
        string ProgNo;

        string sql = @"
select Username,CNname, STN_WORK,ProgNo 
from tbi.dbo.users u 
join tbi.dbo.Winton_mf2000 mf on u.a1 = mf.hrs 
join tbi.dbo.XSingOrd x on mf.mf200 = x.STN_WORK  and u.a2 = x.ProgNo 
where username = '" + username2 + "'";
        DataTable temp2 = BOSSQL.ExecuteQuery(sql);


        STN_WORK = temp2.Rows.Count > 0 ? temp2.Rows[0]["STN_WORK"].ToString() : "";

        ProgNo = temp2.Rows.Count > 0 ? temp2.Rows[0]["ProgNo"].ToString() : "";


        if (STN_WORK == "" || ProgNo == "")
        {
            return;
        }

        //確認是暫存資料庫的單，而不是文中資料庫的單子
        if (type.ToUpper() != "TBIHRS")
        {
            context.Response.Write("此單不可刪除");
            return;
        }


        LeaveApplicationForm temp = Common.Get_LeaveApplicationForm(water, Applyuser, Enterprise.ConStr);

        ProgNo = temp.lProgNo ?? ProgNo;


        if (Common.CheckIsSupervisor(username2))
        {

            string sql_pa123_del = "UPDATE TBI_HRS.dbo.PA123 SET PA60043 = '1' WHERE PA60002 = '" + Applyuser + "' AND PA60003 = '" + water + "'";
            using (SqlConnection conn = new SqlConnection(tbiHRS))
            {
                using (SqlCommand comm = new SqlCommand(sql_pa123_del, conn))
                {
                    conn.Open();
                    comm.ExecuteNonQuery();
                }
            }
            Common.ReplyDeleteData(temp);
        }
        else if (Common.JudgePosition(username, Common.Get_XSingOrd(STN_WORK, ProgNo)) == Position.MUSER)
        {

            //確認是否可銷假
            if (temp.status != 0)
            {
                context.Response.Write("此單審核狀態無法做銷假動作");

                return;
            }

            string ApplyUser = temp.CNname;
            string ApplyTime = string.Format(DateTime.Parse(temp.start_).ToString("yyyy/MM/dd HH:mm") + " ~ " + DateTime.Parse(temp.end_).ToString("yyyy/MM/dd HH:mm"));
            string holiday_type_name = temp.holiday_type_name;
            string Cause = temp.Cause;
            int Total_min = temp.Total_min;
            string CNname = context.Session["CNname"].ToString();

            Dictionary<string, string> to_list = new Dictionary<string, string>();
            to_list.Add("吳佳珊", "js0324071@tbimotion.com.tw");
            to_list.Add("林砡正", "zheng19960910@tbimotion.com.tw");


            string body = string.Format(@"
銷單資訊
                                
姓名: " + ApplyUser + @"
日期: " + ApplyTime + @"
假別: " + holiday_type_name + @"
事由: " + Cause + @"
時數: " + Total_min + @" 分鐘

核准銷單主管: " + CNname + @"

煩請人資確認");


            Common.SendMail(to_list, "主管銷假作業", body);

            string sql_pa123_del = "UPDATE TBI_HRS.dbo.PA123 SET PA60043 = '1' WHERE PA60002 = '" + Applyuser + "' AND PA60003 = '" + water + "'";
            using (SqlConnection conn = new SqlConnection(tbiHRS))
            {
                using (SqlCommand comm = new SqlCommand(sql_pa123_del, conn))
                {
                    conn.Open();
                    comm.ExecuteNonQuery();
                    context.Response.Write("銷假 申請成功，等待人資處理");
                }
            }
            Common.ReplyDeleteData(temp);

        }
        else
        {
            context.Response.Write("非此單可銷假最高主管");
        }
    }
    private DataTable queryDataTable10()
    {
        tenten(context);
        string sql7;
        sql7 = @"select p.pa60007 ,p.pa60008 from  [TBI_HRS].[dbo].[PA123] P where p.pa60002 = '" + username + "' and p.pa60039 != '5' and p.pa60043 is null";
        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.tbiHRS))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql7, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }
    public void datecheck(HttpContext context)
    {
        DataTable dt = queryDataTable10();
        string str_json = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(str_json);
    }
    private DataTable queryDataTable11()
    {
        tenten(context);
        string user60003 = context.Request["user60003"].ToString();
        string pa39 = context.Request["pa39"].ToString();
        string sql7;
        if (pa39 != "null")
        {
            sql7 = @"select p.pa60007 ,p.pa60008 from [TBI_HRS].[dbo].[PA123] P where p.pa60002 = '" + username + "' and p.pa60039 != '5' and p.pa60043 is null and p.pa60003 != '" + user60003 + "'";
        }
        else
        {
            sql7 = @"select p.pa60007 ,p.pa60008 from [hrs_mis].[dbo].[WPA60] P where p.pa60001='" + Enterprise.ConStr + "' AND p.pa60002 = '" + username + "' and p.pa60003 != '" + user60003 + "'";
        }
        DataSet ds = new DataSet();
        if (pa39 != "null")
        {
            using (SqlConnection conn = new SqlConnection(this.tbiHRS))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql7, conn);
                da.Fill(ds);
            }
        }
        else
        {
            using (SqlConnection conn = new SqlConnection(this.hrs))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql7, conn);
                da.Fill(ds);
            }
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }
    public void datecheck2(HttpContext context)
    {
        DataTable dt = queryDataTable11();
        string str_json = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(str_json);
    }
    public void logout(HttpContext context)
    {
        context.Session.Abandon();
    }
    //導航欄navbar的datatable
    private DataTable queryDataTable6()
    {
        tenten(context);
        string sql6;
        sql6 = "SELECT U.CNname , U.a1,W.PAAK003,U.zfbNO FROM tbi.dbo.Users U, tbi.dbo.WPAAK W WHERE U.q1 = W.PAAK002 AND U.Username = '" + username2 + "'";
        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.tbi))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql6, conn);
            da.Fill(ds);
        }

        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }
    //導航欄navbar回傳
    public void navbar(HttpContext context)
    {

        tenten(context);

        if (username2.ToString() != "")
        {
            DataTable dt = this.queryDataTable6();
            if (dt != null)
            {
                SqlConnection Conn = new SqlConnection(tbi);//建立名為conn的連結物件
                Conn.Open();//開啟資料庫
                string sqlstr = "SELECT * FROM Winton_mf2000 where id='" + dt.Rows[0]["zfbNO"].ToString() + "'";/*and online = '1'*/
                SqlCommand cmd = new SqlCommand(sqlstr, Conn);
                SqlDataReader dr = cmd.ExecuteReader();
                dr.Read();
                if (username2 == "A01")
                {
                    context.Session["label3"] = dt.Rows[0][0].ToString() + " " + dt.Rows[0][2].ToString() + "，您好！";
                    context.Session["label9"] = "單位：董事長室";
                    context.Session["label10"] = "工號：" + username2;
                }
                else if (username2 == "A02")
                {
                    context.Session["label3"] = dt.Rows[0][0].ToString() + " " + dt.Rows[0][2].ToString() + "，您好！";
                    context.Session["label9"] = "單位：總經理室";
                    context.Session["label10"] = "工號：" + username2;

                }
                else
                {
                    context.Session["label3"] = dt.Rows[0][0].ToString() + " " + dt.Rows[0][2].ToString() + "，您好！";
                    context.Session["label9"] = "單位：" + dr["CONTEN"].ToString();
                    context.Session["label10"] = "工號：" + username2;

                }

                cmd.Cancel();
                dr.Close();
                Conn.Close();
            }
            context.Response.Write(context.Session["label3"].ToString() + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + context.Session["label9"].ToString() + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + context.Session["label10"].ToString() + "&nbsp;&nbsp;&nbsp;&nbsp;");
        }
        else
        {
            context.Response.Redirect("Login.aspx");//沒有session就回傳0到前端做判斷返回Login的動作，但沒有session的話，if(leaveruser.username2)也會沒有值，因而根本不會進到這層if來
        }
    }
    //部門人數
    private DataTable queryDataTable7()
    {
        tenten(context);
        string sql7;
        sql7 = "select COUNT(username)as dpt from [tbi].[dbo].[Users] where a1 = '" + a1 + "' and DAT_LIME >'" + now + "'";
        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.tbi))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql7, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }
    public void dptall(HttpContext context)
    {
        DataTable dt = this.queryDataTable7();
        string str_json = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(str_json);
    }
    //請假人數
    private DataTable queryDataTable8()
    {
        tenten(context);
        string sql8;
        string abcd;
        List<string> week = new List<string>();
        DataSet ds = new DataSet();
        string userlogweek = DateTime.Now.ToString("ddd");
        string userlogweek2 = userlogweek.Substring(1);
        if (userlogweek2 == "一")
        {
            for (int i = 1; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }

            }
            for (int i = 0; i < 6; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
        }
        else if (userlogweek2 == "二")
        {
            for (int i = 2; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
            for (int i = 0; i < 5; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
        }
        else if (userlogweek2 == "三")
        {
            for (int i = 3; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
            for (int i = 0; i < 4; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
        }
        else if (userlogweek2 == "四")
        {
            for (int i = 4; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
            for (int i = 0; i < 3; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
        }
        else if (userlogweek2 == "五")
        {
            for (int i = 5; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
            for (int i = 0; i < 2; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
        }
        else if (userlogweek2 == "六")
        {
            for (int i = 6; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
            for (int i = 0; i < 1; i++)
            {

                abcd = DateTime.Now.AddDays(i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
        }
        else if (userlogweek2 == "日")//在這天登入要列出未來六天的結果
        {

            for (int i = 0; i < 7; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy-MM-dd");
                sql8 = "SELECT COUNT(DISTINCT pa60002)as leave FROM [TBI_HRS].[dbo].[PA123], [tbi].[dbo].[Users] where DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 08:00:00.000' between PA60007 and PA60008 and pa60039 = '0' or DAT_LIME > '" + now + "' and username like '%'+(PA60002) and a1='" + a1 + "' and '" + abcd + " 17:00:00.000' between PA60007 and PA60008 and pa60039 = '0'";
                using (SqlConnection conn = new SqlConnection(this.tbiHRS))
                {
                    SqlDataAdapter da = new SqlDataAdapter(sql8, conn);
                    da.Fill(ds);
                }
            }
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }
    public void leaveall(HttpContext context)
    {
        DataTable dt = this.queryDataTable8();
        string str_json = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(str_json);
    }


    //一週日期
    public void week(HttpContext context)
    {
        string abcd;
        List<string> week = new List<string>();
        string userlogweek = DateTime.Now.ToString("ddd");
        string userlogweek2 = userlogweek.Substring(1);
        if (userlogweek2 == "一")
        {
            for (int i = 1; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);

            }
            for (int i = 0; i < 6; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            string result = JsonConvert.SerializeObject(week);
            context.Response.Write(result);

        }
        else if (userlogweek2 == "二")
        {
            for (int i = 2; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            for (int i = 0; i < 5; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            string result = JsonConvert.SerializeObject(week);
            context.Response.Write(result);

        }
        else if (userlogweek2 == "三")
        {
            for (int i = 3; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            for (int i = 0; i < 4; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            string result = JsonConvert.SerializeObject(week);
            context.Response.Write(result);

        }
        else if (userlogweek2 == "四")
        {
            for (int i = 4; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            for (int i = 0; i < 3; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            string result = JsonConvert.SerializeObject(week);
            context.Response.Write(result);
        }
        else if (userlogweek2 == "五")
        {
            for (int i = 5; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            for (int i = 0; i < 2; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            string result = JsonConvert.SerializeObject(week);
            context.Response.Write(result);
        }
        else if (userlogweek2 == "六")
        {
            for (int i = 6; i > 0; i--)
            {
                abcd = DateTime.Now.AddDays(-i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            for (int i = 0; i < 1; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            string result = JsonConvert.SerializeObject(week);
            context.Response.Write(result);
        }
        else if (userlogweek2 == "日")//在這天登入要列出未來六天的結果
        {

            for (int i = 0; i < 7; i++)
            {
                abcd = DateTime.Now.AddDays(i).ToString("yyyy/MM/dd ddd");
                week.Add(abcd);
            }
            string result = JsonConvert.SerializeObject(week);
            context.Response.Write(result);
        }
    }


    //職代
    private DataTable queryDataTable4()
    {
        tenten(context);
        int paak = Convert.ToInt32(PAAK200);
        string sql4;
        DataSet ds = new DataSet();

        if (a1 == "H01" || a1 == "H0112")
        {
            //生管  &  線軌生管組
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where (a1 = 'H01' or a1 = 'H0112') and DAT_LIME > '" + now + "' and username != '" + username2 + "'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (paak > 48)
        {
            sql4 = "SELECT username,(username+' / '+ cnname)as name, a1, DAT_LIME, q1, Paak200 FROM [tbi].[dbo].[Users],[tbi].[dbo].[WPAAK] where a1 = '" + a1 + "' and DAT_LIME > '" + now + "' and Username != '" + username2 + "' and q1 = paak002";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "A02")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = 'A01'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }

            //name.Items.Add("A01 / 李清崑");

        }
        else if (username2 == "02031")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '01477'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "01358")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '02462'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00609")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '02642'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "01477")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '02031'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "01460")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '01477'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00105")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '00966'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00819")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '01477'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "02695")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '02625'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "02494")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '01131'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "02670")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '00399'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "01321")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '01134'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00215")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '00220'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00220")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '00215'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "02100")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '00449'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00204")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '00771'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00027")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '00458'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00458")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '00463'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00463")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '00458'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "02105")
        {
                //jungle
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '01390'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "00001")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username = '02695'";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else if (username2 == "02746")
        {
            sql4 = "select (username +' / '+cnname) as name from [tbi].[dbo].[Users] where username in ('02745','03188','02670') ";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }
        }
        else
        {
            sql4 = "SELECT username,(username+' / '+ cnname)as name, a1, DAT_LIME, q1 FROM [tbi].[dbo].[Users] where a1 = '" + a1 + "' and DAT_LIME > '" + now + "' and Username != '" + username2 + "' ";
            using (SqlConnection conn = new SqlConnection(this.tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql4, conn);
                da.Fill(ds);
            }

        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();

    }
    public void bossone(HttpContext context)
    {
        //DataTable dt2 = new DataTable();
        //string sql, sql2;

        //sql2 = " select ProgNo, LUSERID, SUSERID, DUSERID, MUSERID ";
        //sql2 += "from [tbi].[dbo].[Users], [tbi].[dbo].[XSingOrd], [tbi].[dbo].[WPAAK], [tbi].[dbo].[Winton_mf2000] ";
        //sql2 += "where PAAK200 <= '38' and PAAK002 = q1 and a1 = hrs and mf200 = STN_WORK ";
        //sql2 += "order by STN_WORK ";
        //dt2 = BOSSQL.ExecuteQuery(sql2);

        //DataTable dt = new DataTable();
        ////sql += "";
        //sql = "select PA60002, CNname, PA60004, PA60007, PA60008, PA60016, PA60038, PA60011, PA60003, PA60039, PA60040, PA60044 ";
        //sql += "from [tbi].[dbo].[Users], [TBI_HRS].[dbo].[PA123] ";
        ////sql += "PA60007 > '" + DateTime.Now.ToString("yyyy-MM-01") + "' ";
        //sql += "where (username = '0' + PA60002 or username = PA60002) ";
        //sql += "and PA60039 != '0' and PA60039 != '5' and PA60043 is null ";
        ////sql += "and (PA60011 > '1440' or (PA60007 between '1900-01-01' and '2999-12-31' and PA60039 != '1') ";
        //sql += "and ( (PA60011 > '1440' and PA60039>=4 /*一定要給經理以上核過才會出現在總經理待審核資料裡面*/)  ";


        //for (int i = 0; i < dt2.Rows.Count; i++)
        //{
        //    if (dt2.Rows[i]["DUSERID"].ToString() == "01321")
        //    {
        //        sql += "";
        //    }
        //    if ((dt2.Rows[i]["DUSERID"].ToString() != "" && dt2.Rows[i]["MUSERID"].ToString() == "") ||
        //       (dt2.Rows[i]["DUSERID"].ToString() == "" && dt2.Rows[i]["MUSERID"].ToString() != ""))
        //    {
        //        if (dt2.Rows[i]["DUSERID"].ToString() != "" && dt2.Rows[i]["MUSERID"].ToString() == "")
        //        {
        //            string temp = dt2.Rows[i]["DUSERID"].ToString().Substring(1);
        //            sql += "or PA60002 = '" + temp + "' ";
        //        }
        //        else if (dt2.Rows[i]["DUSERID"].ToString() == "" && dt2.Rows[i]["MUSERID"].ToString() != "" ||
        //                dt2.Rows[i]["DUSERID"].ToString() != "" && dt2.Rows[i]["MUSERID"].ToString() != "")
        //        {
        //            string temp = dt2.Rows[i]["MUSERID"].ToString().Substring(1);
        //            sql += "or PA60002 = '" + temp + "' ";
        //        }
        //    }
        //    else if (dt2.Rows[i]["DUSERID"].ToString() != "" && dt2.Rows[i]["MUSERID"].ToString() != "")
        //    {
        //        sql += "or pa60002 = '" + dt2.Rows[i]["DUSERID"].ToString().Substring(1) + "' ";
        //        sql += "or pa60002 = '" + dt2.Rows[i]["MUSERID"].ToString().Substring(1) + "' ";
        //    }
        //}
        //sql += "or q1 = '04' or zfbNO=2 /*zfbNO=>2 總經理室都直接撈出來*/ ";

        //sql += "or PA60002 in  (select RIGHT(username, 4) from tbi.dbo.Users join tbi.dbo.WPAAK on Users.q1=WPAAK.PAAK002 where WPAAK.PAAK200<=38 AND Username not in('A01','A02')/*總經理、董事長 不需要包括在裡面*/) /*撈出所有副理以上的人員*/ ";

        //sql += " )order by CNname,PA60004,PA60007";

        //dt = BOSSQL.ExecuteQuery(sql);

        DataTable dt = Administrator.GetValue(context, Identity.Administrator);//  BOSSONE.GetValue(Identity.Administrator);

        //在DataTable新增一個新欄位，拿來放中文假別
        dt.Columns.Add("abc");
        //新增兩個欄位，拿來放正確格式的日期
        dt.Columns.Add("datefrom");
        dt.Columns.Add("dateto");
        dt.Columns.Add("hrtime");

        dt.Columns.Add("PA604");
        string pa604;
        string datefrom = null;
        string dateto = null;

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            pa604 = dt.Rows[i]["PA60004"].ToString();
            this.sql2 = "select top 1 pa25008 from hrs_mis.dbo.wpa25 where PA25001='" + Enterprise.ConStr + "' AND pa25003 = '" + pa604 + "'";
            SqlConnection corr = new SqlConnection(hrs);//建立名為conn的連結物件
            corr.Open();
            SqlCommand tdiii = new SqlCommand(this.sql2, corr);
            DataTable doublecheck = new DataTable();
            doublecheck.Load(tdiii.ExecuteReader());
            dt.Rows[i]["PA604"] = doublecheck.Rows[0][0].ToString();


            //時數
            double hr = Convert.ToDouble(dt.Rows[i]["PA60011"].ToString());
            dt.Rows[i]["hrtime"] = Convert.ToDouble(hr / 60);

            //日期

            datefrom = DateTime.Parse(dt.Rows[i]["PA60007"].ToString()).ToString("yyyy/MM/dd HH:mm:ss dddd");
            dt.Rows[i]["datefrom"] = datefrom;
            dateto = DateTime.Parse(dt.Rows[i]["PA60008"].ToString()).ToString("yyyy/MM/dd HH:mm:ss dddd");
            dt.Rows[i]["dateto"] = dateto;


            tdiii.Cancel();
            corr.Dispose();
            corr.Close();
        }


        //將DataTable轉成JSON字串
        string str_json1 = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(str_json1);
    }


    private DataTable queryDataTable2()
    {
        //一般主管
        tenten(context);
        DataTable dt = new DataTable();

        //開始篩選 分兩次篩選 
        //第一次用 SQL 方式篩選 
        //第二次用 C# 方式篩選

        //第一次篩選(SQL 方式)
        string sql = @"Declare 
                       @x nvarchar(50)
                       select @x='" + username2 + @"' 
                       
                       select u.Username,pa123.PA60039,pa123.PA60002, u.CNname, pa123.PA60004, pa123.PA60007, pa123.PA60008, pa123.PA60016, pa123.PA60038,pa123.PA60011, pa123.PA60003, pa123.PA60039, pa123.PA60040, pa123.PA60044,XSing.*,wpaak.PAAK200
                       from (select * from TBI_HRS.dbo.PA123 where PA60039=0 or PA60039=1 or PA60039=2 or PA60039=3 or PA60039=4 or PA60039=5 ) pa123                    
                       join  tbi.dbo.Users u on                      (                    RIGHT(REPLICATE('0', 8) + CAST(pa123.PA60002 as NVARCHAR), 3)= u.Username or                    RIGHT(REPLICATE('0', 8) + CAST(pa123.PA60002 as NVARCHAR), 5)= u.Username or                    RIGHT(REPLICATE('0', 8) + CAST(pa123.PA60002 as NVARCHAR), 6)= u.Username                    )                    
                       join tbi.dbo.Winton_mf2000 w_mf2000 on u.a1=w_mf2000.hrs                    
                       join tbi.dbo.XSingOrd XSing on                     
                       (                    
                       w_mf2000.mf200=XSing.STN_WORK  
                       and                    
                       u.a2=XSing.ProgNo                    
                       )
                       join [tbi].[dbo].[WPAAK] wpaak on u.q1=wpaak.PAAK002                
                       where
                       (CASE 
                       	WHEN 50<=wpaak.PAAK200 and wpaak.PAAK200<=99 /*課長以下*/
                       	THEN 
                       		(CASE
                                        
                                         WHEN GUSERID = @x 
                                            THEN (CASE 
                       								WHEN ((pa123.pa60011/60)/8.0)>3 AND PA60039<=4
                       								THEN 'T'
                       							END)
                       				  WHEN MUSERID = @x 
                                            THEN (CASE 
                       								WHEN /*((pa123.pa60011/60)/8.0)>2 AND */PA60039<=3
                       								THEN 'T'
                       							END)
                       				  WHEN DUSERID = @x 
                                            THEN (CASE 
                       								WHEN /*((pa123.pa60011/60)/8.0)>1 AND*/ PA60039<=2
                       								THEN 'T'
                       							END)
                       				  WHEN SUSERID = @x 
                                            THEN (CASE 
                       								WHEN /*((pa123.pa60011/60)/8.0)<=1 AND*/ PA60039<=1
                       								THEN 'T'
                       							END)
                       	
                       		END)
                       	WHEN 39<=wpaak.PAAK200 and wpaak.PAAK200<=48 /*課長階級*/
                       	THEN 
                       		(CASE
                       
                                         WHEN GUSERID = @x 
                                            THEN (CASE 
                       								WHEN ((pa123.pa60011/60)/8.0)>3 AND PA60039<=4
                       								THEN 'T'
                       							END)
                       				    WHEN MUSERID = @x 
                                            THEN (CASE 
                       								WHEN /*((pa123.pa60011/60)/8.0)<=3 AND*/ PA60039<=3
                       								THEN 'T'
                       							END)
                       				    WHEN DUSERID = @x 
                                            THEN (CASE 
                       								WHEN /*((pa123.pa60011/60)/8.0)<=3 AND*/ PA60039<3
                       								THEN 'T'
                       							END)
                       	
                       		END)
                       	WHEN 10<=wpaak.PAAK200 and wpaak.PAAK200<=38 /*副理經理階級*/
                       	THEN 
                       		(CASE
                       				    WHEN MUSERID = @x 
                                            THEN (CASE 
                       								WHEN /*((pa123.pa60011/60)/8.0)<=3 AND*/ PA60039<4 
                       								THEN 'T'
                       							END)                       
                                         WHEN GUSERID = @x 
                                            THEN (CASE 
                       								WHEN ((pa123.pa60011/60)/8.0)>=0 AND PA60039<=4
                       								THEN 'T'
                       							END)
                       	
                       		END)	
                        END)='T'
                       
					   and RIGHT('0000000' + CAST(SUBSTRING(pa123.PA60002, PATINDEX('%[^0]%', pa123.PA60002+'.'), LEN(pa123.PA60002)) as NVARCHAR), 5) != RIGHT('0000000' + CAST(SUBSTRING(@x, PATINDEX('%[^0]%', @x+'.'), LEN(@x)) as NVARCHAR), 5) /* 補足五位數 0，不可以自己審核自己 ex: pa123.PA60002(1477) = @x(1477) */
                       and pa123.PA60039 != 0/*不算審核通過*/
                       and pa123.PA60039 != 5/*不算退件*/
                       and pa123.PA60043 is null/*不是刪除過的單子*/ ";

        sql = sql.Replace("\r\n", "");
        sql = sql.Replace("\t", "");

        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.tbi))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.Fill(ds);
        }


        if (ds.Tables.Count > 0)
        {
            //第二次篩選(C# 方式)
            foreach (DataRow i in ds.Tables[0].Rows.Cast<DataRow>().ToList())
            {
                var PAAK200 = int.Parse(i["PAAK200"].ToString());
                string u_ = i["Username"].ToString();
                bool IsApplyer = false;

                //判斷只要不是主管(課長、副理、經理)的人，都會以一般人員的身分去跑審核權限歸屬表 ex:01134 掛課長 
                //可是課長不是他 在主管也沒有他 他就必須跟一般員工請假一樣跑一般流程

                //一般人員審核流程
                if (i["SUSERID"].ToString() != u_ &&
                   i["DUSERID"].ToString() != u_ &&
                   i["MUSERID"].ToString() != u_)
                {
                    IsApplyer = CheckApplyer(i);
                }

                //當前資料為 課長階級 篩選方法
                if (i["SUSERID"].ToString() == u_)
                {
                    IsApplyer = CheckApplyer2(i);
                }

                //當前資料為 經理、副理階級 篩選方法
                if (i["DUSERID"].ToString() == u_ || i["MUSERID"].ToString() == u_)
                {
                    IsApplyer = true;
                }

                //是否為審核者，若不是審核者即將當筆資料剔除
                if (IsApplyer == false)
                    ds.Tables[0].Rows.Remove(i);

            }
        }

        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }

    //當前資料為 課長階級以下 篩選方法
    public bool CheckApplyer(DataRow i)
    {
        string sql = @"SELECT [ID]
                       ,[STN_WORK]
                       ,[deptctl]
                       ,[ProgNo]
                       ,[LUSERID]
                       ,[SUSERID]
                       ,(select WPAAK.PAAK200  from tbi.dbo.Users  join tbi.dbo.WPAAK on Users.q1=Wpaak.PAAK002  where users.username=[SUSERID])as SUSERID_PAAK200
                       ,[DUSERID]
					   ,(select WPAAK.PAAK200  from tbi.dbo.Users  join tbi.dbo.WPAAK on Users.q1=Wpaak.PAAK002  where users.username=[DUSERID])as DUSERID_PAAK200
                       ,[MUSERID]
					   ,(select WPAAK.PAAK200  from tbi.dbo.Users  join tbi.dbo.WPAAK on Users.q1=Wpaak.PAAK002  where users.username=[MUSERID])as MUSERID_PAAK200
                       ,[GUSERID]
                       FROM [tbi].[dbo].[XSingOrd]  
                       where STN_WORK='" + i["STN_WORK"] + "' AND ProgNo='" + i["ProgNo"] + "'".Replace("\r\n", "").Replace("\t", "");



        DataTable dt = new DataTable();

        using (SqlConnection conn = new SqlConnection(tbi))
        {
            using (SqlCommand comm = new SqlCommand(sql, conn))
            {
                SqlDataAdapter adapter = new SqlDataAdapter(comm);

                conn.Open();

                adapter.Fill(dt);
            }
        }


        var temp = dt.Rows.Cast<DataRow>().Select(z => new XSingOrd
        {
            ID = z["ID"].ToString(),
            deptctl = z["deptctl"].ToString(),
            DUSERID = z["DUSERID"].ToString(),
            DUSERID_PAAK200 = int.Parse(Convert.IsDBNull(z["DUSERID_PAAK200"]) ? "-1" : z["DUSERID_PAAK200"].ToString()),
            GUSERID = z["GUSERID"].ToString(),
            LUSERID = z["LUSERID"].ToString(),
            MUSERID = z["MUSERID"].ToString(),
            MUSERID_PAAK200 = int.Parse(Convert.IsDBNull(z["MUSERID_PAAK200"]) ? "-1" : z["MUSERID_PAAK200"].ToString()),
            ProgNo = z["ProgNo"].ToString(),
            STN_WORK = z["STN_WORK"].ToString(),
            SUSERID = z["SUSERID"].ToString(),
            SUSERID_PAAK200 = int.Parse(Convert.IsDBNull(z["SUSERID_PAAK200"]) ? "-1" : z["SUSERID_PAAK200"].ToString()),
        }).FirstOrDefault();

        //課長申請人是當前使用者
        //審核狀態是 1 (課長只能審核 1)
        if (temp.SUSERID == this.username2)
        {
            if (!string.IsNullOrEmpty(temp.SUSERID))
            {
                if (new[] { 1 }.Contains(int.Parse(i["PA60039"].ToString())))
                    return true;
                else
                    return false;
            }
            else
            {
                return false;
            }


        }
        else if (temp.DUSERID == this.username2)
        {
            //有課長
            if (!string.IsNullOrEmpty(temp.SUSERID))
            {
                if (new[] { 2 }.Contains(int.Parse(i["PA60039"].ToString())))
                    return true;
                else
                    return false;
            }
            //沒有課長
            else
            {
                if (new[] { 1, 2 }.Contains(int.Parse(i["PA60039"].ToString())))
                    return true;
                else
                    return false;
            }
        }
        else if (temp.MUSERID == this.username2)
        {
            //沒有副理 && 沒有課長 的狀況下 經理 可以看到 狀態 1、2、3
            if (string.IsNullOrEmpty(temp.DUSERID) && string.IsNullOrEmpty(temp.SUSERID))
            {
                if (new[] { 1, 2, 3 }.Contains(int.Parse(i["PA60039"].ToString())))
                    return true;
                else
                    return false;
            }
            //沒有副理 && 有課長 的狀況下 經理 可以看到 狀態 2、3
            //課長 可以將狀態 1 變成 2
            if (string.IsNullOrEmpty(temp.DUSERID) && !string.IsNullOrEmpty(temp.SUSERID))
            {
                if (new[] { 2, 3 }.Contains(int.Parse(i["PA60039"].ToString())))
                    return true;
                else
                    return false;
            }
            //有副理 && 沒有課長 的狀況下 經理 可以看到 狀態 3
            //副理 可以將狀態 1、2 變成 3
            if (!string.IsNullOrEmpty(temp.DUSERID) && string.IsNullOrEmpty(temp.SUSERID))
            {
                if (new[] { 3 }.Contains(int.Parse(i["PA60039"].ToString())))
                    return true;
                else
                    return false;
            }

            return false;
        }
        else
        {
            return false;
        }


    }

    //當前資料為 課長階級 篩選方法
    public bool CheckApplyer2(DataRow i)
    {
        string sql = @"SELECT [ID]
                       ,[STN_WORK]
                       ,[deptctl]
                       ,[ProgNo]
                       ,[LUSERID]
                       ,[SUSERID]
                       ,(select WPAAK.PAAK200  from tbi.dbo.Users  join tbi.dbo.WPAAK on Users.q1=Wpaak.PAAK002  where users.username=[SUSERID])as SUSERID_PAAK200
                       ,[DUSERID]
					   ,(select WPAAK.PAAK200  from tbi.dbo.Users  join tbi.dbo.WPAAK on Users.q1=Wpaak.PAAK002  where users.username=[DUSERID])as DUSERID_PAAK200
                       ,[MUSERID]
					   ,(select WPAAK.PAAK200  from tbi.dbo.Users  join tbi.dbo.WPAAK on Users.q1=Wpaak.PAAK002  where users.username=[MUSERID])as MUSERID_PAAK200
                       ,[GUSERID]
                       FROM [tbi].[dbo].[XSingOrd]  
                       where STN_WORK='" + i["STN_WORK"] + "' AND ProgNo='" + i["ProgNo"] + "'".Replace("\r\n", "").Replace("\t", "");



        DataTable dt = new DataTable();

        using (SqlConnection conn = new SqlConnection(tbi))
        {
            using (SqlCommand comm = new SqlCommand(sql, conn))
            {
                SqlDataAdapter adapter = new SqlDataAdapter(comm);

                conn.Open();

                adapter.Fill(dt);
            }
        }


        var temp = dt.Rows.Cast<DataRow>().Select(z => new XSingOrd
        {
            ID = z["ID"].ToString(),
            deptctl = z["deptctl"].ToString(),
            DUSERID = z["DUSERID"].ToString(),
            DUSERID_PAAK200 = int.Parse(Convert.IsDBNull(z["DUSERID_PAAK200"]) ? "-1" : z["DUSERID_PAAK200"].ToString()),
            GUSERID = z["GUSERID"].ToString(),
            LUSERID = z["LUSERID"].ToString(),
            MUSERID = z["MUSERID"].ToString(),
            MUSERID_PAAK200 = int.Parse(Convert.IsDBNull(z["MUSERID_PAAK200"]) ? "-1" : z["MUSERID_PAAK200"].ToString()),
            ProgNo = z["ProgNo"].ToString(),
            STN_WORK = z["STN_WORK"].ToString(),
            SUSERID = z["SUSERID"].ToString(),
            SUSERID_PAAK200 = int.Parse(Convert.IsDBNull(z["SUSERID_PAAK200"]) ? "-1" : z["SUSERID_PAAK200"].ToString()),
        }).FirstOrDefault();


        //副理
        if (temp.DUSERID == this.username2)
        {

            if (new[] { 1, 2, 3 }.Contains(int.Parse(i["PA60039"].ToString())))
                return true;
            else
                return false;
        }

        //經理
        if (temp.MUSERID == this.username2)
        {


            //有副理
            if (!string.IsNullOrEmpty(temp.DUSERID))
            {
                if (new[] { 3 }.Contains(int.Parse(i["PA60039"].ToString())))
                    return true;
                else
                    return false;
            }
            //沒有副理
            else
            {
                if (new[] { 1, 2, 3 }.Contains(int.Parse(i["PA60039"].ToString())))
                    return true;
                else
                    return false;
            }

        }
        else
        {
            return false;
        }

    }


    public void bos(HttpContext context)
    {
        //DataTable dt = this.queryDataTable2();
        DataTable dt = Administrator.GetValue(context, Identity.Administrator);

        dt.Columns.Add("abc");
        dt.Columns.Add("datefrom");
        dt.Columns.Add("dateto");
        dt.Columns.Add("hrtime");
        dt.Columns.Add("PA604");
        string pa604;
        string datefrom = null;
        string dateto = null;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            pa604 = dt.Rows[i]["PA60004"].ToString();
            this.sql2 = "select top 1 pa25008 from hrs_mis.dbo.wpa25 where PA25001='" + Enterprise.ConStr + "' AND pa25003 = '" + pa604 + "'";
            SqlConnection corr = new SqlConnection(hrs);//建立名為conn的連結物件
            corr.Open();
            SqlCommand tdiii = new SqlCommand(this.sql2, corr);
            DataTable doublecheck = new DataTable();
            doublecheck.Load(tdiii.ExecuteReader());
            dt.Rows[i]["PA604"] = doublecheck.Rows[0][0].ToString();


            //時數
            double hr = Convert.ToDouble(dt.Rows[i]["PA60011"].ToString());
            dt.Rows[i]["hrtime"] = Convert.ToDouble(hr / 60);
            //日期
            datefrom = DateTime.Parse(dt.Rows[i]["PA60007"].ToString()).ToString("yyyy/MM/dd HH:mm:ss dddd");
            dt.Rows[i]["datefrom"] = datefrom;
            dateto = DateTime.Parse(dt.Rows[i]["PA60008"].ToString()).ToString("yyyy/MM/dd HH:mm:ss dddd");
            dt.Rows[i]["dateto"] = dateto;


            tdiii.Cancel();
            corr.Dispose();
            corr.Close();
        }





        string str_json2 = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(str_json2);
    }
    private DataTable queryDataTable3()
    {
        //個人假單的流程
        tenten(context);
        string sql3;
        sql3 = " select W.PA60002, U.CNname, W.PA60004, W.PA60007, W.PA60008, W.PA60016, W.PA60038, W.PA60011, W.PA60042, W.PA60003, W.PA60039, W.PA60040,W.PA60044,W.PA60047 ";
        sql3 += "from [tbi].[dbo].[Users] U,[TBI_HRS].[dbo].[PA123] W ";
        sql3 += "where U.username = '" + username2 + "' and W.PA60002 = '" + username + "' and ";
        sql3 += "W.PA60041 is null and W.PA60043 is null ";
        sql3 += "order by W.PA60003 desc";
        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(tbi))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql3, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }
    public void user(HttpContext context)
    {
        //得到一個DataTable物件
        DataTable dt = this.queryDataTable3();
        //在DataTable新增一個新欄位，拿來放中文假別
        dt.Columns.Add("abc");
        dt.Columns.Add("datefrom");
        dt.Columns.Add("dateto");
        dt.Columns.Add("hrtime");
        dt.Columns.Add("PA604");
        string pa604;
        string datefrom;
        string dateto;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            pa604 = dt.Rows[i]["PA60004"].ToString();
            this.sql2 = "select top 1 pa25008 from hrs_mis.dbo.wpa25 where PA25001='" + Enterprise.ConStr + "' AND pa25003 = '" + pa604 + "'";
            SqlConnection corr = new SqlConnection(hrs);//建立名為conn的連結物件
            corr.Open();
            SqlCommand tdiii = new SqlCommand(this.sql2, corr);
            DataTable doublecheck = new DataTable();
            doublecheck.Load(tdiii.ExecuteReader());
            dt.Rows[i]["PA604"] = doublecheck.Rows[0][0].ToString();


            //時數
            double hr = Convert.ToDouble(dt.Rows[i]["PA60011"].ToString());
            dt.Rows[i]["hrtime"] = Convert.ToDouble(hr / 60);

            //日期
            datefrom = dt.Rows[i]["PA60007"].ToString();
            dateto = dt.Rows[i]["PA60008"].ToString();
            dt.Rows[i]["datefrom"] = datefrom;
            dt.Rows[i]["dateto"] = dateto;


            tdiii.Cancel();
            corr.Dispose();
            corr.Close();
        }

        //將DataTable轉成JSON字串
        string str_json3 = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(str_json3);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    //職代
    public void jobagent(HttpContext context)
    {
        DataTable dt = this.queryDataTable4();
        string str_json4 = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(str_json4);
    }


    public void yespass(HttpContext context)
    {
        tenten(context);
        string user = context.Request["user"].ToString();
        string water = context.Request["water"].ToString();
        double hr = Convert.ToDouble(context.Request["hr"].ToString());
        string leave = context.Request["leave"].ToString();
        string check = context.Request["check"].ToString();
        List<string> pa7303 = new List<string>();
        string SQL3;
        SQL3 = "SELECT DISTINCT SUBSTRING(CONVERT(varchar, PA18002, 120), 1, 10) PA18002 FROM hrs_mis.dbo.WPA18 WHERE PA18001='" + Enterprise.ConStr + "' AND ( CONVERT(varchar, PA18002, 120) LIKE '" + Convert.ToDateTime(from).AddYears(-1).ToString().Substring(0, 4) + "%' ";
        SQL3 += "OR CONVERT(varchar, PA18002, 120) LIKE '" + from.ToString().Substring(0, 4) + "%' ";
        SQL3 += "OR CONVERT(varchar, PA18002, 120) LIKE '" + Convert.ToDateTime(from).AddYears(1).ToString().Substring(0, 4) + "%')";
        DataTable pa18 = WorkCheck.Tools.WZDBSQLHELP.ExecuteQuery(SQL3);
        bool b = false;
        string SQL;//計算選取的日期中請了幾小時
        SQL = "SELECT SUM(PA60011) / 60 PA60011 FROM TBI_HRS.dbo.PA123 WHERE PA60002 = '" + user + "' ";
        SQL += "AND PA60043 IS NULL AND PA60039 != '5' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) IN (" + check + ")";
        DataTable dt3 = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(SQL);
        double hr2 = Convert.ToDouble(dt3.Rows[0]["PA60011"].ToString());
        string SQL2;//選取了哪些日期
        SQL2 = "SELECT DISTINCT SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) PA60007, SUBSTRING(CONVERT(varchar, PA60008, 120), 1, 10) PA60008, PA60011 / 60 PA60011 ";
        SQL2 += "FROM TBI_HRS.dbo.PA123 WHERE PA60002 = '" + user + "' AND PA60043 IS NULL AND PA60039 != '5' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) IN (" + check + ")";
        DataTable dt4 = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(SQL2);
        string sql = null;

        //當前使用者的審核權限
        LeaveApplicationForm Current_LeaveAF = Common.Get_LeaveApplicationForm(water, user, Enterprise.ConStr);
        XSingOrd Current_XSingOrd = Common.Get_yespassModel(user, Current_LeaveAF.lProgNo);


        //審核者身份 ( 預設都是一般 )
        Position postion_ = Position.GENERAL;

        //申請者身份 (預設都是一般)
        Position postionApply_ = Position.GENERAL;


        //判斷審核位階(此會判斷是否為最高部門主管)
        postion_ = Common.JudgePosition(username, Current_XSingOrd);

        //判斷申請者位階
        postionApply_ = Common.JudgePosition(user, Current_XSingOrd);

        // 設定審核狀態欄位(PA60039)

        switch (postion_)
        {

            case Position.SUSER:
                {
                    sql = "update TBI_HRS.dbo.PA123 set [PA60039]='2', PA60999 = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "' where [PA60002] = '" + user + "' and  [PA60003] = '" + water + "'";
                    break;
                }
            case Position.DUSER:
                {
                    sql = "update TBI_HRS.dbo.PA123 set [PA60039]='3', PA60999 = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "' where [PA60002] = '" + user + "' and  [PA60003] = '" + water + "'";
                    break;
                }
            case Position.MUSER:
                {
                    sql = "update TBI_HRS.dbo.PA123 set [PA60039]='4', PA60999 = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "' where [PA60002] = '" + user + "' and  [PA60003] = '" + water + "'";
                    break;
                }
            case Position.GUSER:
                {
                    sql = "update TBI_HRS.dbo.PA123 set [PA60039]='0', PA60999 = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "' where [PA60002] = '" + user + "' and  [PA60003] = '" + water + "'";
                    break;
                }
        }

        if (!string.IsNullOrEmpty(sql))
        {
            BOSSQL.TBIHRSExecuteNonQuery(sql);
        }


        //重新讀取一次
        Current_LeaveAF = Common.Get_LeaveApplicationForm(water, user, Enterprise.ConStr);

        //狀態為 退件 ，就跳出此迴圈
        if (Current_LeaveAF.status == 5)
        {
            context.Response.Write("此張單子已經退件，無法通過");
            return;
        }

        //sql 歸空值
        sql = "";
        // 判斷此筆假單目前是否是「完全」審核通過
        switch (postionApply_)
        {
            case Position.GENERAL:
                {
                    ////若組長沒通過會直接跳出
                    //if (Current_LeaveAF.status_luser == null)
                    //{
                    //    SendSupervisor(postionApply_, postion_, Current_XSingOrd, Current_LeaveAF);
                    //    break;
                    //}


                    //接下來開始判斷天數
                    if (hr <= 8)
                    {
                        //三階以上主管審核完畢(>2) 或 總經理審核完畢(=0)
                        if (Current_LeaveAF.status >= 2 || Current_LeaveAF.status == 0)
                        {
                            if (leave == "喪假")
                            {
                                string start = context.Request["start"].ToString();
                                DeathInsert(context, user, water, hr, start);
                            }

                            sql = "update TBI_HRS.dbo.PA123 set [PA60039]='0', PA60999 = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "' where [PA60002] = '" + user + "' and  [PA60003] = '" + water + "'";
                        }
                        else
                        {
                            //還沒審核完，寄信判斷
                            SendSupervisor(postionApply_, postion_, Current_XSingOrd, Current_LeaveAF);
                        }

                    }
                    else if (hr <= 16)
                    {
                        if (Current_LeaveAF.status >= 3 || Current_LeaveAF.status == 0)
                        {

                            if (leave == "喪假")
                            {
                                string start = context.Request["start"].ToString();
                                DeathInsert(context, user, water, hr, start);
                            }

                            sql = "update TBI_HRS.dbo.PA123 set [PA60039]='0', PA60999 = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "' where [PA60002] = '" + user + "' and  [PA60003] = '" + water + "'";
                        }
                        else
                        {
                            //還沒審核完，寄信判斷
                            SendSupervisor(postionApply_, postion_, Current_XSingOrd, Current_LeaveAF);
                        }
                    }
                    else if (hr <= 24)
                    {
                        if (Current_LeaveAF.status >= 4 || Current_LeaveAF.status == 0)
                        {
                            if (leave == "喪假")
                            {
                                string start = context.Request["start"].ToString();
                                DeathInsert(context, user, water, hr, start);
                            }

                            sql = "update TBI_HRS.dbo.PA123 set [PA60039]='0', PA60999 = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "' where [PA60002] = '" + user + "' and  [PA60003] = '" + water + "'";
                        }
                        else
                        {
                            //還沒審核完，寄信判斷
                            SendSupervisor(postionApply_, postion_, Current_XSingOrd, Current_LeaveAF);
                        }
                    }
                    else if (hr > 24)
                    {
                        if (Current_LeaveAF.status == 0)
                        {
                            //不需要再做一次設定了，因為總經理核過的已經是狀態 0         
                            break;
                        }
                        else
                        {
                            //還沒審核完，寄信判斷
                            SendSupervisor(postionApply_, postion_, Current_XSingOrd, Current_LeaveAF);
                        }

                    }
                    break;
                }
            case Position.SUSER:
                {
                    if (hr <= 24)
                    {
                        if (Current_LeaveAF.status >= 4 || Current_LeaveAF.status == 0)
                        {
                            sql = "update TBI_HRS.dbo.PA123 set [PA60039]='0', PA60999 = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "' where [PA60002] = '" + user + "' and  [PA60003] = '" + water + "'";
                        }
                        else
                        {
                            SendSupervisor(postionApply_, postion_, Current_XSingOrd, Current_LeaveAF);
                        }
                    }
                    else if (hr > 24)
                    {
                        if (Current_LeaveAF.status == 0)
                        {
                            break;
                        }
                        else
                        {
                            SendSupervisor(postionApply_, postion_, Current_XSingOrd, Current_LeaveAF);
                        }
                    }
                    break;
                }
            case Position.DUSER:
            case Position.MUSER:
                {
                    if (Current_LeaveAF.status == 0)
                    {

                    }
                    else
                    {
                        SendSupervisor(postionApply_, postion_, Current_XSingOrd, Current_LeaveAF);
                    }
                    break;
                }
        }

        //只需寄信通知下階主管，無任何需要寫進文中SQL
        if (!string.IsNullOrEmpty(sql))
        {
            //寫進文中SQL
            BOSSQL.TBIHRSExecuteNonQuery(sql);

        }

        //  PA60039欄位 0=通過  , 5 = 退件  , 1= 申請成功 無人審核, 
        //  2 = 課長或副理核准通過 且需繼續往上簽 (2~3天時)
        //  3 = 最高級主管核准通過 且需繼續往上簽 (3天以上)

        SqlConnection sele = new SqlConnection(tbiHRS);//建立名為conn的連結物件
        sele.Open();//開啟資料庫
        string select;
        select = " select PA60001, PA60002, PA60004, PA60007, PA60008, PA60016, PA60996, PA60998, PA60011, PA60038, PA60039, PA60003 ";
        select += "from TBI_HRS.dbo.PA123 ";
        select += "where PA60002 = '" + user + "' ";
        select += "and [PA60003] = '" + water + "' and PA60039 = '0'";

        SqlCommand mycomm = new SqlCommand(select, sele);
        DataTable seletable = new DataTable();
        seletable.Load(mycomm.ExecuteReader());



        if (seletable.Rows.Count > 0)
        {
            string Holiday_SQL;
            Holiday_SQL = " select * from [hrs_mis].[dbo].[WPA18] where PA18001='" + Enterprise.ConStr + "' AND PA18002 between '" + DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy/MM/dd 00:00") + "' ";
            Holiday_SQL += "and '" + DateTime.Parse(seletable.Rows[0]["PA60008"].ToString()).ToString("yyyy/MM/dd 23:59") + "' and PA18001 = '" + conStr + "'";
            DataTable Holidaydt = BOSSQL.hrsExecuteQuery(Holiday_SQL);

            string a607 = DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
            string a608 = DateTime.Parse(seletable.Rows[0]["PA60008"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
            int mon = DateTime.DaysInMonth(Convert.ToInt32(a607.Substring(0, 4)), Convert.ToInt32(a607.Substring(5, 2)));
            string nowdate = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
            string ff = DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd");
            string ttt = DateTime.Parse(seletable.Rows[0]["PA60008"].ToString()).ToString("yyyy-MM-dd");
            int fl = (DateTime.Parse(ttt) - DateTime.Parse(ff)).Days + 1;
            DataTable dt = new DataTable();
            string sqlq;

            sqlq = " select PA20002,PA20003 ";
            sqlq += "from [hrs_mis].[dbo].[WPA51], [hrs_mis].[dbo].[WPA20] ";
            sqlq += "where PA51002 = '" + user + "' and PA51001 = '" + Enterprise.ConStr + "' and PA20001 = '" + Enterprise.ConStr + "' ";
            sqlq += "and PA51020 = PA20002";

            dt = BOSSQL.hrsExecuteQuery(sqlq);
            string hrd = null;

            if (dt.Rows.Count > 0)
            {
                if (fl == 1)
                {

                    string frda = DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
                    string toda = DateTime.Parse(seletable.Rows[0]["PA60008"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
                    DateTime FromAndTo_Holiday = DateTime.Parse(DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd"));
                    double pa6012 = (seletable.Rows[0]["PA60004"].ToString() == "9" || seletable.Rows[0]["PA60004"].ToString() == "10") ? pa6012 = Convert.ToDouble(seletable.Rows[0]["PA60011"].ToString()) : pa6012 = 0;
                    if (Holidaydt.Rows.Count < 1)
                    {
                        SqlConnection conn = new SqlConnection(hrs);
                        conn.Open();
                        SqlCommand s_com = new SqlCommand();

                        string SQL_Insert_wpa60 = @"INSERT INTO hrs_mis.dbo.WPA60(PA60001, PA60002, PA60004, PA60007, PA60008, PA60016, 
                                                    PA60996, PA60998,PA60999, PA60011, PA60012, PA60006, PA60005, PA60010, PA60017, PA60019, PA60020
                                                    , PA60021, PA60022, PA60023, PA60024, PA60025, PA60026, PA60029, PA60031, PA60033, PA60034, PA60018)  VALUES(
                                                    @PA60001, @PA60002, @PA60004, @PA60007, @PA60008, @PA60016,
                                                    @PA60996, @PA60998,@PA60999, @PA60011, @PA60012, @PA60006, @PA60005, @PA60010, @PA60017, @PA60019, @PA60020, 
                                                    @PA60021, @PA60022, @PA60023, @PA60024, @PA60025, @PA60026, @PA60029, @PA60031, @PA60033, @PA60034, @PA60018) select pa60003 from hrs_mis.dbo.WPA60 where PA60995=(select IDENT_CURRENT('hrs_mis.dbo.WPA60'))";

                        SqlParameter[] partmeters = new SqlParameter[]
                        {
                                    new SqlParameter("@PA60001",this.conStr),
                                    new SqlParameter("@PA60002",user),
                                    new SqlParameter("@PA60004",Convert.ToInt16(seletable.Rows[0]["PA60004"].ToString())),
                                    new SqlParameter("@PA60007",frda),
                                    new SqlParameter("@PA60008",toda),
                                    new SqlParameter("@PA60016",seletable.Rows[0]["PA60016"].ToString()),

                                    new SqlParameter("@PA60996",user),
                                    new SqlParameter("@PA60998",nowdate),
                                    new SqlParameter("@PA60999",nowdate),
                                    new SqlParameter("@PA60011",seletable.Rows[0]["PA60011"].ToString()),
                                    new SqlParameter("@PA60012",pa6012),
                                    new SqlParameter("@PA60006",DateTime.Parse(a607).ToString("yyyy-MM-dd 00:00:00.000")),
                                    new SqlParameter("@PA60005",DateTime.Now.ToString("yyyy/MM/dd HH:mm")),
                                    new SqlParameter("@PA60010","2"),
                                    new SqlParameter("@PA60017",""),
                                    new SqlParameter("@PA60019","001"),
                                    new SqlParameter("@PA60020",a607.Substring(0, 4)),

                                    new SqlParameter("@PA60021",a607.Substring(5, 2)),
                                    new SqlParameter("@PA60022","001"),
                                    new SqlParameter("@PA60023",a607.Substring(0, 4)),
                                    new SqlParameter("@PA60024",a607.Substring(5, 2)),
                                    new SqlParameter("@PA60025",DateTime.Parse(a607.Substring(0, 8) + "01 00:00:00.000").ToString("yyyy-MM-dd HH:mm:ss.fff")),
                                    new SqlParameter("@PA60026",DateTime.Parse(a607.Substring(0, 8) + Convert.ToString(mon) + " 00:00:00.000").ToString("yyyy-MM-dd HH:mm:ss.fff")),
                                    new SqlParameter("@PA60029",""),
                                    new SqlParameter("@PA60031",""),
                                    new SqlParameter("@PA60033",""),
                                    new SqlParameter("@PA60034",""),
                                    new SqlParameter("@PA60018","0")

                        };
                        SQL_Insert_wpa60 = SQL_Insert_wpa60.Replace("\r\n", "").Replace("\t", "");
                        s_com.CommandText = SQL_Insert_wpa60;
                        s_com.Parameters.AddRange(partmeters);

                        s_com.Connection = conn;


                        string wpa60_water = "";

                        using (SqlDataAdapter adapter = new SqlDataAdapter(s_com))
                        {
                            DataTable dt_only_wpa60_water = new DataTable();

                            adapter.Fill(dt_only_wpa60_water);

                            wpa60_water = dt_only_wpa60_water.Rows[0]["pa60003"].ToString();
                        }




                        //s_com.ExecuteNonQuery();
                        conn.Dispose();
                        conn.Close();

                        Common.Apply_10(seletable, user, leave, Enterprise.ConStr);
                        Common.Apply_9(seletable, user, Convert.ToDouble(seletable.Rows[0]["PA60011"].ToString()), wpa60_water, Enterprise.ConStr);

                    }

                }
                else
                {
                    string Weekneedwork_sql;
                    Weekneedwork_sql = " select BS73002 from [hrs_mis].[dbo].[WBS73] where BS73001 = '0' and BS73004 = '2' and BS73005='8' and ";
                    Weekneedwork_sql += "BS73002 between '" + DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd") + "' and ";
                    Weekneedwork_sql += "'" + DateTime.Parse(seletable.Rows[0]["PA60008"].ToString()).ToString("yyyy-MM-dd") + "' ";
                    DataTable Weekneedwork_dt = BOSSQL.hrsExecuteQuery(Weekneedwork_sql);
                    string Getneedwork = (Weekneedwork_dt.Rows.Count > 0) ? Getneedwork = DateTime.Parse(Weekneedwork_dt.Rows[0]["BS73002"].ToString()).ToString("yyyy-MM-dd") : Getneedwork = "";

                    for (int g = 1; g <= fl; g++)
                    {
                        bool flag = true;
                        if (g == 1)
                        {
                            string frda = DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
                            string toda = DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd 17:00:00.000");
                            string FromAndTo_Holiday = DateTime.Parse(DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd 00:00:00.000")).ToString("yyyy-MM-dd");
                            bool Search_HolidayTorF = Holidaydt.Rows.Cast<DataRow>().Any(jj => DateTime.Parse(jj["PA18002"].ToString()).ToString("yyyy-MM-dd") == FromAndTo_Holiday);
                            if (Search_HolidayTorF == true)
                            {
                                foreach (DataRow dr in Holidaydt.Rows)
                                {
                                    if (DateTime.Parse(dr["PA18002"].ToString()).ToString("yyyy-MM-dd") == FromAndTo_Holiday)
                                    {
                                        flag = false;
                                        break;
                                    }
                                }
                                if (flag == true)
                                {
                                    Common.Cut_to_wpa60_start(seletable, mon, "Start", g, Enterprise.ConStr);
                                }

                            }
                            else
                            {
                                if (Getneedwork == "")
                                {
                                    Common.Cut_to_wpa60_start(seletable, mon, "Start", g, Enterprise.ConStr);

                                }
                                else
                                {
                                    if (Getneedwork != FromAndTo_Holiday)
                                    {
                                        Common.Cut_to_wpa60_start(seletable, mon, "Start", g, Enterprise.ConStr);
                                    }
                                }
                            }
                        }
                        else if (g == fl)
                        {

                            string frda = DateTime.Parse(a608).ToString("yyyy-MM-dd 08:00:00.000");
                            string toda = DateTime.Parse(a608).ToString("yyyy-MM-dd HH:mm:ss.000");
                            string FromAndTo_Holiday = DateTime.Parse(DateTime.Parse(seletable.Rows[0]["PA60008"].ToString()).ToString("yyyy-MM-dd 00:00:00.000")).ToString("yyyy-MM-dd");
                            bool Search_HolidayTorF = Holidaydt.Rows.Cast<DataRow>().Any(jj => DateTime.Parse(jj["PA18002"].ToString()).ToString("yyyy-MM-dd") == FromAndTo_Holiday);
                            if (Search_HolidayTorF == true)
                            {

                                foreach (DataRow dr in Holidaydt.Rows)
                                {
                                    if (DateTime.Parse(dr["PA18002"].ToString()).ToString("yyyy-MM-dd") == FromAndTo_Holiday)
                                    {
                                        flag = false;
                                        break;
                                    }
                                }
                                if (flag == true)
                                {
                                    Common.Cut_to_wpa60_start(seletable, mon, "End", g, Enterprise.ConStr);
                                }
                            }
                            else
                            {

                                Common.Cut_to_wpa60_start(seletable, mon, "End", g, Enterprise.ConStr);
                            }



                        }
                        else
                        {
                            string FromAndTo_Holiday = DateTime.Parse(DateTime.Parse(seletable.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd 00:00:00.000")).AddDays(g - 1).ToString("yyyy-MM-dd");

                            bool Search_HolidayTorF = Holidaydt.Rows.Cast<DataRow>().Any(jj => DateTime.Parse(jj["PA18002"].ToString()).ToString("yyyy-MM-dd") == FromAndTo_Holiday);
                            if (Search_HolidayTorF == true)
                            {

                                foreach (DataRow dr in Holidaydt.Rows)
                                {
                                    if (DateTime.Parse(dr["PA18002"].ToString()).ToString("yyyy-MM-dd") == FromAndTo_Holiday)
                                    {
                                        flag = false;
                                        break;
                                    }
                                    else if (DateTime.Parse(a607).AddDays(g - 1).DayOfWeek.ToString("d") == "0" || DateTime.Parse(a607).AddDays(g - 1).DayOfWeek.ToString("d") == "6")
                                    {
                                        flag = false;
                                        break;
                                    }


                                }
                                if (flag == true)
                                {
                                    Common.Cut_to_wpa60_start(seletable, mon, "Between", g, Enterprise.ConStr);
                                }
                            }
                            else if ((DateTime.Parse(a607).AddDays(g - 1).DayOfWeek.ToString("d") != "0" && DateTime.Parse(a607).AddDays(g - 1).DayOfWeek.ToString("d") != "6") || (Getneedwork != "" && Getneedwork == FromAndTo_Holiday))
                            {
                                Common.Cut_to_wpa60_start(seletable, mon, "Between", g, Enterprise.ConStr);
                            }

                        }
                    }
                }
            }

            string SQL4 = "select * FROM hrs_mis.dbo.WPA60 where PA60001='" + Enterprise.ConStr + "' AND pa60995=(select IDENT_CURRENT('hrs_mis.dbo.WPA60'))";

            DataTable dt2 = WorkCheck.Tools.WZDBSQLHELP.ExecuteQuery(SQL4);

            string dt2result = null;

            for (int i = 0; i < dt2.Rows.Count; i++)
            {
                if (i == dt2.Rows.Count - 1)
                {
                    dt2result += dt2.Rows[i]["PA60003"].ToString();
                }
                else
                {
                    dt2result += dt2.Rows[i]["PA60003"].ToString() + ";";
                }
                //完成
            }
            if (dt2result != null)
            {//將文中的流水號寫到暫存表
                string SQL5 = "UPDATE TBI_HRS.dbo.PA123 SET PA60046 = '" + dt2result + "' WHERE PA60002 = '" + user + "' AND PA60003 = '" + water + "'";
                DataTable dt5 = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(SQL5);
            }
        }
        mycomm.Cancel();
        sele.Dispose();
        sele.Close();

    }



    public SqlCommand Update_wpa60(DataRow dr_wpa60, int cost, string user)
    {

        string dr_wpa60_Primy_F = Convert.ToString(dr_wpa60["PA60995"]);

        int cost_total = int.Parse(dr_wpa60["PA60012"].ToString()) + cost;

        string SQL_Update_wpa60 = @"update [hrs_mis].[dbo].[WPA60] SET [PA60012]=@PA60012 WHERE [PA60995]=@PA60995 and PA60002=@PA60002 ";

        SqlParameter[] partmeters = new SqlParameter[]
        {
                    new SqlParameter("@PA60012",cost_total),
                    new SqlParameter("@PA60995",dr_wpa60_Primy_F),
                    new SqlParameter("@PA60002",user)
        };


        SqlCommand comm_result = new SqlCommand();

        comm_result.CommandText = SQL_Update_wpa60;

        comm_result.Parameters.AddRange(partmeters);

        dr_wpa60["PA60012"] = cost_total;

        return comm_result;

    }



    public void UpdateWPA73(DataRow dr, string WPA60_water)
    {
        string version = Enterprise.ConStr;

        //補休才會做
        if (dr["PA60004"].ToString() == "10")
        {
            SqlCommand comm = new SqlCommand();
            double min = Convert.ToDouble(dr["PA60011"].ToString());
            DataTable tenhr = new DataTable();
            string hrsql;
            hrsql = " select sum(PA73011) as pa73011, sum(PA73012) as pa73012 from [hrs_mis].[dbo].[WPA73] ";
            hrsql += "where PA73002 = '" + dr["PA60002"] + "' and PA73011 != '0' and PA73001 = '" + conStr + "' ";
            hrsql += "and PA73011 != PA73012 and PA73013 > '" + DateTime.Now.ToString("yyyy/MM/dd") + "' ";

            tenhr = BOSSQL.hrsExecuteQuery(hrsql);
            if (Convert.ToDouble(dr["PA60011"].ToString()) > Convert.ToInt16(tenhr.Rows[0][0].ToString()) - Convert.ToInt16(tenhr.Rows[0][1].ToString()))
            {
                //return comm;
            }
            else
            {
                List<string> pa7303 = new List<string>();
                string dt74, dt73, pa74sql;
                double pa7405, lefthr74;

                DataTable tendt = new DataTable();
                string tensql;
                tensql = " select PA73011, PA73012, PA73003, PA73004 from [hrs_mis].[dbo].[WPA73] ";
                tensql += "where PA73002 = '" + dr["PA60002"] + "' and PA73011 != '0' and PA73001 = '" + conStr + "' ";
                tensql += "and PA73011 != PA73012 and PA73013 > '" + DateTime.Now.ToString("yyyy-MM-dd") + "' order by PA73003";
                tendt = BOSSQL.hrsExecuteQuery(tensql);
                if (tendt.Rows.Count > 0)
                {
                    for (int k = 0; k < tendt.Rows.Count; k++)
                    {
                        double left = Convert.ToDouble(tendt.Rows[k]["PA73011"].ToString()) - Convert.ToDouble(tendt.Rows[k]["PA73012"].ToString());
                        if (left != 0 && left >= min)
                        {
                            //min=時數 請假時數
                            //該筆的補休如果比時數多的話 相加
                            SqlConnection data = new SqlConnection(this.hrs);
                            data.Open();
                            SqlCommand s_com2 = new SqlCommand();
                            s_com2.CommandText = "update [hrs_mis].[dbo].[WPA73] set [PA73012]='" + Convert.ToInt16(Convert.ToInt16(tendt.Rows[k]["PA73012"].ToString()) + Convert.ToInt16(min)) + "' where [PA73002] = '" + dr["PA60002"] + "' and PA73003 = '" + Convert.ToDouble(tendt.Rows[k]["PA73003"].ToString()) + "' and PA73001 = '" + conStr + "'";
                            s_com2.Connection = data;
                            s_com2.ExecuteNonQuery();
                            data.Dispose();
                            data.Close();

                            // 以便之後優化時可以只回傳command回去
                            //comm.CommandText += "update [hrs_mis].[dbo].[WPA73] set [PA73012]='" + Convert.ToInt16(Convert.ToInt16(tendt.Rows[k]["PA73012"].ToString()) + Convert.ToInt16(min)) + "' where [PA73002] = '" + dr["PA60002"] + "' and PA73003 = '" + Convert.ToDouble(tendt.Rows[k]["PA73003"].ToString()) + "' and PA73001 = '" + conStr + "';";

                        }
                        else if (left != 0 && left < min)
                        {
                            //如果該筆補休的時數比時數少的話就更新PA73012為最大值，且計算時數剩下多少
                            SqlConnection data = new SqlConnection(hrs);
                            data.Open();
                            SqlCommand s_com2 = new SqlCommand();
                            s_com2.CommandText = "update [hrs_mis].[dbo].[WPA73] set [PA73012]='" + Convert.ToDouble(tendt.Rows[k]["PA73011"].ToString()) + "' where [PA73002] = '" + dr["PA60002"] + "' and PA73003 = '" + Convert.ToDouble(tendt.Rows[k]["PA73003"].ToString()) + "' and PA73001 = '" + conStr + "'";
                            s_com2.Connection = data;
                            s_com2.ExecuteNonQuery();
                            data.Dispose();
                            data.Close();

                            // 以便之後優化時可以只回傳command回去
                            //comm.CommandText = "update [hrs_mis].[dbo].[WPA73] set [PA73012]='" + Convert.ToDouble(tendt.Rows[k]["PA73011"].ToString()) + "' where [PA73002] = '" + dr["PA60002"] + "' and PA73003 = '" + Convert.ToDouble(tendt.Rows[k]["PA73003"].ToString()) + "' and PA73001 = '" + conStr + "';";
                            min = min - (Convert.ToDouble(tendt.Rows[k]["PA73011"].ToString()) - Convert.ToDouble(tendt.Rows[k]["PA73012"].ToString()));


                        }

                        pa7303.Add(tendt.Rows[k]["PA73003"].ToString());

                        if (pa7303.Count > 0)
                        {
                            dt74 = " select sum(PA74005) ";
                            dt74 += "from [hrs_mis].[dbo].[WPA74] ";
                            dt74 += "where PA74004 = '" + pa7303[k] + "' and PA74002 = '" + dr["PA60002"] + "' and PA74001 = '" + conStr + "'";
                            DataTable pa74dt = BOSSQL.hrsExecuteQuery(dt74);

                            dt73 = " select PA73011, PA73012 ";
                            dt73 += "from [hrs_mis].[dbo].[WPA73] ";
                            dt73 += "where PA73003 = '" + pa7303[k] + "' and PA73002 = '" + dr["PA60002"] + "' and PA73001 = '" + conStr + "'";
                            DataTable pa73dt = BOSSQL.hrsExecuteQuery(dt73);
                            //========================================
                            if (pa74dt.Rows[0][0].ToString() != "")
                            {
                                pa7405 = Convert.ToInt16(pa73dt.Rows[0][1].ToString()) - Convert.ToInt16(pa74dt.Rows[0][0].ToString()) + Convert.ToInt16(dr["PA60011"].ToString());
                            }
                            else
                            {
                                pa7405 = Convert.ToInt16(pa73dt.Rows[0][1].ToString()) - 0 + Convert.ToInt16(dr["PA60011"].ToString());
                            }
                            if (pa7405 - Convert.ToInt16(dr["PA60011"].ToString()) <= 0)
                            {
                                pa74sql = " INSERT INTO [hrs_mis].[dbo].[WPA74](PA74001, ";
                                pa74sql += "PA74002, PA74003, PA74004, PA74005, PA74006, ";
                                pa74sql += "PA74996, PA74998 ";
                                pa74sql += ") VALUES('" + conStr + "','" + dr["PA60002"] + "',";
                                pa74sql += "'" + WPA60_water + "',";
                                pa74sql += "'" + pa7303[k] + "','" + pa7405 + "','1',";
                                pa74sql += "'" + dr["PA60002"] + "','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "')";
                                DataTable pa74 = BOSSQL.hrsExecuteNonQuery(pa74sql);

                                lefthr74 = Convert.ToInt16(dr["PA60011"].ToString()) - pa7405;
                            }
                            else
                            {
                                pa74sql = " INSERT INTO [hrs_mis].[dbo].[WPA74](PA74001, ";
                                pa74sql += "PA74002, PA74003, PA74004, PA74005, PA74006, ";
                                pa74sql += "PA74996, PA74998 ";
                                pa74sql += ") VALUES('" + conStr + "','" + dr["PA60002"] + "',";
                                pa74sql += "'" + WPA60_water + "',";
                                pa74sql += "'" + pa7303[k] + "','" + pa7405 + "','1',";
                                pa74sql += "'" + dr["PA60002"] + "','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + "')";
                                DataTable pa74 = BOSSQL.hrsExecuteNonQuery(pa74sql);
                            }

                        }
                    }
                }

            }

            //return comm;
        }
    }

    public string DeathInsert(HttpContext context, string user, string water, double hr, string start)
    {
        tenten(context);
        string sql, sql1, sql2, sql3 = "", sql4, ID;
        int Hrsum = Convert.ToInt32(context.Request["hrsum"]);
        string message = context.Request["message"].ToString();
        string Type = context.Request["death"].ToString().Substring(0, 1);//該筆喪假的天數別
        string NowTime = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss.fff");
        double TypeTimeSum = Convert.ToDouble(Type) * 8 * 60;//該天數別的總分鐘數
        double Dhr = Convert.ToInt32(hr) * 60;//該假單的分鐘數
        double TypeTime = TypeTimeSum - Dhr;
        sql = "select pa60047 from tbi_hrs.dbo.pa123 where pa60002 = '" + user + "' and pa60003 = '" + water + "'";
        DataTable dz = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql);
        string DStart = DateTime.Parse(dz.Rows[0][0].ToString()).ToString("yyyy/MM/dd HH:mm:ss.fff");//假單開始時間&喪假起始時間
        string End = DateTime.Parse(DStart).AddDays(100).ToString("yyyy/MM/dd 23:59:59.000");//百日
        if (message == "HRS insert")
        {
            sql3 = "update TBI_HRS.dbo.PA123 set[PA60039] = '0' where[PA60002] = '" + user + "' and[PA60003] = '" + water + "'";

            //判斷HRS08是否已經有該天數別
            sql1 = "select top 1 * from [TBI_HRS].[dbo].[HRS08] where username = '" + user + "' and type = '" + Type + "' order by ID desc";
            DataTable db = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
            if (db.Rows.Count > 0)//有的話流水號+1
            {
                sql2 = "insert into TBI_HRS.dbo.HRS08(ID ,username, type, start, theEnd, timeleft, Boss, Addtime) values(";
                sql2 += "(SELECT coalesce(MAX(ID),1) FROM TBI_HRS.dbo.HRS08 WHERE(username = '" + user + "')) + 1,'" + user + "',";
                sql2 += "'" + Type + "', '" + DStart + "', '" + End + "','" + TypeTime + "','" + username2 + "','" + NowTime + "'";
                sql2 += ")";
                DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);

                //將pa60044加上HRS08連動ID，因為要抓最新的ID 所以要在剛insert完抓
                sql1 = "select top 1 * from [TBI_HRS].[dbo].[HRS08] where username = '" + user + "' and type = '" + Type + "' order by ID desc";
                DataTable dc = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
                ID = dc.Rows[0][0].ToString();
                sql4 = "update TBI_HRS.dbo.PA123 set pa60044 = '" + Type + "',pa60045 = '" + ID + "' where[PA60002] = '" + user + "' and[PA60003] = '" + water + "'";
                DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql4);
            }
            else
            {
                sql2 = "insert into TBI_HRS.dbo.HRS08(ID, username, type, start, theEnd, timeleft, Boss, Addtime) values(";
                sql2 += "'1','" + user + "',";
                sql2 += "'" + Type + "', '" + DStart + "', '" + End + "','" + TypeTime + "','" + username2 + "','" + NowTime + "'";
                sql2 += ")";
                DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);
                sql4 = "update TBI_HRS.dbo.PA123 set pa60044 = '" + Type + "',pa60045 = '1' where[PA60002] = '" + user + "' and[PA60003] = '" + water + "'";
                DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql4);

            }
        }
        else if (message == "HRS update")
        {
            //更新舊時數
            sql1 = "select top 1 * from [TBI_HRS].[dbo].[HRS08] where username = '" + user + "' and type = '" + Type + "' order by ID desc";
            DataTable da = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
            int TypeTimeLeft = Convert.ToInt32(da.Rows[0][5]);
            double TimeLeft = TypeTimeLeft - Dhr;//扣舊時數
            sql3 = "update TBI_HRS.dbo.PA123 set[PA60039] = '0' where[PA60002] = '" + user + "' and[PA60003] = '" + water + "'";

            sql2 = "update TBI_HRS.dbo.HRS08 set [timeleft] = '" + TimeLeft + "',[Boss] = '" + username2 + "', [Addtime]='" + NowTime + "' ";
            sql2 += "where type = '" + Type + "' and ID = '" + da.Rows[0][0].ToString() + "' and username = '" + user + "'";
            DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql2);

            //將pa60045連動HRS08的ID，因為要抓最新的ID 所以要在剛update完抓
            sql1 = "select top 1 * from [TBI_HRS].[dbo].[HRS08] where username = '" + user + "' and type = '" + Type + "' order by ID desc";
            DataTable dc = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql1);
            ID = dc.Rows[0][0].ToString();
            sql4 = "update TBI_HRS.dbo.PA123 set[PA60039] = '0',pa60044 = '" + Type + "',pa60045 = '" + ID + "' where[PA60002] = '" + user + "' and[PA60003] = '" + water + "'";
            DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql4);
        }
        return sql3;
    }
    public void nopass(HttpContext context)
    {
        //退件
        tenten(context);
        string user = context.Request["user"].ToString();
        string id = context.Request["id"].ToString();
        string water = context.Request["water"].ToString();
        string nopasstext = context.Request["nopasstext"].ToString();
        string from = context.Request["from"].ToString();
        string to = context.Request["to"].ToString();
        string cause = context.Request["cause"].ToString();
        string name = context.Request["name"].ToString();
        string hr = context.Request["hr"].ToString();

        string sql2 = "select CNname from [tbi].[dbo].[Users] where username='" + username2 + "'";
        DataTable dt = BOSSQL.ExecuteQuery(sql2);

        //double hr = Convert.ToDouble(context.Request["user"].ToString()) / 60;
        string s_com = "update TBI_HRS.dbo.PA123 set [PA60039]='5' ,[PA60042] = '" + dt.Rows[0][0].ToString() + "：" + nopasstext + "'  where [PA60002] = '" + user + "' and  [PA60003] = '" + water + "'";
        DataTable ct = BOSSQL.TBIHRSExecuteNonQuery(s_com);
        //  PA60039欄位 0=通過  , 5 = 退件  , 1= 申請成功  無人審核, 
        //  2 = 課長或副理核准通過 且需繼續往上簽 (2~3天時)
        //  3 = 最高級主管核准通過 且需繼續往上簽 (3天以上)

    }
    public void level2(HttpContext context)
    {
        //單位主管的下拉
        tenten(context);
        DataTable dt = new DataTable();
        string sql;
        sql = " select DUSERID from [tbi].[dbo].[Users], [tbi].[dbo].[XSingOrd], [tbi].[dbo].[Winton_mf2000] ";
        sql += "where username = '" + username2 + "' and a1 = hrs and mf200 = STN_WORK and a2 = ProgNo ";
        sql += "and DUSERID != '" + username2 + "'";
        dt = BOSSQL.ExecuteQuery(sql);

        DataTable dt2 = new DataTable();
        string cn;
        if (dt.Rows.Count > 0)
        {

            cn = "select CNname from [tbi].[dbo].[Users] where username = '" + dt.Rows[0][0].ToString() + "'";
            dt2 = BOSSQL.ExecuteQuery(cn);
        }
        //將DataTable轉成JSON字串
        string str_json1 = JsonConvert.SerializeObject(dt2, Formatting.Indented);
        context.Response.Write(str_json1);
    }
    public void level1(HttpContext context)
    {
        //部門主管的下拉
        tenten(context);
        DataTable dt = new DataTable();
        string sql;
        sql = " select MUSERID from [tbi].[dbo].[Users], [tbi].[dbo].[XSingOrd], [tbi].[dbo].[Winton_mf2000] ";
        sql += "where username = '" + username2 + "' and a1 = hrs and mf200 = STN_WORK and a2 = ProgNo ";
        sql += "and MUSERID != '" + username2 + "'";
        dt = BOSSQL.ExecuteQuery(sql);

        DataTable dt2 = new DataTable();
        string cn;
        if (dt.Rows.Count > 0)
        {

            cn = "select CNname from [tbi].[dbo].[Users] where username = '" + dt.Rows[0][0].ToString() + "'";
            dt2 = BOSSQL.ExecuteQuery(cn);
        }
        //將DataTable轉成JSON字串
        string str_json1 = JsonConvert.SerializeObject(dt2, Formatting.Indented);
        context.Response.Write(str_json1);
    }

    public void chief(HttpContext context)
    {
        //課長
        tenten(context);
        DataTable dt = new DataTable();
        string sql;
        sql = " select SUSERID from [tbi].[dbo].[Users], [tbi].[dbo].[XSingOrd], [tbi].[dbo].[Winton_mf2000] ";
        sql += "where username = '" + username2 + "' and a1 = hrs and mf200 = STN_WORK and a2 = ProgNo ";
        sql += "and SUSERID != '" + username2 + "'";
        dt = BOSSQL.ExecuteQuery(sql);

        DataTable dt2 = new DataTable();
        string cn;
        if (dt.Rows.Count > 0)
        {

            cn = "select CNname from [tbi].[dbo].[Users] where username = '" + dt.Rows[0][0].ToString() + "'";
            dt2 = BOSSQL.ExecuteQuery(cn);
        }
        //將DataTable轉成JSON字串
        string str_json1 = JsonConvert.SerializeObject(dt2, Formatting.Indented);
        context.Response.Write(str_json1);
    }

    private DataTable queryDataTable12(string go, string over)//抓有班表的 有排休或調休
    {
        tenten(context);
        string sql;

        sql = " select A.PA51019,B.PB29004 from hrs_mis.dbo.WPA51 A ,hrs_mis.dbo.WPB29 B where A.PA51002 = '" + username + "' ";
        sql += "and B.PB29003='" + username + "' and A.PA51001='" + Enterprise.ConStr + "' and B.PB29001='" + Enterprise.ConStr + "'and B.PB29002 between '" + go + "' and '" + over + "' ";
        //sql += "GROUP BY A.PA51019,B.PB29004 having B.PB29004 > '2'";

        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.hrs))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }


    private DataTable queryDataTable13(string go, string over)//抓有班表的
    {
        tenten(context);
        string sql;

        sql = "select A.PA51019,B.PB29004 from hrs_mis.dbo.WPA51 A ,hrs_mis.dbo.WPB29 B where A.PA51002 = '" + username + "' and B.PB29003='" + username + "' ";
        sql += "and A.PA51001='" + Enterprise.ConStr + "' and B.PB29001='" + Enterprise.ConStr + "' and B.PB29002 between '" + go + "' and '" + over + "' GROUP BY A.PA51019,B.PB29004";

        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.hrs))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }


    private DataTable queryDataTable14(string go, string over)//抓無班表
    {
        tenten(context);
        string sql;
        string go2 = go.Substring(0, 10);
        string over2 = over.Substring(0, 10);

        sql = "select A.PA51019,B.PA18002 from hrs_mis.dbo.WPA51 A ,hrs_mis.dbo.WPA18 B where A.PA51002 = '" + username + "' ";
        sql += "and B.PA18002 between '" + go2 + "' and '" + over2 + "' and A.PA51001='" + Enterprise.ConStr + "' and B.PA18001='" + Enterprise.ConStr + "' GROUP BY A.PA51019,B.PA18002";

        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.hrs))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }
    public void insert(HttpContext context, Insert_form_data insert_form_data = null)
    {
        //新增
        string id, from, to, hr, cause, name, death2, CoDpath, indeath, jobuser;
        if (insert_form_data != null)
        {
            id = insert_form_data.id;
            from = insert_form_data.from;
            to = insert_form_data.to;
            hr = insert_form_data.hr;
            cause = insert_form_data.cause;
            name = insert_form_data.name;
            death2 = insert_form_data.death2;//下拉8,6,3 value
            CoDpath = insert_form_data.CoDpath;
            jobuser = insert_form_data.jobuser;
            indeath = null;
        }
        else
        {

            id = context.Request["id"].ToString();
            from = context.Request["from"].ToString();
            to = context.Request["to"].ToString();
            hr = context.Request["hr"].ToString();
            cause = context.Request["cause"].ToString();
            name = context.Request["name"].ToString();
            death2 = context.Request["death"].ToString();//下拉8,6,3 value
            CoDpath = context.Request["CoDpath"].ToString();
            jobuser = context.Request["jobuser"].ToString();
            indeath = null;
        }

        DateTime fromda = DateTime.Parse(from);
        DateTime to2 = DateTime.Parse(DateTime.Now.ToString("yyyy-MM-01"));
        DateTime LimitApplyDate = Common.GetWorkDay(DateTime.Parse(fromda.ToString("yyyy/MM/01")).AddMonths(1));
        DataTable dp = queryDataTable12(from, to);//抓有班表的 有排休或調休
        DataTable dp2 = queryDataTable13(from, to);//抓有班表的
        DataTable dp3 = queryDataTable14(from, to);//抓無班表

        if (CoDpath == "false")
        {
            context.Response.Write("images not");
            return;
        }
        else if (CoDpath == "not jpg")
        {
            context.Response.Write("not jpg");
            return;
        }
        else
        {
            if (dp.Rows.Count > 0)
            {
                //有資料表示有班表且請假日期中有排休或調休
                //代表可能是行政，也可能是現場
                context.Session["happy"] = "true";
                context.Session["uj"] = dp.Rows[0][0].ToString().Trim();
                context.Session["pb29004"] = dp.Rows[0][1].ToString().Trim();
            }
            else if (dp2.Rows.Count > 0)
            {
                //代表是現場
                context.Session["happy"] = "";
                context.Session["uj"] = "1";
                //↑此1為有班表的1
                context.Session["pb29004"] = "1";
                //↑指定為字串 1  or  2 都可以 1 跟 2都要上班 因此可以直接請假無須接下去判斷
            }
            else if (dp3.Rows.Count > 0)
            {
                //代表是行政
                context.Session["uj"] = dp3.Rows[0][0].ToString().Trim();
                context.Session["pa18002"] = dp3.Rows[0][1].ToString().Trim();
            }
            else if (dp3.Rows.Count == 0)
            {
                context.Session["uj"] = "0";
                context.Session["pa18002"] = "";
            }

            string and = DateTime.Parse(from).ToString("ddd").Substring(1).Trim();
            string i = DateTime.Parse(to).ToString("ddd").Substring(1).Trim();


            //喪假
            if (death2 != "0")//判斷user選了喪假的天數後才會進if
            {
                indeath = death2;
            }
            if (BOSSQL.CheckWordMax(cause))
            {//事由字數
                context.Response.Write("40");
                return;
            }
            //KEN
            //if (DateTime.Parse(DateTime.Now.ToString("yyyy/MM/dd")) > LimitApplyDate)
            //{
            //    context.Response.Write("dateout");
            //    return;
            //}
            int gender = Convert.ToInt32(context.Request["gender"].ToString());
            string gensql;
            gensql = " select * from [TBI_HRS].[dbo].[PA123] ";
            gensql += "where PA60004 = '17' and PA60002 = '" + username + "' ";
            gensql += "and PA60001 = '" + conStr + "' and PA60039 != '5' and PA60043 is null ";
            gensql += "and PA60006 between '" + DateTime.Now.ToString("yyyy-MM-01") + "' ";
            gensql += "and '" + DateTime.Parse(DateTime.Now.AddMonths(1).ToString("yyyy-MM-01")).AddDays(-1).ToString("yyyy-MM-dd 23:59:59") + "'";
            DataTable gen = BOSSQL.TBIHRSExecuteQuery(gensql);
            if (gen.Rows.Count > 0 && id == "17")
            {
                context.Response.Write("生理超過次數");
                return;
            }
            if (DateTime.Parse(DateTime.Parse(to).ToString("yyyy-MM-dd")).Subtract(DateTime.Parse(DateTime.Parse(from).ToString("yyyy-MM-dd"))).TotalDays > 0 && id == "17")
            {
                context.Response.Write("生理假只能請一天");
                return;
            }
            if (gender == 1 && id == "17" || gender == 1 && id == "16" || gender == 1 && id == "7")
            {
                context.Response.Write(false);
                return;
            }

            else
            {
                SqlConnection cob2 = new SqlConnection(tbi);
                cob2.Open();//開啟資料庫
                            //登入者的信箱及名字
                string sql2 = "select CNname, Email from [tbi].[dbo].[Users] where username='" + username2 + "'";
                SqlCommand tbii2 = new SqlCommand(sql2, cob2);
                DataTable dt = new DataTable();
                dt.Load(tbii2.ExecuteReader());

                string idcn = "select top 1 PA25008 from [hrs_mis].[dbo].[WPA25] where PA25001='" + Enterprise.ConStr + "' AND PA25003 = '" + id + "'";
                DataTable cnn = new DataTable();
                cnn = BOSSQL.hrsExecuteQuery(idcn);

                var task1 = Task.Factory.StartNew(() =>
                {

                    if (dt.Rows.Count > 0 && dt.Rows[0][1].ToString() != "")
                    {

                        string sql = "select CNname, Email from [tbi].[dbo].[Users] where username='" + jobuser + "'";
                        DataTable job = new DataTable();
                        job = BOSSQL.ExecuteQuery(sql);
                        //職代通知
                        if (job.Rows.Count > 0)
                        {
                            //SmtpClient jobsmtp = new SmtpClient();
                            //MailMessage jobmsg = new MailMessage();
                            //jobmsg.CC.Add(new MailAddress("a22931628@tbimotion.com.tw", "職代自己"));
                            //jobmsg.From = new MailAddress(dt.Rows[0]["Email"].ToString(), dt.Rows[0]["CNname"].ToString());  /// 寄件者的信箱,寄件者的名字

                            //if (string.IsNullOrEmpty(job.Rows[0]["Email"].ToString()))
                            //    jobmsg.To.Add(new MailAddress("kenwhz@tbimotion.com.tw", job.Rows[0]["CNname"].ToString()));    //收件者
                            //else
                            //    jobmsg.To.Add(new MailAddress(job.Rows[0]["Email"].ToString(), job.Rows[0]["CNname"].ToString()));    //收件者

                            //jobmsg.Subject = "職務代理通知"; // 主旨
                            //jobmsg.Body = "因同仁：" + dt.Rows[0]["CNname"].ToString() + "請假\n請假的區間託您代理其職務。\n日期：" + DateTime.Parse(from).ToString("yyyy/MM/dd") + "~" + DateTime.Parse(to).ToString("yyyy/MM/dd") + "\n\n\n此為系統自動發送，請勿直接回覆。"; /// 內文
                            //jobsmtp.SendCompleted += (sender, e) =>
                            //{

                            //    string ApplyUser = e.UserState.ToString().Split(';')[0];

                            //    string to_ = e.UserState.ToString().Split(';')[1];

                            //    string Type_ = "職務代理通知";

                            //    string CRUD = "Insert";

                            //    FinishSendEamil_Event(ApplyUser, to_, Type_, CRUD);
                            //};

                            //string job_userState = dt.Rows[0]["CNname"].ToString() + ";" + job.Rows[0]["CNname"].ToString();

                            //if (this.IsDebug != true) jobsmtp.SendAsync(jobmsg, job_userState);


                            Dictionary<string, string> to_list = new Dictionary<string, string>();
                            to_list.Add(job.Rows[0]["CNname"].ToString(), job.Rows[0]["Email"].ToString());

                            string body = "因同仁：" + dt.Rows[0]["CNname"].ToString() + "請假\n請假的區間託您代理其職務。\n日期：" + DateTime.Parse(from).ToString("yyyy/MM/dd") + "~" + DateTime.Parse(to).ToString("yyyy/MM/dd") + "\n\n\n此為系統自動發送，請勿直接回覆。"; /// 內文

                            Common.SendMail(to_list, "職務代理通知", body);

                        }
                    }


                });

                var Thisbosmail = Task.Factory.StartNew(() =>
                {
                    //--------------------------------------------------------
                    /// 一般主管寄信
                    DataTable bt = new DataTable();
                    string mailsql;
                    mailsql = " select LUSERID, SUSERID, DUSERID, MUSERID from [tbi].[dbo].[Users],[tbi].[dbo].[XSingOrd], [tbi].[dbo].[Winton_mf2000] ";
                    mailsql += "where a2 = ProgNo and mf200 = STN_WORK and a1 = '" + a1.Trim() + "' and a1 = hrs ";
                    mailsql += "and username = '" + username2 + "'";
                    bt = BOSSQL.ExecuteQuery(mailsql);

                    DataTable cn = new DataTable();
                    string mailname = "";
                    if (Convert.ToDouble(hr) <= 16 && bt.Rows[0]["SUSERID"].ToString() != "" && bt.Rows[0]["SUSERID"].ToString() != username2 &&
                        bt.Rows[0]["DUSERID"].ToString() != username2 && bt.Rows[0]["MUSERID"].ToString() != username2)
                    {
                        //如果課長欄有值&不超過課長的簽核範圍的話就不寄給更上層 不然就寄給更上層
                        mailname = " select CNname, Email from [tbi].[dbo].[Users] where ( ";
                        mailname += "username = '" + bt.Rows[0]["DUSERID"].ToString() + "' ";
                        mailname += "or username = '" + bt.Rows[0]["SUSERID"].ToString() + "' ) and username != '" + username2 + "'";
                        cn = BOSSQL.ExecuteQuery(mailname);
                    }
                    else if (bt.Rows[0]["DUSERID"].ToString() != username2 && bt.Rows[0]["MUSERID"].ToString() != username2)
                    {
                        mailname = " select CNname, Email from [tbi].[dbo].[Users] where ( ";
                        mailname += "username = '" + bt.Rows[0]["DUSERID"].ToString() + "' or username = '" + bt.Rows[0]["MUSERID"].ToString() + "' ";
                        mailname += "or username = '" + bt.Rows[0]["SUSERID"].ToString() + "' ) and username != '" + username2 + "'";
                        cn = BOSSQL.ExecuteQuery(mailname);
                    }

                    for (int k = 0; k < cn.Rows.Count; k++)
                    {
                        if (cn.Rows[k]["Email"].ToString() != "")
                        {
                            //SmtpClient smtp = new SmtpClient();
                            //MailMessage msg = new MailMessage();
                            //msg.CC.Add(new MailAddress("a22931628@tbimotion.com.tw", "一般主管自己"));
                            //msg.From = new MailAddress(dt.Rows[0]["Email"].ToString(), dt.Rows[0]["CNname"].ToString());  /// 寄件者的信箱,寄件者的名字
                            ////msg.To.Add(new MailAddress("a22931628@tbimotion.com.tw", "一般主管"));    ///收件者
                            //if (string.IsNullOrEmpty(cn.Rows[0]["Email"].ToString()))
                            //    msg.To.Add(new MailAddress("kenwhz@tbimotion.com.tw", cn.Rows[0]["CNname"].ToString()));    //收件者
                            //else
                            //    msg.To.Add(new MailAddress(cn.Rows[0]["Email"].ToString(), cn.Rows[0]["CNname"].ToString()));    //收件者
                            //msg.Subject = "請假通知單"; // 主旨
                            //msg.Body = "請假資訊\n假別：" + cnn.Rows[0][0].ToString() + "\n請假時數：" + hr + "小時\n備註：" + cause + "\n職務代理人：" + name + "\n\n\n煩請貴主管上系統做簽核動作\n此為系統自動發送，請勿直接回覆\n\n網址: http://tbihrs.tbimotion.com.tw/"; /// 內文
                            //smtp.SendCompleted += (sender, e) =>
                            //{

                            //    string ApplyUser = e.UserState.ToString().Split(';')[0];

                            //    string to_ = e.UserState.ToString().Split(';')[1];

                            //    string Type_ = "請假通知單";

                            //    string CRUD = "Insert";

                            //    FinishSendEamil_Event(ApplyUser, to_, Type_, CRUD);
                            //};

                            //string userState = dt.Rows[0]["CNname"].ToString() + ";" + cn.Rows[k]["CNname"].ToString();
                            //if (this.IsDebug != true) smtp.SendAsync(msg, userState);


                            Dictionary<string, string> to_list = new Dictionary<string, string>();
                            to_list.Add( cn.Rows[0]["CNname"].ToString(),cn.Rows[0]["Email"].ToString());

                            string body = "請假資訊\n假別：" + cnn.Rows[0][0].ToString() + "\n請假時數：" + hr + "小時\n備註：" + cause + "\n職務代理人：" + name + "\n\n\n煩請貴主管上系統做簽核動作\n此為系統自動發送，請勿直接回覆\n\n網址: http://tbihrs.tbimotion.com.tw/"; /// 內文

                            Common.SendMail(to_list, "請假通知單", body);

                        }
                    }

                    //-----------------------------------------------------------

                });




                DataTable bosmail = new DataTable();
                string bosmailsql = "select top 1 ProgNo, LUSERID, SUSERID, DUSERID, MUSERID from [tbi].[dbo].[Users], [tbi].[dbo].[Winton_mf2000], [tbi].[dbo].[XSingOrd] where a1 = '" + a1.Trim() + "' and a1 = hrs and mf200 = STN_WORK and username = '" + username2 + "' and a2 = ProgNo ";
                bosmail = BOSSQL.ExecuteQuery(bosmailsql);
                //DUSERID 副理
                //MUSERID 經理
                if (bosmail.Rows.Count > 0)
                {
                    if (bosmail.Rows[0]["DUSERID"].ToString() == username2 || bosmail.Rows[0]["MUSERID"].ToString() == username2)
                    {

                        var task2 = Task.Factory.StartNew(() =>
                        {

                            string bosone_sql = "select CNname, Email from [tbi].[dbo].[Users] where q1 = '04' or username = 'A02' and DAT_LIME > '" + DateTime.Now.ToString("yyyyMMdd") + "'";
                            DataTable dt2 = new DataTable();
                            dt2 = BOSSQL.ExecuteQuery(bosone_sql);

                            for (int k = 0; k < dt2.Rows.Count; k++)
                            {

                                //SmtpClient smtp = new SmtpClient();
                                //MailMessage msg = new MailMessage();
                                //msg.CC.Add(new MailAddress("a22931628@tbimotion.com.tw", "總經理自己"));
                                //msg.From = new MailAddress(dt.Rows[0]["Email"].ToString(), dt.Rows[0]["CNname"].ToString());  /// 寄件者的信箱,寄件者的名字
                                //msg.To.Add(new MailAddress(dt2.Rows[k]["Email"].ToString(), dt2.Rows[k]["CNname"].ToString()));    ///收件者
                                ////msg.To.Add(new MailAddress("a22931628@tbimotion.com.tw", "總經理"));
                                //msg.Subject = "請假通知單"; // 主旨
                                //msg.Body = "請假資訊\n人員：" + username + "\n姓名：" + dt.Rows[0]["CNname"].ToString() + "\n假別：" + cnn.Rows[0][0].ToString() + "\n請假時數：" + hr + "小時\n備註：" + cause + "\n職務代理人：" + name + "\n\n\n請總經理 / 特助抽空上系統做簽核動作。\n此為系統自動發送，請勿直接回覆\n\n網址: http://tbihrs.tbimotion.com.tw/"; /// 內文
                                //smtp.SendCompleted += (sender, e) =>
                                //{

                                //    string ApplyUser = e.UserState.ToString().Split(';')[0];

                                //    string to_ = e.UserState.ToString().Split(';')[1];

                                //    string Type_ = "請假通知單";

                                //    string CRUD = "Insert";

                                //    FinishSendEamil_Event(ApplyUser, to_, Type_, CRUD);
                                //};

                                //string A02_userState = dt.Rows[0]["CNname"].ToString() + ";" + dt2.Rows[k]["CNname"].ToString();
                                //if (this.IsDebug != true) smtp.SendAsync(msg, A02_userState);

                                Dictionary<string, string> to_list = new Dictionary<string, string>();
                                to_list.Add( dt2.Rows[k]["CNname"].ToString(),dt2.Rows[k]["Email"].ToString());

                                string body = "請假資訊\n人員：" + username + "\n姓名：" + dt.Rows[0]["CNname"].ToString() + "\n假別：" + cnn.Rows[0][0].ToString() + "\n請假時數：" + hr + "小時\n備註：" + cause + "\n職務代理人：" + name + "\n\n\n請總經理 / 特助抽空上系統做簽核動作。\n此為系統自動發送，請勿直接回覆\n\n網址: http://tbihrs.tbimotion.com.tw/"; /// 內文

                                Common.SendMail(to_list, "請假通知單", body);
                            }

                        });
                    }
                }

                tbii2.Cancel();
                cob2.Dispose();
                cob2.Close();

                Thread.Sleep(500);

                SqlConnection conn = new SqlConnection(tbiHRS);
                conn.Open();
                SqlCommand s_com = new SqlCommand();
                string frda = DateTime.Parse(from).ToString("yyyy-MM-dd HH:mm:ss.fff");
                string toda = DateTime.Parse(to).ToString("yyyy-MM-dd HH:mm:ss.fff");
                string day06 = DateTime.Parse(from).ToString("yyyy-MM-dd 00:00:00.000");

                DateTime tt = DateTime.Now;
                string nowdate = tt.ToString("yyyy-MM-dd HH:mm:ss");
                if (id == "8")
                {
                    string a = context.Request["Hundredtime"].ToString().Replace("T", " ");
                    if (a != "")
                    {
                        string Hundredtime = DateTime.Parse(a).ToString("yyyy-MM-dd HH:mm:ss.fff");
                        s_com.CommandText = " INSERT INTO TBI_HRS.dbo.PA123(PA60001, PA60002, PA60004, PA60007, PA60008, PA60016, ";
                        s_com.CommandText += "PA60996, PA60998, PA60011, PA60038, PA60039, PA60003,PA60044,PA60040, PA60006,PA60047) VALUES(";
                        s_com.CommandText += "'" + conStr + "', '" + username + "','" + id + "'";
                        s_com.CommandText += ",'" + frda + "','" + toda + "','" + cause + "','" + username + "','" + nowdate + "'";
                        s_com.CommandText += ",'" + Convert.ToDouble(hr) * 60 + "','" + name + "'";
                        s_com.CommandText += ",'1',(SELECT coalesce(MAX(PA60003),1) FROM TBI_HRS.dbo.PA123 WHERE(PA60002 = '" + username + "')) + 1";
                        s_com.CommandText += ",'" + indeath + "','" + CoDpath + "','" + day06 + "','" + Hundredtime + "')";
                    }
                    else
                    {
                        string sql = "select pa60047 from TBI_HRS.dbo.PA123 where pa60002 = '" + username + "' and pa60044 = '" + death2 + "'";
                        DataTable da = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(sql);
                        string Hundredtime = DateTime.Parse(da.Rows[0][0].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
                        s_com.CommandText = " INSERT INTO TBI_HRS.dbo.PA123(PA60001, PA60002, PA60004, PA60007, PA60008, PA60016, ";
                        s_com.CommandText += "PA60996, PA60998, PA60011, PA60038, PA60039, PA60003,PA60044,PA60040, PA60006,PA60047) VALUES(";
                        s_com.CommandText += "'" + conStr + "', '" + username + "','" + id + "'";
                        s_com.CommandText += ",'" + frda + "','" + toda + "','" + cause + "','" + username + "','" + nowdate + "'";
                        s_com.CommandText += ",'" + Convert.ToDouble(hr) * 60 + "','" + name + "'";
                        s_com.CommandText += ",'1',(SELECT coalesce(MAX(PA60003),1) FROM TBI_HRS.dbo.PA123 WHERE(PA60002 = '" + username + "')) + 1";
                        s_com.CommandText += ",'" + indeath + "','" + CoDpath + "','" + day06 + "','" + Hundredtime + "')";

                    }

                }
                else
                {
                    s_com.CommandText = " INSERT INTO TBI_HRS.dbo.PA123(PA60001, PA60002, PA60004, PA60007, PA60008, PA60016, ";
                    s_com.CommandText += "PA60996, PA60998, PA60011, PA60038, PA60039, PA60003,PA60044,PA60040, PA60006) VALUES(";
                    s_com.CommandText += "'" + conStr + "', '" + username + "','" + id + "'";
                    s_com.CommandText += ",'" + frda + "','" + toda + "','" + cause + "','" + username + "','" + nowdate + "'";
                    s_com.CommandText += ",'" + Convert.ToDouble(hr) * 60 + "','" + name + "'";
                    s_com.CommandText += ",'1',(SELECT coalesce(MAX(PA60003),1) FROM TBI_HRS.dbo.PA123 WHERE(PA60002 = '" + username + "')) + 1";
                    s_com.CommandText += ",'" + indeath + "','" + CoDpath + "','" + day06 + "')";
                }

                s_com.Connection = conn;
                s_com.ExecuteNonQuery();
                conn.Dispose();
                conn.Close();

            }
        }
    }

    public void upload(HttpContext context)
    {

        tenten(context);

        //上傳檔案處理
        string pathall = "";
        string id = context.Request["id"].ToString();
        if (id == "6" && context.Request.Files.Count == 0 || id == "3" && context.Request.Files.Count == 0 || id == "8" && context.Request.Files.Count == 0 ||
        id == "4" && context.Request.Files.Count == 0 || id == "7" && context.Request.Files.Count == 0 || id == "16" && context.Request.Files.Count == 0 ||
        id == "15" && context.Request.Files.Count == 0 || id == "18" && context.Request.Files.Count == 0 || id == "5" && context.Request.Files.Count == 0)
        {
            context.Response.Write("false");
        }
        else
        {
            if (context.Request.Files.Count > 0)
            {
                HttpFileCollection files = context.Request.Files;
                string path, path1;
                for (int i = 0; i < files.Count; i++)
                {

                    HttpPostedFile file = files[i];
                    FileInfo fileinfo = new FileInfo(file.FileName);


                    if (fileinfo.Extension.ToLower() == ".jpg" || fileinfo.Extension.ToLower() == ".gif" || fileinfo.Extension.ToLower() == ".png" || fileinfo.Extension.ToLower() == ".pdf" || fileinfo.Extension.ToLower() == ".rar" || fileinfo.Extension.ToLower() == ".zip")
                    {

                        string fname = username2 + "_" + DateTime.Now.ToString("yyyyMMdd") + "_" + (i + 1) + fileinfo.Extension.ToLower();

                        path = path1 = "..\\Upload\\";

                        path1 = context.Server.MapPath(path1);
                        string pathToCheck = path1 + fname;
                        //檢查目錄是否存在，不存在則建立目錄
                        if (!System.IO.Directory.Exists(path1))
                        {
                            System.IO.Directory.CreateDirectory(path1);
                        }

                        if (System.IO.File.Exists(pathToCheck))
                        {
                            int count = 2;
                            String OnlyFileName = "";

                            while (System.IO.File.Exists(pathToCheck))
                            {
                                OnlyFileName = username2 + "_" + DateTime.Now.ToString("yyyyMMdd") + "_" + count.ToString() + fileinfo.Extension.ToLower();
                                pathToCheck = path1 + OnlyFileName;
                                count = count + 1;
                            }
                            path += OnlyFileName;
                            pathall += path;
                        }
                        else
                        {
                            path += fname;
                            pathall += path;
                        }


                        file.SaveAs(context.Server.MapPath(Path.Combine(path)));
                    }
                    else
                    {
                        context.Response.Write("not jpg");
                        return;
                    }
                }
            }
            context.Response.Write(pathall);
        }

    }

    public void HRupload(HttpContext context)
    {
        //人資專用上傳檔案處理
        string pathall = "";
        string id = context.Request["id"].ToString();
        string user = context.Request["user"].ToString();
        if (id == "6" && context.Request.Files.Count == 0 || id == "3" && context.Request.Files.Count == 0 || id == "8" && context.Request.Files.Count == 0 ||
        id == "4" && context.Request.Files.Count == 0 || id == "7" && context.Request.Files.Count == 0 || id == "16" && context.Request.Files.Count == 0 ||
        id == "15" && context.Request.Files.Count == 0 || id == "18" && context.Request.Files.Count == 0 || id == "5" && context.Request.Files.Count == 0)
        {
            context.Response.Write("false");
        }
        else
        {
            if (context.Request.Files.Count > 0)
            {
                HttpFileCollection files = context.Request.Files;
                string path, path1;
                for (int i = 0; i < files.Count; i++)
                {

                    HttpPostedFile file = files[i];
                    FileInfo fileinfo = new FileInfo(file.FileName);


                    if (fileinfo.Extension.ToLower() == ".jpg" || fileinfo.Extension.ToLower() == ".gif" || fileinfo.Extension.ToLower() == ".png" || fileinfo.Extension.ToLower() == ".pdf" || fileinfo.Extension.ToLower() == ".rar" || fileinfo.Extension.ToLower() == ".zip")
                    {
                        string fname = username2 + "_" + DateTime.Now.ToString("yyyyMMdd") + "_" + (i + 1) + fileinfo.Extension.ToLower();

                        path = path1 = "..\\Upload\\";

                        path1 = context.Server.MapPath(path1);
                        string pathToCheck = path1 + fname;
                        //檢查目錄是否存在，不存在則建立目錄
                        if (!System.IO.Directory.Exists(path1))
                        {
                            System.IO.Directory.CreateDirectory(path1);
                        }

                        if (System.IO.File.Exists(pathToCheck))
                        {
                            int count = 2;
                            String OnlyFileName = "";

                            while (System.IO.File.Exists(pathToCheck))
                            {
                                OnlyFileName = username2 + "_" + DateTime.Now.ToString("yyyyMMdd") + "_" + count.ToString() + fileinfo.Extension.ToLower();
                                pathToCheck = path1 + OnlyFileName;
                                count = count + 1;
                            }
                            path += OnlyFileName;
                            pathall += path;
                        }
                        else
                        {
                            path += fname;
                            pathall += path;
                        }


                        file.SaveAs(context.Server.MapPath(Path.Combine(path)));
                    }
                    else
                    {
                        context.Response.Write("not jpg");
                        return;
                    }
                }
            }
            context.Response.Write(pathall);
        }

    }

    public void gender(HttpContext context)
    {
        //此處會驗證是否此使用者有設定正確歸屬
        if (Common.CheckProgNo(context) == false)
        {
            context.Response.Write(21);
            return;
        }

        //得到一個DataTable物件
        DataTable dt = this.gendertable();
        //將DataTable轉成JSON字串
        string str_json1 = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(str_json1);
    }
    private DataTable gendertable()
    {
        //請假剩餘時數
        tenten(context);
        string gendersql;

        gendersql = "select [PA51008] from [hrs_mis].[dbo].[WPA51] where PA51001='" + Enterprise.ConStr + "' AND PA51002 = '" + username + "'";

        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.hrs))
        {
            SqlDataAdapter da = new SqlDataAdapter(gendersql, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();

    }

    private DataTable queryDataTable15(string go, string over)//抓有班表的 有排休或調休
    {
        tenten(context);
        string sql;

        sql = "select A.PA51019,B.PB29004 from hrs_mis.dbo.WPA51 A ,hrs_mis.dbo.WPB29 B where A.PA51002 = '" + username + "' ";
        sql += "and B.PB29003='" + username + "' and A.PA51001='" + Enterprise.ConStr + "' and B.PB29001='" + Enterprise.ConStr + "'and B.PB29002 between '" + go + "' and '" + over + "' ";
        sql += "GROUP BY A.PA51019,B.PB29004 having B.PB29004 > '2'";

        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.hrs))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }


    private DataTable queryDataTable16(string go, string over)//抓有班表的
    {
        tenten(context);
        string sql;

        sql = "select A.PA51019,B.PB29004 from hrs_mis.dbo.WPA51 A ,hrs_mis.dbo.WPB29 B where A.PA51002 = '" + username + "' and B.PB29003='" + username + "' ";
        sql += "and A.PA51001='" + Enterprise.ConStr + "' and B.PB29001='" + Enterprise.ConStr + "' and B.PB29002 between '" + go + "' and '" + over + "' GROUP BY A.PA51019,B.PB29004";

        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.hrs))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }


    private DataTable queryDataTable17(string go, string over)//抓無班表
    {
        tenten(context);
        string sql;
        string go2 = go.Substring(0, 10);
        string over2 = over.Substring(0, 10);

        sql = "select A.PA51019,B.PA18002 from hrs_mis.dbo.WPA51 A ,hrs_mis.dbo.WPA18 B where A.PA51002 = '" + username + "' ";
        sql += "and B.PA18002 between '" + go2 + "' and '" + over2 + "' and A.PA51001='" + Enterprise.ConStr + "' and B.PA18001='" + Enterprise.ConStr + "' GROUP BY A.PA51019,B.PA18002";

        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.hrs))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.Fill(ds);
        }
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }


    public void update(HttpContext context)
    {
        //更新button
        string user = context.Request["user"].ToString();
        string water = context.Request["water"].ToString();
        string id2 = context.Request["id2"].ToString();
        string from2 = context.Request["from2"].ToString();
        string to2 = context.Request["to2"].ToString();
        string hr2 = context.Request["hr2"].ToString();
        string cause2 = context.Request["cause2"].ToString();
        string name2 = context.Request["name2"].ToString();
        string death1 = context.Request["updeath"].ToString();//喪假8,6,3
        string death2 = context.Request["death"].ToString();
        string CoDpath = context.Request["CoDpath"].ToString();
        string jobuser = context.Request["jobuser"].ToString();
        string updeath = null;

        DateTime fromda = DateTime.Parse(from2);
        DateTime LimitApplyDate = DateTime.Parse(fromda.ToString("yyyy/MM/01")).AddMonths(1).AddDays(1);
        DataTable dp = queryDataTable15(from2, to2);//抓有班表的 有排休或調休
        DataTable dp2 = queryDataTable16(from2, to2);//抓有班表的
        DataTable dp3 = queryDataTable17(from2, to2);//抓無班表
        if (dp.Rows.Count > 0)
        {
            //有資料表示有班表且請假日期中有排休或調休
            //代表可能是行政，也可能是現場
            context.Session["happy"] = "true";
            context.Session["uj"] = dp.Rows[0][0].ToString().Trim();
            context.Session["pb29004"] = dp.Rows[0][1].ToString().Trim();
        }
        else if (dp2.Rows.Count > 0)
        {
            //代表是現場
            context.Session["happy"] = "";
            context.Session["uj"] = "1";
            //↑此1為有班表的1
            context.Session["pb29004"] = "1";
            //↑指定為字串 1  or  2 都可以 1 跟 2都要上班 因此可以直接請假無須接下去判斷
        }
        else if (dp3.Rows.Count > 0)
        {
            //代表是行政
            context.Session["uj"] = dp3.Rows[0][0].ToString().Trim();
            context.Session["pa18002"] = dp3.Rows[0][1].ToString().Trim();
        }
        else if (dp3.Rows.Count == 0)
        {
            context.Session["uj"] = "0";
            context.Session["pa18002"] = "";
        }

        string and = DateTime.Parse(from2).ToString("ddd").Substring(1).Trim();
        string i = DateTime.Parse(to2).ToString("ddd").Substring(1).Trim();


        //喪假
        if (death2 != "0")//判斷user選了喪假的天數後才會進if
        {
            updeath = death2;
        }
        if (BOSSQL.CheckWordMax(cause2))
        {//事由字數
            context.Response.Write("40");
            return;
        }
        if (DateTime.Now > LimitApplyDate)
        {
            context.Response.Write("dateout");
            return;
        }
        int gender = Convert.ToInt32(context.Request["gender"].ToString());

        if (gender == 1 && id2 == "17" || gender == 1 && id2 == "16" || gender == 1 && id2 == "7")
        {
            context.Response.Write(false);
        }
        else
        {
            var task1 = Task.Factory.StartNew(() =>
            {
                SqlConnection cob2 = new SqlConnection(tbi);
                cob2.Open();//開啟資料庫
                string sql2 = "select CNname, Email from [tbi].[dbo].[Users] where username='" + username2 + "'";
                SqlCommand tbii2 = new SqlCommand(sql2, cob2);
                DataTable dt = new DataTable();
                dt.Load(tbii2.ExecuteReader());
                if (dt.Rows.Count > 0 && dt.Rows[0][1].ToString() != "")
                {
                    string idcn = "select top 1 PA25008 from [hrs_mis].[dbo].[WPA25] where PA25001='" + Enterprise.ConStr + "' AND PA25003 = '" + id2 + "'";
                    DataTable cnn = new DataTable();
                    cnn = BOSSQL.hrsExecuteQuery(idcn);
                    DataTable bt = new DataTable();
                    string mailsql;
                    mailsql = " select LUSERID, SUSERID, DUSERID, MUSERID from [tbi].[dbo].[Users],[tbi].[dbo].[XSingOrd], [tbi].[dbo].[Winton_mf2000] ";
                    mailsql += "where a2 = ProgNo and mf200 = STN_WORK and a1 = '" + a1.Trim() + "' and a1 = hrs ";
                    mailsql += "and username = '" + username2 + "'";
                    bt = BOSSQL.ExecuteQuery(mailsql);

                    DataTable cn = new DataTable();
                    string mailname;
                    mailname = " select CNname, Email from [tbi].[dbo].[Users] where (username = '" + bt.Rows[0]["SUSERID"].ToString() + "' ";
                    mailname += "or username = '" + bt.Rows[0]["DUSERID"].ToString() + "' or username = '" + bt.Rows[0]["MUSERID"].ToString() + "' ";
                    mailname += "or username = '" + bt.Rows[0]["LUSERID"].ToString() + "' ) and username != '" + username2 + "'";
                    cn = BOSSQL.ExecuteQuery(mailname);

                    for (int k = 0; k < cn.Rows.Count; k++)
                    {
                        if (cn.Rows[k]["Email"].ToString() != "")
                        {
                            //SmtpClient smtp = new SmtpClient();
                            //MailMessage msg = new MailMessage();
                            //msg.CC.Add(new MailAddress("a22931628@tbimotion.com.tw", "自己"));
                            //msg.From = new MailAddress(dt.Rows[0]["Email"].ToString(), dt.Rows[0]["CNname"].ToString());  /// 寄件者的信箱,寄件者的名字
                            ////msg.To.Add(new MailAddress("a22931628@tbimotion.com.tw", "123"));    ///收件者
                            //msg.To.Add(new MailAddress(cn.Rows[k]["Email"].ToString(), cn.Rows[k]["CNname"].ToString()));    //收件者
                            //msg.Subject = "請假通知單"; // 主旨
                            //msg.Body = "請假資訊\n假別：" + cnn.Rows[0][0].ToString() + "\n請假時數：" + hr2 + "小時\n備註：" + cause2 + "\n職務代理人：" + name2 + "\n\n\n煩請貴主管上系統做簽核動作\n此為系統自動發送，請勿直接回覆\n\n網址: http://tbihrs.tbimotion.com.tw/"; /// 內文
                            //smtp.SendCompleted += (sender, e) =>
                            //{

                            //    string ApplyUser = e.UserState.ToString().Split(';')[0];

                            //    string to_ = e.UserState.ToString().Split(';')[1];

                            //    string Type_ = "請假通知單";

                            //    string CRUD = "Update";

                            //    FinishSendEamil_Event(ApplyUser, to_, Type_, CRUD);
                            //};
                            //string userState = dt.Rows[0]["CNname"].ToString() + ";" + cn.Rows[k]["CNname"].ToString();
                            //if (this.IsDebug != true) smtp.SendAsync(msg, userState);

                            Dictionary<string, string> to_list = new Dictionary<string, string>();
                            to_list.Add(cn.Rows[k]["CNname"].ToString(), cn.Rows[k]["Email"].ToString());

                            string body = "請假資訊\n假別：" + cnn.Rows[0][0].ToString() + "\n請假時數：" + hr2 + "小時\n備註：" + cause2 + "\n職務代理人：" + name2 + "\n\n\n煩請貴主管上系統做簽核動作\n此為系統自動發送，請勿直接回覆\n\n網址: http://tbihrs.tbimotion.com.tw/"; /// 內文

                            Common.SendMail(to_list, "請假通知單", body);
                        }
                    }
                }
                tbii2.Cancel();
                cob2.Dispose();
                cob2.Close();
            });

            Thread.Sleep(500);

            SqlConnection conn = new SqlConnection(tbiHRS);
            conn.Open();
            SqlCommand s_com = new SqlCommand();
            s_com.CommandText = "update TBI_HRS.dbo.PA123 set [PA60043]='1' where [PA60002] = '" + user + "' and [PA60003] = '" + water + "'";
            s_com.Connection = conn;
            s_com.ExecuteNonQuery();
            conn.Dispose();
            conn.Close();

            Insert_form_data temp = new Insert_form_data();
            temp.id = id2;
            temp.user = user;
            temp.from = from2;
            temp.to = to2;
            temp.hr = hr2;
            temp.cause = cause2;
            temp.name = name2;
            temp.death1 = death1;
            temp.death2 = death2;
            temp.CoDpath = CoDpath;
            temp.updeath = updeath;
            temp.jobuser = jobuser;


            insert(context, temp);
        }
    }

    public void HRupdate(HttpContext context)
    {
        //超過時間就彈出
        if (context.Session["username"] == null)
        {
            context.Response.Write("NotLoggin");
            context.Response.End();

        }


        string CoDpath = context.Request["CoDpath"].ToString();
        string cause2 = context.Request["cause2"].ToString();
        string Modified = context.Session["Username"].ToString().TrimStart('0').PadLeft(4, '0');
        string Creater = context.Request["user"].ToString();
        string water = context.Request["water"].ToString();

        double hr = double.Parse(context.Request["hr2"].ToString()) * 60;
        int leave = int.Parse(context.Request["id2"].ToString());



        string sql = @"update [TBI_HRS].[dbo].[PA123] 
                       set 
                       pa60016=@pa60016
                       ,PA60040=@PA60040
                       ,PA60997=@PA60997
                       ,PA60999=GETDATE()
                       ,PA60011=@PA60011
                       ,PA60004=@PA60004
                       where PA60002=@PA60002 and PA60003=@PA60003";

        sql = sql.Replace("\r\n", "").Replace("\t", "");


        using (SqlConnection conn = new SqlConnection(tbiHRS))
        {
            SqlCommand comm = new SqlCommand(sql, conn);

            comm.Parameters.Add(new SqlParameter("@pa60016", cause2));
            comm.Parameters.Add(new SqlParameter("@PA60040", CoDpath));
            comm.Parameters.Add(new SqlParameter("@PA60997", Modified));
            comm.Parameters.Add(new SqlParameter("@PA60002", Creater));
            comm.Parameters.Add(new SqlParameter("@PA60003", water));
            comm.Parameters.Add(new SqlParameter("@PA60011", hr));
            comm.Parameters.Add(new SqlParameter("@PA60004", leave));


            string tmp = sql;

            foreach (SqlParameter p in comm.Parameters)
            {
                //tmp = tmp.Replace('@' + p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
                tmp = tmp.Replace(p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
            }

            conn.Open();

            comm.ExecuteNonQuery();

            DataRow dr = BOSSQL.TBIHRSExecuteQuery("select * from PA123 where PA60002 = '" + Creater + "' and PA60003 = '" + water + "' ").Rows[0];
            string result = Newtonsoft.Json.JsonConvert.SerializeObject(dr);
            context.Response.Write(result);
        }






        ////人資專用更新button
        //string user = context.Request["user"].ToString();
        //string water = context.Request["water"].ToString();
        //string id2 = context.Request["id2"].ToString();
        //string from2 = context.Request["from2"].ToString();
        //string to2 = context.Request["to2"].ToString();
        //string hr2 = context.Request["hr2"].ToString();
        //string cause2 = context.Request["cause2"].ToString();
        //string death1 = context.Request["updeath"].ToString();//喪假8,6,3
        //string death2 = context.Request["death"].ToString();
        //string CoDpath = context.Request["CoDpath"].ToString();
        //string pa39 = context.Request["pa39"].ToString();
        //string updeath = null;
        //DateTime fromda = DateTime.Parse(from2);
        //DateTime now = DateTime.Parse(DateTime.Now.AddMonths(1).ToString("yyyy-MM-01")).AddDays(-1);
        //DataTable dp = queryDataTable15(from2, to2);//抓有班表的 有排休或調休
        //DataTable dp2 = queryDataTable16(from2, to2);//抓有班表的
        //DataTable dp3 = queryDataTable17(from2, to2);//抓無班表
        //if (dp.Rows.Count > 0)
        //{
        //    //有資料表示有班表且請假日期中有排休或調休
        //    //代表可能是行政，也可能是現場
        //    context.Session["happy"] = "true";
        //    context.Session["uj"] = dp.Rows[0][0].ToString().Trim();
        //    context.Session["pb29004"] = dp.Rows[0][1].ToString().Trim();
        //}
        //else if (dp2.Rows.Count > 0)
        //{
        //    //代表是現場
        //    context.Session["happy"] = "";
        //    context.Session["uj"] = "1";
        //    //↑此1為有班表的1
        //    context.Session["pb29004"] = "1";
        //    //↑指定為字串 1  or  2 都可以 1 跟 2都要上班 因此可以直接請假無須接下去判斷
        //}
        //else if (dp3.Rows.Count > 0)
        //{
        //    //代表是行政
        //    context.Session["uj"] = dp3.Rows[0][0].ToString().Trim();
        //    context.Session["pa18002"] = dp3.Rows[0][1].ToString().Trim();
        //}
        //else if (dp3.Rows.Count == 0)
        //{
        //    context.Session["uj"] = "0";
        //    context.Session["pa18002"] = "";
        //}

        //string and = DateTime.Parse(from2).ToString("ddd").Substring(1).Trim();
        //string i = DateTime.Parse(to2).ToString("ddd").Substring(1).Trim();

        //if (context.Session["uj"].ToString() == "0")
        //{
        //    //沒有班表
        //    //非六日
        //    //進入國定
        //    if (context.Session["pa18002"].ToString() != "")
        //    {
        //        //如果有資料跑出來表示該名使用者請假日子中有國定假日
        //        context.Response.Write("National holidays");
        //        return;
        //    }
        //}
        //else
        //{
        //    //現場的
        //}

        ////喪假
        //if (death2 != "0")//判斷user選了喪假的天數後才會進if
        //{
        //    updeath = death2;
        //}
        //if (BOSSQL.CheckWordMax(cause2))
        //{//事由字數
        //    context.Response.Write("40");
        //    return;
        //}
        //int gender = Convert.ToInt32(context.Request["gender"].ToString());

        //if (gender == 1 && id2 == "17" || gender == 1 && id2 == "16" || gender == 1 && id2 == "7")
        //{
        //    context.Response.Write(false);
        //}
        //else
        //{
        //    SqlConnection upconn = new SqlConnection(tbiHRS);
        //    upconn.Open();
        //    SqlCommand ups_com = new SqlCommand();
        //    string frda = DateTime.Parse(from2).ToString("yyyy-MM-dd HH:mm:ss.fff");
        //    string toda = DateTime.Parse(to2).ToString("yyyy-MM-dd HH:mm:ss.fff");

        //    DateTime tt = DateTime.Now;
        //    string nowdate = tt.ToString("yyyy-MM-dd HH:mm:ss");

        //    if (pa39 != "null")
        //    {
        //        ups_com.CommandText = "UPDATE TBI_HRS.dbo.PA123 SET /*PA60004 = '" + id2 + "',*/ PA60007 = '" + frda + "', PA60008 = '" + toda + "', PA60011 = '" + Convert.ToDouble(hr2) * 60 + "', ";
        //        ups_com.CommandText += "PA60016 = '" + cause2 + "', ";
        //        if (CoDpath != "")
        //        {
        //            ups_com.CommandText += "PA60040 = '" + CoDpath + "', ";
        //        }
        //        ups_com.CommandText += "PA60997 = " + user + ", PA60999 = '" + nowdate + "' WHERE PA60002 = '" + user + "' AND PA60003 = '" + water + "'";
        //    }
        //    //else
        //    //{
        //    //    ups_com.CommandText = "UPDATE hrs_mis.dbo.WPA60 SET PA60004 = '" + id2 + "', PA60007 = '" + frda + "', PA60008 = '" + toda + "', PA60011 = '" + Convert.ToDouble(hr2) * 60 + "', ";
        //    //    ups_com.CommandText += "PA60016 = '" + cause2 + "', PA60997 = 'IVY', PA60999 = '" + nowdate + "' WHERE PA60002 = '" + user + "' AND PA60003 = '" + water + "'";
        //    //}
        //    ups_com.Connection = upconn;
        //    ups_com.ExecuteNonQuery();
        //    upconn.Dispose();
        //    upconn.Close();
        //}
    }

    public void uptime(HttpContext context)
    {
        tenten(context);
        string from = context.Request["from"].ToString();
        string to = context.Request["to"].ToString();
        string sql;
        sql = " select PA20002 ";
        sql += "from [hrs_mis].[dbo].[WPA51], [hrs_mis].[dbo].[WPA20] ";
        sql += "where PA51002 = '" + username + "' and PA51001 = '" + Enterprise.ConStr + "' and PA20001 = '" + Enterprise.ConStr + "' ";
        sql += "and PA51020 = PA20002";

        DataTable dt = new DataTable();
        dt = BOSSQL.hrsExecuteQuery(sql);

        if (dt.Rows[0][0].ToString() == "001" || dt.Rows[0][0].ToString() == "031")
        {
            if (Convert.ToInt16(from.Substring(11, 2)) < 8)
            {
                context.Response.Write("from <8");
                return;
            }
            else if (Convert.ToInt16(to.Substring(11, 2)) > 17)
            {
                context.Response.Write("to >17");
                return;
            }
            else
            {
                context.Response.Write("True");
                return;
            }
        }
        else if (dt.Rows[0][0].ToString() == "010" || dt.Rows[0][0].ToString() == "009")
        {
            if (Convert.ToInt16(from.Substring(11, 2)) < 9)
            {
                context.Response.Write("from <9");
                return;
            }
            else if (Convert.ToInt16(to.Substring(11, 2)) > 18)
            {
                context.Response.Write("to >18");
                return;
            }
            else
            {
                context.Response.Write("True");
                return;
            }

        }
        else if (dt.Rows[0][0].ToString() == "011" || dt.Rows[0][0].ToString() == "032")
        {
            DateTime ti1 = DateTime.Parse(from);
            DateTime ti2 = DateTime.Parse(DateTime.Parse(from).ToString("yyyy-MM-dd 08:30:00"));

            DateTime ti3 = DateTime.Parse(to);
            DateTime ti4 = DateTime.Parse(DateTime.Parse(to).ToString("yyyy-MM-dd 17:30:00"));

            if (ti1 < ti2)
            {
                context.Response.Write("from <830");
                return;
            }
            else if (ti3 > ti4)
            {
                context.Response.Write("to >1730");
                return;
            }
            else
            {
                context.Response.Write("True");
                return;
            }
        }
    }

    public object obj = new object();
    public void FinishSendEamil_Event(string ApplyUser, string to, string Type_, string CRUD)
    {
        string sql_Insert_Leave_Mail_Log = "Insert [TBI_HRS].[dbo].[leave_Maill_Log](Type_,ApplyUser,MailTo,CRUD) values(@Type_,@ApplyUser,@MailTo,@CRUD)";

        using (SqlConnection conn = new SqlConnection(tbiHRS))
        {
            using (SqlCommand comm = new SqlCommand(sql_Insert_Leave_Mail_Log, conn))
            {
                comm.Parameters.AddWithValue("@Type_", Type_);
                comm.Parameters.AddWithValue("@ApplyUser", ApplyUser);
                comm.Parameters.AddWithValue("@MailTo", to);
                comm.Parameters.AddWithValue("@CRUD", CRUD);
                lock (obj)
                {
                    conn.Open();

                    comm.ExecuteNonQuery();
                }


            }
        }
    }

    public bool HasAnnualLeave(string UserID)
    {
        string SQL = @"select PA86002,PA86007,PA86008,PA86010,PA86011
                       FROM [hrs_mis].[dbo].[WPA86] 
                       where [PA86001] = '" + Enterprise.ConStr + @"'
                       and PA86002='" + UserID + @"'
                       and  GETDATE() between PA86007 and PA86008".Replace("\r\n", "").Replace("\t", "");

        DataTable dt_pa86 = new DataTable();

        using (SqlConnection conn = new SqlConnection(tbiHRS))
        {
            using (SqlCommand comm = new SqlCommand(SQL, conn))
            {
                using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
                {
                    conn.Open();
                    adapter.Fill(dt_pa86);
                }
            }
        }

        //是否還有特休時數
        bool result = dt_pa86.Rows.Cast<DataRow>().Any(z =>
        {
            int TotalMin = int.Parse(z["PA86010"].ToString());
            int UsedMin = int.Parse(z["PA86011"].ToString());

            if (UsedMin < TotalMin)
                return true;
            else
                return false;
        });

        return result;
    }

    /// <summary>
    /// 依照目前假單的狀態 寄通知信給主管
    /// </summary>
    /// <param name="postionApply_"></param>
    /// <param name="postion_"></param>
    /// <param name="Current_XSingOrd"></param>
    /// <param name="Current_LeaveAF"></param>
    public void SendSupervisor(Position postionApply_, Position postion_, XSingOrd Current_XSingOrd, LeaveApplicationForm Current_LeaveAF)
    {
        List<SendSupervisorModal> SendSupervisorModal_List = null;
        //判斷申請者身份來寄送信件
        switch (postionApply_)
        {
            case Position.GENERAL:
                {
                    ////組長尚未審核過
                    //if (Current_LeaveAF.status_luser == null)
                    //{
                    //    SendSupervisorModal_List = GetMail(Current_XSingOrd.LUSERID);

                    //    break;
                    //}

                    if (Current_LeaveAF.status == 1)
                    {
                        //有三階主管
                        if (!string.IsNullOrEmpty(Current_XSingOrd.SUSERID))
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.SUSERID);
                        }
                        //有二階主管
                        else if (!string.IsNullOrEmpty(Current_XSingOrd.DUSERID))
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.DUSERID);
                        }
                        //有一階主管
                        else if (!string.IsNullOrEmpty(Current_XSingOrd.MUSERID))
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.MUSERID);
                        }
                        //由總經理、特助
                        else
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.GUSERID);
                        }


                    }
                    if (Current_LeaveAF.status == 2)
                    {
                        if (!string.IsNullOrEmpty(Current_XSingOrd.DUSERID))
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.DUSERID);
                        }
                        else if (!string.IsNullOrEmpty(Current_XSingOrd.MUSERID))
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.MUSERID);
                        }
                        else
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.GUSERID);
                        }

                    }
                    if (Current_LeaveAF.status == 3)
                    {
                        if (!string.IsNullOrEmpty(Current_XSingOrd.MUSERID))
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.MUSERID);
                        }
                        else
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.GUSERID);
                        }
                    }
                    if (Current_LeaveAF.status == 4)
                    {
                        SendSupervisorModal_List = GetMail(Current_XSingOrd.GUSERID);
                    }
                    break;
                }

            case Position.SUSER:
                {
                    if (Current_LeaveAF.status == 1 || Current_LeaveAF.status == 2)
                    {
                        if (!string.IsNullOrEmpty(Current_XSingOrd.DUSERID))
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.DUSERID);
                        }
                        else if (!string.IsNullOrEmpty(Current_XSingOrd.MUSERID))
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.MUSERID);
                        }
                        else
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.GUSERID);
                        }
                    }
                    if (Current_LeaveAF.status == 3)
                    {
                        if (!string.IsNullOrEmpty(Current_XSingOrd.MUSERID))
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.MUSERID);
                        }
                        else
                        {
                            SendSupervisorModal_List = GetMail(Current_XSingOrd.GUSERID);
                        }
                    }
                    if (Current_LeaveAF.status == 4)
                    {
                        SendSupervisorModal_List = GetMail(Current_XSingOrd.GUSERID);
                    }
                    break;
                }
            case Position.DUSER:
            case Position.MUSER:
                {
                    if (new[] { 1, 2, 3, 4 }.Contains(Current_LeaveAF.status))
                    {


                        SendSupervisorModal_List = GetMail(Current_XSingOrd.GUSERID);
                    }
                    break;
                }
        }

        //寄送 MAIL(可能多筆)
        if (SendSupervisorModal_List != null)
        {
            foreach (var SendSuperModal in SendSupervisorModal_List)
            {
                SendMail(SendSuperModal, Current_LeaveAF);
            }
        }


    }


    /// <summary>
    /// 取得MAIL
    /// </summary>
    /// <param name="username"></param>
    /// <returns></returns>
    public List<SendSupervisorModal> GetMail(string username)
    {
        string sql = string.Format(@"DECLARE @username nvarchar(50)='" + username + @"'

                                     IF @username='A02'
                                     		/* 傳送到 總經理、特助 的 email */
                                     		/* q1=04 特助的代號 */
                                     		SELECT Username,CNname, Email,q1		
                                     		FROM [tbi].[dbo].[Users]
                                     		where Username='A02' or q1='04'
                                     
                                     ELSE
                                     		SELECT Username,CNname,
                                     		CASE
                                     			WHEN  Email is null or Email=''
                                     				THEN 'kenwhz@tbimotion.com.tw'
                                     			ELSE Email
                                     		END as 'EMAIL'
                                            ,q1	
                                     		FROM [tbi].[dbo].[Users]
                                     		where TBI_HRS.dbo.CompareUsername(Username,@username)=1
                                     ").Replace("\r\n", "").Replace("\t", "");


        DataTable dt = BOSSQL.TBIHRSExecuteQuery(sql);

        List<SendSupervisorModal> SendSupervisorModal_list = new List<SendSupervisorModal>();


        foreach (DataRow i in dt.Rows)
        {
            SendSupervisorModal SendSupervisorModal_ = new SendSupervisorModal();

            SendSupervisorModal_.Username = i["Username"].ToString();
            SendSupervisorModal_.CNname = i["CNname"].ToString();
            SendSupervisorModal_.Email = i["Email"].ToString();
            SendSupervisorModal_.level_code = i["q1"].ToString();

            SendSupervisorModal_list.Add(SendSupervisorModal_);
        }


        return SendSupervisorModal_list;
    }


    /// <summary>
    /// 寄送 mail
    /// </summary>
    /// <param name="SendSuperModal"></param>
    /// <param name="Current_LeaveAF"></param>
    public void SendMail(SendSupervisorModal SendSuperModal, LeaveApplicationForm Current_LeaveAF)
    {
        Task.Factory.StartNew(() =>
        {

            //SmtpClient smtp = new SmtpClient();
            //MailMessage msg = new MailMessage();

            //msg.From = new MailAddress("admin@tbimotion.com.tw", "系統發送");  // 寄件者的信箱,寄件者的名字
            //msg.To.Add(new MailAddress(SendSuperModal.Email, SendSuperModal.CNname));    //收件者
            //                                                                             //msg.To.Add(new MailAddress(SendSuperModal.Email, SendSuperModal.CNname) )//收件者

            //msg.Subject = "請假通知單"; // 主旨

            //msg.Body = "請假資訊\n人員：" + Current_LeaveAF.username + "\n姓名：" + Current_LeaveAF.CNname + "\n假別：" + Current_LeaveAF.holiday_type_name + "\n請假日期：" + Current_LeaveAF.start_ + "~" + Current_LeaveAF.end_ + "\n請假時數：" + (Current_LeaveAF.Total_min / 60) + "小時\n備註：" + Current_LeaveAF.Cause + "\n職務代理人：" + Current_LeaveAF.agent;

            ////特助&總經理 寄信內容才會加下邊這句話
            //if (SendSuperModal.level_code == "04" || SendSuperModal.Username == "A02")
            //    msg.Body += "\n\n\n請總經理 / 特助抽空上系統做簽核動作。";

            //msg.Body += "\n此為系統自動發送，請勿直接回覆\n\n網址: http://tbihrs.tbimotion.com.tw/"; // 內文


            //smtp.SendCompleted += (sender, e) =>
            //{

            //    string ApplyUser = e.UserState.ToString().Split(';')[0];

            //    string to_ = e.UserState.ToString().Split(';')[1];

            //    string Type_ = "請假通知單";

            //    string CRUD = "Insert";

            //    FinishSendEamil_Event(ApplyUser, to_, Type_, CRUD);
            //};


            //if (this.IsDebug != true) smtp.SendAsync(msg, "Send Mail");


            Dictionary<string, string> to_list = new Dictionary<string, string>();
            to_list.Add( SendSuperModal.CNname,SendSuperModal.Email);

            string body = "請假資訊\n人員：" + Current_LeaveAF.username + "\n姓名：" + Current_LeaveAF.CNname + "\n假別：" + Current_LeaveAF.holiday_type_name + "\n請假日期：" + Current_LeaveAF.start_ + "~" + Current_LeaveAF.end_ + "\n請假時數：" + (Current_LeaveAF.Total_min / 60) + "小時\n備註：" + Current_LeaveAF.Cause + "\n職務代理人：" + Current_LeaveAF.agent;

            Common.SendMail(to_list, "請假通知單", body);
        });

    }
}

