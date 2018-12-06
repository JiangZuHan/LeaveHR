using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HR.DBUtility.Models
{
    public class LeaveApplicationForm
    {

        /// <summary>
        /// 企業編號
        /// </summary>
        public string pa60001 { get; set; }
        public string username { get; set; }
        public string CNname { get; set; }
        public string water { get; set; }
        public string holiday_type_code { get; set; }
        public string holiday_type_name { get; set; }
        public string start_ { get; set; }
        public string end_ { get; set; }
        public int Total_min { get; set; }
        /// <summary>
        /// 事由
        /// </summary>
        public string Cause { get; set; }
        /// <summary>
        /// 代理人
        /// </summary>
        public string agent { get; set; }
        /// <summary>
        /// 審核狀態
        /// </summary>
        public int status { get; set; }

        /// <summary>
        /// 組長審核狀態
        /// </summary>
        public int? status_luser { get; set; }
        /// <summary>
        /// 簽核歸屬代碼
        /// </summary>
        public string lProgNo;
        /// <summary>
        /// 喪假類型
        /// </summary>
        public string HRS08_TYPE { get; set; }
        /// <summary>
        /// 喪假對應ID
        /// </summary>
        public string HRS08_ID { get; set; }


    }
}
