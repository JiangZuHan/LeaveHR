using System;
using System.Collections;
using System.Collections.Specialized;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;

namespace HR.DBUtility
{
    /// <summary>
    /// Copyright (C) 2010 it134.cn
    /// ���ݷ��ʻ�����(����OleDb)
    /// �����û������޸������Լ���Ŀ����Ҫ��
    /// </summary>
    public abstract class DBSQLHELP_TEST
    {
        private static SqlConnection conn = null;
        private static SqlCommand cmd = null;
        private static SqlDataReader sdr = null;
//        public static string connectionString = Shannon.Common.Param.ConnectionStrss;
//        public static string connectionString = Shannon.Common.Param.ConnectionStr;		

        public DBSQLHELP_TEST()
        {
        }

        #region ���Τ�k

        public static SqlConnection connection(string xconn)
        {
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings[xconn].ConnectionString);
            return con;
        }


         private static SqlConnection GetConn(string xconn)
         {
             conn = connection(xconn);

             if (conn.State == ConnectionState.Closed)
             {
                 conn.Open();
             }
             return conn;
         }

        //???�u??��
         private static void OutConn(string xconn)
        {

            using (SqlConnection conn = connection(xconn))
            {
                if (conn.State == ConnectionState.Open)
                {
                    conn.Close();
                }
            }
        }
        public static int ExecuteNonQuery(string cmdText, string xconn)
        {
            int res;
            try
            {
                cmd = new SqlCommand(cmdText, GetConn(xconn));
                res = cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cmd.Dispose();
                OutConn(xconn);
            }
            return res;
        }

        public static int ExecuteSqlTran(string cmdText, string xconn)
        {
            int res;
            cmd = new SqlCommand(cmdText, GetConn(xconn));
            SqlTransaction tran = conn.BeginTransaction();
            try
            {                
                cmd.Transaction = tran;                
                res = cmd.ExecuteNonQuery();

                if (res == 0)
                {
                    tran.Rollback();    //�������
                }
                else
                {
                    tran.Commit();      //������
                }
            }
            catch (Exception ex)
            {
                tran.Rollback();
                res = 0;
//                throw ex;
            }
            finally
            {
                cmd.Dispose();
                OutConn(xconn);
            }
            return res;
        }

        ///  ?�椣???���W?��SQL?�y�Φs??�{
        public static int ExecuteNonQuery(string cmdText, CommandType ct, string xconn)
        {
            int res;
            try
            {
                cmd = new SqlCommand(cmdText, GetConn(xconn));
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
                OutConn(xconn);
            }
            return res;
        }

        ///  ?��???���W?��SQL?�y�Φs??�{
        public static int ExecuteNonQuery(string cmdText, SqlParameter[] paras, CommandType ct, string xconn)
        {
            int res;
            try
            {
                cmd = new SqlCommand(cmdText, GetConn(xconn));
                cmd.CommandType = ct;
                cmd.Parameters.AddRange(paras);
                res = cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cmd.Dispose();
                OutConn(xconn);
            }
            return res;
        }

        public static int ExecuteQuery(string xconn)
        {
            int res;
            try
            {
                res = cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cmd.Dispose();
                OutConn(xconn);
            }
            return res;
        }

        public static DataTable ExecuteQuery(string cmdText, string xconn)
        {
            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, GetConn(xconn));
            using (sdr = cmd.ExecuteReader(CommandBehavior.CloseConnection))
            {
                try
                {
                    dt.Load(sdr);
                }
                finally
                {
                    sdr.Close();
                    cmd.Dispose();
                    OutConn(xconn);
                }
            }
            return dt;
        }

        ///  ?��???���d?SQL?�y�Φs??�{
        public static DataTable ExecuteQuery(string cmdText, SqlParameter[] paras, CommandType ct, string xconn)
        {
            DataTable dt = new DataTable();
            cmd = new SqlCommand(cmdText, GetConn(xconn));
            cmd.CommandType = ct;
            cmd.Parameters.AddRange(paras);
            using (sdr = cmd.ExecuteReader(CommandBehavior.CloseConnection))
            {
                try
                {
                    dt.Load(sdr);
                }
                finally
                {
                    sdr.Close();
                    cmd.Dispose();
                    OutConn(xconn);
                }
            }
            return dt;
        }

        public static DataSet ReadWritQuery(string cmdText, string xconn)
        {
            try
            {
                SqlDataAdapter da = new SqlDataAdapter(cmdText, GetConn(xconn));
                DataSet ds = new DataSet();
                da.Fill(ds);
                da.Dispose();
                return ds;
            }
            finally
            {
                sdr.Close();
                cmd.Dispose();
                OutConn(xconn);
            }
        }

        #endregion
    }
}