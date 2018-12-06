using HR.DBUtility;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI;

namespace HR.WebModel
{
    public class WebPublic : Page
    {
        //傳入MF2000 部門編碼
        public static List<string> xLevel(string STNWORK)
        {
            string SQL = "";
            SQL = "WITH Parts";
            SQL += " AS";
            SQL += " (";
            SQL += " SELECT STN_WORK, LPAAK200, LUSERID, '' AS hrs, 0 AS ComponentLevel";
            SQL += " FROM XSingOrd";
            SQL += " WHERE STN_WORK = '" + STNWORK + "' AND LPAAK200 <> ''";
            SQL += " UNION ALL";
            SQL += " SELECT bom.STN_WORK, bom.LPAAK200, bom.LUSERID, P.hrs, ComponentLevel + 1";
            SQL += " FROM XSingOrd AS bom INNER JOIN Parts AS p ON bom.STN_WORK = p.LPAAK200";
            SQL += " where bom.ProgramName = 'AllecDoor'";
            SQL += " )";
            SQL += " SELECT * FROM Parts";

            DataTable dt = new DataTable();
            dt = DBSQLHELP_TEST.ExecuteQuery(SQL, "tbiConnectionString");
            List<string> list = new List<string>();
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                list.Add(dt.Rows[i][1].ToString());
            }
            return list;
        }

        //傳入HR 部門編碼
        public static List<string> hrLevel(string hrs)
        {
            string SQL = "";
            SQL = "WITH Parts";
            SQL += " AS";
            SQL += " (";
            SQL += " SELECT STN_WORK, LPAAK200, LUSERID, '' AS hrs, 0 AS ComponentLevel, mf.hrs";
            SQL += " FROM XSingOrd AS P INNER JOIN Winton_mf2000 AS mf ON P.STN_WORK = mf.mf200";
            SQL += " WHERE mf.hrs = '" + hrs + "' AND LPAAK200 <> ''";
            SQL += " UNION ALL";
            SQL += " SELECT bom.STN_WORK, bom.LPAAK200, bom.LUSERID, P.hrs, ComponentLevel + 1, mf.hrs";
            SQL += " FROM XSingOrd AS bom INNER JOIN Parts AS p ON bom.STN_WORK = p.LPAAK200";
            SQL += " INNER JOIN Winton_mf2000 AS mf ON bom.STN_WORK = mf.mf200";
            SQL += " where bom.ProgramName = 'AllecDoor'";
            SQL += " )";
            SQL += " SELECT P.STN_WORK, P.LPAAK200, P.LUSERID, P.ComponentLevel, mf.hrs, mf.CONTEN";
            SQL += " FROM Parts AS P INNER JOIN Winton_mf2000 AS mf ON P.LPAAK200 = mf.mf200";

            DataTable dt = new DataTable();
            dt = DBSQLHELP_TEST.ExecuteQuery(SQL, "tbiConnectionString");
            List<string> list = new List<string>();

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                list.Add(dt.Rows[i]["hrs"].ToString() + ";"+ dt.Rows[i]["CONTEN"].ToString());
            }
            return list;
        }

        public static string GetJsonClient(string name, HttpContext context)
        {
            if (context.Request[name] == null) { return ""; }
            string temp = context.Request[name];
            return temp;
        }
    }
}
