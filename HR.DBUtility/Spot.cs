using HR.DBUtility.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace HR.DBUtility
{
    public class Spot
    {
        public static DataTable GetValue(HttpContext context, Identity identity)
        {

            if (context.Session["UserName"] == null)
                return null;

            string username2 = context.Session["UserName"].ToString();
            string username = username2.Equals("A02") ? "A02" : username2.TrimStart('0').PadLeft(4, '0');
            string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;


            DataTable dt = new DataTable();

            //開始篩選 分兩次篩選 
            //第一次用 SQL 方式篩選 
            //第二次用 C# 方式篩選

            //第一次篩選(SQL 方式)
            string sql = @"Declare 
                         @x nvarchar(50)
                         select @x='"+username2+ @"' 
                         
                         select u.Username,[TBI_HRS].dbo.[GETPOSITION](PA60002,PA60048,XSing.ProgNo,STN_WORK) as Postion_,pa123.PA60048,pa123.PA60039,pa123.PA60002, u.CNname, pa123.PA60004, pa123.PA60007, pa123.PA60008, pa123.PA60016, pa123.PA60038,pa123.PA60011, pa123.PA60003, pa123.PA60039,pa123.PA600390, pa123.PA60040, pa123.PA60044,XSing.*,wpaak.PAAK200 
                         from (select * from TBI_HRS.dbo.PA123 where PA60039=0 or PA60039=1 or PA60039=2 or PA60039=3 or PA60039=4 or PA60039=5 ) pa123                    
                         join  tbi.dbo.Users u on                      (                    RIGHT(REPLICATE('0', 8) + CAST(pa123.PA60002 as NVARCHAR), 3)= u.Username or                    RIGHT(REPLICATE('0', 8) + CAST(pa123.PA60002 as NVARCHAR), 5)= u.Username or                    RIGHT(REPLICATE('0', 8) + CAST(pa123.PA60002 as NVARCHAR), 6)= u.Username                    )                    
                         join tbi.dbo.Winton_mf2000 w_mf2000 on u.zfbNO=w_mf2000.id                     
                         join tbi.dbo.XSingOrd XSing on                     
                         (                    
                             w_mf2000.mf200=XSing.STN_WORK  
                             and 
                             (CASE
                         	    WHEN PA123.PA60048 is not null
                         		    THEN PA123.PA60048
                         	    ELSE u.a2
                             END)=XSing.ProgNo
                         )
                         join [tbi].[dbo].[WPAAK] wpaak on u.q1=wpaak.PAAK002                
                         where
                         (CASE 
                         	WHEN [TBI_HRS].dbo.[GETPOSITION](PA60002,PA60048,XSing.ProgNo,STN_WORK)='GeneralUSERID' or [TBI_HRS].dbo.[GETPOSITION](PA60002,PA60048,XSing.ProgNo,STN_WORK)='LUSERID'  /*課長以下*/
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
                         			  WHEN LUSERID = @x 
                                              THEN (CASE 
                         								WHEN  PA600390 is null /* 現場- 組長尚未簽過 */
                         								THEN 'T'
                         							END)
                         	
                         		END)
                         	WHEN [TBI_HRS].dbo.[GETPOSITION](PA60002,PA60048,XSing.ProgNo,STN_WORK)='SUSERID'  /*課長階級*/
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
                         	WHEN [TBI_HRS].dbo.[GETPOSITION](PA60002,PA60048,XSing.ProgNo,STN_WORK)='DUSERID' or [TBI_HRS].dbo.[GETPOSITION](PA60002,PA60048,XSing.ProgNo,STN_WORK)='MUSERID' /*副理經理階級*/
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
            using (SqlConnection conn = new SqlConnection(tbi))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.Fill(ds);
            }


            if (ds.Tables.Count > 0)
            {
                //第二次篩選(C# 方式)
                foreach (DataRow i in ds.Tables[0].Rows.Cast<DataRow>().ToList())
                {
                    //第一次篩選 - 審核權限表

                    var PAAK200 = int.Parse(i["PAAK200"].ToString());
                    bool IsApplyer = false;
                    string u_ = i["Username"].ToString();

                    //當前資料為 課長階級以下 篩選方法
                    if (i["SUSERID"].ToString() != u_ &&
                       i["DUSERID"].ToString() != u_ &&
                       i["MUSERID"].ToString() != u_)
                    {
                        IsApplyer = CheckApplyer(i, context);
                    }
                    //當前資料為 課長階級 篩選方法
                    if (i["SUSERID"].ToString() == u_)
                    {
                        IsApplyer = CheckApplyer2(i, context);
                    }
                    //當前資料為 經理、副理階級 篩選方法
                    //建立一個特別的規則 專門給徐經理使用 當他審核李其申副理時
                    //等文中籍職更改後即可刪除此段
                    if (i["DUSERID"].ToString() == u_ || i["MUSERID"].ToString() == u_)
                    {
                        IsApplyer = true;
                    }

                    //是否為審核者，若不是審核者即將當筆資料剔除
                    if (IsApplyer == false)
                    {
                        ds.Tables[0].Rows.Remove(i);

                        continue;

                    }


                    //第二次篩選 - 行政&現場  篩選掉

                    //行政
                    if (identity == Identity.Administrator)
                    {
                        //刪除現場人員
                        if (Common.JudgeIsSpot(u_) == Identity.Spot)
                        {
                            ds.Tables[0].Rows.Remove(i);
                            continue;
                        }
                    }
                    //現場
                    else
                    {
                        //刪除行政人員
                        if (Common.JudgeIsSpot(u_) == Identity.Administrator)
                        {
                            ds.Tables[0].Rows.Remove(i);
                            continue;
                        }
                    }
                }
            }

            return ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable();
        }

        //當前資料為 課長階級以下 篩選方法
        public static bool CheckApplyer(DataRow i, HttpContext context)
        {
            if (context.Session["UserName"] == null)
                return false;

            string username2 = context.Session["UserName"].ToString();
            string username = username2.Equals("A02") ? "A02" : username2.TrimStart('0').PadLeft(4, '0');
            string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;
            string PAAK200 = GetPAAK(username2);

            string ProgNo = "";

            if (!string.IsNullOrEmpty(i["PA60048"].ToString()))
                ProgNo = i["PA60048"].ToString();
            else
                ProgNo = i["ProgNo"].ToString();


            //取得目前使用者的所屬權限表
            var temp = Get_XSingOrd(i["STN_WORK"].ToString(), ProgNo);


            //組長是否審核 true=審核通過、或沒有組長 false=沒有審核過 
            bool CheckLuserID = false;

            //沒有組長直接通過
            if (string.IsNullOrEmpty(temp.LUSERID))
            {
                CheckLuserID = true;
            }
            //有組長需判斷 PA600390是否有寫入
            else
            {

                if (i["PA600390"].ToString() == "5")
                {
                    CheckLuserID = true;
                }
                else
                {
                    CheckLuserID = false;
                }
            }
            //登入者是否權限大於組長 或同級組長
            if (temp.LUSERID == i["PA60002"].ToString().TrimStart('0').PadLeft(5, '0'))
            {
                CheckLuserID = true;
            }


            //組長申請人是當前使用者
            //審核狀態是 1 (課長只能審核 1)
            if (temp.LUSERID == username2)
            {
                if (!string.IsNullOrEmpty(temp.LUSERID))
                {
                    //審核狀態一定要是 1 (課長尚未審核)
                    //組長是否審核一定要是 null (組長尚未簽核 )，現場規則
                    if (new[] { 1 }.Contains(int.Parse(i["PA60039"].ToString())) && CheckLuserID == false)
                        return true;
                    else
                        return false;
                }
                else
                {
                    return false;
                }


            }
            else if (temp.SUSERID == username2)
            {
                if (!string.IsNullOrEmpty(temp.SUSERID))
                {
                    if (new[] { 1 }.Contains(int.Parse(i["PA60039"].ToString())) && CheckLuserID == true)
                        return true;
                    else
                        return false;
                }
                else
                {
                    return false;
                }


            }
            else if (temp.DUSERID == username2)
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
                    if (new[] { 1, 2 }.Contains(int.Parse(i["PA60039"].ToString())) && CheckLuserID == true)
                        return true;
                    else
                        return false;
                }
            }
            else if (temp.MUSERID == username2)
            {

                //沒有副理 && 沒有課長 的狀況下 經理 可以看到 狀態 1、2、3
                if (string.IsNullOrEmpty(temp.DUSERID) && string.IsNullOrEmpty(temp.SUSERID))
                {
                    if (new[] { 1, 2, 3 }.Contains(int.Parse(i["PA60039"].ToString())) && CheckLuserID == true)
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

                //有副理 && 沒有課長(或有課長)(不須判斷是否有課長) 的狀況下 經理 可以看到 狀態 3
                //副理 可以將狀態 1、2 變成 3
                if (!string.IsNullOrEmpty(temp.DUSERID))
                {
                    if (new[] { 3 }.Contains(int.Parse(i["PA60039"].ToString())))
                        return true;
                    else
                        return false;
                }

                return false;
            }
            else if (temp.GUSERID == username2)
            {
                //沒有課長、副理、經理 的狀況下 總經理可以看到 1、2、3、4
                if (string.IsNullOrEmpty(temp.SUSERID) && string.IsNullOrEmpty(temp.DUSERID) && string.IsNullOrEmpty(temp.MUSERID))
                {
                    if (new[] { 1, 2, 3, 4 }.Contains(int.Parse(i["PA60039"].ToString())))
                        return true;
                    else
                        return false;
                }

                //沒有副理、經理 的狀況下 總經理可以看到 2、3、4
                if (string.IsNullOrEmpty(temp.DUSERID) && string.IsNullOrEmpty(temp.MUSERID))
                {
                    if (new[] { 2, 3, 4 }.Contains(int.Parse(i["PA60039"].ToString())))
                        return true;
                    else
                        return false;
                }

                //沒有經理 的狀況下 總經理可以看到 3、4
                if (string.IsNullOrEmpty(temp.MUSERID))
                {
                    if (new[] { 3, 4 }.Contains(int.Parse(i["PA60039"].ToString())))
                        return true;
                    else
                        return false;
                }

                //有經理 的狀況下 總經理可以看到 4
                if (!string.IsNullOrEmpty(temp.MUSERID))
                {
                    if (new[] { 4 }.Contains(int.Parse(i["PA60039"].ToString())))
                        return true;
                    else
                        return false;
                }

                //其他都不行

                return false;
            }
            else
            {
                return false;
            }

        }
        /// <summary>
        /// 取得當前使用者的 PAAK200 (權限)
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public static string GetPAAK(string username)
        {
            string PAAK200 = BOSSQL.ExecuteQuery("select * from users join WPAAK on q1 = PAAK002 where username = '" + username + "'").Rows[0]["PAAK200"].ToString();
            return PAAK200;
        }

        //當前資料為 課長階級 篩選方法
        public static bool CheckApplyer2(DataRow i, HttpContext context)
        {
            if (context.Session["UserName"] == null)
                return false;

            string username2 = context.Session["UserName"].ToString();
            string username = username2.Equals("A02") ? "A02" : username2.TrimStart('0').PadLeft(4, '0');
            string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;

            string ProgNo = "";

            if (!string.IsNullOrEmpty(i["PA60048"].ToString()))
                ProgNo = i["PA60048"].ToString();
            else
                ProgNo = i["ProgNo"].ToString();


            //取得目前使用者的所屬權限表
            var temp = Get_XSingOrd(i["STN_WORK"].ToString(), ProgNo);

            //經理
            if (temp.MUSERID == username2)
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

        public static XSingOrd Get_XSingOrd(string STN_WORK, string ProgNo)
        {
            string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;

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
                       where STN_WORK='" + STN_WORK + "' AND ProgNo='" + ProgNo + "'".Replace("\r\n", "").Replace("\t", "");



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

            return temp;
        }
        /// <summary>
        /// 個人主檔裡面，是否為有班表人員
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public static bool IsSchedulePerson(string username)
        {

            StringBuilder sb = new StringBuilder();
            sb.Append("/*PA51019 0=非排班、1=排班*/ ");
            sb.Append("select PA51001, PA51002, PA51004, PA51019 from hrs_mis.dbo.WPA51 ");
            sb.Append("where PA51001 = '"+Enterprise.ConStr_produceline+"' ");
            sb.Append("and PA51002 = '"+username+"' ");

            DataTable dt= BOSSQL.hrsExecuteQuery(sb.ToString());

            if (dt.Rows.Count>0)
            {
                if (dt.Rows[0]["PA51019"].ToString() == "1")
                    return true;//有班表人員
                else
                    return false;//無班表人員
            }

            return false;
            
        }
    }
}
