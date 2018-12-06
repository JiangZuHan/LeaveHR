using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;


namespace HR.DBUtility
{
    public class BOSSQL
    {
        public static SqlConnection connection()
        {
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["tbiConnectionString"].ConnectionString);
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
        public static SqlConnection hrsconnection()
        {
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["hrsConnectionString"].ConnectionString);
            return con;
        }

        private static SqlConnection hrsGetConn()
        {
            SqlConnection conn = hrsconnection();

            if (conn.State == ConnectionState.Closed)
            {
                conn.Open();
            }
            return conn;
        }
        private static void hrsOutConn()
        {

            using (SqlConnection conn = hrsconnection())
            {
                if (conn.State == ConnectionState.Open)
                {
                    conn.Close();
                }
            }

        }

        public static DataTable hrsExecuteQuery(string cmdText)
        {
            SqlCommand cmd = new SqlCommand();

            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, hrsGetConn());
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
                    hrsOutConn();
                }
            }

            return dt;
        }
        public static SqlConnection TBIHRSconnection()
        {
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["tbiHRSConnectionString"].ConnectionString);
            return con;
        }

        private static SqlConnection TBIHRSGetConn()
        {
            SqlConnection conn = TBIHRSconnection();

            if (conn.State == ConnectionState.Closed)
            {
                conn.Open();
            }
            return conn;
        }
        private static void TBIHRSOutConn()
        {

            using (SqlConnection conn = TBIHRSconnection())
            {
                if (conn.State == ConnectionState.Open)
                {
                    conn.Close();
                }
            }

        }

        public static DataTable TBIHRSExecuteQuery(string cmdText)
        {
            SqlCommand cmd = new SqlCommand();

            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, TBIHRSGetConn());
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
                    TBIHRSOutConn();
                }
            }

            return dt;
        }
        public static DataTable hrsExecuteNonQuery(string cmdText)
        {
            SqlCommand cmd = new SqlCommand();

            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, hrsGetConn());
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
        public static DataTable TBIHRSExecuteNonQuery(string cmdText)
        {
            SqlCommand cmd = new SqlCommand();

            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, TBIHRSGetConn());
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
        /// <summary>
        /// KEN_增加字數判斷不可以超過40位元_20180125
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        public static bool CheckWordMax(string input)
        {
            Regex regChina = new Regex("^[^\x00-\xFF]");
            Regex regEnglish = new Regex("^[a-zA-Z]");

            int Word_qty = 0;

            foreach (char s in input)
            {
                if (regChina.IsMatch(Convert.ToString(s)))
                {
                    Word_qty += 2;
                }
                else if (regEnglish.IsMatch(Convert.ToString(s)))
                {
                    Word_qty += 1;
                }
                else
                {
                    Word_qty += 1;
                }
            }

            return (Word_qty > 40);

        }
        public static DataTable hrsExecuteNonQuery2(string cmdText, SqlParameter[] sql_arr)
        {
            SqlCommand cmd = new SqlCommand();

            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, hrsGetConn());
            foreach (SqlParameter i in sql_arr)
            {
                cmd.Parameters.Add(i);
            }

            string tmp = cmd.CommandText.ToString();
            foreach (SqlParameter p in cmd.Parameters)
            {
                //tmp = tmp.Replace('@' + p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
                tmp = tmp.Replace(p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
            }
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
        public static DataTable ExecuteQuery2(string cmdText, SqlParameter[] sql_Para_arr)
        {
            SqlCommand cmd = new SqlCommand();

            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, GetConn());
            foreach (SqlParameter i in sql_Para_arr)
            {
                cmd.Parameters.Add(i);
            }

            string tmp = cmd.CommandText.ToString();
            foreach (SqlParameter p in cmd.Parameters)
            {
                //tmp = tmp.Replace('@' + p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
                tmp = tmp.Replace(p.ParameterName.ToString(), "'" + p.Value.ToString() + "'");
            }



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
