using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace 全傳請假系統
{
    public partial class check1_produeline : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string conStr = ConfigurationManager.AppSettings["conStr"];
            if (Session["UserName"] == null)
            {
                Response.Write("<script>alert('登入時限已到，請重新登入');location.href='Login.aspx';</script>");
            }
            else if (Session["UserName"] != null)
            {
                Label19.Text = "登入時間：" + Session["time"].ToString();
                string strSQL;
                string connStr = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;
                //建立連接
                SqlConnection myConn = new SqlConnection(connStr);//建立名為conn的連結物件
                if (Session["UserName"].ToString() == "A02")
                {
                    strSQL = "SELECT U.id, U.Username, U.UserPwd, U.CNname, U.q1, U.a1, U.DAT_LIME, W.PAAK200 FROM tbi.dbo.Users U, tbi.dbo.WPAAK W WHERE U.q1 = W.PAAK002 AND U.Username = @paramName GROUP BY U.id, U.Username, U.UserPwd, U.CNname, U.q1, U.a1, U.DAT_LIME, W.PAAK200";
                    //建立SQL命令對象
                    SqlCommand myCommand = new SqlCommand(strSQL, myConn);
                    myCommand.Parameters.Add("@paramName", SqlDbType.VarChar).Value = Session["UserName"].ToString().Trim();
                    //打開連接
                    myConn.Open();
                    //得到Data結果集
                    SqlDataReader myDataReader = myCommand.ExecuteReader();
                    try
                    {
                        if (myDataReader.HasRows)
                        {
                            while (myDataReader.Read())
                            {
                                Session["CNname"] = myDataReader["CNname"].ToString();
                                Session["userone"] = myDataReader["Username"].ToString().Substring(0, 1);
                                DateTime now = DateTime.Now;
                                Session["now"] = now.ToString("yyyyMMdd");
                                SqlConnection cob = new SqlConnection(connStr);//建立名為conn的連結物件
                                cob.Open();//開啟資料庫
                                string sql2 = "SELECT U.CNname, U.a1, K.PAAK003, K.PAAK200 FROM tbi.dbo.Users U, tbi.dbo.WPAAK K WHERE U.Username = '" + Session["UserName"].ToString() + "' AND U.q1 = K.PAAK002 GROUP BY U.CNname, U.a1, K.PAAK003, K.PAAK200";
                                SqlCommand tbii = new SqlCommand(sql2, cob);
                                DataTable dt = new DataTable();
                                dt.Load(tbii.ExecuteReader());
                                Session["db"] = dt.Rows[0][1].ToString();
                                Session["level"] = dt.Rows[0][3].ToString();
                                tbii.Cancel();
                                cob.Dispose();
                                cob.Close();

                            }
                        }
                        myCommand.Dispose();
                    }
                    catch
                    {
                        myConn.Dispose();
                        myConn.Close();
                    }
                    finally
                    {
                        myConn.Dispose();
                        myConn.Close();
                    }
                }
                else
                {
                    strSQL = "SELECT U.id, U.Username, U.UserPwd, U.CNname, U.q1, U.a1, U.DAT_LIME, W.PAAK200, mf.CONTEN FROM tbi.dbo.WPAAK W INNER JOIN tbi.dbo.Users U ON W.PAAK002 = U.q1 LEFT JOIN tbi.dbo.Winton_mf2000 mf ON u.runk = mf.ClassID AND u.a1 = mf.hrs AND mf.online = '1' WHERE U.Username = @paramName ORDER BY U.Username";
                    //建立SQL命令對象
                    SqlCommand myCommand = new SqlCommand(strSQL, myConn);
                    myCommand.Parameters.Add("@paramName", SqlDbType.VarChar).Value = Session["UserName"].ToString().Trim();
                    //打開連接
                    myConn.Open();
                    //得到Data結果集
                    SqlDataReader myDataReader = myCommand.ExecuteReader();
                    try
                    {
                        if (myDataReader.HasRows)
                        {
                            while (myDataReader.Read())
                            {
                                Session["CNname"] = myDataReader["CNname"].ToString();
                                Session["userone"] = myDataReader["Username"].ToString().Substring(0, 1);
                                //-------------------------------------------------------------------------------------
                                DateTime now = DateTime.Now;
                                Session["now"] = now.ToString("yyyyMMdd");
                                SqlConnection cob = new SqlConnection(connStr);//建立名為conn的連結物件
                                cob.Open();//開啟資料庫
                                string sql2 = "SELECT U.CNname, U.a1, K.PAAK003, K.PAAK200 FROM tbi.dbo.Users U, tbi.dbo.WPAAK K WHERE U.Username = '" + Session["UserName"].ToString() + "' AND U.q1 = K.PAAK002 GROUP BY U.CNname, U.a1, K.PAAK003, K.PAAK200";
                                SqlCommand tbii = new SqlCommand(sql2, cob);
                                DataTable dt = new DataTable();
                                dt.Load(tbii.ExecuteReader());
                                Session["db"] = dt.Rows[0][1].ToString();
                                Session["level"] = dt.Rows[0][3].ToString();
                                tbii.Cancel();
                                cob.Dispose();
                                cob.Close();

                            }
                        }
                        myCommand.Dispose();
                    }
                    catch
                    {
                        myConn.Dispose();
                        myConn.Close();
                    }
                    finally
                    {
                        myConn.Dispose();
                        myConn.Close();
                    }
                }
            }
        }
    }
}