using System;
using System.Collections.Generic;
using System.Linq;
using System.Configuration;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;

namespace HR.DBUtility
{
    public class DBSQLHELP_TBI_HRS
    {
        //private static SqlCommand cmd = null;
        //private static SqlDataReader sdr = null;
        public static SqlConnection connection_TBI_HRS()
        {
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString);
            return con;
        }


        private static SqlConnection GetConn_TBI_HRS()
        {
            SqlConnection conn = connection_TBI_HRS();

            if (conn.State == ConnectionState.Closed)
            {
                conn.Open();
            }
            return conn;
        }

        private static void OutConn()
        {

            using (SqlConnection conn = connection_TBI_HRS())
            {
                if (conn.State == ConnectionState.Open)
                {
                    conn.Close();
                }
            }
        }
        public static DataTable ExecuteQuery_TBI_HRS(string cmdText)
        {
            SqlCommand cmd = new SqlCommand();

            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, GetConn_TBI_HRS());
            using (SqlDataReader sdr = cmd.ExecuteReader(CommandBehavior.CloseConnection))
            {
                try
                {
                    dt.Load(sdr);
                }
                catch (Exception ex)
                {

                }
                finally
                {
                    sdr.Close();
                    cmd.Dispose();
                    OutConn();
                }
            }

            return dt;
        }
    }
}
