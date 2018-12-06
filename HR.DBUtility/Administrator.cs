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
    public class Administrator
    {

        public static DataTable GetValue(HttpContext context, Identity identity)
        {
            
            if (context.Session["UserName"] == null)
                return null;

            string Username = context.Session["UserName"].ToString();
            string username2 = Username.Equals("A02") ? "A02" : Username.TrimStart('0').PadLeft(4, '0');
            string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;

            DataTable dt = new DataTable();

            //開始篩選 分兩次篩選 
            //第一次用 SQL 方式篩選 
            //第二次用 C# 方式篩選


            //第一次篩選(SQL 方式)
            string sql = @"Declare 
                           @x nvarchar(50)
                           select @x='"+Username+ @"' 
                           
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
                    var PAAK200 = int.Parse(i["PAAK200"].ToString());
                    bool IsApplyer = false;
                    string u_ = i["Username"].ToString();


                    //判斷只要不是主管(課長、副理、經理)的人，都會以一般人員的身分去跑審核權限歸屬表 ex:01134 掛課長 
                    //可是課長不是他 在主管也沒有他 他就必須跟一般員工請假一樣跑一般流程

                    //既不是 (課長) 也不是 (副理)  也不是 (經理) 跑一般審核流程
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
        public static bool CheckApplyer(DataRow i,HttpContext context)
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
            string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;
            string Username = context.Session["UserName"].ToString();
            string username2 = Username.Equals("A02") ? "A02" : Username.TrimStart('0').PadLeft(4, '0');


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
            if (temp.SUSERID == Username)
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
            else if (temp.DUSERID == Username)
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
            else if (temp.MUSERID == Username)
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
            else if (temp.GUSERID == Username)
            {
                //沒有課長、副理、經理 的狀況下 總經理可以看到 1、2、3、4
                if (  string.IsNullOrEmpty(temp.SUSERID) && string.IsNullOrEmpty(temp.DUSERID) && string.IsNullOrEmpty(temp.MUSERID) )
                {
                    if (new[] { 1, 2, 3,4 }.Contains(int.Parse(i["PA60039"].ToString())))
                        return true;
                    else
                        return false;
                }

                //沒有副理、經理 的狀況下 總經理可以看到 2、3、4
                if ( string.IsNullOrEmpty(temp.DUSERID) && string.IsNullOrEmpty(temp.MUSERID))
                {
                    if (new[] {  2, 3, 4 }.Contains(int.Parse(i["PA60039"].ToString())))
                        return true;
                    else
                        return false;
                }

                //沒有經理 的狀況下 總經理可以看到 3、4
                if ( string.IsNullOrEmpty(temp.MUSERID))
                {
                    if (new[] {  3, 4 }.Contains(int.Parse(i["PA60039"].ToString())))
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



        //當前資料為 課長階級 篩選方法
        public static bool CheckApplyer2(DataRow i,HttpContext context)
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
            string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;
            string Username = context.Session["UserName"].ToString();
            string username2 = Username.Equals("A02") ? "A02" : Username.TrimStart('0').PadLeft(4, '0');

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
            if (temp.DUSERID == Username)
            {

                if (new[] { 1, 2, 3 }.Contains(int.Parse(i["PA60039"].ToString())))
                    return true;
                else
                    return false;
            }

            //經理
            if (temp.MUSERID == Username)
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
    }
}
