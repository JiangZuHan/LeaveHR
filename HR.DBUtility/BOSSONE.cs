using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HR.DBUtility
{
    public class BOSSONE
    {


        public static DataTable GetValue(Identity identity)
        {
            //DataTable dt2 = new DataTable();
            //string sql, sql2;

            //sql2 = " select ProgNo, LUSERID, SUSERID, DUSERID, MUSERID ";
            //sql2 += "from [tbi].[dbo].[Users], [tbi].[dbo].[XSingOrd], [tbi].[dbo].[WPAAK], [tbi].[dbo].[Winton_mf2000] ";
            //sql2 += "where PAAK200 <= '38' and PAAK002 = q1 and a1 = hrs and mf200 = STN_WORK ";
            //sql2 += "order by STN_WORK ";
            //dt2 = BOSSQL.ExecuteQuery(sql2);

            DataTable dt = new DataTable();
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





            foreach (DataRow dr in dt.Rows.Cast<DataRow>().ToList())
            {
                string username = dr["PA60002"]?.ToString() ?? "";

                username = username.PadLeft(5, '0');

                //行政
                if (identity == Identity.Administrator)
                {
                    //刪除現場人員
                    if (Common.JudgeIsSpot(username)==Identity.Spot)
                        dt.Rows.Remove(dr);
                }
                //現場
                else
                {
                    //刪除行政人員
                    if (Common.JudgeIsSpot(username) == Identity.Administrator)
                        dt.Rows.Remove(dr);
                }

            }


            return dt;
        }
    }
}
