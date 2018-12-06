using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using NLog;
using HR.DBUtility;
using HR.WebModel;

namespace WorkCheck.Tools
{
    /// <summary>
    /// HR 的摘要描述
    /// </summary>
    public class HR : IHttpHandler
    {
        private static Logger logger = LogManager.GetCurrentClassLogger();

        public void ProcessRequest(HttpContext context)
        {
            if (context.Request["mode"] != null)
            {
                string ClassId = context.Request["mode"].ToString();
                switch (ClassId)
                {
                    case "checklist":
                        checklist(context);
                        break;
                    case "checkwork":
                        checkworkTEST(context);           //checkwork(context);
                        break;
                    case "TestDownloadFile":
                        TestDownloadFile(context);
                        break;
                    case "Sace":
                        Sace(context);           //checkwork(context);
                        break;
                    case "Showdep":
                        Showdep(context);
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

        public void checklist(HttpContext context)
        {
            //{\"l00\":441639,\"l01\":\"2016-11-30 08:59:11\",\"l02\":\"A-1F-ATT\",\"l06\":\"4266981378\",\"l07\":\"李景怡\",\"l08\":\"正常進出\",\"l09\":\"\",\"l10\":\"A-1F                                                                                                \",\"l15\":\"行銷企劃室\"}
            string search = context.Request["search"].ToString();
            string start = context.Request["start"].ToString();
            string end = context.Request["end"].ToString();
            string where = sqlwhere(search, start, end, "l01");
            string coddep = GetJsonClient("coddep", context);
            string PAKK = GetJsonClient("PAKK", context);       //傳入"003;35;00819" 組別代碼;級職;登入者卡號
            string[] xPAKK = PAKK.Split(';');
            string Ucard = "";
            string xSQL = "";
            string SQL = "";
            string SQL_temp1_string = "";
            string SQL_temp2_string = "";

            if (Convert.ToInt16(xPAKK[1]) <= 50)
            {

                if (coddep != "")
                {
                    if (coddep.IndexOf(";") > -1)
                    {
                        List<string> coddep_l = coddep.Split(';').ToList();

                        for (int i = 0, cout = coddep_l.Count; i < cout; i++)
                        {
                            if (i == 0)
                            {
                                xSQL += "M2.D01 = '" + coddep_l[i].Trim() + "'";
                            }
                            else
                            {
                                xSQL += "OR M2.D01 = '" + coddep_l[i].Trim() + "'";
                            }
                        }

                        xSQL = "AND ( " + xSQL + " )";

                    }
                    else
                    {
                        //if (coddep != "003")
                        //{
                        xSQL += " AND (M2.D01 ='" + coddep.Replace(";", "' or M2.D01 = '") + "')";


                        //                            if (xdep != "")
                        //                            {
                        //                                xSQL += " AND (M2.D01 ='" + xdep.Replace(",", "' or M2.D01 = '") + "')";
                        //                            }
                        //                            else
                        //                            {
                        //                                xSQL += " AND M2.D01 = ''";
                        //                            }
                        //}
                    }
                }
                else
                {
                    //Ucard = " and (m1.p01 = '" + xPAKK[2] + "')";
                    SQL_temp1_string = "with temp as ( ";
                    SQL_temp2_string = " ) select* from temp where p01 = '" + xPAKK[2] + "' ";
                }
            }
            else
            {
                //Ucard = " and (m1.p01 = '" + xPAKK[2] + "')";
                SQL_temp1_string = "with temp as ( ";
                SQL_temp2_string = " ) select* from temp where p01 = '" + xPAKK[2] + "' ";
            }

            DataTable dt = new DataTable();
            SQL = "{1}";
            SQL += "SELECT l00,CONVERT(nvarchar, l01,120) l01,l02,l06,l07,l08,l09,l10,l15, P01, CASE WHEN SUBSTRING(P01,1,1) = '0' THEN SUBSTRING(P01,2,4) ELSE P01 END xP01, M2.D01";
            //SQL += FROM L03 m INNER JOIN P00 m1 ON m.l06 = m1.p08;
            //SQL += " FROM (select *  FROM L03 m where l06 = (select p08 from P00 where p01 = '" + xPAKK[2] + "')) m INNER JOIN P00 m1 ON m.l06 = m1.p08";
            SQL += " FROM L03 m /*(select *  FROM L03 m where l06 = (select top 1 p08 from P00 where p01 = '" + xPAKK[2] + "' and p10=1 /* 猜測P10 1=啟用 0=不啟用 */ )) m*/ INNER JOIN P00 m1 ON m.l06 = m1.p08";
            SQL += " LEFT JOIN D00 M2 ON M1.P108 = M2.D00";
            SQL += " WHERE 1=1";
            SQL += " And L12 IN ( '238','283','291','292','293','294','295','296','300','301','302','304','305','306','312','313','314','315','316','317','324','325','326','327','329','330','331','332','333','334','335','336','337','338','339','340','341','342','343')";
            SQL += " AND L07 != '不明' and  (convert(nvarchar(255),l08) like '%正常進出%' or convert(nvarchar(255),l08) like '%指紋進出%' )";
            SQL += " {0}";
            SQL += xSQL;
            SQL += "{2}";
            SQL += " --order by P01, l01";
            //            SQL += " order by P.P01, L.l01";

            SQL = string.Format(SQL, where, SQL_temp1_string, SQL_temp2_string);
            dt = DBSQLHELP.ExecuteQuery(SQL);

            dt.Columns.Add("xCheck");
            dt.Columns["xCheck"].DefaultValue = "";
            if (dt.Rows.Count > 0)
            {
                DataTable myDatatable = new DataTable();
                myDatatable.TableName = "Table";
                myDatatable.Columns.Add("l01");     //1
                myDatatable.Columns.Add("l15");     //8
                myDatatable.Columns.Add("P01");     //9
                myDatatable.Columns.Add("l07");     //4
                myDatatable.Columns.Add("xMinute");
                myDatatable.Columns.Add("YN");
                myDatatable.Columns.Add("xPA51020");    //班別
                myDatatable.Columns.Add("CPA51020");    //班別中文

                string cadno = "";
                string cadTime = "";
                string[] xDtable = new string[8];

                SQL = "SELECT M.PA51002, M.PA51014, M.PA51020, M.PA51019, M.PA51025, M1.PA20003";
                SQL += " FROM WPA51 M INNER JOIN WPA20 M1 ON M.PA51020 = M1.PA20002";
                SQL += " WHERE M.PA51001 = '001' AND M1.PA20001='001'";
                SQL += " AND (M.PA51025 IS NULL ";
                if (start != "")
                {
                    SQL += " OR (M.PA51025 >= DATEADD(day, DATEDIFF(day, '', '" + start + "'), ''))";
                }
                SQL += " )";
                //            SQL += " AND PA51025 < DATEADD(day, DATEDIFF(day, '', '" + end + "') + 1, '')))";

                DataTable dtWPA51 = new DataTable();
                dtWPA51 = WZDBSQLHELP.ExecuteQuery(SQL);

                SQL = "SELECT M.PB29002, M.PB29003, M.PB29004, M.PB29005, M1.PA20003 ";
                SQL += " FROM WPB29 M INNER JOIN WPA20 M1 ON M.PB29005 = M1.PA20002";
                SQL += " WHERE M.PB29001 = '001' AND M1.PA20001='001'";
                SQL += sqlwhere(search, start, end, "M.PB29002");
                DataTable dtWPB29 = new DataTable();
                dtWPB29 = WZDBSQLHELP.ExecuteQuery(SQL);

                //請假單
                SQL = "SELECT * from WPA60";
                SQL += " WHERE PA60001 = '001'";
                if (start != "")
                {
                    SQL += " AND PA60007 >= DATEADD(day, DATEDIFF(day, '', '" + start + "'), '')";
                }
                if (end != "")
                {
                    SQL += " AND PA60008 < DATEADD(day, DATEDIFF(day, '', '" + end + "') + 1, '')";
                }
                SQL += " ORDER BY PA60002, PA60007";
                DataTable dtWPA60 = new DataTable();
                dtWPA60 = WZDBSQLHELP.ExecuteQuery(SQL);

                DataRow[] dr;

                string[] xChart = { "001", "002", "003", "004", "006", "007", "008", "009", "010", "013", "021", "026", "027", "037", "039", "040", "045", "046", "047", "048", "052" };
                string xPA51020 = "";
                string[,] x20Chart = new string[,] { { "001", "08:00" }, { "003", "17:00" }, { "005", "13:00" }, { "008", "17:00" }, { "009", "09:00" }, { "010", "09:00" }, { "011", "08:30" }, { "014", "08:00" }, { "015", "20:00" }, { "016", "08:00" }, { "017", "20:00" }, { "018", "08:00" }, { "019", "20:00" }, { "020", "18:00" }, { "021", "08:00" }, { "028", "17:00" }, { "029", "17:00" }, { "030", "15:00" } };
                DateTime x20TimeChart;  //應打卡時間
                DateTime x20NowTime;    //打卡時間
                TimeSpan ts;

                DateTime sWPA60Time;
                DateTime eWPA60Time;
                string xL01 = "";

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //                System.Diagnostics.Debug.Print(i.ToString());
                    //                if (i == 288)
                    //                {
                    //                    string fffff = "";
                    //                }
                    //                if (cadno != dt.Rows[i][9].ToString ())

                    if (dt.Rows[i]["P01"].ToString() == "00027")
                    {
                        string dddd = "0";
                    }
                    //if (dt.Rows[i]["xCheck"].ToString() == "")
                    //{
                    xDtable[0] = dt.Rows[i][1].ToString();
                    xDtable[1] = dt.Rows[i][8].ToString();
                    xDtable[2] = dt.Rows[i][9].ToString();
                    xDtable[3] = dt.Rows[i][4].ToString();
                    xDtable[4] = "--";
                    xDtable[5] = "";
                    xDtable[6] = "";
                    xDtable[7] = "";

                    //找卡號在打卡的位置
                    dr = dtWPA51.Select("PA51002 = '" + dt.Rows[i][10].ToString() + "'");
                    if (dr.Length > 0)
                    {
                        //是否為行政人員(是否有排班)

                        //                       if (Array.IndexOf(xChart,  dtWPA51.Rows[dtWPA51.Rows.IndexOf(dr[0])]["PA51014"].ToString())>-1)
                        if (Convert.ToInt16(dtWPA51.Rows[dtWPA51.Rows.IndexOf(dr[0])]["PA51019"].ToString()) == 0)
                        {
                            //行政人員出勤代碼
                            xPA51020 = dtWPA51.Rows[dtWPA51.Rows.IndexOf(dr[0])]["PA51020"].ToString();
                            xDtable[6] = xPA51020;
                            xDtable[7] = dtWPA51.Rows[dtWPA51.Rows.IndexOf(dr[0])]["PA20003"].ToString();

                            for (int j = 0; j < x20Chart.GetUpperBound(0) - 1; j++)
                            {
                                if (x20Chart[j, 0] == xPA51020)
                                {
                                    xL01 = dt.Rows[i]["L01"].ToString();
                                    xL01 = xL01.Substring(0, xL01.IndexOf(" "));
                                    x20TimeChart = Convert.ToDateTime(xL01 + " " + x20Chart[j, 1].ToString());
                                    x20NowTime = Convert.ToDateTime(dt.Rows[i]["L01"].ToString());
                                    if (DateTime.Compare(x20NowTime.AddMinutes(-15), x20TimeChart) > 0)
                                    {
                                        ts = x20NowTime - x20TimeChart;
                                        if (ts.Minutes > 30)
                                        {
                                            xDtable[4] = (Convert.ToDouble(ts.Hours.ToString()) + 1).ToString();
                                        }
                                        else
                                        {
                                            xDtable[4] = (Convert.ToDouble(ts.Hours.ToString()) + 0.5).ToString();
                                        }

                                        dr = dtWPA60.Select("PA60002 = '" + dt.Rows[i]["xP01"].ToString() + "'");
                                        if (dr.Length > 0)
                                        {
                                            for (int x = 0; x < dr.Length; x++)
                                            {
                                                sWPA60Time = Convert.ToDateTime(dtWPA60.Rows[dtWPA60.Rows.IndexOf(dr[x])]["PA60007"].ToString());
                                                eWPA60Time = Convert.ToDateTime(dtWPA60.Rows[dtWPA60.Rows.IndexOf(dr[x])]["PA60008"].ToString());
                                                if (sWPA60Time < x20NowTime && eWPA60Time >= x20NowTime)
                                                {
                                                    xDtable[5] = "Y";
                                                    break;
                                                }
                                            }
                                            if (xDtable[5] == "")
                                            {
                                                xDtable[5] = "N";
                                            }
                                        }
                                        else
                                        {
                                            xDtable[5] = "Y";
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                        else
                        {
                            //找現場人員(班表)出勤代碼位置
                            dr = dtWPB29.Select("PB29003 = '" + dt.Rows[i]["xP01"].ToString() + "'");
                            if (dr.Length > 0)
                            {
                                //找現場人員(班表)出勤代碼
                                xPA51020 = dtWPB29.Rows[dtWPB29.Rows.IndexOf(dr[0])]["PB29005"].ToString();
                                xDtable[6] = xPA51020;
                                xDtable[7] = dtWPB29.Rows[dtWPB29.Rows.IndexOf(dr[0])]["PA20003"].ToString();

                                for (int j = 0; j < x20Chart.GetUpperBound(0) - 1; j++)
                                {
                                    if (x20Chart[j, 0] == xPA51020)
                                    {
                                        xL01 = dt.Rows[i]["L01"].ToString();
                                        xL01 = xL01.Substring(0, xL01.IndexOf(" "));
                                        x20TimeChart = Convert.ToDateTime(xL01 + " " + x20Chart[j, 1].ToString());
                                        x20NowTime = Convert.ToDateTime(dt.Rows[i]["L01"].ToString());
                                        if (DateTime.Compare(x20NowTime.AddMinutes(-10), x20TimeChart) > 0)
                                        {
                                            ts = x20NowTime - x20TimeChart;
                                            if (ts.Minutes > 30)
                                            {
                                                xDtable[4] = (Convert.ToDouble(ts.Hours.ToString()) + 1).ToString();
                                            }
                                            else
                                            {
                                                xDtable[4] = (Convert.ToDouble(ts.Hours.ToString()) + 0.5).ToString();
                                            }

                                            dr = dtWPA60.Select("PA60002 = '" + dt.Rows[i]["xP01"].ToString() + "'");
                                            if (dr.Length > 0)
                                            {
                                                for (int x = 0; x < dr.Length; x++)
                                                {
                                                    sWPA60Time = Convert.ToDateTime(dtWPA60.Rows[dtWPA60.Rows.IndexOf(dr[x])]["PA60007"].ToString());
                                                    eWPA60Time = Convert.ToDateTime(dtWPA60.Rows[dtWPA60.Rows.IndexOf(dr[x])]["PA60008"].ToString());
                                                    if (sWPA60Time < x20NowTime && eWPA60Time >= x20NowTime)
                                                    {
                                                        xDtable[5] = "Y";
                                                        break;
                                                    }
                                                }
                                                if (xDtable[5] == "")
                                                {
                                                    xDtable[5] = "N";
                                                }
                                            }
                                            else
                                            {
                                                xDtable[5] = "Y";
                                            }
                                        }
                                        break;
                                    }
                                }
                            }
                            else
                            {
                                //沒有找到班表
                                xDtable[4] = "No 班表";
                            }
                        }
                        string sss = "0";
                        //                        dtWPA51.Rows.IndexOf(dr[0]);
                    }

                    myDatatable.Rows.Add(xDtable);
                    cadno = dt.Rows[i][9].ToString();
                    cadTime = dt.Rows[i][1].ToString().Substring(0, dt.Rows[i][1].ToString().IndexOf(" "));

                    dr = dt.Select("P01 = '" + cadno + "' AND l01 >= '" + cadTime + "' AND l01 < '" + Convert.ToDateTime(cadTime).AddDays(1).ToString("yyyy-MM-dd") + "'");
                    if (dr.Length > 0)
                    {
                        for (int xd = 0; xd < dr.Length; xd++)
                        {
                            dt.Rows[dt.Rows.IndexOf(dr[xd])]["xCheck"] = "V";
                        }
                    }
                    //}
                }
                myDatatable.DefaultView.Sort = "P01, l01";
                myDatatable = myDatatable.DefaultView.ToTable();

                string result = Newtonsoft.Json.JsonConvert.SerializeObject(myDatatable);
                dt = null;
                context.Response.Write(result);
            }
            else
            {
                context.Response.Write("");
            }
        }
        public void Showdep(HttpContext context)
        {
            string xShow = WebPublic.GetJsonClient("xShow", context);
            string userid = WebPublic.GetJsonClient("userid", context);
            string zfbNO = WebPublic.GetJsonClient("zfbNO", context);
            string SQL = "";
            DataTable dt;
            string result="";

            if (xShow != "003")
            {
                SQL = "SELECT mf200, hrs, CONTEN FROM Winton_mf2000";
                SQL += " WHERE id = '" + zfbNO + "'";
                dt = DBSQLHELP_TEST.ExecuteQuery(SQL, "tbiConnectionString");
                if (dt.Rows.Count > 0)
                {
                    List<string> STN = new List<string>();

                    //STN = WebPublic.hrLevel(dt.Rows[0][1].ToString());

                    STN.Add(dt.Rows[0]["hrs"].ToString() + ";" + dt.Rows[0]["CONTEN"].ToString());
                    STN.Sort();

                    List<student_Item> student_Items = new List<student_Item>();
                    string[] xSTN;
                    student_Items.Add(new student_Item() { PA11002 = "ALL", PA11003 = "ALL" });
                    for (int i = 0; i < STN.Count; i++)
                    {
                        xSTN = STN[i].Split(';');
                        student_Items.Add(new student_Item() { PA11002 = xSTN[0], PA11003 = xSTN[1] });
                    }

                    //[{\"PA11002\":\"ALL\",\"PA11003\":\"ALL\"},{\"PA11002\":\"001\",\"PA11003\":\"管理部\"}]
                    result = Newtonsoft.Json.JsonConvert.SerializeObject(student_Items);
                }
            }
            else
            {
                SQL = "select PA11002, PA11003 from WPA11";
                SQL += " WHERE PA11001 = '001'";
                SQL += " ORDER BY PA11002";
                dt = WZDBSQLHELP.ExecuteQuery(SQL);
                if (dt.Rows.Count > 1)
                {
                    DataRow dr;
                    dr = dt.NewRow();
                    dr[0] = "ALL";
                    dr[1] = "ALL";
                    dt.Rows.InsertAt(dr, 0);
                    dr = null;
                }
                result = Newtonsoft.Json.JsonConvert.SerializeObject(dt);

            }
            context.Response.Write(result);
        }

        public void Showdep_bak(HttpContext context)
        {
            string xShow = context.Request["xShow"].ToString();
            string userid = context.Request["userid"].ToString();

            string xdep = "";
            //xUcard = " and (U.Username ='" + Ucard.Replace(",", "' or U.Username = '") + "')";

            string SQL;

            SQL = "select PA11002, PA11003 from WPA11";
            SQL += " WHERE PA11001 = '001'";
            if (xShow != "003")
            {
                xdep = xSendClasss(userid);
                if (xdep !="")
                {
                    SQL += " AND (PA11002 ='" + xdep.Replace(",", "' or PA11002 = '") + "')";
                }
                else
                {
                    SQL += " AND PA11002 = ''";
                }
            }

            SQL += " ORDER BY PA11002";
            DataTable dt = WZDBSQLHELP.ExecuteQuery(SQL);
            if (dt.Rows.Count>1)
            {
                DataRow dr;
                dr = dt.NewRow();
                dr[0] = "ALL";
                dr[1] = "ALL";
//                dt.Rows.Add(dr);
                
                dt.Rows.InsertAt(dr, 0);
                dr = null;
            }
            string result = Newtonsoft.Json.JsonConvert.SerializeObject(dt);
            dt = null;
            context.Response.Write(result);

        }
        //排班 + 考勤
        public void checkwork(HttpContext context)
        {
            string SQL = "";
            DataTable dt_cw = new DataTable(); //打卡記錄
            DataTable dt_wz = new DataTable(); //文中排班
            DataTable dt_noschedule = new DataTable(); //文中員工是否屬於排班
            DataTable xdt_cw = new DataTable();         //沒排班有加班費

            string txt = context.Request["txt"].ToString(); //判斷是否匯出txt 1=txt
            int all = int.Parse(context.Request["all"].ToString()); //全一/全二
            int addmin = int.Parse(context.Request["addmin"].ToString()); //使用者key 緩衝時間
            int radombuffer = int.Parse(context.Request["radombuffer"].ToString()); //使用者key 下班亂數時間區間
            string datetime_s = context.Request["start"].ToString(); //"2016-11-01 10:00:00";
            string datetime_e = context.Request["end"].ToString(); //"2016-11-02 10:00:00";

            string date_s = DateTime.Parse(datetime_s).ToString("yyyy-MM-dd"); //"2016-11-01";
            string date_e = DateTime.Parse(datetime_e).ToString("yyyy-MM-dd");//"2016-11-02";
            string Ucard = context.Request["Ucard"].ToString();                 //00819,00966
            string xUcard = Ucard;

            if (Ucard != "")
            {
                //(m1.p01='00819' or m1.p01='00966')    00819,00966
                if (Ucard.Substring(Ucard.Length - 1, 1) == ",")
                {
                    Ucard = Ucard.Substring(0, Ucard.Length - 1);

                }
                Ucard = " and (p.p01='" + Ucard.Replace(",", "' or p.p01='") + "')";
            }
            logger.Debug("取打卡記錄");
            //取打卡記錄

            SQL = "SELECT CASE WHEN SUBSTRING(P01,1,1) = '0' THEN SUBSTRING(P01,2,4) ELSE P01 END P01,L.* ";
            SQL += " FROM L03 L LEFT JOIN P00 P ON L.l06 = P08";
            SQL += " WHERE 1=1";
            SQL += " And L12 IN ( '238','283','291','292','293','294','295','296','300','301','302','304','305','306','312','313','314','315','316','317','324','325','326','327')";
            SQL += " AND L07 != '不明' and  (convert(nvarchar(255),l08) like '%正常進出%' or convert(nvarchar(255),l08) like '%指紋進出%' )";
            SQL += " AND L01 BETWEEN '{0}' AND '{1}' {2}";
            //            SQL += " order by P.P01, L.l01";

            SQL = string.Format(SQL, datetime_s, datetime_e, Ucard);
            dt_cw = DBSQLHELP.ExecuteQuery(SQL);

            dt_cw.DefaultView.Sort = "P01, l01";
            dt_cw = dt_cw.DefaultView.ToTable();


            //            SQL = string.Format(@"SELECT CASE WHEN SUBSTRING(P01,1,1) = '0' THEN SUBSTRING(P01,2,4) ELSE P01 END P01,L.* FROM L03 L
            //            LEFT JOIN P00 P ON L.l06 = P08
            //            WHERE L02 IN ('A-1F-ATT','D棟1F(前)考勤機','D棟1F(後)考勤機','D棟2F(前)考勤機','D棟2F(後)考勤機','D棟3F(前)考勤機','D棟3F(後)考勤機'
            //                         ,'C棟1F(前)考勤機','C棟1F(後)考勤機','C棟2F(前)考勤機','C棟2F(後)考勤機','C棟3F(前)考勤機','C棟3F(後)考勤機'
            //                         ,'B棟1F(前)考勤機','B棟1F(後)考勤機','B棟2F(前)考勤機','B棟2F(後)考勤機','B棟3F(前)考勤機','B棟3F(後)考勤機')
            //            AND L07 != '不明' and convert(nvarchar(255),l08) = '正常進出'
            //            AND L01 BETWEEN '{0}' AND '{1}' {2} order by P.P01, L.l01", datetime_s, datetime_e, Ucard);

            //            dt_cw = DBSQLHELP.ExecuteQuery(SQL);

            var cw = from row in dt_cw.AsEnumerable()
                     select new
                     {
                         empid = row.Field<string>("P01"),
                         lin = row.Field<int>("L00"),
                         time = row.Field<DateTime>("L01"),
                         macloc = row.Field<string>("L02"),
                         cardno = row.Field<string>("L06"),
                         empname = row.Field<string>("L07"),
                         empdep = row.Field<string>("L15"),
                     };
            logger.Debug("取班表");
            //取班表
            SQL = string.Format(@"SELECT * FROM WPB29 WHERE PB29001 = '001' and PB29002 BETWEEN '{0}' AND '{1}'", date_s, date_e);
            dt_wz = WZDBSQLHELP.ExecuteQuery(SQL);

            //2016-02-06 新增----------------------------------------------------------------------------
            SQL = "select MAX(PB29995) from WPB29";
            DataTable xdt = WZDBSQLHELP.ExecuteQuery(SQL);
            int xPB29995 = int.Parse(xdt.Rows[0][0].ToString());
            xdt = null;
            logger.Debug(xPB29995.ToString());
            //            TimeSpan ts1 = DateTime.Parse(datetime_e) - DateTime.Parse(datetime_s);
            TimeSpan ts1 = DateTime.Parse(date_e) - DateTime.Parse(date_s);
            DateTime DateT_s = DateTime.Parse(date_s);

            SQL = "SELECT M.PA51002,M.PA51004,M.PA51019,M.PA51025, M.PA51020";
            SQL += " FROM WPA51 M INNER JOIN WPA15 M1 ON M.PA51017 = M1.PA15002";
            SQL += " WHERE M.PA51001 = '001' AND M.PA51019 = '0' AND M.PA51025 IS NULL";
            SQL += " AND M.PA51014 IN ('005', '006', '008', '010', '011', '012', '013', '014', '015', '016', '025', '028', '029', '030', '031', '032', '033', '034', '035', '036', '037', '041', '042', '043', '049', '054')";
            SQL += " AND M1.PA15001 = '001' AND M1.PA15002 IN ('005', '006', '007', '008', '009')";
            SQL += " order by M.PA51002";

            xdt_cw = WZDBSQLHELP.ExecuteQuery(SQL);

            //找國定假日----------------------------------------------------------------------------------------------------------------------------
            string xPA51020 = "";
            string xSQL = "";
            DateTime xDate_s = DateTime.Parse(date_s + " 00:00:00.000");
            DateTime xDate_e = DateTime.Parse(date_e + " 23:59:59.997");

            DataTable xWPA18 = new DataTable();
            //            xSQL = "select count(*) from WPA18 where 1=1 and PA18002 BETWEEN '" + xDate_s.ToString() + "' AND '" + xDate_e.ToString() + "'";
            xSQL = "SELECT PA18002  FROM WPA18";
            xSQL += " WHERE PA18001 = '001' AND PA18002 BETWEEN '" + date_s + " 00:00:00.000' AND  '" + date_e + " 23:59:59.997'";
            xWPA18 = WZDBSQLHELP.ExecuteQuery(xSQL);

            logger.Debug("xDate_s=" + xDate_s.ToString() + ";" + "xDate_e=" + xDate_e.ToString());
            logger.Debug("xdt_cw.Rows.Count = " + xdt_cw.Rows.Count.ToString());
            DataRow[] dr;
            DataRow[] xdr;
            try
            {

                if (xdt_cw.Rows.Count > 0)
                {
                    for (int x = 0; x < xdt_cw.Rows.Count; x++)
                    {
                        xPA51020 = xdt_cw.Rows[x][4].ToString();

                        if (xdt_cw.Rows[x][0].ToString() == "0625")
                        {
                            string sss = "0";
                        }
                        dr = dt_wz.Select("PB29003 = '" + xdt_cw.Rows[x][0].ToString() + "'");
                        logger.Debug("x=" + x + ";dr.Length=" + dr.Length);
                        if (dr.Length == 0)
                        {
                            //2017-03-29 新增 比對是否有打卡,有打才列入-------------------------------------------------------------------------------
                            dr = dt_cw.Select("P01 = '" + xdt_cw.Rows[x][0].ToString() + "'");
                            //------------------------------------------------------------------------------------------------------------------------
                            if (dr.Length > 0)
                            {
                                for (int xx = 0; xx <= int.Parse(ts1.Days.ToString()); xx++)
                                {
                                    xPB29995 += 1;

                                    //沒有國定假日,就判斷是不是六,日上班
                                    if (xWPA18.Rows.Count == 0)
                                    {
                                        switch (int.Parse(DateT_s.DayOfWeek.ToString("d")))
                                        {
                                            case 0:
                                            case 6:
                                                dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "3", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                                break;
                                            default:
                                                dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "1", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                                break;
                                        }
                                    }
                                    else
                                    {
                                        //有國定假日,就判斷是不是上班日 = 國定假日
                                        xdr = xWPA18.Select("PA18002 = '" + xDate_s + "'");
                                        if (xdr.Length > 0)     //國定假日
                                        {
                                            dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "3", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                        }
                                        else
                                        {
                                            dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "1", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                        }
                                    }
                                    //                                }
                                    xDate_s = xDate_s.AddDays(1);
                                    xDate_e = xDate_e.AddDays(1);
                                    DateT_s = DateT_s.AddDays(1);
                                    xdr = null;
                                    //                                xdr = null;
                                }
                            }
                        }
                        logger.Debug("x=" + x + ";dr.Length=END");
                        dr = null;
                        DateT_s = DateTime.Parse(date_s);
                    }
                }
            }
            catch (Exception ex)
            {
                logger.Debug("ex=" + ex.Message);
                HttpContext.Current.Response.End();
                throw;
            }

            logger.Debug("wz");
            var wz = from row in dt_wz.AsEnumerable()
                     select new
                     {
                         time = row.Field<DateTime>("PB29002"),
                         empid = row.Field<string>("PB29003"),
                         kind = row.Field<int>("PB29004"), //排班代碼
                         type = row.Field<string>("PB29005"), //班別
                     };

            ////取文中人員屬於非排班者
            //            SQL = string.Format(@"SELECT PA51002,PA51004,PA51019,PA51025 FROM WPA51 WHERE PA51001 = '001' AND PA51019 = '0' AND PA51025 IS NULL");

            //20170206 修改--------------------------
            SQL = string.Format(@"SELECT M.PA51002,M.PA51004,M.PA51019,M.PA51025 FROM WPA51 M INNER JOIN WPA15 M1 ON M.PA51017 = M1.PA15002 WHERE M.PA51001 = '001' AND M.PA51019 = '0' AND M.PA51025 IS NULL AND M1.PA15001 = '001' AND M1.PA15002 not IN ('005', '006', '007', '008', '009')");
            //---------------------------------------
            dt_noschedule = WZDBSQLHELP.ExecuteQuery(SQL);
            var noschedule = from row in dt_noschedule.AsEnumerable()
                             select new
                             {
                                 empid = row.Field<string>("PA51002"),
                                 kind = row.Field<int>("PA51019"), //是否屬排班 0-非排班 1-排班
                             };

            DataTable all_1 = new DataTable(); //正常
            all_1.Columns.Add("EMPID");
            all_1.Columns.Add("EMPNAME");
            all_1.Columns.Add("DEP");
            all_1.Columns.Add("TIME");
            all_1.Columns.Add("TYPE");
            all_1.Columns.Add("CARDNO");
            all_1.Columns.Add("ALLKIND");

            DataTable all_2 = new DataTable(); //加班
            all_2.Columns.Add("EMPID");
            all_2.Columns.Add("EMPNAME");
            all_2.Columns.Add("DEP");
            all_2.Columns.Add("TIME");
            all_2.Columns.Add("TYPE");
            all_2.Columns.Add("CARDNO");
            all_2.Columns.Add("ALLKIND");

            Random rd = new Random();
            string morning_s = "06:30"; //早班上班時間 + 緩衝時間
            string morning_e = "17:00"; //正常早班下班時間
            string night_s = "18:30"; //晚班上班時間 + 緩衝時間
            string night_e = "05:00"; //正常晚班下班時間
            string evening_s = "16:00"; //中班上班時間
            string evening_e = "02:00"; //正常中班下班時間

            string Nevening_s = "15:00"; //新中班上班時間
            string Nevening_e = "00:00"; //新正常中班下班時間

            string xStarTime = "00:00:00.000";
            string xEndTime = "23:59:59.997";

            string morning_buffer = DateTime.Parse(morning_e).AddMinutes(addmin).TimeOfDay.ToString(); //早班下班緩衝時間
            string night_buffer = DateTime.Parse(night_e).AddMinutes(addmin).TimeOfDay.ToString(); //晚班下班緩衝時間
            string evening_buffer = DateTime.Parse(evening_e).AddMinutes(addmin).TimeOfDay.ToString(); //中班下班緩衝時間
            string Nevening_buffer = DateTime.Parse(Nevening_e).AddMinutes(addmin).TimeOfDay.ToString(); //中班下班緩衝時間

            string morning_extra = "19:30"; //早班加班時間開始
            string night_extra = "07:30"; //晚班加班時間開始

            var morning = new List<string> { "001", "004", "014", "016", "018" }; //早班代碼
            var night = new List<string> { "002", "007", "012", "013", "015", "017", "019" }; //晚班代碼
            var evening = new List<string> { "003", "005", "008", "022", "023", "025", "028", "029" }; //中班代碼

            try
            {
                foreach (var schedule in wz)
                {
                    logger.Debug("foreach");
                    if (schedule.empid == "0625")
                    {
                        string HHHH = "";
                    }

                    //早班
                    if (morning.Contains(schedule.type))
                    {
                        if (schedule.kind == 1) //1→排班
                        {
                            //判斷正常早班(無加班)
                            var filter = cw.Where(
                                w => w.empid == schedule.empid &&
                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + morning_s) && w.time <= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + morning_buffer)));
                            foreach (var data in filter)
                            {
                                add_all(all_1, data.empid, data.empname, data.empdep, data.time, "早班", data.cardno, "全一");
                            }

                            //判斷正常早班加班
                            var filter_extra = cw.Where(
                                w => w.empid == schedule.empid && w.time.Date == schedule.time.Date &&
                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + morning_buffer)));
                            foreach (var data in filter_extra)
                            {
                                //全一 //下班時間亂數
                                string radomtime = schedule.time.ToString("yyyy-MM-dd ") + DateTime.Parse(morning_extra).AddMinutes(rd.Next(0, radombuffer)).TimeOfDay.ToString();
                                add_all(all_1, data.empid, data.empname, data.empdep, DateTime.Parse(radomtime), "早班", data.cardno, "全一");
                                //全二
                                add_all(all_2, data.empid, data.empname, data.empdep, DateTime.Parse(data.time.ToString("yyyy-MM-dd ") + "19:30"), "早班", data.cardno, "全二");
                                add_all(all_2, data.empid, data.empname, data.empdep, data.time, "早班", data.cardno, "全二");
                            }

                        }
                        else if (schedule.kind == 3) //3→排休
                        {
                            //判斷早班為排休卻有打卡記錄→加班
                            //2017-03-15    修正所有班別排休都算在全2
                            var filter = cw.Where(
                                w => w.empid == schedule.empid &&
                                (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + xStarTime) && w.time <= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + xEndTime))
                            );

                            //                            var filter = cw.Where(
                            //                                w => w.empid == schedule.empid &&
                            //                                (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + morning_s) && w.time <= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + morning_buffer))
                            //                            );
                            foreach (var data in filter)
                            {
                                add_all(all_2, data.empid, data.empname, data.empdep, data.time, "早班", data.cardno, "全二");
                            }
                        }
                    }
                    //晚班
                    if (night.Contains(schedule.type))
                    {
                        if (schedule.empid == "0625")
                        {
                            string HHHH1 = "";
                        }
                        if (schedule.kind == 1)//1→排班
                        {
                            //判斷正常晚班(無加班)
                            var filter = cw.Where(
                                w => w.empid == schedule.empid &&
                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + night_s) &&
                            w.time <= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + night_buffer)));
                            foreach (var data in filter)
                            {
                                add_all(all_1, data.empid, data.empname, data.empdep, data.time, "晚班", data.cardno, "全一");
                            }

                            //判斷正常晚班加班
                            var filter_extra = cw.Where(
                                w => w.empid == schedule.empid && w.time.Date == schedule.time.AddDays(1).Date &&
                            (w.time >= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + night_buffer)));
                            foreach (var data in filter_extra)
                            {
                                //全一 //下班時間亂數
                                string radomtime = schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + DateTime.Parse(night_extra).AddMinutes(rd.Next(0, radombuffer)).TimeOfDay.ToString();
                                add_all(all_1, data.empid, data.empname, data.empdep, DateTime.Parse(radomtime), "晚班", data.cardno, "全一");
                                //全二
                                add_all(all_2, data.empid, data.empname, data.empdep, DateTime.Parse(data.time.ToString("yyyy-MM-dd ") + "07:30"), "晚班", data.cardno, "全二");
                                add_all(all_2, data.empid, data.empname, data.empdep, data.time, "晚班", data.cardno, "全二");
                            }
                        }
                        else if (schedule.kind == 3)//3→排休
                        {
                            //判斷晚班為排休卻有打卡記錄→加班
                            var filter = cw.Where(w => w.empid == schedule.empid &&
                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + xStarTime) && w.time <= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + xEndTime)));

                            //                            var filter = cw.Where(w => w.empid == schedule.empid &&
                            //                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + night_s) && w.time <= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + night_buffer)));
                            foreach (var data in filter)
                            {
                                add_all(all_2, data.empid, data.empname, data.empdep, data.time, "晚班", data.cardno, "全二");
                            }
                        }
                    }
                    //中班
                    if (evening.Contains(schedule.type))
                    {
                        if (schedule.kind == 1)//1→排班
                        {
                            //判斷正常中班(無加班)
                            var filter = cw.Where(w => w.empid == schedule.empid &&
                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + evening_s) && w.time <= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + evening_buffer)));
                            foreach (var data in filter)
                            {
                                add_all(all_1, data.empid, data.empname, data.empdep, data.time, "中班", data.cardno, "全一");
                            }
                        }
                        else if (schedule.kind == 3)//3→排休
                        {
                            //判斷晚班為排休卻有打卡記錄→加班
                            var filter = cw.Where(w => w.empid == schedule.empid &&
                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + xStarTime) && w.time <= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + xEndTime)));

                            //                            var filter = cw.Where(w => w.empid == schedule.empid &&
                            //                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + evening_s) && w.time <= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + evening_buffer)));
                            foreach (var data in filter)
                            {
                                add_all(all_2, data.empid, data.empname, data.empdep, data.time, "中班", data.cardno, "全二");
                            }
                        }
                    }
                    //新中班
                    if (evening.Contains(schedule.type))
                    {
                        if (schedule.kind == 1)//1→排班
                        {
                            //判斷正常中班(無加班)
                            var filter = cw.Where(w => w.empid == schedule.empid &&
                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + Nevening_s) && w.time <= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + Nevening_buffer)));
                            foreach (var data in filter)
                            {
                                add_all(all_1, data.empid, data.empname, data.empdep, data.time, "中班", data.cardno, "全一");
                            }
                        }
                        else if (schedule.kind == 3)//3→排休
                        {
                            //判斷晚班為排休卻有打卡記錄→加班
                            var filter = cw.Where(w => w.empid == schedule.empid &&
                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + xStarTime) && w.time <= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + xEndTime)));

                            //                            var filter = cw.Where(w => w.empid == schedule.empid &&
                            //                            (w.time >= DateTime.Parse(schedule.time.ToString("yyyy-MM-dd ") + Nevening_s) && w.time <= DateTime.Parse(schedule.time.AddDays(1).ToString("yyyy-MM-dd ") + Nevening_buffer)));
                            foreach (var data in filter)
                            {
                                add_all(all_2, data.empid, data.empname, data.empdep, data.time, "中班", data.cardno, "全二");
                            }
                        }
                    }
                }

                logger.Debug("無排班");
                //無排班→ 全一
                //在不是排班者中取得對應打卡資料
                foreach (var row in noschedule)
                {
                    var filter = cw.Where(w => w.empid == row.empid);
                    foreach (var data in filter)
                    {
                        add_all(all_1, data.empid, data.empname, data.empdep, data.time, "非排班", data.cardno, "全一");
                    }
                }

                //////判斷有打卡 沒有排班
                ////var data_intersect = cw.Select(s => s.empid).Except(wz.Select(s => s.empid));
                ////foreach (var data in data_intersect)
                ////{
                ////    var filter = cw.Where(w => w.empid == data);
                ////    foreach (var data2 in filter)
                ////    {
                ////        add_all(all_1, data2.empid, data2.empname, data2.empdep, data2.time, "非排班", data2.cardno);
                ////    }
                ////}
                logger.Debug("OK");

            }
            catch (Exception ex)
            {
                logger.Debug(ex.Message);
                HttpContext.Current.Response.End();
                throw;
            }


            if (txt == "1")
            {
                ////匯出TXT
                string filename_1 = HttpUtility.UrlEncode("全1__" + DateTime.Parse(date_s).ToString("yyyyMMdd") + "-" + DateTime.Parse(date_e).ToString("yyyyMMdd"));
                string filename_2 = HttpUtility.UrlEncode("全2__" + DateTime.Parse(date_s).ToString("yyyyMMdd") + "-" + DateTime.Parse(date_e).ToString("yyyyMMdd"));

                if (all == 1)
                {
                    StringBuilder sb1 = new StringBuilder();
                    for (int i = 0; i < all_1.Rows.Count; i++)
                    {
                        string output = all_1.Rows[i]["CARDNO"].ToString() + " " + DateTime.Parse(all_1.Rows[i]["TIME"].ToString()).ToString("yyyyMMddHHmmss") + " 1 1 001";
                        sb1.Append(output);
                        sb1.Append("\r\n");
                    }
                    HttpContext.Current.Response.Clear();
                    HttpContext.Current.Response.ClearHeaders();
                    HttpContext.Current.Response.AddHeader("Content-Length", sb1.ToString().Length.ToString());
                    HttpContext.Current.Response.ContentType = "text/plain";
                    HttpContext.Current.Response.AppendHeader("Content-Disposition", "attachment;filename=" + filename_1 + ".txt");
                    HttpContext.Current.Response.Write(sb1.ToString());
                }
                else if (all == 2)
                {
                    StringBuilder sb2 = new StringBuilder();
                    for (int i = 0; i < all_2.Rows.Count; i++)
                    {
                        string output = all_2.Rows[i]["CARDNO"].ToString() + " " + DateTime.Parse(all_2.Rows[i]["TIME"].ToString()).ToString("yyyyMMddHHmmss") + " 1 1 001";
                        sb2.Append(output);
                        sb2.Append("\r\n");
                    }
                    HttpContext.Current.Response.Clear();
                    HttpContext.Current.Response.ClearHeaders();
                    HttpContext.Current.Response.AddHeader("Content-Length", sb2.ToString().Length.ToString());
                    HttpContext.Current.Response.ContentType = "text/plain";
                    HttpContext.Current.Response.AppendHeader("Content-Disposition", "attachment;filename=" + filename_2 + ".txt");
                    HttpContext.Current.Response.Write(sb2.ToString());
                }

                HttpContext.Current.Response.End();
            }
            else
            {
                all_1.Merge(all_2);
                string result = Newtonsoft.Json.JsonConvert.SerializeObject(all_1);
                context.Response.Write(result);
            }
        }


        //排班 + 考勤
        public void checkworkTEST(HttpContext context)
        {
            string SQL = "";
            DataTable dt_cw = new DataTable(); //打卡記錄
            DataTable ddt_cw = new DataTable(); //組別_打卡記錄

            DataTable dt_wz = new DataTable(); //文中排班
            DataTable dt_noschedule = new DataTable(); //文中員工是否屬於排班
            DataTable xdt_cw = new DataTable();         //沒排班有加班費

            string txt = context.Request["txt"].ToString(); //判斷是否匯出txt 1=txt
            int all = int.Parse(context.Request["all"].ToString()); //全一/全二
            int addmin = int.Parse(context.Request["addmin"].ToString()); //使用者key 緩衝時間
            int radombuffer = int.Parse(context.Request["radombuffer"].ToString()); //使用者key 下班亂數時間區間
            string datetime_s = context.Request["start"].ToString(); //"2016-11-01 10:00:00";
            string datetime_e = context.Request["end"].ToString(); //"2016-11-02 10:00:00";

            string date_s = DateTime.Parse(datetime_s).ToString("yyyy-MM-dd"); //"2016-11-01";
            string date_e = DateTime.Parse(datetime_e).ToString("yyyy-MM-dd");//"2016-11-02";
            string Ucard = context.Request["Ucard"].ToString();                 //00819,00966
            string xUcard = Ucard;
            string coddep = GetJsonClient("coddep", context);       //組別

            if (Ucard != "")
            {
                //(m1.p01='00819' or m1.p01='00966')    00819,00966
                if (Ucard.Substring(Ucard.Length - 1, 1) == ",")
                {
                    Ucard = Ucard.Substring(0, Ucard.Length - 1);

                }
                Ucard = "and (p.p01='" + Ucard.Replace(",", "' or p.p01='") + "')";
            }
            logger.Debug("取打卡記錄");
            //取打卡記錄
            SQL = "SELECT CASE WHEN SUBSTRING(P01,1,1) = '0' THEN SUBSTRING(P01,2,4) ELSE P01 END P01, ";
            SQL += " L00, L01, L02, L06, L07, L15";
            SQL += " FROM L03 L LEFT JOIN P00 P ON L.l06 = P08";
            SQL += " WHERE 1=1";
            //            SQL += " And L12 IN ( '238','283','291','292','293','294','295','296','300','301','302','304','305','306','312','313','314','315','316','317','324','325','326','327')";
            SQL += " And L12 IN ( '238','283','291','292','293','294','295','296','300','301','302','304','305','306','312','313','314','315','316','317','324','325','326','327','329','330','331','332','333','334','335','336','337','338','339','340','341','342','343')";
            //            SQL += " AND L07 != '不明' and convert(nvarchar(255),l08) like '%正常進出%'";
            SQL += " AND L07 != '不明' and (convert(nvarchar(255),l08) like '%正常進出%' or convert(nvarchar(255),l08) like '%指紋進出%' )";
            SQL += " AND L01 BETWEEN '{0}' AND '{1}' {2}";
            //            SQL += " order by P.P01, L.l01";

            SQL = string.Format(SQL, datetime_s, datetime_e, Ucard);
            ddt_cw = DBSQLHELP.ExecuteQuery(SQL);

            //-------------------------------------------------------------------------------------------
            //20170603 新增組別
            if (coddep != "")
            {
                //                dt_cw.TableName = "";
                //                dt_cw.Columns.Add("P01");     //0
                //                dt_cw.Columns.Add("L00");     //1
                //                dt_cw.Columns.Add("L01");     //2
                //                dt_cw.Columns.Add("L02");     //3
                //                dt_cw.Columns.Add("L06");     //4
                //                dt_cw.Columns.Add("L07");     //5
                //                dt_cw.Columns.Add("L15");     //6
                dt_cw = ddt_cw.Copy();
                dt_cw.Clear();

                string[] xDtable = new string[7];
                DataRow row;

                DataTable xddt = new DataTable();
                SQL = "SELECT PA51002, PA51004 FROM WPA51";
                SQL += " WHERE PA51014 = '" + coddep + "'";
                SQL += " AND PA51001 = '001' AND PA51025 IS NULL";
                xddt = WZDBSQLHELP.ExecuteQuery(SQL);
                if (xddt.Rows.Count > 0)
                {
                    DataRow[] findrows;
                    int xr = 0;
                    int i = 0;

                    foreach (DataRow DRow in xddt.Rows)
                    {
                        findrows = ddt_cw.Select("P01 = '" + DRow[0].ToString() + "'");
                        if (findrows.Length > 0)
                        {
                            for (i = 0; i < findrows.Length; i++)
                            {
                                xr = ddt_cw.Rows.IndexOf(findrows[i]);

                                //                                xDtable[0] = ddt_cw.Rows[xr]["P01"].ToString();
                                //                                xDtable[1] = ddt_cw.Rows[xr]["L00"].ToString();
                                //                                xDtable[2] = ddt_cw.Rows[xr]["L01"].ToString();
                                //                                xDtable[3] = ddt_cw.Rows[xr]["L02"].ToString();
                                //                                xDtable[4] = ddt_cw.Rows[xr]["L06"].ToString();
                                //                                xDtable[5] = ddt_cw.Rows[xr]["L07"].ToString();
                                //                                xDtable[6] = ddt_cw.Rows[xr]["L15"].ToString();
                                //                                dt_cw.Rows.Add(xDtable);
                                row = dt_cw.NewRow();
                                row["P01"] = ddt_cw.Rows[xr]["P01"].ToString();
                                row["L00"] = ddt_cw.Rows[xr]["L00"].ToString();
                                row["L01"] = ddt_cw.Rows[xr]["L01"].ToString();
                                row["L02"] = ddt_cw.Rows[xr]["L02"].ToString();
                                row["L06"] = ddt_cw.Rows[xr]["L06"].ToString();
                                row["L07"] = ddt_cw.Rows[xr]["L07"].ToString();
                                row["L15"] = ddt_cw.Rows[xr]["L15"].ToString();
                                dt_cw.Rows.Add(row);

                            }
                        }
                    }
                    dt_cw.DefaultView.Sort = "P01, l01";
                    dt_cw = dt_cw.DefaultView.ToTable();
                }
            }
            else
            {
                dt_cw = ddt_cw.Copy();
                dt_cw.DefaultView.Sort = "P01, l01";
                dt_cw = dt_cw.DefaultView.ToTable();
            }

            //-------------------------------------------------------------------------------------------
            //            dt_cw.DefaultView.Sort = "P01, l01";
            //            dt_cw = dt_cw.DefaultView.ToTable();

            var cw = from row in dt_cw.AsEnumerable()
                     select new
                     {
                         empid = row.Field<string>("P01"),
                         lin = row.Field<int>("L00"),
                         time = row.Field<DateTime>("L01"),
                         macloc = row.Field<string>("L02"),
                         cardno = row.Field<string>("L06"),
                         empname = row.Field<string>("L07"),
                         empdep = row.Field<string>("L15"),
                     };
            logger.Debug("取班表");
            //取班表
            string xxdate_s = DateTime.Parse(date_s).AddDays(-1).Date.ToString("yyyy-MM-dd");
            SQL = string.Format(@"SELECT * FROM WPB29 WHERE PB29001 = '001' and PB29002 BETWEEN '{0}' AND '{1}'", xxdate_s, date_e);
            //20170602 修正版表要抓前一天,不然夜班會有問題
            //            SQL = string.Format(@"SELECT * FROM WPB29 WHERE PB29001 = '001' and PB29002 BETWEEN '{0}' AND '{1}'", date_s, date_e);
            dt_wz = WZDBSQLHELP.ExecuteQuery(SQL);

            //2017/11/11特休加班------------------------------------------------------------------------------------------------------------------------
            DataRow[] W60dr;
            string WPA60SQL = "";

            string TWPA60;
            DateTime SPA60007;
            DateTime EPA60008;

            DataTable xWPA60 = new DataTable();
            WPA60SQL = "select M.PA60002, M.PA60006, M.PA60007, M.PA60008, M1.PB29005 ";
            WPA60SQL += " FROM WPA60 M LEFT JOIN WPB29 M1 ON M.PA60002 = M1.PB29003";
            WPA60SQL += " WHERE M.PA60001='001' AND M1.PB29001='001' AND M.PA60004 = '9'";
            //            WPA60SQL += " AND PA60002 = '0619'";
            WPA60SQL += " and M.PA60006 BETWEEN '" + date_s + " 00:00:00.000' AND  '" + date_e + " 23:59:59.997'";
            xWPA60 = WZDBSQLHELP.ExecuteQuery(WPA60SQL);
            int a = 0;

            TimeSpan xts = DateTime.Parse(date_e) - DateTime.Parse(date_s);
            DateTime xADate = DateTime.Parse(date_s + " 00:00:00.000");

            if (xWPA60.Rows.Count > 0)
            {
                for (int x = 0; x < xWPA60.Rows.Count; x++)
                {
                    if (xWPA60.Rows[x][0].ToString() == "2049")
                    {
                        string aaaaa = "0";
                    }
                    SPA60007 = Convert.ToDateTime(xWPA60.Rows[x]["PA60007"]);
                    EPA60008 = Convert.ToDateTime(xWPA60.Rows[x]["PA60008"]);

                    TWPA60 = EPA60008.Subtract(SPA60007).TotalHours.ToString();
                    if (Convert.ToDouble(TWPA60) >= 8 && xWPA60.Rows[x]["PA60008"].ToString() != "008" && xWPA60.Rows[x]["PA60008"].ToString() != "018" && xWPA60.Rows[x]["PA60008"].ToString() != "019")
                    {
                        W60dr = dt_wz.Select("PB29003 = '" + xWPA60.Rows[x][0].ToString() + "' AND PB29004 = '1' AND PB29002 >= '" + Convert.ToDateTime(xWPA60.Rows[x]["PA60006"]).ToString("yyyy-MM-dd 00:00:00.000") + "' AND PB29002 <='" + Convert.ToDateTime(xWPA60.Rows[x]["PA60006"]).ToString("yyyy-MM-dd 23:59:59.997") + "'");
                        if (W60dr.Length > 0)
                        {
                            for (a = 0; a < W60dr.Length; a++)
                            {
                                dt_wz.Rows[dt_wz.Rows.IndexOf(W60dr[a])]["PB29004"] = "3";
                            }
                        }
                    }
                    //                        xADate = DateTime.Parse(date_s + " 00:00:00.000").AddDays(b);
                }
            }
            xWPA60 = null;
            //--------------------------------------------------------------------------------------------------------------------------


            //2016-02-06 新增----------------------------------------------------------------------------
            SQL = "select MAX(PB29995) from WPB29";
            DataTable xdt = WZDBSQLHELP.ExecuteQuery(SQL);
            int xPB29995 = int.Parse(xdt.Rows[0][0].ToString());
            xdt = null;
            logger.Debug(xPB29995.ToString());
            //            TimeSpan ts1 = DateTime.Parse(datetime_e) - DateTime.Parse(datetime_s);
            TimeSpan ts1 = DateTime.Parse(date_e) - DateTime.Parse(date_s);
            DateTime DateT_s = DateTime.Parse(date_s);

            SQL = "SELECT M.PA51002,M.PA51004,M.PA51019,M.PA51025, M.PA51020";
            SQL += " FROM WPA51 M INNER JOIN WPA15 M1 ON M.PA51017 = M1.PA15002";
            SQL += " WHERE M.PA51001 = '001' AND M.PA51019 = '0' AND M.PA51025 IS NULL";
            SQL += " AND M.PA51014 IN ('005', '006', '008', '010', '011', '012', '013', '014', '015', '016', '025', '028', '029', '030', '031', '032', '033', '034', '035', '036', '037', '041', '042', '043', '049', '054')";
            SQL += " AND M1.PA15001 = '001' AND M1.PA15002 IN ('006', '007', '008', '009')";
            SQL += " order by M.PA51002";

            xdt_cw = WZDBSQLHELP.ExecuteQuery(SQL);

            //找國定假日----------------------------------------------------------------------------------------------------------------------------
            string xPA51020 = "";
            string xSQL = "";
            DateTime xDate_s = DateTime.Parse(date_s + " 00:00:00.000");
            DateTime xDate_e = DateTime.Parse(date_e + " 23:59:59.997");

            DataTable xWPA18 = new DataTable();
            //            xSQL = "select count(*) from WPA18 where 1=1 and PA18002 BETWEEN '" + xDate_s.ToString() + "' AND '" + xDate_e.ToString() + "'";
            xSQL = "SELECT PA18002 FROM WPA18";
            xSQL += " WHERE PA18001 = '001' AND PA18002 BETWEEN '" + date_s + " 00:00:00.000' AND  '" + date_e + " 23:59:59.997'";
            xWPA18 = WZDBSQLHELP.ExecuteQuery(xSQL);

            logger.Debug("xDate_s=" + xDate_s.ToString() + ";" + "xDate_e=" + xDate_e.ToString());
            logger.Debug("xdt_cw.Rows.Count = " + xdt_cw.Rows.Count.ToString());

            DataRow[] dr;
            DataRow[] xdr;

            try
            {
                if (xdt_cw.Rows.Count > 0)
                {
                    for (int x = 0; x < xdt_cw.Rows.Count; x++)
                    {
                        xPA51020 = xdt_cw.Rows[x][4].ToString();

                        if (xdt_cw.Rows[x][0].ToString() == "0619")
                        {
                            string sss = "0";
                        }
                        dr = dt_wz.Select("PB29003 = '" + xdt_cw.Rows[x][0].ToString() + "'");
                        logger.Debug("x=" + x + ";dr.Length=" + dr.Length);
                        if (dr.Length == 0)
                        {
                            //2017-03-29 新增 比對是否有打卡,有打才列入-------------------------------------------------------------------------------
                            dr = dt_cw.Select("P01 = '" + xdt_cw.Rows[x][0].ToString() + "'");
                            //------------------------------------------------------------------------------------------------------------------------
                            if (dr.Length > 0)
                            {
                                for (int xx = 0; xx <= int.Parse(ts1.Days.ToString()); xx++)
                                {
                                    xPB29995 += 1;

                                    //沒有國定假日,就判斷是不是六,日上班
                                    if (xWPA18.Rows.Count == 0)
                                    {
                                        switch (int.Parse(DateT_s.DayOfWeek.ToString("d")))
                                        {
                                            case 0:
                                            case 6:
                                                dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "3", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                                break;
                                            default:
                                                dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "1", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                                break;
                                        }
                                    }
                                    else
                                    {
                                        //有國定假日,就判斷是不是上班日 = 國定假日
                                        xdr = xWPA18.Select("PA18002 = '" + xDate_s + "'");
                                        if (xdr.Length > 0)     //國定假日
                                        {
                                            dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "3", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                        }
                                        else
                                        {
                                            dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "1", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                        }
                                    }

                                    //
                                    xDate_s = xDate_s.AddDays(1);
                                    xDate_e = xDate_e.AddDays(1);
                                    DateT_s = DateT_s.AddDays(1);
                                    xdr = null;
                                    //                                xdr = null;
                                }
                            }
                        }
                        logger.Debug("x=" + x + ";dr.Length=END");
                        dr = null;
                        DateT_s = DateTime.Parse(date_s);
                    }
                }
            }
            catch (Exception ex)
            {
                logger.Debug("ex=" + ex.Message);
                var obj = new { success = "1", msg = ex.Message };
                string result = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
                context.Response.Write(result);
                return;
            }
            xWPA60 = null;

            logger.Debug("wz");
            var wz = from row in dt_wz.AsEnumerable()
                     select new
                     {
                         time = row.Field<DateTime>("PB29002"),
                         empid = row.Field<string>("PB29003"),
                         kind = row.Field<int>("PB29004"), //排班代碼
                         type = row.Field<string>("PB29005"), //班別
                     };

            ////取文中人員屬於非排班者
            //            SQL = string.Format(@"SELECT PA51002,PA51004,PA51019,PA51025 FROM WPA51 WHERE PA51001 = '001' AND PA51019 = '0' AND PA51025 IS NULL");

            //20170206 修改--------------------------
            //            SQL = string.Format(@"SELECT M.PA51002,M.PA51004,M.PA51019,M.PA51025 FROM WPA51 M INNER JOIN WPA15 M1 ON M.PA51017 = M1.PA15002 WHERE M.PA51001 = '001' AND M.PA51019 = '0' AND M.PA51025 IS NULL AND M1.PA15001 = '001' AND M1.PA15002 not IN ('005', '006', '007', '009')");
            //---------------------------------------

            //20170426 因為加入派遣人員修改,將AND M.PA51019 = '0' 是否屬排班移除
            SQL = string.Format(@"SELECT M.PA51002,M.PA51004,M.PA51019,M.PA51025 FROM WPA51 M INNER JOIN WPA15 M1 ON M.PA51017 = M1.PA15002 WHERE M.PA51001 = '001'  AND (M.PA51025 IS NULL OR M.PA51025 <= '" + datetime_e + "') AND M1.PA15001 = '001' AND M1.PA15002 not IN ('005', '006', '007', '009')");
            //---------------------------------------
            dt_noschedule = WZDBSQLHELP.ExecuteQuery(SQL);

            //20170705 因為加入雙軌(009)的行政人員修改,
            dt_noschedule.PrimaryKey = new DataColumn[] { dt_noschedule.Columns["PA51002"] };


            SQL = string.Format(@"SELECT M.PA51002,M.PA51004,M.PA51019,M.PA51025 FROM WPA51 M INNER JOIN WPA15 M1 ON M.PA51017 = M1.PA15002 WHERE M.PA51001 = '001' AND M.PA51025 IS NULL AND M1.PA15001 = '001' AND M.PA51014 IN ('001', '002', '003', '004', '007', '008', '009', '010', '017', '021', '022', '026', '027', '028', '037', '038', '039', '040', '043', '044', '045', '046', '047', '048', '052', '053') AND M1.PA15002 IN ('009')");
            var xxxdt = WZDBSQLHELP.ExecuteQuery(SQL);
            dt_noschedule.Merge(xxxdt);
            //---------------------------------------

            var noschedule = from row in dt_noschedule.AsEnumerable()
                             select new
                             {
                                 empid = row.Field<string>("PA51002"),
                                 kind = row.Field<int>("PA51019"), //是否屬排班 0-非排班 1-排班
                             };

            DataTable all_1 = new DataTable(); //正常
            all_1.Columns.Add("EMPID");
            all_1.Columns.Add("EMPNAME");
            all_1.Columns.Add("DEP");
            all_1.Columns.Add("TIME");
            all_1.Columns.Add("TYPE");
            all_1.Columns.Add("CARDNO");
            all_1.Columns.Add("ALLKIND");

            DataTable all_2 = new DataTable(); //加班
            all_2.Columns.Add("EMPID");
            all_2.Columns.Add("EMPNAME");
            all_2.Columns.Add("DEP");
            all_2.Columns.Add("TIME");
            all_2.Columns.Add("TYPE");
            all_2.Columns.Add("CARDNO");
            all_2.Columns.Add("ALLKIND");

            Random rd = new Random();
            string morning_s = "06:30"; //早班上班時間 + 緩衝時間
            string morning_e = "17:00"; //正常早班下班時間
            string night_s = "18:30"; //晚班上班時間 + 緩衝時間
            string night_e = "05:00"; //正常晚班下班時間
            string evening_s = "16:00"; //中班上班時間
            string evening_e = "02:00"; //正常中班下班時間

            string Nevening_s = "15:00"; //新中班上班時間
            string Nevening_e = "00:00"; //新正常中班下班時間

            string NNevening_s = "13:00"; //新新中班上班時間
            string NNevening_e = "22:00"; //新新正常中班下班時間

            string xStarTime = "00:00:00.000";
            string xEndTime = "23:59:59.997";

            string morning_buffer = DateTime.Parse(morning_e).AddMinutes(addmin).TimeOfDay.ToString(); //早班下班緩衝時間
            string night_buffer = DateTime.Parse(night_e).AddMinutes(addmin).TimeOfDay.ToString(); //晚班下班緩衝時間
            string evening_buffer = DateTime.Parse(evening_e).AddMinutes(addmin).TimeOfDay.ToString(); //中班下班緩衝時間
            string Nevening_buffer = DateTime.Parse(Nevening_e).AddMinutes(addmin).TimeOfDay.ToString(); //新中班下班緩衝時間
            string NNevening_buffer = DateTime.Parse(NNevening_e).AddMinutes(addmin).TimeOfDay.ToString(); //新新中班下班緩衝時間

            string morning_extra = "19:30"; //早班加班時間開始
            string night_extra = "07:30"; //晚班加班時間開始

            var morning = new List<string> { "001", "004", "014", "016", "027" }; //早班代碼
            var night = new List<string> { "002", "007", "012", "013", "015", "017" }; //晚班代碼
            var evening = new List<string> { "003", "008", "022", "023", "025", "028", "029" }; //中班代碼
            var Nevening = new List<string> { "030" }; //新中班代碼
            var NNevening = new List<string> { "005" }; //新新中班代碼

            DataRow[] xfindrows;
            string xxx;


            //            xtime = row.Field<DateTime>("PB29002"),
            string xempid;      //ID
            int xkind;          //排班代碼
            string xtype;       //班別
            int SS;
            int SS1;
            DateTime SDate;
            DateTime EDate;
            TimeSpan TTotal;
            DateTime OffWorkTime;
            DateTime OnWorkTime;

            DataTable sDT = new DataTable();

            sDT.Columns.Add("卡號");
            sDT.Columns.Add("時間");

            Random ro = new Random();
            int iResult;
            int xPB29004 = 0;
            int xk = 0;
            try
            {
                //dt_wz → 班表    cw → 打卡 xdt_cw
                foreach (var schedule in cw)
                {
                    xk += 1;
                    if (schedule.empid.ToString() == "0619")
                    {
                        int xkj = 0;
                    }
                    //找班表=上班的人  PB29004 = 1
                    //20170412 修正
                    //xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date + "' AND PB29004 = '1'");
                    if (schedule.empid.ToString() != "")
                    {
                        xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date + "'");
                        //班表有找到人
                        if (xfindrows.Length > 0)
                        {
                            SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                            xempid = dt_wz.Rows[SS][2].ToString();
                            xkind = int.Parse(dt_wz.Rows[SS][3].ToString());
                            xtype = dt_wz.Rows[SS][4].ToString();
                            xPB29004 = int.Parse(dt_wz.Rows[SS]["PB29004"].ToString());        //取上班還是放假

                            //早班
                            if (morning.Contains(xtype))
                            {
                                if (xPB29004 == 1)
                                {
                                    //找是否為現場人員(有加班費的人)
                                    xfindrows = dt_noschedule.Select("PA51002 = '" + schedule.empid.ToString() + "'");
                                    if (xfindrows.Length == 0)
                                    {
                                        SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 08:00");
                                        EDate = SDate.AddHours(-4);   //提前4小時來上班
                                                                      //上班時間打
                                        if (schedule.time >= EDate && schedule.time <= SDate)
                                        {
                                            //                                    System.Diagnostics.Debug.Print(schedule.empid + schedule.time);
                                            TTotal = SDate.Subtract(Convert.ToDateTime(schedule.time)); //日期相減
                                                                                                        //如果上班打卡時間在1小時內
                                            if (int.Parse(TTotal.Hours.ToString()) == 0)
                                            {
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "早班", schedule.cardno, "全一");
                                            }
                                            else
                                            {
                                                //上班加班用1小時內亂數去跑時間
                                                iResult = ro.Next(60, radombuffer * 60 * 6);     //上班班亂數以秒做單位

                                                //20170603 提早來亂數是要0800減
                                                //OnWorkTime = SDate.AddSeconds(iResult);
                                                OnWorkTime = SDate.AddSeconds(iResult * (-1));
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OnWorkTime, "早班", schedule.cardno, "全一");
                                                //如果提早1HR以上班則全部在全2
                                                if (int.Parse(TTotal.Hours.ToString()) >= 1)
                                                {
                                                    //20170603 上班開始時間不用切直接帶打卡時間
                                                    //EDate = SDate.AddMinutes((int)TTotal.TotalMinutes * -1);
                                                    EDate = schedule.time;
                                                    //增加開始加班時間與結束時間
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, EDate, "早班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, SDate, "早班", schedule.cardno, "全二");
                                                }
                                            }
                                            //                                    sDT.Rows.Add(schedule.empid, TTotal.Hours);
                                        }
                                        else
                                        {
                                            SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 17:00");
                                            EDate = SDate.AddHours(7);
                                            if (schedule.time >= SDate && schedule.time <= EDate)
                                            {
                                                iResult = ro.Next(60, radombuffer * 60);     //下班亂數以秒做單位
                                                TTotal = schedule.time.Subtract(SDate); //打卡下班時間 - 正常下班時間
                                                SS = (int)TTotal.TotalMinutes;

                                                //下班班時間 如果下班時間大於緩衝分鐘
                                                if (SS > addmin)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    OffWorkTime = OffWorkTime.AddSeconds(iResult);
                                                    SS = SS - addmin;                               //超過緩衝加班時間
                                                }
                                                else
                                                {
                                                    OffWorkTime = schedule.time;
                                                    SS = 0;
                                                }

                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "早班", schedule.cardno, "全一");
                                                //下班結束----------------------------------------------
                                                //下班加班超過法定
                                                if (SS > 0)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "早班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "早班", schedule.cardno, "全二");
                                                }
                                            }
                                            else
                                            {
                                                //除了正常與加班上下班之外的,遲到 早退
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "早班", schedule.cardno, "全一");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //班表上有但是有來加班的人
                                    if (xPB29004 == 3)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                    }
                                }
                            }       //早班結束

                            //晚班
                            if (night.Contains(xtype))
                            {

                                if (schedule.time.Hour < 12)
                                {
                                    xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date.AddDays(-1) + "'");
                                    if (xfindrows.Length > 0)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xempid = dt_wz.Rows[SS][2].ToString();
                                        xkind = int.Parse(dt_wz.Rows[SS][3].ToString());
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        xPB29004 = int.Parse(dt_wz.Rows[SS]["PB29004"].ToString());        //取上班還是放假
                                    }
                                }
                                if (xPB29004 == 1)
                                {
                                    //找是否為現場人員(有加班費的人)
                                    xfindrows = dt_noschedule.Select("PA51002 = '" + schedule.empid.ToString() + "'");
                                    if (xfindrows.Length == 0)
                                    {
                                        SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 20:00");
                                        EDate = SDate.AddHours(-4);   //提前4小時來上班
                                                                      //上班時間打
                                        if (schedule.time >= EDate && schedule.time <= SDate)
                                        {
                                            //                                    System.Diagnostics.Debug.Print(schedule.empid + schedule.time);
                                            TTotal = SDate.Subtract(Convert.ToDateTime(schedule.time)); //日期相減
                                                                                                        //如果上班打卡時間在1小時內
                                            if (int.Parse(TTotal.Hours.ToString()) == 0)
                                            {
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "晚班", schedule.cardno, "全一");
                                            }
                                            else
                                            {
                                                //上班加班用1小時內亂數去跑時間
                                                iResult = ro.Next(60, radombuffer * 60 * 6);     //上班班亂數以秒做單位
                                                //20170603 提早來亂數是要1200減
                                                //OnWorkTime = SDate.AddSeconds(iResult);
                                                OnWorkTime = SDate.AddSeconds(iResult * (-1));
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OnWorkTime, "晚班", schedule.cardno, "全一");
                                                //如果提早1HR以上班則全部在全2
                                                if (int.Parse(TTotal.Hours.ToString()) >= 1)
                                                {
                                                    //20170603 上班開始時間不用切直接帶打卡時間
                                                    //EDate = SDate.AddMinutes((int)TTotal.TotalMinutes * -1);
                                                    EDate = schedule.time;
                                                    //增加開始加班時間與結束時間
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, EDate, "晚班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, SDate, "晚班", schedule.cardno, "全二");
                                                }
                                            }
                                            //                                    sDT.Rows.Add(schedule.empid, TTotal.Hours);
                                        }
                                        else
                                        {
                                            SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 05:00");
                                            EDate = SDate.AddHours(7);
                                            if (schedule.time >= SDate && schedule.time <= EDate)
                                            {
                                                iResult = ro.Next(60, radombuffer * 60);     //下班亂數以秒做單位
                                                TTotal = schedule.time.Subtract(SDate); //打卡下班時間 - 正常下班時間
                                                SS = (int)TTotal.TotalMinutes;

                                                //下班班時間 如果下班時間大於緩衝分鐘
                                                if (SS > addmin)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    OffWorkTime = OffWorkTime.AddSeconds(iResult);
                                                    SS = SS - addmin;                               //超過緩衝加班時間
                                                }
                                                else
                                                {
                                                    OffWorkTime = schedule.time;
                                                    SS = 0;
                                                }

                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "晚班", schedule.cardno, "全一");
                                                //下班結束----------------------------------------------
                                                //下班加班超過法定
                                                if (SS > 0)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "晚班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "晚班", schedule.cardno, "全二");
                                                }
                                            }
                                            else
                                            {
                                                //除了正常與加班上下班之外的,遲到 早退
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "晚班", schedule.cardno, "全一");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //班表上有但是有來加班的人
                                    if (xPB29004 == 3)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                    }
                                }
                            }       //晚班結束

                            //中班
                            if (evening.Contains(xtype))
                            {
                                if (schedule.time.Hour < 12)
                                {
                                    xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date.AddDays(-1) + "'");
                                    if (xfindrows.Length > 0)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xempid = dt_wz.Rows[SS][2].ToString();
                                        xkind = int.Parse(dt_wz.Rows[SS][3].ToString());
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        xPB29004 = int.Parse(dt_wz.Rows[SS]["PB29004"].ToString());        //取上班還是放假
                                    }
                                }
                                if (xPB29004 == 1)
                                {
                                    //找是否為現場人員(有加班費的人)
                                    xfindrows = dt_noschedule.Select("PA51002 = '" + schedule.empid.ToString() + "'");
                                    if (xfindrows.Length == 0)
                                    {
                                        SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 17:00");
                                        EDate = SDate.AddHours(-4);   //提前4小時來上班
                                                                      //上班時間打
                                        if (schedule.time >= EDate && schedule.time <= SDate)
                                        {
                                            //                                    System.Diagnostics.Debug.Print(schedule.empid + schedule.time);
                                            TTotal = SDate.Subtract(Convert.ToDateTime(schedule.time)); //日期相減
                                                                                                        //如果上班打卡時間在1小時內
                                            if (int.Parse(TTotal.Hours.ToString()) == 0)
                                            {
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "中班", schedule.cardno, "全一");
                                            }
                                            else
                                            {
                                                //上班加班用1小時內亂數去跑時間
                                                iResult = ro.Next(60, radombuffer * 60 * 6);     //上班班亂數以秒做單位

                                                //20170603 提早來亂數是要減
                                                //OnWorkTime = SDate.AddSeconds(iResult);
                                                OnWorkTime = SDate.AddSeconds(iResult * (-1));
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OnWorkTime, "中班", schedule.cardno, "全一");
                                                //如果提早1HR以上班則全部在全2
                                                if (int.Parse(TTotal.Hours.ToString()) >= 1)
                                                {
                                                    //20170603 上班開始時間不用切直接帶打卡時間
                                                    //EDate = SDate.AddMinutes((int)TTotal.TotalMinutes * -1);
                                                    EDate = schedule.time;
                                                    //增加開始加班時間與結束時間
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, EDate, "中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, SDate, "中班", schedule.cardno, "全二");
                                                }
                                            }
                                            //                                    sDT.Rows.Add(schedule.empid, TTotal.Hours);
                                        }
                                        else
                                        {
                                            SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 02:00");
                                            EDate = SDate.AddHours(7);
                                            if (schedule.time >= SDate && schedule.time <= EDate)
                                            {
                                                iResult = ro.Next(60, radombuffer * 60);     //下班亂數以秒做單位
                                                TTotal = schedule.time.Subtract(SDate); //打卡下班時間 - 正常下班時間
                                                SS = (int)TTotal.TotalMinutes;

                                                //下班班時間 如果下班時間大於緩衝分鐘
                                                if (SS > addmin)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    OffWorkTime = OffWorkTime.AddSeconds(iResult);
                                                    SS = SS - addmin;                               //超過緩衝加班時間
                                                }
                                                else
                                                {
                                                    OffWorkTime = schedule.time;
                                                    SS = 0;
                                                }

                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "中班", schedule.cardno, "全一");
                                                //下班結束----------------------------------------------
                                                //下班加班超過法定
                                                if (SS > 0)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "中班", schedule.cardno, "全二");
                                                }
                                            }
                                            else
                                            {
                                                //除了正常與加班上下班之外的,遲到 早退
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "中班", schedule.cardno, "全一");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //班表上有但是有來加班的人
                                    if (xPB29004 == 3)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                    }
                                }
                            }       //中班結束

                            //新中班
                            if (Nevening.Contains(xtype))
                            {
                                if (schedule.time.Hour < 12)
                                {
                                    xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date.AddDays(-1) + "'");
                                    if (xfindrows.Length > 0)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xempid = dt_wz.Rows[SS][2].ToString();
                                        xkind = int.Parse(dt_wz.Rows[SS][3].ToString());
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        xPB29004 = int.Parse(dt_wz.Rows[SS]["PB29004"].ToString());        //取上班還是放假
                                    }
                                }
                                if (xPB29004 == 1)
                                {
                                    //找是否為現場人員(有加班費的人)
                                    xfindrows = dt_noschedule.Select("PA51002 = '" + schedule.empid.ToString() + "'");
                                    if (xfindrows.Length == 0)
                                    {
                                        SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 15:00");
                                        EDate = SDate.AddHours(-4);   //提前4小時來上班
                                                                      //上班時間打
                                        if (schedule.time >= EDate && schedule.time <= SDate)
                                        {
                                            //                                    System.Diagnostics.Debug.Print(schedule.empid + schedule.time);
                                            TTotal = SDate.Subtract(Convert.ToDateTime(schedule.time)); //日期相減
                                                                                                        //如果上班打卡時間在1小時內
                                            if (int.Parse(TTotal.Hours.ToString()) == 0)
                                            {
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全一");
                                            }
                                            else
                                            {
                                                //上班加班用1小時內亂數去跑時間
                                                iResult = ro.Next(60, radombuffer * 60 * 6);     //上班班亂數以秒做單位
                                                //20170603 提早來亂數是要減
                                                //OnWorkTime = SDate.AddSeconds(iResult);
                                                OnWorkTime = SDate.AddSeconds(iResult * (-1));
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OnWorkTime, "新中班", schedule.cardno, "全一");
                                                //如果提早1HR以上班則全部在全2
                                                if (int.Parse(TTotal.Hours.ToString()) >= 1)
                                                {
                                                    //20170603 上班開始時間不用切直接帶打卡時間
                                                    //EDate = SDate.AddMinutes((int)TTotal.TotalMinutes * -1);
                                                    EDate = schedule.time;
                                                    //增加開始加班時間與結束時間
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, EDate, "新中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, SDate, "新中班", schedule.cardno, "全二");
                                                }
                                            }
                                            //                                    sDT.Rows.Add(schedule.empid, TTotal.Hours);
                                        }
                                        else
                                        {
                                            SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 23:59");
                                            EDate = SDate.AddHours(7);
                                            if (schedule.time >= SDate && schedule.time <= EDate)
                                            {
                                                iResult = ro.Next(60, radombuffer * 60);     //下班亂數以秒做單位
                                                TTotal = schedule.time.Subtract(SDate); //打卡下班時間 - 正常下班時間
                                                SS = (int)TTotal.TotalMinutes;

                                                //下班班時間 如果下班時間大於緩衝分鐘
                                                if (SS > addmin)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    OffWorkTime = OffWorkTime.AddSeconds(iResult);
                                                    SS = SS - addmin;                               //超過緩衝加班時間
                                                }
                                                else
                                                {
                                                    OffWorkTime = schedule.time;
                                                    SS = 0;
                                                }

                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "新中班", schedule.cardno, "全一");
                                                //下班結束----------------------------------------------
                                                //下班加班超過法定
                                                if (SS > 0)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "新中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                                }
                                            }
                                            else
                                            {
                                                //除了正常與加班上下班之外的,遲到 早退
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全一");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //班表上有但是有來加班的人
                                    if (xPB29004 == 3)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                    }
                                }
                            }       //新中班結束

                            //新新中班
                            if (NNevening.Contains(xtype))
                            {
                                if (schedule.time.Hour < 12)
                                {
                                    xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date.AddDays(-1) + "'");
                                    if (xfindrows.Length > 0)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xempid = dt_wz.Rows[SS][2].ToString();
                                        xkind = int.Parse(dt_wz.Rows[SS][3].ToString());
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        xPB29004 = int.Parse(dt_wz.Rows[SS]["PB29004"].ToString());        //取上班還是放假
                                    }
                                }
                                if (xPB29004 == 1)
                                {
                                    //找是否為現場人員(有加班費的人)
                                    xfindrows = dt_noschedule.Select("PA51002 = '" + schedule.empid.ToString() + "'");
                                    if (xfindrows.Length == 0)
                                    {
                                        SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 13:00");
                                        EDate = SDate.AddHours(-4);   //提前4小時來上班
                                                                      //上班時間打
                                        if (schedule.time >= EDate && schedule.time <= SDate)
                                        {
                                            //                                    System.Diagnostics.Debug.Print(schedule.empid + schedule.time);
                                            TTotal = SDate.Subtract(Convert.ToDateTime(schedule.time)); //日期相減
                                                                                                        //如果上班打卡時間在1小時內
                                            if (int.Parse(TTotal.Hours.ToString()) == 0)
                                            {
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新新中班", schedule.cardno, "全一");
                                            }
                                            else
                                            {
                                                //上班加班用1小時內亂數去跑時間
                                                iResult = ro.Next(60, radombuffer * 60 * 6);     //上班班亂數以秒做單位
                                                //20170603 提早來亂數是要減
                                                //OnWorkTime = SDate.AddSeconds(iResult);
                                                OnWorkTime = SDate.AddSeconds(iResult * (-1));
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OnWorkTime, "新新中班", schedule.cardno, "全一");
                                                //如果提早1HR以上班則全部在全2
                                                if (int.Parse(TTotal.Hours.ToString()) >= 1)
                                                {
                                                    //20170603 上班開始時間不用切直接帶打卡時間
                                                    //EDate = SDate.AddMinutes((int)TTotal.TotalMinutes * -1);
                                                    EDate = schedule.time;
                                                    //增加開始加班時間與結束時間
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, EDate, "新新中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, SDate, "新新中班", schedule.cardno, "全二");
                                                }
                                            }
                                            //                                    sDT.Rows.Add(schedule.empid, TTotal.Hours);
                                        }
                                        else
                                        {
                                            SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 22:00");
                                            EDate = SDate.AddHours(7);
                                            if (schedule.time >= SDate && schedule.time <= EDate)
                                            {
                                                iResult = ro.Next(60, radombuffer * 60);     //下班亂數以秒做單位
                                                TTotal = schedule.time.Subtract(SDate); //打卡下班時間 - 正常下班時間
                                                SS = (int)TTotal.TotalMinutes;

                                                //下班班時間 如果下班時間大於緩衝分鐘
                                                if (SS > addmin)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    OffWorkTime = OffWorkTime.AddSeconds(iResult);
                                                    SS = SS - addmin;                               //超過緩衝加班時間
                                                }
                                                else
                                                {
                                                    OffWorkTime = schedule.time;
                                                    SS = 0;
                                                }

                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "新新中班", schedule.cardno, "全一");
                                                //下班結束----------------------------------------------
                                                //下班加班超過法定
                                                if (SS > 0)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "新新中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                                }
                                            }
                                            else
                                            {
                                                //除了正常與加班上下班之外的,遲到 早退
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新新中班", schedule.cardno, "全一");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //班表上有但是有來加班的人
                                    if (xPB29004 == 3)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                    }
                                }
                            }       //新新中班結束
                        }
                        else
                        {
                            //班表上有但是有來加班的人
                            xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date + "' AND PB29004 = '3'");
                            if (xfindrows.Length > 0)
                            {
                                SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                xtype = dt_wz.Rows[SS][4].ToString();
                                add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                            }
                        }
                    }
                    else
                    {
                        logger.Debug("找不到資料 " + schedule.empname.ToString() + ";" + schedule.time.ToString());
                    }
                }

                logger.Debug("無排班");
                //無排班→ 全一
                //在不是排班者中取得對應打卡資料
                foreach (var row in noschedule)
                {
                    if (row.empid == "2590")
                    {
                        var tttt = "";
                    }
                    var filter = cw.Where(w => w.empid == row.empid);
                    foreach (var data in filter)
                    {
                        add_all(all_1, data.empid, data.empname, data.empdep, data.time, "非排班", data.cardno, "全一");
                    }
                }
                logger.Debug("OK");
            }
            catch (Exception ex)
            {
                logger.Debug(ex.Message);
                var obj = new { success = "1", msg = ex.Message };
                string result = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
                context.Response.Write(result);
                return;
            }

            try
            {
                ////匯出TXT
                string fName1 = "";
                string fName2 = "";

                string filename_1 = "全1__" + DateTime.Parse(date_s).ToString("yyyyMMdd") + "-" + DateTime.Parse(date_e).ToString("yyyyMMdd") + DateTime.Now.ToString("hhmmssff") + ".txt";
                string filename_2 = "全2__" + DateTime.Parse(date_s).ToString("yyyyMMdd") + "-" + DateTime.Parse(date_e).ToString("yyyyMMdd") + DateTime.Now.ToString("hhmmssff") + ".txt";

                string savepath = context.Server.MapPath("~\\");
                FileStream fileStream = new FileStream(@savepath + "DLtmp\\" + filename_1, FileMode.Create);
                fileStream.Close();           //切記開了要關,不然會被佔用而無法修改喔!!!
                string output;
                using (StreamWriter sw = new StreamWriter(@savepath + "DLtmp\\" + filename_1))
                {
                    for (int i = 0; i < all_1.Rows.Count; i++)
                    {
                        // 欲寫入的文字資料 ~
                        output = all_1.Rows[i]["CARDNO"].ToString() + " " + DateTime.Parse(all_1.Rows[i]["TIME"].ToString()).ToString("yyyyMMddHHmmss") + " 1 1 001";
                        sw.WriteLine(output);
                    }
                }
                fName1 = "/DLtmp/" + filename_1;

                if (all_2.Rows.Count > 0)
                {
                    fileStream = new FileStream(@savepath + "DLtmp\\" + filename_2, FileMode.Create);
                    fileStream.Close();           //切記開了要關,不然會被佔用而無法修改喔!!!
                    output = "";
                    using (StreamWriter sw = new StreamWriter(@savepath + "DLtmp\\" + filename_2))
                    {
                        for (int i = 0; i < all_2.Rows.Count; i++)
                        {
                            // 欲寫入的文字資料 ~
                            output = all_2.Rows[i]["CARDNO"].ToString() + " " + DateTime.Parse(all_2.Rows[i]["TIME"].ToString()).ToString("yyyyMMddHHmmss") + " 1 1 001";
                            sw.WriteLine(output);
                        }
                    }
                    fName2 = "/DLtmp/" + filename_2;
                }

                var obj = new { success = "0", fName1 = fName1, fName2 = fName2 };
                string result = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
                context.Response.Write(result);
            }
            catch (Exception ex)
            {
                var obj = new { success = "1", msg = ex.Message };
                string result = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
                context.Response.Write(result);
            }

        }

        //排班 + 考勤
        public void checkworkTEST_20170603(HttpContext context)
        {
            string SQL = "";
            DataTable dt_cw = new DataTable(); //打卡記錄
            DataTable dt_wz = new DataTable(); //文中排班
            DataTable dt_noschedule = new DataTable(); //文中員工是否屬於排班
            DataTable xdt_cw = new DataTable();         //沒排班有加班費

            string txt = context.Request["txt"].ToString(); //判斷是否匯出txt 1=txt
            int all = int.Parse(context.Request["all"].ToString()); //全一/全二
            int addmin = int.Parse(context.Request["addmin"].ToString()); //使用者key 緩衝時間
            int radombuffer = int.Parse(context.Request["radombuffer"].ToString()); //使用者key 下班亂數時間區間
            string datetime_s = context.Request["start"].ToString(); //"2016-11-01 10:00:00";
            string datetime_e = context.Request["end"].ToString(); //"2016-11-02 10:00:00";

            string date_s = DateTime.Parse(datetime_s).ToString("yyyy-MM-dd"); //"2016-11-01";
            string date_e = DateTime.Parse(datetime_e).ToString("yyyy-MM-dd");//"2016-11-02";
            string Ucard = context.Request["Ucard"].ToString();                 //00819,00966
            string xUcard = Ucard;

            if (Ucard != "")
            {
                //(m1.p01='00819' or m1.p01='00966')    00819,00966
                if (Ucard.Substring(Ucard.Length - 1, 1) == ",")
                {
                    Ucard = Ucard.Substring(0, Ucard.Length - 1);

                }
                Ucard = "and (p.p01='" + Ucard.Replace(",", "' or p.p01='") + "')";
            }
            logger.Debug("取打卡記錄");
            //取打卡記錄
            SQL = "SELECT CASE WHEN SUBSTRING(P01,1,1) = '0' THEN SUBSTRING(P01,2,4) ELSE P01 END P01, ";
            SQL += " L00, L01, L02, L06, L07, L15";
            SQL += " FROM L03 L LEFT JOIN P00 P ON L.l06 = P08";
            SQL += " WHERE 1=1";
            SQL += " And L12 IN ( '238','283','291','292','293','294','295','296','300','301','302','304','305','306','312','313','314','315','316','317','324','325','326','327')";
            SQL += " AND L07 != '不明' and convert(nvarchar(255),l08) like '%正常進出%'";
            SQL += " AND L01 BETWEEN '{0}' AND '{1}' {2}";
            //            SQL += " order by P.P01, L.l01";

            SQL = string.Format(SQL, datetime_s, datetime_e, Ucard);
            dt_cw = DBSQLHELP.ExecuteQuery(SQL);

            dt_cw.DefaultView.Sort = "P01, l01";
            dt_cw = dt_cw.DefaultView.ToTable();

            var cw = from row in dt_cw.AsEnumerable()
                     select new
                     {
                         empid = row.Field<string>("P01"),
                         lin = row.Field<int>("L00"),
                         time = row.Field<DateTime>("L01"),
                         macloc = row.Field<string>("L02"),
                         cardno = row.Field<string>("L06"),
                         empname = row.Field<string>("L07"),
                         empdep = row.Field<string>("L15"),
                     };
            logger.Debug("取班表");
            //取班表
            string xxdate_s = DateTime.Parse(date_s).AddDays(-1).Date.ToString("yyyy-MM-dd");
            SQL = string.Format(@"SELECT * FROM WPB29 WHERE PB29001 = '001' and PB29002 BETWEEN '{0}' AND '{1}'", xxdate_s, date_e);
            //20170602 修正版表要抓前一天,不然夜班會有問題
            //            SQL = string.Format(@"SELECT * FROM WPB29 WHERE PB29001 = '001' and PB29002 BETWEEN '{0}' AND '{1}'", date_s, date_e);
            dt_wz = WZDBSQLHELP.ExecuteQuery(SQL);

            //2016-02-06 新增----------------------------------------------------------------------------
            SQL = "select MAX(PB29995) from WPB29";
            DataTable xdt = WZDBSQLHELP.ExecuteQuery(SQL);
            int xPB29995 = int.Parse(xdt.Rows[0][0].ToString());
            xdt = null;
            logger.Debug(xPB29995.ToString());
            //            TimeSpan ts1 = DateTime.Parse(datetime_e) - DateTime.Parse(datetime_s);
            TimeSpan ts1 = DateTime.Parse(date_e) - DateTime.Parse(date_s);
            DateTime DateT_s = DateTime.Parse(date_s);

            SQL = "SELECT M.PA51002,M.PA51004,M.PA51019,M.PA51025, M.PA51020";
            SQL += " FROM WPA51 M INNER JOIN WPA15 M1 ON M.PA51017 = M1.PA15002";
            SQL += " WHERE M.PA51001 = '001' AND M.PA51019 = '0' AND M.PA51025 IS NULL";
            SQL += " AND M.PA51014 IN ('005', '006', '008', '010', '011', '012', '013', '014', '015', '016', '025', '028', '029', '030', '031', '032', '033', '034', '035', '036', '037', '041', '042', '043', '049', '054')";
            SQL += " AND M1.PA15001 = '001' AND M1.PA15002 IN ('005', '006', '007', '008', '009')";
            SQL += " order by M.PA51002";

            xdt_cw = WZDBSQLHELP.ExecuteQuery(SQL);

            //找國定假日----------------------------------------------------------------------------------------------------------------------------
            string xPA51020 = "";
            string xSQL = "";
            DateTime xDate_s = DateTime.Parse(date_s + " 00:00:00.000");
            DateTime xDate_e = DateTime.Parse(date_e + " 23:59:59.997");

            DataTable xWPA18 = new DataTable();
            //            xSQL = "select count(*) from WPA18 where 1=1 and PA18002 BETWEEN '" + xDate_s.ToString() + "' AND '" + xDate_e.ToString() + "'";
            xSQL = "SELECT PA18002  FROM WPA18";
            xSQL += " WHERE PA18001 = '001' AND PA18002 BETWEEN '" + date_s + " 00:00:00.000' AND  '" + date_e + " 23:59:59.997'";
            xWPA18 = WZDBSQLHELP.ExecuteQuery(xSQL);

            logger.Debug("xDate_s=" + xDate_s.ToString() + ";" + "xDate_e=" + xDate_e.ToString());
            logger.Debug("xdt_cw.Rows.Count = " + xdt_cw.Rows.Count.ToString());
            DataRow[] dr;
            DataRow[] xdr;
            try
            {

                if (xdt_cw.Rows.Count > 0)
                {
                    for (int x = 0; x < xdt_cw.Rows.Count; x++)
                    {
                        xPA51020 = xdt_cw.Rows[x][4].ToString();

                        if (xdt_cw.Rows[x][0].ToString() == "0625")
                        {
                            string sss = "0";
                        }
                        dr = dt_wz.Select("PB29003 = '" + xdt_cw.Rows[x][0].ToString() + "'");
                        logger.Debug("x=" + x + ";dr.Length=" + dr.Length);
                        if (dr.Length == 0)
                        {
                            //2017-03-29 新增 比對是否有打卡,有打才列入-------------------------------------------------------------------------------
                            dr = dt_cw.Select("P01 = '" + xdt_cw.Rows[x][0].ToString() + "'");
                            //------------------------------------------------------------------------------------------------------------------------
                            if (dr.Length > 0)
                            {
                                for (int xx = 0; xx <= int.Parse(ts1.Days.ToString()); xx++)
                                {
                                    xPB29995 += 1;

                                    //沒有國定假日,就判斷是不是六,日上班
                                    if (xWPA18.Rows.Count == 0)
                                    {
                                        switch (int.Parse(DateT_s.DayOfWeek.ToString("d")))
                                        {
                                            case 0:
                                            case 6:
                                                dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "3", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                                break;
                                            default:
                                                dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "1", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                                break;
                                        }
                                    }
                                    else
                                    {
                                        //有國定假日,就判斷是不是上班日 = 國定假日
                                        xdr = xWPA18.Select("PA18002 = '" + xDate_s + "'");
                                        if (xdr.Length > 0)     //國定假日
                                        {
                                            dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "3", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                        }
                                        else
                                        {
                                            dt_wz.Rows.Add("001", DateT_s.ToString(), xdt_cw.Rows[x][0].ToString(), "1", xPA51020, "", xPB29995, "ACC", "ACC", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                                        }
                                    }
                                    //                                }
                                    xDate_s = xDate_s.AddDays(1);
                                    xDate_e = xDate_e.AddDays(1);
                                    DateT_s = DateT_s.AddDays(1);
                                    xdr = null;
                                    //                                xdr = null;
                                }
                            }
                        }
                        logger.Debug("x=" + x + ";dr.Length=END");
                        dr = null;
                        DateT_s = DateTime.Parse(date_s);
                    }
                }
            }
            catch (Exception ex)
            {
                logger.Debug("ex=" + ex.Message);
                HttpContext.Current.Response.End();
                throw;
            }

            logger.Debug("wz");
            var wz = from row in dt_wz.AsEnumerable()
                     select new
                     {
                         time = row.Field<DateTime>("PB29002"),
                         empid = row.Field<string>("PB29003"),
                         kind = row.Field<int>("PB29004"), //排班代碼
                         type = row.Field<string>("PB29005"), //班別
                     };

            ////取文中人員屬於非排班者
            //            SQL = string.Format(@"SELECT PA51002,PA51004,PA51019,PA51025 FROM WPA51 WHERE PA51001 = '001' AND PA51019 = '0' AND PA51025 IS NULL");

            //20170206 修改--------------------------
            //            SQL = string.Format(@"SELECT M.PA51002,M.PA51004,M.PA51019,M.PA51025 FROM WPA51 M INNER JOIN WPA15 M1 ON M.PA51017 = M1.PA15002 WHERE M.PA51001 = '001' AND M.PA51019 = '0' AND M.PA51025 IS NULL AND M1.PA15001 = '001' AND M1.PA15002 not IN ('005', '006', '007', '009')");
            //---------------------------------------

            //20170426 因為加入派遣人員修改,將AND M.PA51019 = '0' 是否屬排班移除
            SQL = string.Format(@"SELECT M.PA51002,M.PA51004,M.PA51019,M.PA51025 FROM WPA51 M INNER JOIN WPA15 M1 ON M.PA51017 = M1.PA15002 WHERE M.PA51001 = '001'  AND M.PA51025 IS NULL AND M1.PA15001 = '001' AND M1.PA15002 not IN ('005', '006', '007', '009')");
            //---------------------------------------
            dt_noschedule = WZDBSQLHELP.ExecuteQuery(SQL);
            var noschedule = from row in dt_noschedule.AsEnumerable()
                             select new
                             {
                                 empid = row.Field<string>("PA51002"),
                                 kind = row.Field<int>("PA51019"), //是否屬排班 0-非排班 1-排班
                             };

            DataTable all_1 = new DataTable(); //正常
            all_1.Columns.Add("EMPID");
            all_1.Columns.Add("EMPNAME");
            all_1.Columns.Add("DEP");
            all_1.Columns.Add("TIME");
            all_1.Columns.Add("TYPE");
            all_1.Columns.Add("CARDNO");
            all_1.Columns.Add("ALLKIND");

            DataTable all_2 = new DataTable(); //加班
            all_2.Columns.Add("EMPID");
            all_2.Columns.Add("EMPNAME");
            all_2.Columns.Add("DEP");
            all_2.Columns.Add("TIME");
            all_2.Columns.Add("TYPE");
            all_2.Columns.Add("CARDNO");
            all_2.Columns.Add("ALLKIND");

            Random rd = new Random();
            string morning_s = "06:30"; //早班上班時間 + 緩衝時間
            string morning_e = "17:00"; //正常早班下班時間
            string night_s = "18:30"; //晚班上班時間 + 緩衝時間
            string night_e = "05:00"; //正常晚班下班時間
            string evening_s = "16:00"; //中班上班時間
            string evening_e = "02:00"; //正常中班下班時間

            string Nevening_s = "15:00"; //新中班上班時間
            string Nevening_e = "00:00"; //新正常中班下班時間

            string xStarTime = "00:00:00.000";
            string xEndTime = "23:59:59.997";

            string morning_buffer = DateTime.Parse(morning_e).AddMinutes(addmin).TimeOfDay.ToString(); //早班下班緩衝時間
            string night_buffer = DateTime.Parse(night_e).AddMinutes(addmin).TimeOfDay.ToString(); //晚班下班緩衝時間
            string evening_buffer = DateTime.Parse(evening_e).AddMinutes(addmin).TimeOfDay.ToString(); //中班下班緩衝時間
            string Nevening_buffer = DateTime.Parse(Nevening_e).AddMinutes(addmin).TimeOfDay.ToString(); //中班下班緩衝時間

            string morning_extra = "19:30"; //早班加班時間開始
            string night_extra = "07:30"; //晚班加班時間開始

            var morning = new List<string> { "001", "004", "014", "016", "027" }; //早班代碼
            var night = new List<string> { "002", "007", "012", "013", "015", "017" }; //晚班代碼
            var evening = new List<string> { "003", "005", "008", "022", "023", "025", "028", "029" }; //中班代碼
            var Nevening = new List<string> { "030" }; //新中班代碼

            DataRow[] xfindrows;
            string xxx;


            //            xtime = row.Field<DateTime>("PB29002"),
            string xempid;      //ID
            int xkind;          //排班代碼
            string xtype;       //班別
            int SS;
            int SS1;
            DateTime SDate;
            DateTime EDate;
            TimeSpan TTotal;
            DateTime OffWorkTime;
            DateTime OnWorkTime;

            DataTable sDT = new DataTable();

            sDT.Columns.Add("卡號");
            sDT.Columns.Add("時間");

            Random ro = new Random();
            int iResult;
            int xPB29004 = 0;
            int xk = 0;
            try
            {
                //dt_wz → 班表    cw → 打卡 xdt_cw
                foreach (var schedule in cw)
                {
                    xk += 1;
                    if (schedule.empid.ToString() == "2960")
                    {
                        int xkj = 0;
                    }
                    //找班表=上班的人  PB29004 = 1
                    //20170412 修正
                    //xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date + "' AND PB29004 = '1'");
                    if (schedule.empid.ToString() != "")
                    {
                        xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date + "'");
                        //班表有找到人
                        if (xfindrows.Length > 0)
                        {
                            SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                            xempid = dt_wz.Rows[SS][2].ToString();
                            xkind = int.Parse(dt_wz.Rows[SS][3].ToString());
                            xtype = dt_wz.Rows[SS][4].ToString();
                            xPB29004 = int.Parse(dt_wz.Rows[SS]["PB29004"].ToString());        //取上班還是放假

                            //早班
                            if (morning.Contains(xtype))
                            {
                                if (xPB29004 == 1)
                                {
                                    //找是否為現場人員(有加班費的人)
                                    xfindrows = dt_noschedule.Select("PA51002 = '" + schedule.empid.ToString() + "'");
                                    if (xfindrows.Length == 0)
                                    {
                                        SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 08:00");
                                        EDate = SDate.AddHours(-4);   //提前4小時來上班
                                                                      //上班時間打
                                        if (schedule.time >= EDate && schedule.time <= SDate)
                                        {
                                            //                                    System.Diagnostics.Debug.Print(schedule.empid + schedule.time);
                                            TTotal = SDate.Subtract(Convert.ToDateTime(schedule.time)); //日期相減
                                                                                                        //如果上班打卡時間在1小時內
                                            if (int.Parse(TTotal.Hours.ToString()) == 0)
                                            {
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "早班", schedule.cardno, "全一");
                                            }
                                            else
                                            {
                                                //上班加班用1小時內亂數去跑時間
                                                iResult = ro.Next(60, radombuffer * 60 * 6);     //上班班亂數以秒做單位

                                                //20170603 提早來亂數是要0800減
                                                //OnWorkTime = SDate.AddSeconds(iResult);
                                                OnWorkTime = SDate.AddSeconds(iResult * (-1));
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OnWorkTime, "早班", schedule.cardno, "全一");
                                                //如果提早1HR以上班則全部在全2
                                                if (int.Parse(TTotal.Hours.ToString()) >= 1)
                                                {
                                                    //20170603 上班開始時間不用切直接帶打卡時間
                                                    //EDate = SDate.AddMinutes((int)TTotal.TotalMinutes * -1);
                                                    EDate = schedule.time;
                                                    //增加開始加班時間與結束時間
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, EDate, "早班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, SDate, "早班", schedule.cardno, "全二");
                                                }
                                            }
                                            //                                    sDT.Rows.Add(schedule.empid, TTotal.Hours);
                                        }
                                        else
                                        {
                                            SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 17:00");
                                            EDate = SDate.AddHours(7);
                                            if (schedule.time >= SDate && schedule.time <= EDate)
                                            {
                                                iResult = ro.Next(60, radombuffer * 60);     //下班亂數以秒做單位
                                                TTotal = schedule.time.Subtract(SDate); //打卡下班時間 - 正常下班時間
                                                SS = (int)TTotal.TotalMinutes;

                                                //下班班時間 如果下班時間大於緩衝分鐘
                                                if (SS > addmin)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    OffWorkTime = OffWorkTime.AddSeconds(iResult);
                                                    SS = SS - addmin;                               //超過緩衝加班時間
                                                }
                                                else
                                                {
                                                    OffWorkTime = schedule.time;
                                                    SS = 0;
                                                }

                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "早班", schedule.cardno, "全一");
                                                //下班結束----------------------------------------------
                                                //下班加班超過法定
                                                if (SS > 0)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "早班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "早班", schedule.cardno, "全二");
                                                }
                                            }
                                            else
                                            {
                                                //除了正常與加班上下班之外的,遲到 早退
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "早班", schedule.cardno, "全一");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //班表上有但是有來加班的人
                                    if (xPB29004 == 3)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                    }
                                }
                            }       //早班結束

                            //晚班
                            if (night.Contains(xtype))
                            {

                                if (schedule.time.Hour < 12)
                                {
                                    xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date.AddDays(-1) + "'");
                                    if (xfindrows.Length > 0)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xempid = dt_wz.Rows[SS][2].ToString();
                                        xkind = int.Parse(dt_wz.Rows[SS][3].ToString());
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        xPB29004 = int.Parse(dt_wz.Rows[SS]["PB29004"].ToString());        //取上班還是放假
                                    }
                                }
                                if (xPB29004 == 1)
                                {
                                    //找是否為現場人員(有加班費的人)
                                    xfindrows = dt_noschedule.Select("PA51002 = '" + schedule.empid.ToString() + "'");
                                    if (xfindrows.Length == 0)
                                    {
                                        SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 20:00");
                                        EDate = SDate.AddHours(-4);   //提前4小時來上班
                                                                      //上班時間打
                                        if (schedule.time >= EDate && schedule.time <= SDate)
                                        {
                                            //                                    System.Diagnostics.Debug.Print(schedule.empid + schedule.time);
                                            TTotal = SDate.Subtract(Convert.ToDateTime(schedule.time)); //日期相減
                                                                                                        //如果上班打卡時間在1小時內
                                            if (int.Parse(TTotal.Hours.ToString()) == 0)
                                            {
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "晚班", schedule.cardno, "全一");
                                            }
                                            else
                                            {
                                                //上班加班用1小時內亂數去跑時間
                                                iResult = ro.Next(60, radombuffer * 60 * 6);     //上班班亂數以秒做單位
                                                //20170603 提早來亂數是要1200減
                                                //OnWorkTime = SDate.AddSeconds(iResult);
                                                OnWorkTime = SDate.AddSeconds(iResult * (-1));
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OnWorkTime, "晚班", schedule.cardno, "全一");
                                                //如果提早1HR以上班則全部在全2
                                                if (int.Parse(TTotal.Hours.ToString()) >= 1)
                                                {
                                                    //20170603 上班開始時間不用切直接帶打卡時間
                                                    //EDate = SDate.AddMinutes((int)TTotal.TotalMinutes * -1);
                                                    EDate = schedule.time;
                                                    //增加開始加班時間與結束時間
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, EDate, "晚班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, SDate, "晚班", schedule.cardno, "全二");
                                                }
                                            }
                                            //                                    sDT.Rows.Add(schedule.empid, TTotal.Hours);
                                        }
                                        else
                                        {
                                            SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 05:00");
                                            EDate = SDate.AddHours(7);
                                            if (schedule.time >= SDate && schedule.time <= EDate)
                                            {
                                                iResult = ro.Next(60, radombuffer * 60);     //下班亂數以秒做單位
                                                TTotal = schedule.time.Subtract(SDate); //打卡下班時間 - 正常下班時間
                                                SS = (int)TTotal.TotalMinutes;

                                                //下班班時間 如果下班時間大於緩衝分鐘
                                                if (SS > addmin)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    OffWorkTime = OffWorkTime.AddSeconds(iResult);
                                                    SS = SS - addmin;                               //超過緩衝加班時間
                                                }
                                                else
                                                {
                                                    OffWorkTime = schedule.time;
                                                    SS = 0;
                                                }

                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "晚班", schedule.cardno, "全一");
                                                //下班結束----------------------------------------------
                                                //下班加班超過法定
                                                if (SS > 0)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "晚班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "晚班", schedule.cardno, "全二");
                                                }
                                            }
                                            else
                                            {
                                                //除了正常與加班上下班之外的,遲到 早退
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "晚班", schedule.cardno, "全一");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //班表上有但是有來加班的人
                                    if (xPB29004 == 3)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                    }
                                }
                            }       //晚班結束

                            //中班
                            if (evening.Contains(xtype))
                            {
                                if (schedule.time.Hour < 12)
                                {
                                    xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date.AddDays(-1) + "'");
                                    if (xfindrows.Length > 0)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xempid = dt_wz.Rows[SS][2].ToString();
                                        xkind = int.Parse(dt_wz.Rows[SS][3].ToString());
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        xPB29004 = int.Parse(dt_wz.Rows[SS]["PB29004"].ToString());        //取上班還是放假
                                    }
                                }
                                if (xPB29004 == 1)
                                {
                                    //找是否為現場人員(有加班費的人)
                                    xfindrows = dt_noschedule.Select("PA51002 = '" + schedule.empid.ToString() + "'");
                                    if (xfindrows.Length == 0)
                                    {
                                        SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 17:00");
                                        EDate = SDate.AddHours(-4);   //提前4小時來上班
                                                                      //上班時間打
                                        if (schedule.time >= EDate && schedule.time <= SDate)
                                        {
                                            //                                    System.Diagnostics.Debug.Print(schedule.empid + schedule.time);
                                            TTotal = SDate.Subtract(Convert.ToDateTime(schedule.time)); //日期相減
                                                                                                        //如果上班打卡時間在1小時內
                                            if (int.Parse(TTotal.Hours.ToString()) == 0)
                                            {
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "中班", schedule.cardno, "全一");
                                            }
                                            else
                                            {
                                                //上班加班用1小時內亂數去跑時間
                                                iResult = ro.Next(60, radombuffer * 60 * 6);     //上班班亂數以秒做單位

                                                //20170603 提早來亂數是要減
                                                //OnWorkTime = SDate.AddSeconds(iResult);
                                                OnWorkTime = SDate.AddSeconds(iResult * (-1));
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OnWorkTime, "中班", schedule.cardno, "全一");
                                                //如果提早1HR以上班則全部在全2
                                                if (int.Parse(TTotal.Hours.ToString()) >= 1)
                                                {
                                                    //20170603 上班開始時間不用切直接帶打卡時間
                                                    //EDate = SDate.AddMinutes((int)TTotal.TotalMinutes * -1);
                                                    EDate = schedule.time;
                                                    //增加開始加班時間與結束時間
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, EDate, "中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, SDate, "中班", schedule.cardno, "全二");
                                                }
                                            }
                                            //                                    sDT.Rows.Add(schedule.empid, TTotal.Hours);
                                        }
                                        else
                                        {
                                            SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 02:00");
                                            EDate = SDate.AddHours(7);
                                            if (schedule.time >= SDate && schedule.time <= EDate)
                                            {
                                                iResult = ro.Next(60, radombuffer * 60);     //下班亂數以秒做單位
                                                TTotal = schedule.time.Subtract(SDate); //打卡下班時間 - 正常下班時間
                                                SS = (int)TTotal.TotalMinutes;

                                                //下班班時間 如果下班時間大於緩衝分鐘
                                                if (SS > addmin)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    OffWorkTime = OffWorkTime.AddSeconds(iResult);
                                                    SS = SS - addmin;                               //超過緩衝加班時間
                                                }
                                                else
                                                {
                                                    OffWorkTime = schedule.time;
                                                    SS = 0;
                                                }

                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "中班", schedule.cardno, "全一");
                                                //下班結束----------------------------------------------
                                                //下班加班超過法定
                                                if (SS > 0)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "中班", schedule.cardno, "全二");
                                                }
                                            }
                                            else
                                            {
                                                //除了正常與加班上下班之外的,遲到 早退
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "中班", schedule.cardno, "全一");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //班表上有但是有來加班的人
                                    if (xPB29004 == 3)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                    }
                                }
                            }       //中班結束

                            //新中班
                            if (Nevening.Contains(xtype))
                            {
                                if (schedule.time.Hour < 12)
                                {
                                    xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date.AddDays(-1) + "'");
                                    if (xfindrows.Length > 0)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xempid = dt_wz.Rows[SS][2].ToString();
                                        xkind = int.Parse(dt_wz.Rows[SS][3].ToString());
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        xPB29004 = int.Parse(dt_wz.Rows[SS]["PB29004"].ToString());        //取上班還是放假
                                    }
                                }
                                if (xPB29004 == 1)
                                {
                                    //找是否為現場人員(有加班費的人)
                                    xfindrows = dt_noschedule.Select("PA51002 = '" + schedule.empid.ToString() + "'");
                                    if (xfindrows.Length == 0)
                                    {
                                        SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 15:00");
                                        EDate = SDate.AddHours(-4);   //提前4小時來上班
                                                                      //上班時間打
                                        if (schedule.time >= EDate && schedule.time <= SDate)
                                        {
                                            //                                    System.Diagnostics.Debug.Print(schedule.empid + schedule.time);
                                            TTotal = SDate.Subtract(Convert.ToDateTime(schedule.time)); //日期相減
                                                                                                        //如果上班打卡時間在1小時內
                                            if (int.Parse(TTotal.Hours.ToString()) == 0)
                                            {
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全一");
                                            }
                                            else
                                            {
                                                //上班加班用1小時內亂數去跑時間
                                                iResult = ro.Next(60, radombuffer * 60 * 6);     //上班班亂數以秒做單位
                                                //20170603 提早來亂數是要減
                                                //OnWorkTime = SDate.AddSeconds(iResult);
                                                OnWorkTime = SDate.AddSeconds(iResult * (-1));
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OnWorkTime, "新中班", schedule.cardno, "全一");
                                                //如果提早1HR以上班則全部在全2
                                                if (int.Parse(TTotal.Hours.ToString()) >= 1)
                                                {
                                                    //20170603 上班開始時間不用切直接帶打卡時間
                                                    //EDate = SDate.AddMinutes((int)TTotal.TotalMinutes * -1);
                                                    EDate = schedule.time;
                                                    //增加開始加班時間與結束時間
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, EDate, "新中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, SDate, "新中班", schedule.cardno, "全二");
                                                }
                                            }
                                            //                                    sDT.Rows.Add(schedule.empid, TTotal.Hours);
                                        }
                                        else
                                        {
                                            SDate = Convert.ToDateTime(schedule.time.ToString().Substring(0, schedule.time.ToString().IndexOf(" ")) + " 23:59");
                                            EDate = SDate.AddHours(7);
                                            if (schedule.time >= SDate && schedule.time <= EDate)
                                            {
                                                iResult = ro.Next(60, radombuffer * 60);     //下班亂數以秒做單位
                                                TTotal = schedule.time.Subtract(SDate); //打卡下班時間 - 正常下班時間
                                                SS = (int)TTotal.TotalMinutes;

                                                //下班班時間 如果下班時間大於緩衝分鐘
                                                if (SS > addmin)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    OffWorkTime = OffWorkTime.AddSeconds(iResult);
                                                    SS = SS - addmin;                               //超過緩衝加班時間
                                                }
                                                else
                                                {
                                                    OffWorkTime = schedule.time;
                                                    SS = 0;
                                                }

                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "新中班", schedule.cardno, "全一");
                                                //下班結束----------------------------------------------
                                                //下班加班超過法定
                                                if (SS > 0)
                                                {
                                                    OffWorkTime = SDate.AddMinutes(addmin);
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, OffWorkTime, "新中班", schedule.cardno, "全二");
                                                    add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                                }
                                            }
                                            else
                                            {
                                                //除了正常與加班上下班之外的,遲到 早退
                                                add_all(all_1, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全一");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //班表上有但是有來加班的人
                                    if (xPB29004 == 3)
                                    {
                                        SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                        xtype = dt_wz.Rows[SS][4].ToString();
                                        add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                                    }
                                }
                            }       //新中班結束
                        }
                        else
                        {
                            //班表上有但是有來加班的人
                            xfindrows = dt_wz.Select("PB29003 = '" + schedule.empid.ToString() + "' AND PB29002 = '" + schedule.time.Date + "' AND PB29004 = '3'");
                            if (xfindrows.Length > 0)
                            {
                                SS = dt_wz.Rows.IndexOf(xfindrows[0]);
                                xtype = dt_wz.Rows[SS][4].ToString();
                                add_all(all_2, schedule.empid, schedule.empname, schedule.empdep, schedule.time, "新中班", schedule.cardno, "全二");
                            }
                        }
                    }
                    else
                    {
                        logger.Debug("找不到資料 " + schedule.empname.ToString() + ";" + schedule.time.ToString());
                    }
                }

                logger.Debug("無排班");
                //無排班→ 全一
                //在不是排班者中取得對應打卡資料
                foreach (var row in noschedule)
                {
                    var filter = cw.Where(w => w.empid == row.empid);
                    foreach (var data in filter)
                    {
                        add_all(all_1, data.empid, data.empname, data.empdep, data.time, "非排班", data.cardno, "全一");
                    }
                }
                logger.Debug("OK");
            }
            catch (Exception ex)
            {
                logger.Debug(ex.Message);
                HttpContext.Current.Response.End();
                throw;
            }

            try
            {
                ////匯出TXT
                string fName1 = "";
                string fName2 = "";

                string filename_1 = "全1__" + DateTime.Parse(date_s).ToString("yyyyMMdd") + "-" + DateTime.Parse(date_e).ToString("yyyyMMdd") + DateTime.Now.ToString("hhmmssff") + ".txt";
                string filename_2 = "全2__" + DateTime.Parse(date_s).ToString("yyyyMMdd") + "-" + DateTime.Parse(date_e).ToString("yyyyMMdd") + DateTime.Now.ToString("hhmmssff") + ".txt";

                string savepath = context.Server.MapPath("~\\");
                FileStream fileStream = new FileStream(@savepath + "DLtmp\\" + filename_1, FileMode.Create);
                fileStream.Close();           //切記開了要關,不然會被佔用而無法修改喔!!!
                string output;
                using (StreamWriter sw = new StreamWriter(@savepath + "DLtmp\\" + filename_1))
                {
                    for (int i = 0; i < all_1.Rows.Count; i++)
                    {
                        // 欲寫入的文字資料 ~
                        output = all_1.Rows[i]["CARDNO"].ToString() + " " + DateTime.Parse(all_1.Rows[i]["TIME"].ToString()).ToString("yyyyMMddHHmmss") + " 1 1 001";
                        sw.WriteLine(output);
                    }
                }
                fName1 = "/DLtmp/" + filename_1;

                if (all_2.Rows.Count > 0)
                {
                    fileStream = new FileStream(@savepath + "DLtmp\\" + filename_2, FileMode.Create);
                    fileStream.Close();           //切記開了要關,不然會被佔用而無法修改喔!!!
                    output = "";
                    using (StreamWriter sw = new StreamWriter(@savepath + "DLtmp\\" + filename_2))
                    {
                        for (int i = 0; i < all_2.Rows.Count; i++)
                        {
                            // 欲寫入的文字資料 ~
                            output = all_2.Rows[i]["CARDNO"].ToString() + " " + DateTime.Parse(all_2.Rows[i]["TIME"].ToString()).ToString("yyyyMMddHHmmss") + " 1 1 001";
                            sw.WriteLine(output);
                        }
                    }
                    fName2 = "/DLtmp/" + filename_2;
                }

                var obj = new { success = "0", fName1 = fName1, fName2 = fName2 };
                string result = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
                context.Response.Write(result);
            }
            catch (Exception ex)
            {
                var obj = new { success = "1", exprot = ex.Message };
                string result = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
                context.Response.Write(result);
            }

        }

        public void Sace(HttpContext context)
        {
            try
            {
                //                System.IO.Directory.CreateDirectory(@"d:\web\123\web");
                //            System.IO.File.CreateText(@"d:\web\123\abc.txt");

                string savepath = context.Server.MapPath("~\\");
                FileStream fileStream = new FileStream(@savepath + "DLtmp\\test1.txt", FileMode.Create);
                fileStream.Close();   //切記開了要關,不然會被佔用而無法修改喔!!!

                using (StreamWriter sw = new StreamWriter(@savepath + "DLtmp\\test1.txt"))
                {
                    // 欲寫入的文字資料 ~

                    sw.Write("This is  ");
                    sw.WriteLine("Shinyo Test lallalallaaaa.");
                    sw.WriteLine("-------o   ---  V ---- o  -----");
                    sw.Write("Time is : ");
                    sw.WriteLine(DateTime.Now);
                }

                var obj = new { success = "/test1.txt" };
                string result = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
                context.Response.Write(result);
            }
            catch (Exception ex)
            {
                var obj = new { success = ex.Message };
                string result = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
                context.Response.Write(result);
            }
        }

        public void add_all(DataTable dt, string empid, string empname, string empdep, DateTime time, string type, string cardno, string allkind)
        {
            DataRow row = dt.NewRow();
            row["EMPID"] = empid;
            row["EMPNAME"] = empname;
            row["DEP"] = empdep;
            row["TIME"] = time;
            row["TYPE"] = type;
            row["CARDNO"] = cardno;
            row["ALLKIND"] = allkind;
            dt.Rows.Add(row);
        }

        public bool dateBetween(string compare, string start, string end)
        {
            return DateTime.Parse(compare) >= DateTime.Parse(start) && DateTime.Parse(compare) <= DateTime.Parse(end);
        }

        public string sqlwhere(string search, string start, string end, string TableName)
        {
            string where = "";
            if (search != "")
            {
                where += "AND (l15 LIKE '%{0}%' OR l07 LIKE '%{0}%' OR l06 LIKE '%{0}%' OR l02 LIKE '%{0}%' OR l10 LIKE '%{0}%')".Replace("{0}", search);
            }
            if (start != "" && end != "")
            {

                where += " AND " + TableName + " >= DATEADD(day, DATEDIFF(day, '', '" + start + "'), '')";
                where += " AND " + TableName + " < DATEADD(day, DATEDIFF(day, '', '" + end + "') + 1, '')";
            }

            return where;
        }

        private string xSendClasss(string UserID)
        {
            string SQL = "";
            DataTable dt = new DataTable();
            SQL = "SELECT M.STN_WORK, M.deptctl, M.ProgNo, M.LPAAK200 , M1.id, M1.hrs";
            SQL += " FROM XSingOrd M INNER JOIN Winton_mf2000 M1 ON M.STN_WORK = M1.mf200";
            SQL += " WHERE M.ProgramName = 'AllecDoor' AND M.LPAAK200 = '" + UserID + "'";
            dt= DBSQLHELP_TEST.ExecuteQuery(SQL, "tbiConnectionString");
            string xdeptctl = "";
            if (dt.Rows.Count>0)
            {
                for (int i=0;i< dt.Rows.Count;i++)
                {
                    xdeptctl += dt.Rows[i]["hrs"].ToString() + ",";
                }
                xdeptctl = xdeptctl.Substring(0, xdeptctl.Length - 1);
            }
            return xdeptctl;
        }
        public string GetJsonClient(string name, HttpContext context)
        {
            if (context.Request[name] == null) { return ""; }
            string temp = context.Request[name];
            return temp;
        }

        public class student_Item
        {
            public string PA11002 { set; get; }//姓名
            public string PA11003 { set; get; }//身高
        }

        [System.Web.Services.WebMethod]
        private void TestDownloadFile(HttpContext context)
        {
            string filename_1 = "1234.txt";
            StringBuilder sb1 = new StringBuilder();
            for (int i = 0; i < 1000; i++)
            {
                string output = "第" + i + "行";
                sb1.Append(output);
                sb1.Append("\r\n");
            }
            HttpContext.Current.Response.Clear();
            HttpContext.Current.Response.ClearHeaders();
            HttpContext.Current.Response.AddHeader("Content-Length", sb1.ToString().Length.ToString());
            HttpContext.Current.Response.ContentType = "text/plain";
            HttpContext.Current.Response.AppendHeader("Content-Disposition", "attachment;filename=" + filename_1);
            HttpContext.Current.Response.Write(sb1.ToString());
            HttpContext.Current.Response.End();

            var obj = new { result = "0", msg = "output.txt" };
            string result = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
            context.Response.Write(result);

        }
    }
}