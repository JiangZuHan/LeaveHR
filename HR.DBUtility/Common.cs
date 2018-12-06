using HR.DBUtility.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace HR.DBUtility
{
    public class Common
    {
        static string tbi = ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString;

        static string hrs = ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString;

        static string tbiHRS = ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString;

        /// <summary>
        /// 是否有審核頁面
        /// </summary>
        /// <param name="Username"></param>
        /// <returns></returns>
        public static bool CanCheck(string Username)
        {
            string sql = "";

            //判斷是否為現場組別理面
            Identity current_identity = Common.JudgeIsSpot(Username);

            if (current_identity == Identity.Administrator)
            {
                sql = string.Format(@"select top 1 1
from
( 
/* 課長 */
SELECT [SUSERID] as 'Username'
FROM [tbi].[dbo].[XSingOrd]
where ProgramName='WPA60'
union 
/* 副理 */
SELECT [DUSERID] as 'Username'
FROM [tbi].[dbo].[XSingOrd]
where ProgramName='WPA60'
union
/* 經理 */
SELECT [MUSERID] as 'Username'
FROM [tbi].[dbo].[XSingOrd]
where ProgramName='WPA60'
union
/* 總經理 */
SELECT [GUSERID] as 'Username'
FROM [tbi].[dbo].[XSingOrd]
where ProgramName='WPA60'
) TT
where Username ='" + Username + "'");
            }
            else if (current_identity == Identity.Spot)
            {
                sql = string.Format(@"select top 1 1
from
( 
/* 組長 */
SELECT [LUSERID] as 'Username'
FROM [tbi].[dbo].[XSingOrd]
where ProgramName='WPA60'
union 
/* 課長 */
SELECT [SUSERID] as 'Username'
FROM [tbi].[dbo].[XSingOrd]
where ProgramName='WPA60'
union 
/* 副理 */
SELECT [DUSERID] as 'Username'
FROM [tbi].[dbo].[XSingOrd]
where ProgramName='WPA60'
union
/* 經理 */
SELECT [MUSERID] as 'Username'
FROM [tbi].[dbo].[XSingOrd]
where ProgramName='WPA60'
union
/* 總經理 */
SELECT [GUSERID] as 'Username'
FROM [tbi].[dbo].[XSingOrd]
where ProgramName='WPA60'
) TT
where Username ='" + Username + "'");
            }


            return BOSSQL.ExecuteQuery(sql).Rows.Count > 0;

        }

        //public static dynamic GetVacation()
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

        //public static dynamic GetWorkHoliday()
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

        private static T Cast<T>(T typeHolder, Object x)
        {
            // typeHolder above is just for compiler magic
            // to infer the type to cast x to
            return (T)x;
        }



        public static DateTime GetWorkDay(DateTime start)
        {
            DateTime Result = new DateTime();

            var Vacation_ = GetVacation();

            var WorkHoliday_ = GetWorkHoliday();

            bool condition1 = false;
            bool condition2_Vacation_ = false;
            bool condition3_WorkHoliday_ = false;

            Result = start;

            do
            {
                bool tag_condit1_condit2 = false;
                bool tag_condit3 = false;

                condition1 = (Result.DayOfWeek == DayOfWeek.Saturday || Result.DayOfWeek == DayOfWeek.Sunday);

                condition2_Vacation_ = Vacation_.Any<Vaction>(z => z.BS73002 == Result.ToString("yyyy/MM/dd"));

                condition3_WorkHoliday_ = WorkHoliday_.Any<Vaction>(z => z.BS73002 == Result.ToString("yyyy/MM/dd"));

                //不是 六、日
                if (condition1 == false)
                {
                    //然後 六、日 當中也不可以是補上班日
                    if (condition3_WorkHoliday_ == false)
                    {
                        tag_condit1_condit2 = true;
                    }
                }

                //一 ~ 五 當中不可以是國定假日
                if (condition2_Vacation_ == false)
                {
                    tag_condit3 = true;
                }

                //判斷剛剛上面兩個條件都必須等於 true 才可以跳出去
                if (tag_condit1_condit2 == true && tag_condit3 == true)
                {
                    break;
                }

                Result = Result.AddDays(1);

            } while (true);

            return Result;
        }

        /// <summary>
        /// 取得現場或行政人員，依據類型
        /// </summary>
        public static List<string> GetSpecifyTypePerson(List<string> username_list, Enterprise type_)
        {
            return new List<string>();
        }

        /// <summary>
        /// 判斷使用者是否為現場或是行政
        /// </summary>
        public static Identity JudgeIsSpot(string username)
        {


            string sql = "select 1 status_ from TBI_HRS.dbo.GroupSpotList where hrs=(select a1 from tbi.dbo.Users where username=@username)";

            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(tbiHRS))
            {
                using (SqlCommand comm = new SqlCommand(sql, conn))
                {

                    using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
                    {
                        comm.Parameters.AddWithValue("@username", username);

                        conn.Open();

                        adapter.Fill(dt);

                    }
                }
            }


            if (dt.Rows.Count > 0)
            {
                return Identity.Spot;
            }
            else
            {
                return Identity.Administrator;
            }

        }

        /// <summary>
        /// 判斷使用者可審核的部門是否為現場或是行政
        /// </summary>
        public static bool HasAuditSpotDepartment(string username)
        {


            string sql = string.Format(@"DECLARE @x nvarchar(50) = @username
                            
                            /* 暫存從聯合的部門代號和文中部門代號對照表 */
                            DECLARE @TmpTable TABLE(
                            hr varchar(20)
                            )
                            
                            Insert into @TmpTable
                            select hrs from tbi.dbo.Winton_mf2000 where mf200 in (select distinct STN_WORK from tbi.dbo.XSingOrd
                            where ProgramName = 'WPA60'
                            AND(LUSERID = @x
                            OR SUSERID = @x
                            OR DUSERID = @x
                            OR MUSERID = @x
                            OR GUSERID = @x)
                            )  
                            
                            
                            /* 比對當前使用者可以審核的所有部門裡面有沒現場部門 */
                            select top 1 1 _status from TBI_HRS.dbo.GroupSpotList where exists(select top 1 1 from @TmpTable where hr = GroupSpotList.hrs)").Replace("\r\n", "").Replace("\t", "");

            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(tbiHRS))
            {
                using (SqlCommand comm = new SqlCommand(sql, conn))
                {

                    using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
                    {
                        comm.Parameters.AddWithValue("@username", username);

                        conn.Open();

                        adapter.Fill(dt);

                    }
                }
            }

            if (dt.Rows.Count > 0)
            {
                //審核部門裡面有現場組別
                return true;
            }
            else
            {
                //審核部門裡面沒有現場組別
                return false;
            }
        }

        /// <summary>
        /// 確認是否是人資部門可使用人資權限使用者
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public static bool CheckIsSupervisor(string username)
        {
            StringBuilder sb = new StringBuilder();

            sb.Append("SELECT [ID],[UserName],[CNname],[Status]  FROM[TBI_HRS].[dbo].[Supervisor] where UserName='" + username + "'");

            return BOSSQL.TBIHRSExecuteQuery(sb.ToString()).Rows.Count > 0;

        }
        /// <summary>
        /// 判段此使用者 在 審核權限表 上面的身份
        /// </summary>
        /// <param name="user"></param>
        /// <param name="Current_XSingOrd"></param>
        /// <returns></returns>
        public static Position JudgePosition(string user, XSingOrd Current_XSingOrd)
        {
            Position postion_ = Position.GENERAL;

            //判斷審核位階(此會判斷是否為最高部門主管)
            //組長
            if (Current_XSingOrd.LUSERID.TrimStart('0') == user.TrimStart('0'))
            {
                postion_ = Position.LUSER;
            }
            //課長
            else if (Current_XSingOrd.SUSERID.TrimStart('0') == user.TrimStart('0'))
            {
                postion_ = Position.SUSER;
            }
            //副理
            else if (Current_XSingOrd.DUSERID.TrimStart('0') == user.TrimStart('0'))
            {

                //副理為最高部門主管，審核權限更為經理
                if (string.IsNullOrEmpty(Current_XSingOrd.MUSERID))
                {
                    postion_ = Position.MUSER;
                }
                //副理非最高部門主管
                else
                {
                    postion_ = Position.DUSER;
                }
            }
            //經理
            else if (Current_XSingOrd.MUSERID.TrimStart('0') == user.TrimStart('0'))
            {
                postion_ = Position.MUSER;
            }
            //總經理
            else if (Current_XSingOrd.GUSERID.TrimStart('0') == user.TrimStart('0'))
            {
                postion_ = Position.GUSER;
            }
            //一般員工
            //全部職位都不是，就歸為一般員工
            else
            {
                postion_ = Position.GENERAL;
            }

            return postion_;
        }

        /// <summary>
        /// 取得審核權限表
        /// </summary>
        /// <param name="STN_WORK"></param>
        /// <param name="ProgNo"></param>
        /// <returns></returns>
        public static XSingOrd Get_XSingOrd(string STN_WORK, string ProgNo)
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
        /// 取得所有最高階主管的工號 (依據審核權限表)
        /// </summary>
        /// <returns></returns>
        public static List<string> GetAllMUser()
        {
            string sql =
@"select distinct
(CASE

    WHEN MUSERID = ''

        THEN DUSERID

    ELSE MUSERID
END)
as MUSERID
  FROM tbi.dbo.XSingOrd
  where DUSERID != ''
  or MUSERID!= ''";


            DataTable dt = BOSSQL.ExecuteQuery(sql);

            return dt.Rows.Cast<DataRow>().Select(z => z["MUSERID"].ToString()).ToList();

        }



        /// <summary>
        /// 寄 MAIL
        /// </summary>
        /// <param name="TO_list_"></param>
        /// <param name="subject"></param>
        /// <param name="body"></param>
        public static void SendMail(Dictionary<string, string> TO_list_, string subject, string body)
        {

            foreach (var i in TO_list_.Keys.ToList())
            {
                TO_list_[i] = "kenwhz@tbimotion.com.tw";
            }


            Task.Factory.StartNew(() =>
            {

                SmtpClient smtp = new SmtpClient();
                MailMessage msg = new MailMessage();

            smtp.Credentials = new System.Net.NetworkCredential("admin@tbimotion.com.tw", "jens00819");//寄信帳密
                msg.From = new MailAddress("admin@tbimotion.com.tw", "系統發送");

                foreach (var i in TO_list_)
                {
                    msg.To.Add(new MailAddress(i.Value, i.Key));
                }

                msg.Subject = subject;

                msg.Body = body;

                msg.Body += "\n\n此為系統自動發送，請勿直接回覆";

                //if (this.IsDebug != true) 
                smtp.SendAsync(msg, "Send Mail");


            });

        }

        /// <summary>
        /// 取得非最高級主管以外的課級 / 組長 (有權限查詢員工出勤狀況者)
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public static bool Get_IsLeaderOrChief(string username)
        {
            string SQL;

            SQL = @"select distinct * from 
(
select distinct LUSERID from XSingOrd where ProgramName = 'WPA60' and LUSERID != ''
union
select distinct suserid from XSingOrd where ProgramName = 'WPA60' and SUSERID != ''
union
select distinct duserid from XSingOrd where ProgramName = 'WPA60' and DUSERID != '' and MUSERID != ''
) as temp where LUSERID = '" + username + "'";

            return BOSSQL.ExecuteQuery(SQL).Rows.Count > 0;

        }


        /// <summary>
        /// 依照 流水號 取得目前此假單相關資訊
        /// </summary>
        /// <param name="water"></param>
        /// <param name="applyUser"></param>
        /// <returns></returns>
        public static LeaveApplicationForm Get_LeaveApplicationForm(string water, string applyUser, string CODE)
        {
            string sql = string.Format(@"Declare @username nvarchar(30)='" + applyUser + @"'

                                     DECLARe @CNname nvarchar(30)=(select CNname from tbi.dbo.Users where SUBSTRING(Username,PATINDEX('%[^0]%',Username),LEN(Username))=SUBSTRING(@username,PATINDEX('%[^0]%',@username),LEN(@username)) )

                                     SELECT pa60001 ,PA60002,@CNname CNname,PA60003,PA60004,PA60007,PA60008,PA60011,PA60016,PA60038,PA600390,PA60039,PA60048
                                     FROM [TBI_HRS].[dbo].[PA123]
                                     where TBI_HRS.dbo.CompareUsername(PA60002,@username)=1
                                     AND PA60003=" + water).Replace("\r\n", "").Replace("\t", "");

            DataTable dt = BOSSQL.TBIHRSExecuteQuery(sql);


            sql = string.Format(@"select PA25003,PA25008 from hrs_mis.dbo.WPA25
                              where pa25001='" + CODE + @"'
                              AND pa25002 ='001'").Replace("\r\n", "").Replace("\t", "");

            DataTable dt2 = BOSSQL.hrsExecuteQuery(sql);

            var holiday_ = (from f1 in dt.AsEnumerable()
                            join f2 in dt2.AsEnumerable()
                            on f1.Field<int>("PA60004") equals f2.Field<int>("PA25003")
                            select new
                            {
                                holiday_type_code = f2.Field<int>("PA25003"),
                                holiday_type_name = f2.Field<string>("PA25008")
                            }).FirstOrDefault();


            LeaveApplicationForm temp = new LeaveApplicationForm();

            temp.pa60001 = Convert.ToString(dt.Rows[0]["pa60001"]);
            temp.username = Convert.ToString(dt.Rows[0]["PA60002"]);
            temp.CNname = Convert.ToString(dt.Rows[0]["CNname"]);
            temp.water = Convert.ToString(dt.Rows[0]["PA60003"]);
            temp.holiday_type_code = Convert.ToString(dt.Rows[0]["PA60004"]);
            temp.holiday_type_name = holiday_.holiday_type_name;
            temp.start_ = Convert.ToString(dt.Rows[0]["PA60007"]);
            temp.end_ = Convert.ToString(dt.Rows[0]["PA60008"]);
            temp.Total_min = Convert.ToInt32(dt.Rows[0]["PA60011"]);
            temp.Cause = Convert.ToString(dt.Rows[0]["PA60016"]);
            temp.agent = Convert.ToString(dt.Rows[0]["PA60038"]);
            temp.status = Convert.ToInt32(dt.Rows[0]["PA60039"]);
            temp.status_luser = dt.Rows[0]["PA600390"] == DBNull.Value ? default(int?) : int.Parse(dt.Rows[0]["PA600390"].ToString());
            temp.lProgNo = dt.Rows[0]["PA60048"] == DBNull.Value ? default(string) : dt.Rows[0]["PA60048"].ToString();


            return temp;

        }

        /// <summary>
        /// 查看是否有歸屬
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public static bool CheckProgNo(HttpContext context)
        {
            string username = context.Session["username"].ToString();


            string sql = @"SELECT top 1 1 result_ /* 1= 有設定歸屬 空=無設定歸屬 */
  FROM[tbi].[dbo].[Users]
  join tbi.dbo.XSingOrd on Users.a2 = XSingOrd.ProgNo
  where Username = '" + username + "'";


            // >=1 有歸屬，<1 沒有歸屬
            bool result = BOSSQL.ExecuteQuery(sql).Rows.Count > 0;

            return result;


        }

        /// <summary>
        /// 取得此人的歸屬表
        /// </summary>
        /// <param name="applyUser"></param>
        /// <param name="ProgNo"></param>
        /// <returns></returns>
        public static XSingOrd Get_yespassModel(string applyUser, string ProgNo = null)
        {
            //依照目前登入者取得 部門(mf200) 歸屬(a2)
            string sql = string.Format(@"select u.Username,u.CNname,w_mf2000.mf200,u.a2
                                   from  tbi.dbo.Users u        
                                   join tbi.dbo.Winton_mf2000 w_mf2000 on u.a1=w_mf2000.hrs    
                                   where TBI_HRS.dbo.CompareUsername(Username,'" + applyUser + "')=1").Replace("\r\n", "").Replace("\t", "");

            DataTable dt = BOSSQL.ExecuteQuery(sql);

            string ProgNo_end = "";

            if (ProgNo == null)
                ProgNo_end = dt.Rows[0]["a2"].ToString();
            else
                ProgNo_end = ProgNo;


            var temp = new { mf200 = dt.Rows[0]["mf200"].ToString(), a2 = ProgNo_end };

            return Common.Get_XSingOrd(temp.mf200, temp.a2);
        }
        public static void ReplyDeleteData(LeaveApplicationForm temp)
        {
            switch (temp.holiday_type_code)
            {
                case "8"://喪假
                    {
                        SET_8(temp);
                        break;
                    }
                case "9"://特休
                    {
                        break;
                    }
                case "10"://補休

                    {
                        break;
                    }
            }
        }
        /// <summary>
        /// 復原扣除喪假的相關邏輯
        /// </summary>
        /// <param name="temp"></param>
        private static void SET_8(LeaveApplicationForm temp)
        {
            if (temp.username == null || temp.HRS08_TYPE == null || temp.HRS08_ID == null)
            {
                return;
            }

            string sql = string.Format(@"DECLARE @username nvarchar(50)=N'" + temp.username + @"'
DECLARE @type int= " + temp.HRS08_TYPE + @"
DECLARE @ID int= " + temp.HRS08_ID + @"

/*要補回的時間*/
DECLARE @a int= 960
/*原先剩餘時間*/
DECLARE @b int= (select timeleft from TBI_HRS.dbo.HRS08 where username = @username AND[type] = @type AND ID = @ID)

update TBI_HRS.dbo.HRS08 set timeleft = @a + @b where username = @username AND[type] = @type AND ID = @ID");

            BOSSQL.TBIHRSExecuteNonQuery(sql);


        }

        /// <summary>
        /// 取得補班時段
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public static IEnumerable<Vaction> GetWorkHoliday()
        {
            //------------------例假日需補班時段-----------------
            //sql_wbs73 [例假日需補班時段 sql 指令] - 底下有說明
            //dt_wbs73 [例假日需補班時段 table ] - 取得資料
            //data [只取得例假日需補班時段 table 需要的欄位] - 只抓取 時間 BS73002 (轉成 yyyy/MM/dd 格式) 和 BS73003 介紹欄位資料


            string sql_wbs73 = @"/* BS73001 = 稅制規則,BS73001 = 區分,BS73001 = 行事曆別
	                                補上班依據觀察 BS73001=0 , BS73004=2 , BS73005=8
	                                就會是要補上班的日子*/
                                    select * from [hrs_mis].[dbo].WBS73
                                    where BS73002 
                                    between DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0) and DATEADD(yy,DATEDIFF(yy,-1,GETDATE()),-1)
                                    and BS73001=0 
                                    and BS73004=2 
                                    and BS73005=8 
                                    order by BS73002";
            sql_wbs73 = sql_wbs73.Replace("\r\n", "").Replace("\t", "");

            DataTable dt_wbs73 = new DataTable();

            using (SqlConnection conn = new SqlConnection(hrs))
            {
                using (SqlCommand comm = new SqlCommand(sql_wbs73, conn))
                {
                    using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
                    {
                        conn.Open();
                        adapter.Fill(dt_wbs73);
                    }
                }
            }


            var data = dt_wbs73.Rows.Cast<DataRow>().Select(z =>
            {
                string temp_date = DateTime.Parse(z["BS73002"].ToString()).ToString("yyyy/MM/dd");
                string temp_val = z["BS73003"].ToString();
                var temp = new Vaction { BS73002 = temp_date, BS73003 = temp_val };
                return temp;
            });

            return data;
        }

        /// <summary>
        /// 國定假日
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public static IEnumerable<Vaction> GetVacation()
        {
            //------------------國定假日時段-----------------
            //sql_wbs73 [國定假日時段 sql 指令] - 底下有說明
            //dt_wbs73 [國定假日時段 table ] - 取得資料
            //data [只取得國定假日時段 table 需要的欄位] - 只抓取 時間 BS73002 (轉成 yyyy/MM/dd 格式) 和 BS73003 介紹欄位資料


            string sql_wbs73 = @"/* BS73001 = 稅制規則,BS73001 = 區分,BS73001 = 行事曆別
	                                補國定假日依據觀察 BS73001=0 , BS73004=0 or 1 , BS73005=7 or 9
	                                就會是要補上班的日子*/
                                    select * from [hrs_mis].[dbo].WBS73
                                    where BS73002 
                                    between DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0) and DATEADD(yy,DATEDIFF(yy,-1,GETDATE()),-1)
                                    and BS73001=0 
                                    and BS73004 in (0,1)
                                    and BS73005 in (7,9)
                                    order by BS73002";
            sql_wbs73 = sql_wbs73.Replace("\r\n", "").Replace("\t", "");

            DataTable dt_wbs73 = new DataTable();

            using (SqlConnection conn = new SqlConnection(hrs))
            {
                using (SqlCommand comm = new SqlCommand(sql_wbs73, conn))
                {
                    using (SqlDataAdapter adapter = new SqlDataAdapter(comm))
                    {
                        conn.Open();
                        adapter.Fill(dt_wbs73);
                    }
                }
            }

            var data = dt_wbs73.Rows.Cast<DataRow>().Select(z =>
            {
                string temp_date = DateTime.Parse(z["BS73002"].ToString()).ToString("yyyy/MM/dd");
                string temp_val = z["BS73003"].ToString();
                var temp = new Vaction { BS73002 = temp_date, BS73003 = temp_val };
                return temp;
            });

            return data;

        }


        /// <summary>
        /// 取得區間內所有非假日時段(工作時段)
        /// </summary>
        /// <param name="start_"></param>
        /// <param name="end_"></param>
        /// <returns></returns>
        public static List<DateTime> CalcWorkDay(DateTime start_, DateTime end_)
        {

            var WorkHoliday = GetWorkHoliday();

            List<DateTime> result = new List<DateTime>();

            for (DateTime i = start_, max = end_; i <= max; i = i.AddDays(1))
            {
                //申請日期不可以是六、日
                if (i.DayOfWeek != DayOfWeek.Saturday && i.DayOfWeek != DayOfWeek.Sunday)
                {
                    result.Add(i);

                }
                //申請日期是 六、日 情況下
                else
                {
                    //是否為補班日
                    if (WorkHoliday.Any(z => DateTime.Parse(z.BS73002).Date.CompareTo(i.Date) == 0))
                    {
                        result.Add(i);
                    }
                    else
                    {
                        continue;
                    }
                }
            }

            return result;
        }

        public static double Admin_sumhr(HttpContext context, string ConStr)
        {
            DateTime time1 = DateTime.Parse(context.Request["time1"].ToString());
            DateTime time2 = DateTime.Parse(context.Request["time2"].ToString());

            string Date_from = time1.ToString("yyyy-MM-dd");
            string Date_to = time2.ToString("yyyy-MM-dd");
            double sum_hr = 0;
            string name = context.Session["UserName"].ToString().Length == 5 ? context.Session["UserName"].ToString().Substring(1) : context.Session["UserName"].ToString();

            //上下班的時間
            string sql = "";
            sql += "select PA51020, PB26005, PB26006 from hrs_mis.[dbo].WPB26 join ";
            sql += "(select PA51020 from hrs_mis.[dbo].WPA51 where PA51002 = '" + name + @"' and PA51001= '" + ConStr + @"' ) ";
            sql += "as WPB29 on PB26002 = PA51020 where PB26001 = '" + ConStr + "' and PB26004 = 1";
            DataTable dt = BOSSQL.hrsExecuteQuery(sql);

            sql = "";
            //國定
            sql += "select * from WPA18 ";
            sql += "where PA18002 like '%" + DateTime.Now.ToString("yyyy") + "%' ";
            sql += "and pa18001 = '" + ConStr + "'";
            DataTable Hugh_dt = BOSSQL.hrsExecuteQuery(sql);

            sql = "";
            sql += "select * from WBS73 ";
            sql += "where BS73001=0 and BS73004 =2 and BS73005=8 ";
            sql += "and BS73002 like '%" + DateTime.Now.ToString("yyyy") + "%'";
            DataTable NotHugh_dt = BOSSQL.hrsExecuteQuery(sql);

            double range_day = Math.Ceiling(DateTime.Parse(Date_to).Subtract(DateTime.Parse(Date_from)).TotalDays) + 1;

            for (int i = 0; i < range_day; i++)
            {
                string Temp_time = time1.AddDays(i).ToString("yyyy-MM-dd"); //用來存放第幾天的時候 (暫時性)

                string Temp_start = i == 0 ?
                           //判斷請假時間是否正確 ex 正常下班08:00~17:00 若請07:00~17:00  自動切割為08:00~17:00
                           Convert.ToDouble(time1.ToString("HH.mm")) < Convert.ToDouble(DateTime.Parse(dt.Rows[0]["PB26005"].ToString()).ToString("HH.mm")) ?
                           Temp_time + " " + DateTime.Parse(dt.Rows[0]["PB26005"].ToString()).ToString("HH:mm:ss")
                           :
                           Temp_time + " " + time1.ToString("HH:mm:ss")
                       :
                       Temp_time + " " + DateTime.Parse(dt.Rows[0]["PB26005"].ToString()).ToString("HH:mm:ss");  //用來計算當天請假時數  最後再加總
                string Temp_end = i == range_day - 1 ?
                            //判斷請假時間是否正確 ex 正常下班08:00~17:00 若請07:00~17:00  自動切割為08:00~17:00
                            Convert.ToDouble(time2.ToString("HH.mm")) >= Convert.ToDouble(DateTime.Parse(dt.Rows[dt.Rows.Count - 1]["PB26006"].ToString()).ToString("HH.mm")) ?
                            Temp_time + " " + DateTime.Parse(dt.Rows[1]["PB26006"].ToString()).ToString("HH:mm:ss")
                            :
                            Temp_time + " " + time2.ToString("HH:mm:ss")
                       :
                       Temp_time + " " + DateTime.Parse(dt.Rows[1]["PB26006"].ToString()).ToString("HH:mm:ss"); //用來計算當天請假時數  最後再加總

                //取得休息時間的判斷
                double down_time = DateTime.Parse(dt.Rows[0]["PB26006"].ToString()).Subtract(DateTime.Parse(dt.Rows[0]["PB26005"].ToString())).TotalHours;

                double down_time_start = dt.Rows.Count > 1 ? Convert.ToDouble(DateTime.Parse(dt.Rows[1]["PB26005"].ToString()).ToString("HH.mm")) : 0;

                double Temp_hr = DateTime.Parse(Temp_end).Subtract(DateTime.Parse(Temp_start)).TotalHours; //計算每一天共請時數 再與總時數加起來

                Temp_hr = Temp_hr < 0 ? DateTime.Parse(Temp_end).AddDays(1).Subtract(DateTime.Parse(Temp_start)).TotalHours : Temp_hr;

                //超過休息時間 扣除1H
                if (Convert.ToDouble(DateTime.Parse(Temp_end).ToString("HH.mm")) >= down_time_start && Temp_hr > down_time) Temp_hr--;

                //判斷有無國定假日
                var result = from dr in Hugh_dt.Rows.Cast<DataRow>()
                             where DateTime.Parse(dr["PA18002"].ToString()).ToString("yyyy-MM-dd") == Temp_time
                             select dr;

                //如果有國定 時數就不算在內，如果沒有國定 時數正常運算
                Temp_hr = result.Count() > 0 ? 0 : Temp_hr;


                //判斷有無六、日
                result = from dr in NotHugh_dt.Rows.Cast<DataRow>()
                         where DateTime.Parse(dr["BS73002"].ToString()).ToString("yyyy-MM-dd") == Temp_time
                         select dr;

                //先判斷是否六日，是 再判斷是不是補班 如果是補班 時數無需扣除 如果不是補班 就不算六日的時數 (雙層判斷)
                Temp_hr = DateTime.Parse(Temp_time).ToString("ddd").Substring(1, 1) == "六" || DateTime.Parse(Temp_time).ToString("ddd").Substring(1, 1) == "日" ?
                        result.Count() > 0 ?
                        Temp_hr
                        :
                        0
                    :
                    Temp_hr;

                //加總時數累加
                sum_hr = sum_hr + Temp_hr;

            }
            return sum_hr;
        }

        public static double Spot_sumhr(HttpContext context, string ConStr)
        {
            DateTime time1 = DateTime.Parse(context.Request["time1"].ToString());
            DateTime time2 = DateTime.Parse(context.Request["time2"].ToString());
            string Alternative = context.Request["Alternative"] != null ? context.Request["Alternative"].ToString() : "";

            //預設為沒有跨天
            bool IsSpotHr_Over_day = false;

            string name = context.Session["UserName"].ToString().Length == 5 ? context.Session["UserName"].ToString().Substring(1) : context.Session["UserName"].ToString();
            name = Alternative != "" ? Alternative.Length == 5 ? Alternative.Substring(1) : Alternative : name;
            //WPB29 現場班表
            //WPB26 上下班時間
            double range_day = Math.Ceiling(time2.Subtract(time1).TotalDays);
            double sum_hr = 0;

            string sql;
            sql = "select PB29003, PB26005, PB26006 from WPB26 join ";
            sql += "(select top 1 PB29003, PB29005 from WPB29 where PB29003 = '" + name + "' and PB29001= '" + ConStr + "' order by PB29002 desc) as WPB29 ";
            sql += "on PB26002 = pb29005 where PB26001 = '" + ConStr + "' and PB26004 = 1";

            DataTable dt = BOSSQL.hrsExecuteQuery(sql);
            DataTable dt2 = new DataTable();

            //判斷是廠務or人資  (沒有班表的人)
            bool IsSpot_Notable = Spot.IsSchedulePerson(name);

            if (IsSpot_Notable)
            {//有班表

                sql = "select * from WPB29 where PB29003 = '" + name + "' ";
                sql += "and PB29001 = '" + ConStr + "' and PB29002 between '" + time1.ToString("yyyy-MM-dd") + "' and '" + time2.ToString("yyyy-MM-dd") + "'";

                dt2 = BOSSQL.hrsExecuteQuery(sql);

                //有班表, 但申請區間尚未匯入班表
                if(dt2.Rows.Count == 0)
                {
                    return 0;
                }

            }
            else
            {
                //沒班表 ,使用行政版本計算時數
                sum_hr = Admin_sumhr(context, ConStr);
                return sum_hr;
            }


            if (dt.Rows.Count > 0)
            {
                //int count = 0;
                //DateTime Temp_time1 = time1;
                //double Temp_hr = 0;
                //判斷有無跨天的根據  如果是負數即是跨天人員
                double type_ = Convert.ToDouble(DateTime.Parse(dt.Rows[dt.Rows.Count - 1]["PB26006"].ToString()).ToString("HH.mm")) - Convert.ToDouble(DateTime.Parse(dt.Rows[0]["PB26005"].ToString()).ToString("HH.mm"));
                if (type_ < 0)
                {
                    //跨天
                    IsSpotHr_Over_day = true;
                }

                for (int i = 0; i < range_day; i++)
                {
                    string Temp_time = time1.AddDays(i).ToString("yyyy-MM-dd "); //用來存放第幾天的時候 (暫時性)
                    string Temp_start = "", Temp_end = "";

                    //主要是抓取起的時間
                    //第一次跑時
                    if (i == 0)
                    {
                        DateTime Default_start_time = DateTime.Parse(Temp_time + DateTime.Parse(dt.Rows[0]["PB26005"].ToString()).ToString("HH:mm"));
                        DateTime Default_end_time = DateTime.Parse(Temp_time + DateTime.Parse(dt.Rows[dt.Rows.Count - 1]["PB26006"].ToString()).ToString("HH:mm"));
                        DateTime Start_time = DateTime.Parse(Temp_time + time1.ToString("HH:mm:ss"));
                        DateTime End_time = DateTime.Parse(Temp_time + time2.ToString("HH:mm:ss"));
                        if (IsSpotHr_Over_day)
                        {
                            //跨天 ex:20:00~05:00
                            if (Start_time >= Default_start_time && Start_time <= Default_end_time.AddDays(1) && End_time.AddDays(1) >= Default_start_time && End_time.AddDays(1) <= Default_end_time.AddDays(range_day))
                            {
                                Temp_start = Temp_time + time1.ToString("HH:mm:ss");
                            }
                            else
                            {
                                return 0;
                            }
                        }
                        else
                        {
                            //無跨天 ex:08:00~17:00
                            if (Start_time >= Default_start_time && Start_time <= Default_end_time && End_time >= Default_start_time && End_time <= Default_end_time.AddDays(range_day - 1))
                            {
                                Temp_start = Temp_time + time1.ToString("HH:mm:ss");
                            }
                            else
                            {
                                return 0;
                            }
                        }
                    }
                    else
                    {
                        Temp_start = Temp_time + DateTime.Parse(dt.Rows[0]["PB26005"].ToString()).ToString("HH:mm:ss");
                    }

                    //主要是取迄的時間
                    //如果是最後一次跑
                    if (i == range_day - 1)
                    {
                        DateTime Default_start_time = DateTime.Parse(Temp_time + DateTime.Parse(dt.Rows[0]["PB26005"].ToString()).ToString("HH:mm"));
                        DateTime Default_end_time = DateTime.Parse(Temp_time + DateTime.Parse(dt.Rows[dt.Rows.Count - 1]["PB26006"].ToString()).ToString("HH:mm"));
                        DateTime Start_time = DateTime.Parse(Temp_time + time1.ToString("HH:mm:ss"));
                        DateTime End_time = DateTime.Parse(Temp_time + time2.ToString("HH:mm:ss"));
                        //判斷是否跨天人員 true = 跨天
                        if (IsSpotHr_Over_day)
                        {
                            //跨天 ex:20:00~05:00
                            if (Start_time >= Default_start_time && Start_time <= Default_end_time.AddDays(1) && End_time.AddDays(1) >= Default_start_time && End_time.AddDays(1) <= Default_end_time.AddDays(range_day))
                            {
                                Temp_end = Temp_time + time2.ToString("HH:mm:ss");
                            }
                            else
                            {
                                return 0;
                            }
                        }
                        else
                        {
                            //無跨天 ex:08:00~17:00
                            if (Start_time >= Default_start_time && Start_time <= Default_end_time && End_time >= Default_start_time && End_time <= Default_end_time.AddDays(range_day - 1))
                            {
                                Temp_end = Temp_time + time2.ToString("HH:mm:ss");
                            }
                            else
                            {
                                return 0;
                            }
                        }

                    }
                    else
                    {
                        Temp_end = Temp_time + DateTime.Parse(dt.Rows[dt.Rows.Count - 1]["PB26006"].ToString()).ToString("HH:mm:ss");
                    }

                    //取得休息時間的判斷
                    double down_time = DateTime.Parse(dt.Rows[0]["PB26006"].ToString()).Subtract(DateTime.Parse(dt.Rows[0]["PB26005"].ToString())).TotalHours;

                    //每個班的休息開始時間  (用來判斷是否超過休息時間的依據)
                    double down_time_start = dt.Rows.Count > 1 ? Convert.ToDouble(DateTime.Parse(dt.Rows[1]["PB26005"].ToString()).ToString("HH.mm")) : 0;

                    //計算當天的總時數 (還沒扣除休息時間1H)
                    double Temp_hr = DateTime.Parse(Temp_end).Subtract(DateTime.Parse(Temp_start)).TotalHours; //計算每一天共請時數 再與總時數加起來

                    //初步計算時數  如果是現場有跨天情況的話 當天出勤日的結束日會再加一天才會正常時數
                    Temp_hr = Temp_hr < 0 ? DateTime.Parse(Temp_end).AddDays(1).Subtract(DateTime.Parse(Temp_start)).TotalHours : Temp_hr;


                    //判斷是否要扣除1H休息時間
                    if (Temp_hr > down_time)
                    {
                        if (Temp_hr - down_time >= 1)
                        {
                            Temp_hr--;
                        }
                        else
                        {
                            Temp_hr = Temp_hr - 0.5;
                        }
                    }


                    sql = null;
                    dt2 = null;
                    //dt = null;
                    //抓出排 "休" 的時間
                    sql = "select * from WPB29 where PB29003 = '" + name + "' and PB29004 = 3 ";
                    sql += "and PB29001 = '"+ConStr+"' and PB29002 between '" + time1.ToString("yyyy-MM-dd") + "' and '" + time2.ToString("yyyy-MM-dd") + "'";
                    dt2 = BOSSQL.hrsExecuteQuery(sql);

                    if (dt2.Rows.Count > 0)
                    {
                        //現場
                        //如果目前計算天數是休假時就不加時數，即也不加入總時數
                        var a = from row in dt2.Rows.Cast<DataRow>()
                                where Temp_time == DateTime.Parse(row["PB29002"].ToString()).ToString("yyyy-MM-dd")
                                select row;

                        Temp_hr = a.Count() == 0 ? Temp_hr : 0;

                    }
                    sum_hr = sum_hr + Temp_hr;
                }
            }

            return sum_hr;

        }

        /// <summary>
        /// 寫入文中
        /// </summary>
        /// <param name="pa123dt"></param>
        /// <param name="mon"></param>
        /// <param name="Type_"></param>
        /// <param name="number"></param>
        public static void Cut_to_wpa60_start(DataTable pa123dt, int mon, string Type_, int number, string ConStr)
        {
            string Upanddown_Work_SQL = "select PB26005, PB26006, PB26002 from [hrs_mis].[dbo].[WPB26] join [hrs_mis].[dbo].[WPA51] on PA51020 = PB26002 and PA51001 = PB26001  where PA51002 = '" + pa123dt.Rows[0]["PA60002"].ToString() + "' and PA51001 = '" + ConStr + "'";
            DataTable WPB26 = BOSSQL.hrsExecuteQuery(Upanddown_Work_SQL);

            string hrd = null, user = pa123dt.Rows[0]["PA60002"].ToString();
            double min = 0, pa6012 = 0;
            string frda = DateTime.Parse(pa123dt.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
            string toda = DateTime.Parse(DateTime.Parse(pa123dt.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(0, 10) + DateTime.Parse(WPB26.Rows[1]["PB26006"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(10, 6)).ToString("yyyy-MM-dd HH:mm:ss.fff");

            DateTime nowdate = DateTime.Now;

            SqlConnection conn = new SqlConnection(hrs);
            conn.Open();
            SqlCommand s_com = new SqlCommand();

            if (Type_ == "Start")
            {
                frda = DateTime.Parse(pa123dt.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
                toda = DateTime.Parse(DateTime.Parse(pa123dt.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(0, 10) + DateTime.Parse(WPB26.Rows[1]["PB26006"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(10, 6)).ToString("yyyy-MM-dd HH:mm:ss.fff");
                if (frda.ToString().Substring(14, 2) == "30")
                {
                    hrd = frda.Substring(11, 2) + ".5";
                }
                else
                {
                    hrd = frda.Substring(11, 2);
                }
                //======================================================
                string hr_ = DateTime.Parse(WPB26.Rows[1]["PB26006"].ToString()).ToString("yyyy-MM-dd HH.mm:ss.fff").Substring(14, 2);
                if (hr_ == "30")
                {
                    hr_ = DateTime.Parse(WPB26.Rows[1]["PB26006"].ToString()).ToString("yyyy-MM-dd HH.mm:ss.fff").Substring(11, 2) + ".5";
                }
                else
                {
                    hr_ = DateTime.Parse(WPB26.Rows[1]["PB26006"].ToString()).ToString("yyyy-MM-dd HH.mm:ss.fff").Substring(11, 2);
                }
                //======================================================
                min = Convert.ToDouble(hr_) - Convert.ToDouble(hrd);
                if (WPB26.Rows[0]["PB26002"].ToString() == "009" || WPB26.Rows[0]["PB26002"].ToString() == "010")
                {
                    if (min > 5)
                    {
                        min = min - 1;
                    }
                }
                else
                {
                    if (min >= 5)
                    {
                        min = min - 1;
                    }
                }


                pa6012 = (pa123dt.Rows[0]["PA60004"].ToString() == "9" || pa123dt.Rows[0]["PA60004"].ToString() == "10") ? pa6012 = min : pa6012 = 0;
            }
            else if (Type_ == "End")
            {
                frda = DateTime.Parse(DateTime.Parse(pa123dt.Rows[0]["PA60008"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(0, 10) + DateTime.Parse(WPB26.Rows[0]["PB26005"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(10, 6)).ToString("yyyy-MM-dd HH:mm:ss.fff");
                toda = DateTime.Parse(pa123dt.Rows[0]["PA60008"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
                mon = DateTime.DaysInMonth(Convert.ToInt32(frda.Substring(0, 4)), Convert.ToInt32(frda.Substring(5, 2)));
                if (toda.ToString().Substring(14, 2) == "30")
                {
                    hrd = toda.Substring(11, 2) + ".5";
                }
                else
                {
                    hrd = toda.Substring(11, 2);
                }
                //======================================================
                string hr_ = DateTime.Parse(WPB26.Rows[0]["PB26005"].ToString()).ToString("yyyy-MM-dd HH.mm:ss.fff").Substring(14, 2);
                if (hr_ == "30")
                {
                    hr_ = DateTime.Parse(WPB26.Rows[0]["PB26005"].ToString()).ToString("yyyy-MM-dd HH.mm:ss.fff").Substring(11, 2) + ".5";
                }
                else
                {
                    hr_ = DateTime.Parse(WPB26.Rows[0]["PB26005"].ToString()).ToString("yyyy-MM-dd HH.mm:ss.fff").Substring(11, 2);
                }
                //======================================================
                min = Convert.ToDouble(hrd) - Convert.ToDouble(hr_);
                if (WPB26.Rows[0]["PB26002"].ToString() == "009" || WPB26.Rows[0]["PB26002"].ToString() == "010")
                {
                    if (min > 5)
                    {
                        min = min - 1;
                    }
                }
                else
                {
                    if (min >= 5)
                    {
                        min = min - 1;
                    }
                }
                pa6012 = (pa123dt.Rows[0]["PA60004"].ToString() == "9" || pa123dt.Rows[0]["PA60004"].ToString() == "10") ? pa6012 = min : pa6012 = 0;
            }
            else if (Type_ == "Between")
            {
                frda = DateTime.Parse(DateTime.Parse(pa123dt.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(0, 10) + DateTime.Parse(WPB26.Rows[0]["PB26005"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(10, 6)).AddDays(number - 1).ToString("yyyy-MM-dd HH:mm:ss.fff");
                toda = DateTime.Parse(DateTime.Parse(pa123dt.Rows[0]["PA60007"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(0, 10) + DateTime.Parse(WPB26.Rows[1]["PB26006"].ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff").Substring(10, 6)).AddDays(number - 1).ToString("yyyy-MM-dd HH:mm:ss.fff");
                mon = DateTime.DaysInMonth(Convert.ToInt32(frda.Substring(0, 4)), Convert.ToInt32(frda.Substring(5, 2)));
                min = 8;
                pa6012 = (pa123dt.Rows[0]["PA60004"].ToString() == "9" || pa123dt.Rows[0]["PA60004"].ToString() == "10") ? pa6012 = min : pa6012 = 0;
            }


            string SQL_Insert_wpa60 = @"INSERT INTO hrs_mis.dbo.WPA60(PA60001, PA60002, PA60004, PA60007, PA60008, PA60016, 
                                                    PA60996, PA60998,PA60999, PA60011, PA60012, PA60006, PA60005, PA60010, PA60017, PA60019, PA60020
                                                    , PA60021, PA60022, PA60023, PA60024, PA60025, PA60026, PA60029, PA60031, PA60033, PA60034, PA60018)   VALUES(
                                                    @PA60001, @PA60002, @PA60004, @PA60007, @PA60008, @PA60016,
                                                    @PA60996, @PA60998,@PA60999, @PA60011, @PA60012, @PA60006, @PA60005, @PA60010, @PA60017, @PA60019, @PA60020, 
                                                    @PA60021, @PA60022, @PA60023, @PA60024, @PA60025, @PA60026, @PA60029, @PA60031, @PA60033, @PA60034, @PA60018) select pa60003 from hrs_mis.dbo.WPA60 where PA60995=(select IDENT_CURRENT('hrs_mis.dbo.WPA60')) ";

            SqlParameter[] partmeters = new SqlParameter[]
            {
                                            new SqlParameter("@PA60001",ConStr),
                                            new SqlParameter("@PA60002",user),
                                            new SqlParameter("@PA60004",Convert.ToInt16(pa123dt.Rows[0]["PA60004"].ToString())),
                                            new SqlParameter("@PA60007",frda),
                                            new SqlParameter("@PA60008",toda),
                                            new SqlParameter("@PA60016",pa123dt.Rows[0]["PA60016"].ToString()),

                                            new SqlParameter("@PA60996",user),
                                            new SqlParameter("@PA60998",nowdate.ToString("yyyy-MM-dd HH:mm:ss.fff")),
                                            new SqlParameter("@PA60999",nowdate.ToString("yyyy-MM-dd HH:mm:ss.fff")),
                                            new SqlParameter("@PA60011",Convert.ToDouble(min) * 60),
                                            new SqlParameter("@PA60012",Convert.ToDouble(pa6012) * 60),
                                            new SqlParameter("@PA60006",DateTime.Parse(frda).ToString("yyyy-MM-dd 00:00:00.000")),
                                            new SqlParameter("@PA60005",DateTime.Parse(pa123dt.Rows[0]["PA60998"].ToString()).ToString("yyyy-MM-dd 00:00:00.000")),
                                            new SqlParameter("@PA60010","2"),
                                            new SqlParameter("@PA60017",""),
                                            new SqlParameter("@PA60019","001"),
                                            new SqlParameter("@PA60020",frda.Substring(0, 4)),

                                            new SqlParameter("@PA60021",frda.Substring(5, 2)),
                                            new SqlParameter("@PA60022","001"),
                                            new SqlParameter("@PA60023",frda.Substring(0, 4)),
                                            new SqlParameter("@PA60024",frda.Substring(5, 2)),
                                            new SqlParameter("@PA60025",DateTime.Parse(frda.Substring(0, 8) + "01 00:00:00.000").ToString("yyyy-MM-dd HH:mm:ss.fff")),
                                            new SqlParameter("@PA60026",DateTime.Parse(frda.Substring(0, 8) + Convert.ToString(mon) + " 00:00:00.000").ToString("yyyy-MM-dd HH:mm:ss.fff")),
                                            new SqlParameter("@PA60029",""),
                                            new SqlParameter("@PA60031",""),
                                            new SqlParameter("@PA60033",""),
                                            new SqlParameter("@PA60034",""),
                                            new SqlParameter("@PA60018","0")

            };
            SQL_Insert_wpa60 = SQL_Insert_wpa60.Replace("\r\n", "").Replace("\t", "");
            s_com.CommandText = SQL_Insert_wpa60;

            s_com.Connection = conn;
            s_com.Parameters.AddRange(partmeters);
            //s_com.ExecuteNonQuery();

            string tmp = SQL_Insert_wpa60;

            foreach (SqlParameter p in s_com.Parameters)
            {
                //tmp = tmp.Replace('@' + p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
                tmp = tmp.Replace(p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
            }


            //===========================假別中文名字=============================
            string Leave_cnnamesql = "select top 1  PA25008 from [hrs_mis].[dbo].[WPA25] where pa25001 = '" + ConStr + "' and PA25003 = '" + pa123dt.Rows[0]["PA60004"].ToString() + "'";
            DataTable Leave_dt = BOSSQL.hrsExecuteQuery(Leave_cnnamesql);
            //===========================假別中文名字=============================

            string wpa60_water = "";

            using (SqlDataAdapter adapter = new SqlDataAdapter(s_com))
            {
                DataTable dt_only_wpa60_water = new DataTable();

                adapter.Fill(dt_only_wpa60_water);

                wpa60_water = dt_only_wpa60_water.Rows[0]["pa60003"].ToString();
            }

            conn.Dispose();
            conn.Close();

            Apply_10(pa123dt, user, Leave_dt.Rows[0][0].ToString(), ConStr);

            Apply_9(pa123dt, user, Convert.ToDouble(min) * 60, wpa60_water, ConStr);

        }

        /// <summary>
        /// 申請補休邏輯
        /// </summary>
        /// <param name="seletable"></param>
        /// <param name="user"></param>
        /// <param name="leave"></param>
        /// <param name="ConStr"></param>
        public static void Apply_10(DataTable seletable, string user, string leave, string ConStr)
        {
            //------------------申請補休-----------------
            //WPA74 [WPA73&WPA60對照表] - 增加資料(多筆)
            //WPA73 [加班申請資料] - 修改已用時數(多筆)
            //WPA60 [請假資料] - 修改已用時數(多筆)
            if (Convert.ToInt16(seletable.Rows[0]["PA60004"].ToString()) == 10)
            {
                string sql_wpa73 = @"/*WPA73*/
                         SELECT *
                         FROM [hrs_mis].[dbo].[WPA73]
                         where PA73002='" + user + @"'
                         and PA73001='" + ConStr + @"'
                         and PA73011 is not null
                         and PA73013 is not null
                         and PA73013>=  DateADD(day,DATEDIFF(DAY,0,GETDATE()),0) order by PA73007";
                string sql_wpa60 = @"select PA60001,PA60002,PA60004, PA60003,PA60011,PA60012,PA60995
                         FROM hrs_mis.dbo.WPA60
                         where PA60001='" + ConStr + "' AND pa60995=(select IDENT_CURRENT('hrs_mis.dbo.WPA60'))";

                sql_wpa73 = sql_wpa73.Replace("\r\n", "").Replace("\t", "");
                sql_wpa60 = sql_wpa60.Replace("\r\n", "").Replace("\t", "");

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
                            comm.CommandText = sql_wpa60;
                            adapter.Fill(ds, "WPA60_u");
                        }
                    }
                }

                DataTable dt_wpa73 = ds.Tables["WPA73_u"];
                DataTable dt_wpa60 = ds.Tables["WPA60_u"];

                int rest = dt_wpa73.Rows.Cast<DataRow>().Sum(z => int.Parse(z["PA73011"].ToString()) - int.Parse(z["PA73012"].ToString()));
                int need = int.Parse(dt_wpa60.Rows[0]["PA60011"].ToString());

                List<SqlCommand> comm_list = new List<SqlCommand>();

                //先初步判斷WPA73可使
                //用的時數還夠用
                if (rest >= need)
                {

                    do
                    {
                        foreach (DataRow dr in dt_wpa73.Rows)
                        {
                            //目前這筆還剩餘的分鐘數
                            int current_rest = int.Parse(dr["PA73011"].ToString()) - int.Parse(dr["PA73012"].ToString());

                            string wpa60_f = dt_wpa60.Rows[0]["PA60003"].ToString();

                            int wpa73_f = int.Parse(dr["PA73003"].ToString());

                            if (current_rest > 0)
                            {
                                int Pre_need = need;

                                need = need <= current_rest ? (need - need) : (need - current_rest);

                                comm_list.Add(Insert_wpa74(user, wpa60_f, wpa73_f, Pre_need - need, "1", ConStr));

                                comm_list.Add(Update_wpa73(dr, Pre_need - need, user,ConStr));

                                break;
                            }
                        }

                    } while (need > 0);


                    using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString))
                    {
                        conn.Open();
                        using (SqlTransaction transcation = conn.BeginTransaction(IsolationLevel.ReadCommitted))
                        {
                            try
                            {

                                comm_list.ForEach(z =>
                                {
                                    z.Transaction = transcation;
                                    z.Connection = conn;
                                    string tmp = z.CommandText;
                                    foreach (SqlParameter p in z.Parameters)
                                    {
                                        //tmp = tmp.Replace('@' + p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
                                        tmp = tmp.Replace(p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
                                    }
                                    string test = "";
                                });
                                comm_list.ForEach(z => z.ExecuteNonQuery());
                                transcation.Commit();

                            }
                            catch (Exception error)
                            {
                                System.Diagnostics.Debug.WriteLine(error.Message);
                                transcation.Rollback();
                            }
                        }
                    }


                }
            }
            //------------------申請補休 END-----------------
        }


        public static SqlCommand Insert_wpa74(string user, string wpa60_f, int water, double cost, string PA74006IS1OR3, string ConStr)
        {


            string SQL_Insert_wpa74 = @"insert [hrs_mis].[dbo].[WPA74]([PA74001],[PA74002],[PA74003],[PA74004],[PA74005],[PA74006],[PA74996],[PA74997],[PA74998],[PA74999])  
                                            values(@PA74001,@PA74002,@PA74003,@PA74004,@PA74005,@PA74006,@PA74996,@PA74997,getdate(),getdate())";

            SqlParameter[] partmeters = new SqlParameter[]
            {
                    new SqlParameter("@PA74001",ConStr),
                    new SqlParameter("@PA74002",user),
                    new SqlParameter("@PA74003",wpa60_f),
                    new SqlParameter("@PA74004",water),
                    new SqlParameter("@PA74005",cost),
                    new SqlParameter("@PA74006",PA74006IS1OR3),
                    new SqlParameter("@PA74996",user),
                    new SqlParameter("@PA74997",user),

            };

            SQL_Insert_wpa74 = SQL_Insert_wpa74.Replace("\r\n", "").Replace("\t", "");

            SqlCommand comm_result = new SqlCommand();

            comm_result.CommandText = SQL_Insert_wpa74;

            comm_result.Parameters.AddRange(partmeters);

            return comm_result;

        }

        public static SqlCommand Update_wpa73(DataRow dr_wpa73, int cost, string user, string ConStr)
        {
            string dr_wpa73_Primy_F = Convert.ToString(dr_wpa73["PA73995"]);

            int cost_total = int.Parse(dr_wpa73["PA73012"].ToString()) + cost;

            string SQL_Update_wpa73 = @"update [hrs_mis].[dbo].[WPA73] SET [PA73012]=@PA73012,[PA73999]=getdate() WHERE [PA73995]=@PA73995 and PA73001=@PA73001 and PA73002=@PA73002 ";

            SqlParameter[] partmeters = new SqlParameter[]
            {
                    new SqlParameter("@PA73012",cost_total),
                    new SqlParameter("@PA73995",dr_wpa73_Primy_F),
                    new SqlParameter("@PA73001",ConStr),
                    new SqlParameter("@PA73002",user)
            };

            SqlCommand comm_result = new SqlCommand();

            comm_result.CommandText = SQL_Update_wpa73;

            comm_result.Parameters.AddRange(partmeters);

            dr_wpa73["PA73012"] = cost_total;

            return comm_result;
        }


        /// <summary>
        /// 申請特休邏輯
        /// </summary>
        /// <param name="seletable"></param>
        /// <param name="user"></param>
        /// <param name="leave"></param>
        public static void Apply_9(DataTable seletable, string user, double hr_cut, string wpa60_water, string ConStr)
        {
            //------------------申請特休-----------------
            //dt [WPA86 特休時數表] - 增加資料(多筆)
            //WPA73 [加班申請資料] - 修改已用時數(多筆)
            //WPA60 [請假資料] - 修改已用時數(多筆)
            if (Convert.ToInt16(seletable.Rows[0]["PA60004"].ToString()) == 9)
            {
                List<SqlCommand> result_comm_list = Update_WPA86ANDWPA74(user, hr_cut, wpa60_water, Convert.ToDouble(seletable.Rows[0]["PA60011"].ToString()),ConStr);

                using (SqlConnection conn = new SqlConnection(hrs))
                {
                    conn.Open();
                    using (SqlTransaction transaction = conn.BeginTransaction(IsolationLevel.ReadCommitted))
                    {
                        try
                        {
                            result_comm_list.ForEach(z => z.Connection = conn);

                            result_comm_list.ForEach(z => z.Transaction = transaction);

                            result_comm_list.ForEach(z => z.ExecuteNonQuery());

                            transaction.Commit();

                        }
                        catch (Exception error)
                        {
                            transaction.Rollback();
                        }
                    }
                }

            }

        }

        public static List<SqlCommand> Update_WPA86ANDWPA74(string user, double hr_cut, string wpa60_water, double hr_all, string ConStr)
        {
            string sql2;
            sql2 = " select PA86010, PA86011, PA86005, PA86003 FROM [hrs_mis].[dbo].[WPA86] where [PA86002] = '" + user + "' and  [PA86004] = '" + DateTime.Now.ToString("yyyy") + "' ";
            sql2 += "and PA86007 <= '" + DateTime.Now.ToString("yyyy-MM-dd") + "' and PA86001 = '" + Enterprise.ConStr_produceline + "' ";
            DataTable dt = BOSSQL.hrsExecuteQuery(sql2);//86 table

            DataSet ds = new DataSet();
            List<SqlCommand> comm_result = new List<SqlCommand>();
            SqlCommand comm_wpa86 = new SqlCommand();
            SqlCommand comm_wpa74 = new SqlCommand();
            string Update86_sql = "", Insert_wpa74_sql = "";
            List<List<string>> WPA86_output_WPA74_list = new List<List<string>>();

            double current_hr = hr_cut;

            do
            {
                foreach (DataRow i in dt.Rows)
                {
                    int PA86010_i = int.Parse(i["PA86010"].ToString());
                    int PA86011_i = int.Parse(i["PA86011"].ToString());
                    int PA86003_water_i = int.Parse(i["PA86003"].ToString());

                    if (PA86010_i - PA86011_i > 0)
                    {
                        int rest = PA86010_i - PA86011_i;

                        //double cost = current_hr < rest ? PA86011_i + current_hr : PA86010_i;

                        double cost = rest < current_hr ? rest : current_hr;

                        current_hr = current_hr - cost;


                        i["PA86011"] = int.Parse(i["PA86011"].ToString()) + cost;

                        SqlCommand WPA86_sqlComm = UpdateWPA86(Convert.ToDouble(i["PA86011"].ToString()), user, PA86003_water_i,ConStr);

                        comm_result.Add(WPA86_sqlComm);

                        SqlCommand WPA74_sqlComm = Common.Insert_wpa74(user, wpa60_water, PA86003_water_i, cost, "3", Enterprise.ConStr_produceline);

                        comm_result.Add(WPA74_sqlComm);

                        break;
                    }
                }

            } while (current_hr > 0);


            return comm_result;


        }

        public static SqlCommand UpdateWPA86(double cost, string user, int PA86003_water_i,string ConStr)
        {
            string sql_UpdateWPA86 = "Update [hrs_mis].[dbo].[WPA86] set PA86011=@PA86011 where PA86002=@PA86002 and PA86003=@PA86003 and PA86001='" + Enterprise.ConStr_produceline + "'  ";

            SqlCommand comm = new SqlCommand();

            comm.Parameters.AddWithValue("@PA86011", cost);
            comm.Parameters.AddWithValue("@PA86002", user);
            comm.Parameters.AddWithValue("@PA86003", PA86003_water_i);

            comm.CommandText = sql_UpdateWPA86;


            return comm;

        }
    }
}
