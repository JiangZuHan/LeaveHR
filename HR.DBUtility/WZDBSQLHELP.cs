using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace WorkCheck.Tools
{
    public class WZDBSQLHELP
    {
        //private static SqlCommand cmd = null;
        //private static SqlDataReader sdr = null;

        public static SqlConnection connection()
        {
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString);
            return con;
        }

        private static SqlConnection GetConn()
        {
            SqlConnection conn = connection();

            if (conn.State == ConnectionState.Closed)
            {
                conn.Open();
            }
            return conn;
        }

        private static void OutConn()
        {

            using (SqlConnection conn = connection())
            {
                if (conn.State == ConnectionState.Open)
                {
                    conn.Close();
                }
            }
        }

        public static DataTable ExecuteQuery(string cmdText)
        {
            SqlCommand cmd = new SqlCommand();

            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, GetConn());
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

        public static int ExecuteNonQuery(string cmdText)
        {
            SqlCommand cmd = new SqlCommand();
            int res;
            try
            {
                cmd = new SqlCommand(cmdText, GetConn());
                res = cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                OutConn();
            }
            return res;
        }

        public static int ExecuteNonQuery(string cmdText, CommandType ct)
        {
            SqlCommand cmd = new SqlCommand();
            int res;
            try
            {
                cmd = new SqlCommand(cmdText, GetConn());
                cmd.CommandType = ct;
                res = cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cmd.Dispose();
                OutConn();
            }
            return res;
        }
    }
}