
using HR.DBUtility;
using HRS.Common;
using Newtonsoft.Json;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.SessionState;

namespace 全傳請假系統.Tools
{
    //03009_2
    /// <summary>
    /// Login 的摘要描述
    /// </summary>
    public class Login : IHttpHandler, IRequiresSessionState
    {
        string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;
        string hrs = ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString;
        string tbiHRS = ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString;
        HttpContext Cur_context;

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        public void ProcessRequest(HttpContext context)
        {
            this.Cur_context = context;

            if (context.Request["mode"] != null)
            {
                string mode = context.Request["mode"].ToString();
                switch (mode)
                {
                    case "Login":
                        Login_(context);
                        break;
                }
            }
        }


        public void Login_(HttpContext context)
        {
            string account = context.Request["account"].ToString().Trim();
            string account2 = "";
            if (account != "")
            {
                account2 = account.Substring(1);
            }
            string password = context.Request["password"].ToString().Trim();
            //建立連接
            using (SqlConnection myConn = new SqlConnection(tbi))
            {
                //String strSQL = @"SELECT U.id, U.Username, U.UserPwd, U.CNname, U.q1, U.a1, U.DAT_LIME, W.PAAK200, mf.CONTEN, U.zfbNO FROM tbi.dbo.WPAAK W INNER JOIN tbi.dbo.Users U ON W.PAAK002 = U.q1 LEFT JOIN tbi.dbo.Winton_mf2000 mf ON U.a1 = mf.hrs AND mf.online = '1' WHERE U.Username = @paramName ORDER BY U.Username";
                String strSQL = "SELECT U.id, U.Username, U.UserPwd, U.CNname, U.q1, U.a1, U.DAT_LIME, W.PAAK200, mf.CONTEN, U.zfbNO FROM tbi.dbo.WPAAK W INNER JOIN tbi.dbo.Users U ON W.PAAK002 = U.q1 LEFT JOIN tbi.dbo.Winton_mf2000 mf ON U.zfbNO = mf.id WHERE U.Username = @paramName ORDER BY U.Username";
                //建立SQL命令對象
                SqlCommand myCommand = new SqlCommand(strSQL, myConn);
                myCommand.Parameters.Add("@paramName", SqlDbType.VarChar).Value = account;
                //打開連接
                myConn.Open();
                //得到Data結果集
                SqlDataReader myDataReader = myCommand.ExecuteReader();

                if (myDataReader.HasRows)
                {
                    while (myDataReader.Read())
                    {
                        if (account == myDataReader["Username"].ToString().Trim() && (DESEncrypt.Encrypt(password, Param.EncCode) == myDataReader["UserPwd"].ToString().Trim() || password == myDataReader["UserPwd"].ToString().Trim()))
                        {
                            string Date1 = myDataReader["DAT_LIME"].ToString().Trim();
                            string Date2 = DateTime.Now.ToString("yyyyMMdd");
                            if (string.Compare(Date1, Date2) > 0)
                            {
                                context.Session["UserName"] = myDataReader["Username"].ToString().Trim();
                                context.Session["PAAK200"] = myDataReader["PAAK200"].ToString().Trim();
                                context.Session["CONTEN"] = myDataReader["CONTEN"].ToString().Trim();
                                context.Session["a1"] = myDataReader["a1"].ToString().Trim();
                                context.Session["zfbNO"] = myDataReader["zfbNO"].ToString().Trim();
                                DateTime time = DateTime.Now;
                                context.Session["time"] = time.ToString("yyyy/MM/dd dddd HH:mm:ss");
                                int paak200 = Convert.ToInt32(myDataReader["PAAK200"].ToString());
                                //context.Response.Write(paak200);
                                //myDataReader.Close();

                                //此處設定登入頁面，並存入 SESSION 中
                                //行政 & 非排班人員 => Home.aspx
                                //現場 & 排班人員 => Home_produceline.aspx
                                GetHomePageUrl_fun(context);

                                if (context.Session["Identity"] == null)
                                    return;


                                GetCurrentPage();

                                context.Response.Write(JsonConvert.SerializeObject(new { url = Cur_context.Session["Home"].ToString(), paak = paak200 }));

                                context.Session["CanCheck"] = Common.CanCheck(account);

                                //string strSQL2 = "SELECT U.id, U.Username, U.UserPwd, U.CNname, U.q1, U.DAT_LIME, PA.PADF005, PA.PADF011 FROM tbi.dbo.Users U, OPENDATASOURCE('SQLOLEDB', '" + hrs + "').hrs_mis.dbo.WPADF PA WHERE U.Username = '0' + PA.PADF002 AND U.Username = '" + account + "' GROUP BY U.id, U.Username, U.UserPwd, U.CNname, U.q1, U.DAT_LIME, PA.PADF005, PA.PADF011";
                                SqlConnection Conn = new SqlConnection(hrs);
                                string strSQL2 = "SELECT PADF002, PADF005, PADF006 FROM hrs_mis.dbo.WPADF WHERE PADF002 = '" + account2 + "' AND PADF006 >= '" + DateTime.Now.ToString("yyyy-MM-dd") + "'";
                                SqlCommand cmd2 = new SqlCommand(strSQL2, Conn);
                                Conn.Open();
                                SqlDataReader myDataReader2 = cmd2.ExecuteReader();
                                try
                                {
                                    if (myDataReader2.HasRows)
                                    {
                                        while (myDataReader2.Read())
                                        {
                                            if (account2 == myDataReader2["PADF002"].ToString().Trim())
                                            {
                                                context.Response.Write(" 留職停薪");
                                                context.Session["PADF"] = "留職停薪";
                                            }
                                        }
                                    }
                                }
                                catch
                                {
                                    cmd2.Dispose();
                                    myDataReader2.Close();
                                    Conn.Dispose();
                                    Conn.Close();
                                }
                                finally
                                {
                                    cmd2.Dispose();
                                    myDataReader2.Close();
                                    Conn.Dispose();
                                    Conn.Close();
                                }
                            }
                            else
                            {
                                context.Response.Write(string.Compare(Date1, Date2));
                            }
                        }
                        else
                        {
                            context.Response.Write(false);
                        }
                    }
                }
                myCommand.Dispose();

            }

        }

        /// <summary>
        /// 依照目前的身分取得相對應的頁面
        /// </summary>
        private void GetCurrentPage()
        {
            string username = Cur_context.Session["UserName"].ToString();

            Identity temp = (Identity)this.Cur_context.Session["Identity"];

            switch (temp)
            {
                case Identity.Administrator:
                    {
                        //預設使用 Home.aspx
                        //人資最高權限人員使用 Home_produceline.aspx (可使用 代 KEY 功能)
                        if (Common.CheckIsSupervisor(username))
                        {
                            Cur_context.Session["Home"] = "Home_produceline.aspx";
                        }
                        else
                        {
                            Cur_context.Session["Home"] = "Home.aspx";
                        }

                        Cur_context.Session["check1"] = "check1.aspx";
                        Cur_context.Session["select2"] = "select2.aspx";

                        //是否增加現場審核頁面(ex: 總經理、有管理現場部門的行政主管)
                        if (Common.HasAuditSpotDepartment(username))
                        {
                            Cur_context.Session["check2"] = "check1_produceline.aspx";
                        }
                        else
                        {
                            Cur_context.Session.Remove("check2.aspx");
                        }

                        break;
                    }
                case Identity.Spot:
                    {
                        Cur_context.Session["Home"] = "Home_produceline.aspx";
                        Cur_context.Session["check2"] = "check1_produceline.aspx";
                        Cur_context.Session["select2"] = "select2_produceline.aspx";


                        break;
                    }
            }

        }

        //依據文中個人主檔判斷是使用 排班 或是 非排班 頁面 

        public void GetHomePageUrl_fun(HttpContext context)
        {
            string username = context.Session["UserName"].ToString();


            //判斷是否為現場組別理面
            Identity current_identity = Common.JudgeIsSpot(username);


            //行政組別
            if (current_identity == Identity.Administrator)
            {
                //判斷當前登入者在審核權限表裡面，可以審核的組別是否有在 28 組裡面

                context.Session["Identity"] = Identity.Administrator;

                //return "Home.aspx";

            }
            //現場組別
            else
            {
                context.Session["Identity"] = Identity.Spot;

                //return "Home_produceline.aspx";
            }

        }

    }
}