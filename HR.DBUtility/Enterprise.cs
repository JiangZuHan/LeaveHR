using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HR.DBUtility
{
    public class Enterprise
    {
        /// <summary>
        /// 行政企業別代號
        /// </summary>
        public static string ConStr = ConfigurationManager.AppSettings["conStr"].ToString();
        /// <summary>
        /// 現場企業別代號
        /// </summary>
        public static string ConStr_produceline = ConfigurationManager.AppSettings["Enterprise_number_produceline"].ToString();



        
    }


    /// <summary>
    /// 判斷身份
    /// </summary>
    public enum Identity
    {
        /// <summary>
        /// 現場人員(現場組別裡面的所有人)
        /// </summary>
        Spot,
        /// <summary>
        /// 行政人員(非現場組別裡面的人)
        /// </summary>
        Administrator
    }
}
