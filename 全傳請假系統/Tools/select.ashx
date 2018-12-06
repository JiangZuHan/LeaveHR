<%@ WebHandler Language="C#" Class="_select" %>

using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using HRS.Common;
using HR.DBUtility;
using WorkCheck.Tools;
using 全傳請假系統.ViewModel;


public class _select : IHttpHandler, IRequiresSessionState
{
    string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;
    string tbiHRS = ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString;
    string hrs = ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString;
    string SQL1 = "SELECT CONTEN FROM tbi.dbo.Winton_mf2000";
    //string SQL2 = "SELECT Username, CNname FROM tbi.dbo.Users  JOIN tbi.dbo.Winton_mf2000 ON hrs = a1 JOIN [tbi].[dbo].[WPAAK] on q1 = PAAK002 WHERE /* DAT_LIME > CONVERT(varchar(12), GETDATE(), 112) */ ";

    string SQL2 = @"/*當前使用者的 部門別*/
                    DECLARE @x nvarchar(50)=(select zfbNO from tbi.dbo.Users where Username='#username');
                    DECLARE @PAAK200 nvarchar(50)='#paak200';
                    
                    WITH 
                    TempTable AS   /* 想要的格式暫存Table */             
                    (                 
                      SELECT id,mf200,hrs,CONTEN,
                    	(CASE hrs 
                    		WHEN 'C001' /*船務課*/
                    			THEN 'C0'
                    		WHEN '026' /*線軌生管組*/
                    			THEN '004'
                    		WHEN '027' /*職安室*/
                    			THEN '001'
                    		ELSE SUBSTRING(hrs,1,LEN(REPLACE(hrs,' ',''))-1)
                    	END) parent_             
                      FROM tbi.dbo.Winton_mf2000               
                    ),  
                    AreasCTE AS                
                    (                 
                    /*anchor select, start with the country of Canada, which will be the root element for our search*/                
                    SELECT id,mf200,hrs,CONTEN,parent_            
                    FROM TempTable          
                    WHERE id = @x /*設定當前使用者*/                
                    UNION ALL                
                    /*recursive select, recursive until you reach a leaf (an Area which is not a parent of any other area)*/          
                    SELECT a.id,a.mf200,a.hrs,a.CONTEN,a.parent_               
                    FROM TempTable  a                 
                    INNER JOIN AreasCTE s ON  a.parent_= s.hrs                 
                    )                 
                    /*Now, you will have all Areas in Canada, so now let's filter by the AreaType 'City'                    
                    SELECT CONTEN  FROM AreasCTE   */                     
                                                
                    SELECT distinct Username, CNname ,CONTEN,DAT_LIME                
                    FROM tbi.dbo.Users                  
                    JOIN tbi.dbo.Winton_mf2000 ON zfbNO=Winton_mf2000.id                 
                    JOIN [tbi].[dbo].[WPAAK] on q1 = PAAK002                 
                    WHERE ";

    string SQL3, SQL4;
    string CONTEN, PAAK200, PA60002, username;
    string conStr = Enterprise.ConStr;
    string tbiHRS_ConStr = Enterprise.ConStr;


    public void Hiu(HttpContext context)
    {
        CONTEN = context.Session["CONTEN"].ToString().Trim();
        PAAK200 = context.Session["PAAK200"].ToString().Trim();
        PA60002 = context.Session["UserName"].ToString().Trim();
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

            Hiu(context);
            string mode = context.Request["mode"].ToString();
            switch (mode)
            {
                case "Dept":
                    Dept(context);
                    break;
                case "User":
                    User(context);
                    break;
                case "User2":
                    User2(context);
                    break;
                case "Search":
                    Search(context);
                    break;
                case "Approval":
                    Approval(context);
                    break;
                case "CanAdvanceMode":
                    CanAdvanceMode(context);
                    break;
            }
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }


    private void CanAdvanceMode(HttpContext context)
    {

        if (Common.CheckIsSupervisor(PA60002))
        {
            context.Response.Write(99);
            return;
        }

        if (Common.GetAllMUser().Contains(PA60002))
        {
            context.Response.Write(1);
            return;
        }


        context.Response.Write(0);
    }
    private DataTable DataTable1(string SQL1, HttpContext context)
    {
        Hiu(context);


        if (CONTEN != "人力資源部" && PAAK200 != "1" && PAAK200 != "20")
        {
            //除了人資部以外，各個部門的主管可以看到權責單位部門(多個)
            SQL1 = @"/*當前使用者的 部門別*/
                    DECLARE @x nvarchar(50)=(select zfbNO from tbi.dbo.Users where Username='" + PA60002 + @"');
                    
                    WITH 
                    TempTable AS   /* 想要的格式暫存Table */             
                    (                 
                      SELECT id,mf200,hrs,CONTEN,
                    	(CASE hrs 
                    		WHEN 'C001' /*船務課*/
                    			THEN 'C0'
                    		WHEN '026' /*線軌生管組*/
                    			THEN '004'
                    		WHEN '027' /*職安室*/
                    			THEN '001'
                    		ELSE SUBSTRING(hrs,1,LEN(REPLACE(hrs,' ',''))-1)
                    	END) parent_             
                      FROM tbi.dbo.Winton_mf2000               
                    ),  
                    AreasCTE AS                
                    (                 
                    /*anchor select, start with the country of Canada, which will be the root element for our search*/                
                    SELECT id,mf200,hrs,CONTEN,parent_            
                    FROM TempTable          
                    WHERE id = @x /*設定當前使用者*/                
                    UNION ALL                
                    /*recursive select, recursive until you reach a leaf (an Area which is not a parent of any other area)*/          
                    SELECT a.id,a.mf200,a.hrs,a.CONTEN,a.parent_               
                    FROM TempTable  a                 
                    INNER JOIN AreasCTE s ON  a.parent_= s.hrs                 
                    )                 
                    /*Now, you will have all Areas in Canada, so now let's filter by the AreaType 'City'    */                
                    SELECT CONTEN  FROM AreasCTE ";

            //SQL1 += " WHERE CONTEN = '" + CONTEN + "'";// AND online = '1'";
        }



        DataSet ds = new DataSet();
        SqlConnection conn = new SqlConnection(tbi);
        SqlDataAdapter da = new SqlDataAdapter(SQL1, conn);
        da.Fill(ds);
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }

    private DataTable DataTable2(string SQL2, HttpContext context)
    {
        Hiu(context);
        if (CONTEN != "人力資源部" && CONTEN != "稽核室" && PAAK200 != "1" && PAAK200 != "20")
        {
            //SQL2 += " Username != '" + PA60002 + "' AND CONTEN = '" + CONTEN + "' and PAAK200 > '" + PAAK200 + "' GROUP BY Username, CNname";
            SQL2 = SQL2.Replace("\r\n", "").Replace("\r\n", "");

            SQL2 = SQL2.Replace("#username", PA60002).Replace("#paak200", PAAK200);

            SQL2 += "Username != @x AND CONTEN in (SELECT CONTEN FROM AreasCTE  ) AND PAAK200 > @PAAK200 AND DAT_LIME > CONVERT(varchar(12), GETDATE(), 112) ";
        }
        else
        {
            SQL2 = SQL2.Replace("\r\n", "").Replace("\r\n", "");

            SQL2 += " Username != '" + PA60002 + "' ";
        }
        DataSet ds = new DataSet();
        using (SqlConnection conn = new SqlConnection(tbi))
        {
            using (SqlDataAdapter da = new SqlDataAdapter(SQL2, conn))
            {
                da.Fill(ds);
                return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
            }
        }


    }

    private DataTable DataTable3(string SQL2, HttpContext context)
    {
        Hiu(context);
        if (CONTEN == "人力資源部" || CONTEN != "稽核室" || PAAK200 == "1" || PAAK200 == "20")
        {
            string dept = context.Request["dept"].ToString().Trim();
            if (dept != "")
            {
                SQL2 += " Username != '" + PA60002 + "' AND CONTEN IN (" + dept + ") GROUP BY Username, CNname ";
            }
            else
            {
                SQL2 += " Username != '" + PA60002 + "' GROUP BY Username, CNname";
            }
        }
        else
        {
            SQL2 += " Username != '" + PA60002 + "' AND CONTEN = '" + CONTEN + "' and PAAK200 > '" + PAAK200 + "' GROUP BY Username, CNname";
        }
        DataSet ds = new DataSet();
        SqlConnection conn = new SqlConnection(tbi);
        SqlDataAdapter da = new SqlDataAdapter(SQL2, conn);
        da.Fill(ds);
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }

    private DataTable DataTable4(string SQL3, HttpContext context)
    {
        Hiu(context);
        string dept = context.Request["dept"].ToString().Trim().Replace("'","");
        string approval = context.Request["approval"].ToString().Trim();
        string user = context.Request["user"].ToString().Trim();
        string leavedate = context.Request["leavedate"].ToString().Trim();
        string toleavedate = context.Request["toleavedate"].ToString().Trim();
        string leave = context.Request["leave"].ToString().Trim();
        if (PA60002.StartsWith("0") == true && PA60002.Length == 5)
        {
            PA60002 = PA60002.Substring(1);
        }
        if (user.StartsWith("0") == true)
        {
            user = user.Substring(1);
        }

        //兩次篩選
        //第一次使用 SQL 做篩選     

        string sql = string.Format(@"DECLARE @input_start_ nvarchar(50)=N'" + leavedate + @"'
DECLARE @input_end_ nvarchar(50)=N'" + toleavedate + @"'

DECLARE @start_ datetime=DATEADD(year,DATEDIFF(year,0,GETDATE()),-365) /* 去年年初 */
DECLARE @end_ datetime=DATEADD(year,DATEDIFF(year,-1,getdate()),364) /* 明年年底 */

/* 如果為空字串，傳回NULL */
IF NULLIF(@input_start_,'') is not null
	set @start_=CONVERT(datetime,@input_start_)

IF NULLIF(@input_end_,'') is not null
	set @end_=CONVERT(datetime,@input_end_)

select PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003, PA60038, PA60040, PA60039, PA60042, CONTEN, CNname 
FROM  TBI_HRS.dbo.PA123
left JOIN tbi.dbo.Users ON SUBSTRING(Username, PATINDEX('%[^0]%', Username), LEN(Username)) = SUBSTRING(PA60002, PATINDEX('%[^0]%', PA60002), LEN(PA60002))  
left JOIN tbi.dbo.Winton_mf2000 mf on Users.zfbNO=mf.id
WHERE PA60043 IS NULL
AND PA60001 = '" + Enterprise.ConStr + @"'
AND
/* 計算所有包含時間的方式 */
(CASE 
	WHEN SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN @start_ AND @end_
		THEN 1
	WHEN CONVERT(datetime,@start_) BETWEEN PA60007 AND PA60008
		THEN 1
	WHEN CONVERT(datetime,@end_) BETWEEN PA60007 AND PA60008
		THEN 1
END)=1");


        DataTable dt = BOSSQL.TBIHRSExecuteQuery(sql);



        //第二次使用 C# 做篩選   

        //空值 丟空 table 回去
        if (dt.Rows.Count <= 0) return dt;

        List<DataRow> temp = dt.Rows.Cast<DataRow>().ToList();

        //篩選部門  
        if (dept != "")
            temp = temp.Where(z => z["CONTEN"].ToString()==dept).ToList();

        //篩選指定人員
        if (user != "")
            temp = temp.Where(z => z["PA60002"].ToString()==user).ToList();
        else
            temp = temp.Where(z => z["PA60002"].ToString()==username).ToList();

        //篩選審核狀態
        if (approval != "-1")
            temp = temp.Where(z => z["PA60039"].ToString()==approval).ToList();

        //篩選假別
        if (leave != "")
            temp = temp.Where(z => z["PA60004"].ToString()==leave).ToList();

        if (temp.Count > 0)
            dt = temp.CopyToDataTable();
        else
            dt = new DataTable();

        return dt;
    }

    private DataTable DataTable5(HttpContext context)
    {
        Hiu(context);
        string week = context.Request["week2"].ToString().Trim();
        string week2 = DateTime.Parse(week).ToString("yyyy-MM-dd");
        if (PA60002 == "A02")
        {
            SQL4 = "SELECT CONTEN, PA60002, CNname, PA60004, PA60007, PA60008, PA60011, PA60016, PA60038, PA60040, PA60998, PA60996, PA60003 FROM TBI_HRS.dbo.PA123, tbi.dbo.Winton_mf2000 mf JOIN tbi.dbo.Users u ON zfbNO = mf.id JOIN tbi.dbo.WPAAK ON PAAK002 = q1 WHERE PA60001='" + tbiHRS_ConStr + "' AND Username LIKE '%' + PA60002 AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) <= '" + week2 + "' AND SUBSTRING(CONVERT(varchar, PA60008, 120), 1, 10) >= '" + week2 + "' AND PA60039 = '0' AND PA60043 IS NULL AND (PAAK200 BETWEEN '10' AND '38' OR PA60011 >= '1440') ORDER BY PA60007";
        }
        else
        {
            SQL4 = "SELECT CONTEN, PA60002, CNname, PA60004, PA60007, PA60008, PA60011, PA60016, PA60038, PA60040, PA60998, PA60996, PA60003 FROM TBI_HRS.dbo.PA123, tbi.dbo.Winton_mf2000 mf JOIN tbi.dbo.Users u ON zfbNO = mf.id WHERE PA60001='" + tbiHRS_ConStr + "' AND Username LIKE '%' + PA60002 AND CONTEN = '" + CONTEN + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) <= '" + week2 + "' AND SUBSTRING(CONVERT(varchar, PA60008, 120), 1, 10) >= '" + week2 + "' AND PA60039 = '0' AND PA60043 IS NULL ORDER BY PA60007";
        }
        DataSet ds = new DataSet();
        SqlConnection conn = new SqlConnection(tbi);
        SqlDataAdapter da = new SqlDataAdapter(SQL4, conn);
        da.Fill(ds);
        return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
    }

    public void Dept(HttpContext context)
    {
        DataTable dt = this.DataTable1(SQL1, context);
        string ReturnString = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(ReturnString);

        //順便初始化職級和簽核權限的對照表
        InitHr_MISPA51ANDTbiWPAAK_(context);
    }

    public void InitHr_MISPA51ANDTbiWPAAK_(HttpContext context)
    {
        string WPAAK_sql = "select PAAK002,PAAK003,PAAK200 from tbi.dbo.WPAAK ";
        DataTable WPAAK_dt = DBSQLHELP_TBI_HRS.ExecuteQuery_TBI_HRS(WPAAK_sql);

        string WPA51_sql = "select PA51002,PA51135 as PAAK002 from hrs_mis.dbo.wpa51 where PA51001='" + Enterprise.ConStr + "' /*and PA51025 is null 加上後離職人員要查詢會跳Error*/";
        DataTable WPA51_dt = WZDBSQLHELP.ExecuteQuery(WPA51_sql);

        var result = from wpaak in WPAAK_dt.AsEnumerable()
                     join wpa51 in WPA51_dt.AsEnumerable()
                     on wpaak.Field<string>("PAAK002") equals wpa51.Field<string>("PAAK002")
                     select new WPA51ANDWPAAK_
                     {
                         PAAK002 = wpaak["PAAK002"].ToString(),
                         PAAK003 = wpaak["PAAK003"].ToString(),
                         PAAK200 = wpaak["PAAK200"].ToString(),
                         PA51002 = wpa51["PA51002"].ToString()
                     };

        var result_r = result.ToList();

        context.Session["PA51ANDTbiWPAAK"] = result_r;

    }

    public void User(HttpContext context)
    {
        DataTable dt = this.DataTable2(SQL2, context);
        string ReturnString = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(ReturnString);
    }

    public void User2(HttpContext context)
    {
        DataTable dt = this.DataTable3(SQL2, context);
        string ReturnString = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(ReturnString);
    }

    private DataTable PA60(HttpContext context)
    {
        string dept = context.Request["dept"].ToString().Trim();
        string approval = context.Request["approval"].ToString().Trim();
        string user = context.Request["user"].ToString().Trim();
        string leavedate = context.Request["leavedate"].ToString().Trim();
        string toleavedate = context.Request["toleavedate"].ToString().Trim();
        string leave = context.Request["leave"].ToString().Trim();
        if (PA60002.StartsWith("0") == true && PA60002.Length == 5)
        {
            PA60002 = PA60002.Substring(1);
        }
        if (user.StartsWith("0") == true)
        {
            user = user.Substring(1);
        }
        if (approval == "-1" || approval == "0")
        {
            if (dept != "")//1.有選取部門
            {
                if (user != "")//2.選取部門下查詢指定工號
                {
                    if (leavedate != "" && toleavedate != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '" + toleavedate + "' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                        if (leave != "")//4.
                        {
                            SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '" + toleavedate + "' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                        }
                    }
                    else if (leavedate != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '29991231' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                        if (leave != "")//4.
                        {
                            SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '29991231' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                        }
                    }
                    else if (toleavedate != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '19700101' AND '" + toleavedate + "' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                        if (leave != "")//4.
                        {
                            SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE AND PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '19700101' AND '" + toleavedate + "' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                        }
                    }
                    else if (leavedate == "" && toleavedate == "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) AND DATEADD(mm, 1, DATEADD(dd, 0, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))) - 1 and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                        if (leave != "")//4.
                        {
                            SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) AND DATEADD(mm, 1, DATEADD(dd, 0, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))) - 1 AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                        }
                    }
                }
                else//2.選取部門下不選取工號
                {
                    string sql = "SELECT Username, CONTEN FROM tbi.dbo.Users JOIN tbi.dbo.Winton_mf2000 ON zfbNO = Winton_mf2000.id /*a1 = hrs AND online = '1'*/ WHERE CONTEN IN (" + dept + ")";
                    SqlConnection corr = new SqlConnection(tbi);//建立名為conn的連結物件
                    corr.Open();
                    SqlCommand tdiii = new SqlCommand(sql, corr);
                    DataTable doublecheck = new DataTable();
                    doublecheck.Load(tdiii.ExecuteReader());
                    tdiii.Cancel();
                    corr.Dispose();
                    corr.Close();
                    string num = null;
                    for (int i = 0; i < doublecheck.Rows.Count; i++)
                    {
                        if (doublecheck.Rows[i]["Username"].ToString().StartsWith("0") == true && doublecheck.Rows[i]["Username"].ToString().Length == 5)
                        {
                            if (i == doublecheck.Rows.Count - 1)
                            {
                                num += "'" + doublecheck.Rows[i]["Username"].ToString().Substring(1) + "'";
                            }
                            else
                            {
                                num += "'" + doublecheck.Rows[i]["Username"].ToString().Substring(1) + "', ";
                            }
                        }
                        else
                        {
                            if (i == doublecheck.Rows.Count - 1)
                            {
                                num += "'" + doublecheck.Rows[i]["Username"].ToString() + "'";
                            }
                            else
                            {
                                num += "'" + doublecheck.Rows[i]["Username"].ToString() + "', ";
                            }
                        }
                        if (leavedate != "" && toleavedate != "")//3.
                        {
                            SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 IN (" + num + ") AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '" + toleavedate + "' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                            if (leave != "")//4.
                            {
                                SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 IN (" + num + ") AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '" + toleavedate + "' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                            }
                        }
                        else if (leavedate != "")//3.
                        {
                            SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 IN (" + num + ") AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '29991231' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                            if (leave != "")//4.
                            {
                                SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 IN (" + num + ") AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '29991231' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                            }
                        }
                        else if (toleavedate != "")//3.
                        {
                            SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 IN (" + num + ") AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '19700101' AND '" + toleavedate + "' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                            if (leave != "")//4.
                            {
                                SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 IN (" + num + ") AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '19700101' AND '" + toleavedate + "' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                            }
                        }
                        else if (leavedate == "" && toleavedate == "")//3.
                        {
                            SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 IN (" + num + ") AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) AND DATEADD(mm, 1, DATEADD(dd, 0, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))) - 1 and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                            if (leave != "")//4.
                            {
                                SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 IN (" + num + ") AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) AND DATEADD(mm, 1, DATEADD(dd, 0, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))) - 1 AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                            }
                        }
                    }
                }
            }
            else if (user != "")//1.不選取部門下查詢指定工號
            {
                if (leavedate != "" && toleavedate != "")//2.
                {
                    SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '" + toleavedate + "' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    if (leave != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '" + toleavedate + "' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    }
                }
                else if (leavedate != "")//2.
                {
                    SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '29991231' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    if (leave != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '29991231' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    }
                }
                else if (toleavedate != "")//2.
                {
                    SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '19700101' AND '" + toleavedate + "' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    if (leave != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '19700101' AND '" + toleavedate + "' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    }
                }
                else if (leavedate == "" && toleavedate == "")//2.
                {
                    SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) AND DATEADD(mm, 1, DATEADD(dd, 0, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))) - 1 and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    if (leave != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + user + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) AND DATEADD(mm, 1, DATEADD(dd, 0, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))) - 1 AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    }
                }
            }
            else if (user == "")//1.查詢自己紀錄
            {
                if (leavedate != "" && toleavedate != "")//2.
                {
                    SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + PA60002 + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '" + toleavedate + "' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    if (leave != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + PA60002 + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '" + toleavedate + "' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    }
                }
                else if (leavedate != "")//2.
                {
                    SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + PA60002 + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '29991231' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    if (leave != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + PA60002 + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '" + leavedate + "' AND '29991231' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    }
                }
                else if (toleavedate != "")//2.
                {
                    SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + PA60002 + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '19700101' AND '" + toleavedate + "' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    if (leave != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + PA60002 + "' AND SUBSTRING(CONVERT(varchar, PA60007, 120), 1, 10) BETWEEN '19700101' AND '" + toleavedate + "' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    }
                }
                else if (leavedate == "" && toleavedate == "")//2.
                {
                    SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + PA60002 + "' and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    if (leave != "")//3.
                    {
                        SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE PA60002 = '" + PA60002 + "' AND PA60004 IN (" + leave + ") and PA60004 not in ('0') and PA60001 = '" + conStr + "'";
                    }
                }
            }
            DataSet ds = new DataSet();
            SqlConnection conn = new SqlConnection(hrs);
            SqlDataAdapter da = new SqlDataAdapter(SQL3, conn);
            da.Fill(ds);
            return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
        }
        else
        {
            SQL3 = "SELECT PA60002, PA60004, ISNULL(PA60007, '') PA60007, ISNULL(PA60008, '') PA60008, PA60011, PA60016, PA60998, PA60996, PA60003 FROM hrs_mis.dbo.WPA60 WHERE '1' != '1' and PA60004 not in ('0')";
            DataSet ds = new DataSet();
            SqlConnection conn = new SqlConnection(hrs);
            SqlDataAdapter da = new SqlDataAdapter(SQL3, conn);
            da.Fill(ds);
            return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
        }
    }

    public void Search(HttpContext context)
    {

        DataTable dt = this.DataTable4(SQL3, context);
        dt.Columns.Add("start");
        dt.Columns.Add("end");
        dt.Columns.Add("time");
        dt.Columns.Add("app");
        dt.Columns.Add("audit");
        dt.Columns.Add("PA604");
                        dt.Columns.Add("TYP");
        DataTable pa60 = this.PA60(context);
        pa60.Columns.Add("start");
        pa60.Columns.Add("end");
        pa60.Columns.Add("time");
        pa60.Columns.Add("app");
        pa60.Columns.Add("audit");
        pa60.Columns.Add("PA604");
        pa60.Columns.Add("CONTEN");
        pa60.Columns.Add("CNname");
        pa60.Columns.Add("PA60038");
        pa60.Columns.Add("PA60040");
        pa60.Columns.Add("PA60042");
                        pa60.Columns.Add("TYP");
        string dept = context.Request["dept"].ToString().Trim();
        string pa604;
        for (int i = 0; i < pa60.Rows.Count; i++)
        {
            pa604 = pa60.Rows[i]["PA60004"].ToString();
            string sql2 = "SELECT TOP 1 PA25008 FROM hrs_mis.dbo.WPA25 WHERE PA25001='" + Enterprise.ConStr + "' AND PA25003 = '" + pa604 + "'";
            SqlConnection corr = new SqlConnection(hrs);//建立名為conn的連結物件
            corr.Open();
            SqlCommand tdiii = new SqlCommand(sql2, corr);
            DataTable doublecheck = new DataTable();
            doublecheck.Load(tdiii.ExecuteReader());
            pa60.Rows[i]["PA604"] = doublecheck.Rows[0][0].ToString();
            tdiii.Cancel();
            corr.Dispose();
            corr.Close();
            pa60.Rows[i]["time"] = Convert.ToDouble(pa60.Rows[i]["PA60011"].ToString()) / 60;
            string start = DateTime.Parse(pa60.Rows[i]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            string end = DateTime.Parse(pa60.Rows[i]["PA60008"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            string app = DateTime.Parse(pa60.Rows[i]["PA60998"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            string[] split1 = start.Split('T');
            string[] split2 = end.Split('T');
            string[] split3 = app.Split('T');
            pa60.Rows[i]["start"] = split1[0];
            pa60.Rows[i]["end"] = split2[0];
            pa60.Rows[i]["app"] = split3[0];
                                pa60.Rows[i]["TYP"] = "HRS";
            string user = context.Request["user"].ToString().Trim();
            string user2;
            string sql;
            if (dept != "")
            {
                if (user != "")
                {
                    sql = "SELECT TOP 1 CNname, CONTEN FROM tbi.dbo.Users u JOIN tbi.dbo.Winton_mf2000 mf ON zfbNO = mf.id /*AND online = '1'*/ WHERE Username = '" + user + "'";
                }
                else
                {
                    if (pa60.Rows[i]["PA60002"].ToString().Length == 4)
                    {
                        user2 = "0" + pa60.Rows[i]["PA60002"].ToString();
                    }
                    else
                    {
                        user2 = pa60.Rows[i]["PA60002"].ToString();
                    }
                    sql = "SELECT TOP 1 Username, CNname, CONTEN FROM tbi.dbo.Users u left JOIN tbi.dbo.Winton_mf2000 mf ON zfbNO = mf.id /*AND online = '1'*/ WHERE Username = '" + user2 + "'";
                }
            }
            else
            {
                if (user != "")
                {
                    sql = "SELECT TOP 1 CNname, CONTEN FROM tbi.dbo.Users u left JOIN tbi.dbo.Winton_mf2000 mf ON zfbNO = mf.id /*AND online = '1'*/ WHERE Username = '" + user + "'";
                }
                else
                {
                    sql = "SELECT TOP 1 CNname, CONTEN FROM tbi.dbo.Users u left JOIN tbi.dbo.Winton_mf2000 mf ON zfbNO = mf.id /*AND online = '1'*/ WHERE Username = '" + context.Session["username"].ToString() + "'";
                }
            }
            SqlConnection cor = new SqlConnection(tbi);//建立名為conn的連結物件
            cor.Open();
            SqlCommand tdii = new SqlCommand(sql, cor);
            DataTable cnname = new DataTable();
            cnname.Load(tdii.ExecuteReader());
            pa60.Rows[i]["CNname"] = cnname.Rows[0]["CNname"].ToString();
            pa60.Rows[i]["CONTEN"] = cnname.Rows[0]["CONTEN"].ToString();
            tdii.Cancel();
            cor.Dispose();
            cor.Close();
        }



        for (int i = 0; i < dt.Rows.Count; i++)
        {
            DataRow row = pa60.NewRow();
            string user = context.Request["user"].ToString().Trim();
            string user2;
            string sql;
            if (dept != "")
            {
                if (user != "")
                {
                    sql = "SELECT TOP 1 CNname, CONTEN FROM tbi.dbo.Users JOIN tbi.dbo.Winton_mf2000 ON Users.zfbNo=Winton_mf2000.id  /*AND online = '1'*/ WHERE Username = '" + user + "'";
                }
                else
                {
                    if (dt.Rows[i]["PA60002"].ToString().Length == 4)
                    {
                        user2 = "0" + dt.Rows[i]["PA60002"].ToString();
                    }
                    else
                    {
                        user2 = dt.Rows[i]["PA60002"].ToString();
                    }
                    sql = "SELECT TOP 1 Username, CNname, CONTEN FROM tbi.dbo.Users JOIN tbi.dbo.Winton_mf2000 ON Users.zfbNo=Winton_mf2000.id  /*AND online = '1'*/ WHERE Username = '" + user2 + "'";
                }
            }
            else
            {
                if (user != "")
                {
                    sql = "SELECT TOP 1 CNname, CONTEN FROM tbi.dbo.Users JOIN tbi.dbo.Winton_mf2000 ON Users.zfbNo=Winton_mf2000.id  /*AND online = '1'*/ WHERE Username = '" + user + "'";
                }
                else
                {
                    sql = "SELECT TOP 1 CNname, CONTEN FROM tbi.dbo.Users JOIN tbi.dbo.Winton_mf2000 ON Users.zfbNo=Winton_mf2000.id  /*AND online = '1'*/ WHERE Username = '" + context.Session["username"].ToString() + "'";
                }
            }
            SqlConnection mycon = new SqlConnection(tbi);//建立名為conn的連結物件
            mycon.Open();
            SqlCommand mycom = new SqlCommand(sql, mycon);
            DataTable cnname = new DataTable();
            cnname.Load(mycom.ExecuteReader());
            row["CNname"] = cnname.Rows[0]["CNname"].ToString();
            row["CONTEN"] = cnname.Rows[0]["CONTEN"].ToString();
            mycom.Cancel();
            mycon.Dispose();
            mycon.Close();
            if (dept != "")
            {
                if (user != "")
                {
                    if (user.StartsWith("0") == true)
                    {
                        user2 = user;
                        user = user.Substring(1);
                    }
                    row["PA60002"] = user;
                }
                else
                {
                    if (cnname.Rows[0]["Username"].ToString().StartsWith("0") == true && cnname.Rows[0]["Username"].ToString().Length == 5)
                    {
                        row["PA60002"] = cnname.Rows[0]["Username"].ToString().Substring(1);
                    }
                    else
                    {
                        row["PA60002"] = cnname.Rows[0]["Username"].ToString();
                    }
                }
            }
            else
            {
                if (user != "")
                {
                    if (user.StartsWith("0") == true)
                    {
                        user2 = user;
                        user = user.Substring(1);
                    }
                    row["PA60002"] = user;
                }
                else
                {
                    row["PA60002"] = username.ToString();
                }
            }
            string sql2 = "SELECT TOP 1 PA25008 FROM hrs_mis.dbo.WPA25 WHERE PA25001='" + Enterprise.ConStr + "' AND PA25003 = '" + dt.Rows[i]["PA60004"].ToString() + "'";
            SqlConnection corr = new SqlConnection(hrs);//建立名為conn的連結物件
            corr.Open();
            SqlCommand tdiii = new SqlCommand(sql2, corr);
            DataTable doublecheck = new DataTable();
            doublecheck.Load(tdiii.ExecuteReader());
            row["PA604"] = doublecheck.Rows[0][0].ToString();
            tdiii.Cancel();
            corr.Dispose();
            corr.Close();
            string start = DateTime.Parse(dt.Rows[i]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            string end = DateTime.Parse(dt.Rows[i]["PA60008"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            string app = DateTime.Parse(dt.Rows[i]["PA60998"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            string[] split1 = start.Split('T');
            string[] split2 = end.Split('T');
            string[] split3 = app.Split('T');
            row["start"] = split1[0];
            row["end"] = split2[0];
            row["app"] = split3[0];
            row["time"] = Convert.ToDouble(dt.Rows[i]["PA60011"].ToString()) / 60;
            row["PA60004"] = dt.Rows[i]["PA60004"].ToString();
            row["PA60016"] = dt.Rows[i]["PA60016"].ToString();
            row["PA60038"] = dt.Rows[i]["PA60038"].ToString();
            row["PA60040"] = dt.Rows[i]["PA60040"].ToString();
            row["PA60996"] = dt.Rows[i]["PA60996"].ToString();
            row["PA60042"] = dt.Rows[i]["PA60042"].ToString();
            row["PA60003"] = dt.Rows[i]["PA60003"].ToString();
                                row["TYP"] = "TBIHRS";
            string b = dt.Rows[i]["PA60039"].ToString();
            if (b == "0")
            {
                row["audit"] = "已通過審核";
            }
            else if (b == "1")
            {
                row["audit"] = "申請成功";
            }
            else if (b == "2")
            {
                row["audit"] = "課長或副理核准";
            }
            else if (b == "3")
            {
                row["audit"] = "最高級主管核准";
            }
            else if (b == "5")
            {
                row["audit"] = "退件";
            }
            pa60.Rows.Add(row);
        }
        DataTable dtCopy = pa60.Copy();
        DataView dv = pa60.DefaultView;
        dv.Sort = "start DESC";
        dtCopy = dv.ToTable();

        //篩選只有自己級別以下才能查看
        DataTable result = Filter_DownUser(context, dtCopy);

        string ReturnString = JsonConvert.SerializeObject(result, Formatting.Indented);
        context.Response.Write(ReturnString);

    }

    public DataTable Filter_DownUser(HttpContext context, DataTable dtCopy)
    {
        //回傳空值
        if (dtCopy.Rows.Count == 0) return new DataTable();

        //確認 session PA51ANDTbiWPAAK 一定要有資料
        if (context.Session["PA51ANDTbiWPAAK"] == null) InitHr_MISPA51ANDTbiWPAAK_(context);
        //搜尋者是"人資部"，資料"全部傳回"，"不用篩選"
        //搜尋者是"稽核部"，資料"全部傳回"，"不用篩選"
        if (this.CONTEN.IndexOf("人力") > -1 || this.CONTEN.IndexOf("稽核") > -1) return dtCopy;


        List<WPA51ANDWPAAK_> list1_WPA51ANDWPAAK_ = (List<WPA51ANDWPAAK_>)context.Session["PA51ANDTbiWPAAK"];




        DataTable result = dtCopy.Rows.Cast<DataRow>().Where(z =>
        {
            var tt = list1_WPA51ANDWPAAK_.First(x => x.PA51002 == z["PA60002"].ToString());

            //搜尋人員權限 超過 資料裡的人員權限 才可搜尋
            //( 此處搜尋權限為比大小 權限越"大" 值越"小" )
            int search_paak200 = int.Parse(this.PAAK200);
            int row_paak200 = int.Parse(tt.PAAK200);

            return search_paak200 <= row_paak200 ? true : false;


        }).CopyToDataTable();

        return result;
    }

    public void Approval(HttpContext context)
    {
        DataTable dt = this.DataTable5(context);
        dt.Columns.Add("start");
        dt.Columns.Add("end");
        dt.Columns.Add("time");
        dt.Columns.Add("app");
        dt.Columns.Add("PA604");
        string pa604;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            pa604 = dt.Rows[i]["PA60004"].ToString();
            string sql2 = "SELECT TOP 1 PA25008 FROM hrs_mis.dbo.WPA25 WHERE PA25001='" + Enterprise.ConStr + "' AND PA25003 = '" + pa604 + "'";
            SqlConnection corr = new SqlConnection(hrs);//建立名為conn的連結物件
            corr.Open();
            SqlCommand tdiii = new SqlCommand(sql2, corr);
            DataTable doublecheck = new DataTable();
            doublecheck.Load(tdiii.ExecuteReader());
            dt.Rows[i]["PA604"] = doublecheck.Rows[0][0].ToString();
            dt.Rows[i]["time"] = Convert.ToDouble(dt.Rows[i]["PA60011"].ToString()) / 60;
            string start = DateTime.Parse(dt.Rows[i]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            string end = DateTime.Parse(dt.Rows[i]["PA60008"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            string app = DateTime.Parse(dt.Rows[i]["PA60998"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            string[] split1 = start.Split('T');
            string[] split2 = end.Split('T');
            string[] split3 = app.Split('T');
            dt.Rows[i]["start"] = split1[0];
            dt.Rows[i]["end"] = split2[0];
            dt.Rows[i]["app"] = split3[0];
            tdiii.Cancel();
            corr.Dispose();
            corr.Close();
        }
        string ReturnString = JsonConvert.SerializeObject(dt, Formatting.Indented);
        context.Response.Write(ReturnString);
    }

}